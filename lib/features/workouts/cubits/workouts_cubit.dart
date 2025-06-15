import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym/features/workouts/cubits/workouts_state.dart';
import 'package:gym/features/exercises/data/models/exercises.dart';
import 'package:gym/features/workouts/data/models/plan_model.dart';
import 'package:gym/features/workouts/data/models/plan_response.dart';
import 'package:gym/features/workouts/data/models/set_model.dart';
import 'package:gym/features/workouts/data/models/workout_model.dart';
import 'package:gym/features/workouts/data/workouts_repository.dart';

class WorkoutsCubit extends Cubit<WorkoutsState> {
  final WorkoutsRepository _repository;

  WorkoutsCubit({required WorkoutsRepository repository})
      : _repository = repository,
        super(const WorkoutsState());
  void updateExercise(Exercise updatedExercise) {
    final updatedExercises = List<Exercise>.from(state.selectedExercises);
    final index =
        updatedExercises.indexWhere((e) => e.id == updatedExercise.id);
    if (index != -1) {
      updatedExercises[index] = updatedExercise;
      emit(state.copyWith(selectedExercises: updatedExercises));
    }
  }

  void deleteExercise(String exerciseId) {
    final updatedExercises = List<Exercise>.from(state.selectedExercises)
      ..removeWhere((e) => e.id == exerciseId);
    emit(state.copyWith(selectedExercises: updatedExercises));
  }

  deleteWorkoutExercise(String workoutExcId) async {
    final resp = await _repository.deleteWorkoutExercise(workoutExcId);
    resp.fold(
      (l) => emit(state.copyWith(errorMessage: l.message)),
      (r) {
        // Update selectedExercises by removing the deleted exercise
        final updatedExercises = List<Exercise>.from(state.selectedExercises)
          ..removeWhere((e) => e.workoutExerciseID == workoutExcId);

        // Update currentWorkout by removing the deleted workout exercise
        if (state.currentWorkout != null) {
          final updatedWorkoutExercises =
              List<WorkoutExercise>.from(state.currentWorkout!.workoutExercises)
                ..removeWhere((we) => we.id == workoutExcId);

          final updatedWorkout = WorkoutModel(
            id: state.currentWorkout!.id,
            planId: state.currentWorkout!.planId,
            userId: state.currentWorkout!.userId,
            title: state.currentWorkout!.title,
            date: state.currentWorkout!.date,
            workoutExercises: updatedWorkoutExercises,
          );

          // Update the workouts list
          final updatedWorkouts = state.workouts.map((w) {
            if (w.id == updatedWorkout.id) {
              return updatedWorkout;
            }
            return w;
          }).toList();

          emit(state.copyWith(
            selectedExercises: updatedExercises,
            currentWorkout: updatedWorkout,
            workouts: updatedWorkouts,
          ));
        } else {
          emit(state.copyWith(
            selectedExercises: updatedExercises,
          ));
        }
      },
    );
  }

  // Load all plans
  Future<void> loadPlans() async {
    emit(state.copyWith(status: WorkoutsStatus.loadingPlans, clearError: true));

    final result = await _repository.getPlans();

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: WorkoutsStatus.error,
          errorMessage: failure.message,
        ));
      },
      (plansData) {
        emit(state.copyWith(
          status: WorkoutsStatus.success,
          plans: plansData,
        ));
      },
    );
  }

  void updateExercisesOrder(List<Exercise> updatedExercises) {
    emit(state.copyWith(selectedExercises: updatedExercises));
  }

  // Create a new plan
  Future<void> createPlan(String title, {String? notes}) async {
    emit(state.copyWith(status: WorkoutsStatus.creatingPlan, clearError: true));

    final result = await _repository.createPlan(title, notes: notes);

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: WorkoutsStatus.error,
          errorMessage: 'Failed to create plan: ${failure.message}',
        ));
      },
      (response) {
        final List<PlanResponse> plans = state.plans..add(response);
        emit(state.copyWith(
          status: WorkoutsStatus.success,
          plans: plans,
          currentPlan: response,
        ));
      },
    );
  }

  // Delete a plan
  Future<void> deletePlan(String planId) async {
    emit(state.copyWith(status: WorkoutsStatus.deletingPlan, clearError: true));

    final result = await _repository.deletePlan(planId);

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: WorkoutsStatus.error,
          errorMessage: 'Failed to delete plan: ${failure.message}',
        ));
      },
      (_) {
        final updatedPlans = List<PlanResponse>.from(state.plans)
          ..removeWhere((plan) => plan.id == planId);

        emit(state.copyWith(
          status: WorkoutsStatus.success,
          plans: updatedPlans,
          clearCurrentPlan: state.currentPlan?.id == planId,
        ));
      },
    );
  }

  // Set current plan
  void setCurrentPlan(PlanResponse plan) {
    emit(state.copyWith(currentPlan: plan, workouts: []
        // clearCurrentWorkout: true,
        // clearCurrentExercise: true,
        ));
    // Only load workouts if we don't have any for this plan
    // if (plan.workouts.isEmpty) {
    loadWorkoutsForPlan(plan.id);
    // }
  }

  // Helper function to unify exercise data
  Exercise _unifyExerciseData(WorkoutExercise workoutExercise) {
    if (workoutExercise.exerciseId != null &&
        workoutExercise.exercise != null) {
      // Regular exercise
      return Exercise(
        id: workoutExercise.exercise!.id,
        workoutExerciseID: workoutExercise.id,
        name: workoutExercise.exercise!.name,
        description: workoutExercise.exercise!.description,
        videoUrl: workoutExercise.exercise!.videoUrl,
        primaryMuscle: workoutExercise.exercise!.primaryMuscle,
        category: workoutExercise.exercise!.category,
      );
    } else if (workoutExercise.customExerciseId != null &&
        workoutExercise.customExercise != null) {
      // Custom exercise
      return Exercise(
        id: workoutExercise.customExercise!.id,
        workoutExerciseID: workoutExercise.id,
        name: workoutExercise.customExercise!.name,
        description: workoutExercise.customExercise!.description,
        videoUrl: workoutExercise.customExercise!.videoUrl,
        primaryMuscle: workoutExercise.customExercise!.primaryMuscle,
        category: 'Custom', // Custom exercises don't have a category
      );
    } else {
      // Fallback case
      return Exercise(
        id: workoutExercise.id,
        workoutExerciseID: workoutExercise.id,
        name: 'Unknown Exercise',
        description: '',
        videoUrl: '',
        primaryMuscle: '',
        category: '',
      );
    }
  }

  // Load workouts for a plan
  Future<void> loadWorkoutsForPlan(String planId) async {
    emit(state.copyWith(
        status: WorkoutsStatus.loadingWorkouts, clearError: true));

    final result = await _repository.getWorkoutsForPlan(planId);

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: WorkoutsStatus.error,
          errorMessage: 'Failed to load workouts: ${failure.message}',
        ));
      },
      (workoutsData) {
        // Process each workout to unify exercise data
        final processedWorkouts = workoutsData.map((workout) {
          final processedExercises = workout.workoutExercises.map((we) {
            // Create unified exercise
            final unifiedExercise = _unifyExerciseData(we);

            // Create new WorkoutExercise with unified exercise
            return WorkoutExercise(
              id: we.id,
              workoutId: we.workoutId,
              exerciseId: we.exerciseId,
              exercise: unifiedExercise,
              customExerciseId: we.customExerciseId,
              customExercise: we.customExercise,
              sets: we.sets,
            );
          }).toList();

          // Return updated workout with processed exercises
          return WorkoutModel(
            id: workout.id,
            planId: workout.planId,
            userId: workout.userId,
            title: workout.title,
            date: workout.date,
            workoutExercises: processedExercises,
          );
        }).toList();

        emit(state.copyWith(
          status: WorkoutsStatus.success,
          workouts: processedWorkouts,
        ));
      },
    );
  }

  // Create a new workout
  Future<void> createWorkout(String title, {String? notes}) async {
    if (state.currentPlan == null) {
      emit(state.copyWith(
        status: WorkoutsStatus.error,
        errorMessage: 'No plan selected',
      ));
      return;
    }

    emit(state.copyWith(
        status: WorkoutsStatus.creatingWorkout, clearError: true));

    final result = await _repository.createWorkout(
      state.currentPlan!.id,
      title,
      notes: notes, // Pass notes parameter
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: WorkoutsStatus.error,
          errorMessage: 'Failed to create workout: ${failure.message}',
        ));
      },
      (newWorkout) {
        // Add the new workout to the existing list
        final updatedWorkouts = List<WorkoutModel>.from(state.workouts)
          ..add(newWorkout);

        emit(state.copyWith(
          status: WorkoutsStatus.success,
          workouts: updatedWorkouts,
          currentWorkout: newWorkout,
        ));
      },
    );
  }

  // Set current workout
  void setCurrentWorkout(WorkoutModel workout) {
    // Find the latest version of this workout from the state's workouts list
    final latestWorkout = state.workouts.firstWhere(
      (w) => w.id == workout.id,
      orElse: () => workout, // Fallback to the provided workout if not found
    );

    print('Setting current workout: ${latestWorkout.title}');
    print('Workout exercises count: ${latestWorkout.workoutExercises.length}');

    // Extract exercises from workoutExercises and ensure no duplicates
    final exercises = latestWorkout.workoutExercises
        .map((we) {
          if (we.exercise != null) {
            return we.exercise;
          } else if (we.customExercise != null) {
            return we.customExercise;
          }
          return null;
        })
        .where((e) => e != null)
        .toList();

    // Remove any duplicates based on exercise ID
    final uniqueExercises =
        exercises.fold<List<Exercise>>([], (list, exercise) {
      if (!list.any((e) => e.id == exercise!.id)) {
        list.add(exercise!);
      }
      return list;
    });

    print('Extracted exercises count: ${uniqueExercises.length}');

    emit(state.copyWith(
      currentWorkout: latestWorkout,
      clearCurrentExercise: true,
      selectedExercises: uniqueExercises,
    ));
  }

  // Load all exercises
  Future<void> loadExercises() async {
    emit(state.copyWith(status: WorkoutsStatus.loading, clearError: true));

    final result = await _repository.getExercises();

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: WorkoutsStatus.error,
          errorMessage: 'Failed to load exercises: ${failure.message}',
        ));
      },
      (exercisesData) {
        final exercises = exercisesData
            .map((exercise) => Exercise.fromJson(exercise))
            .toList();
        emit(state.copyWith(
          status: WorkoutsStatus.success,
          exercises: exercises,
        ));
      },
    );
  }

  // Load exercises for a workout
  Future<void> loadExercisesForWorkout() async {
    emit(state.copyWith(
        clearError: true, selectedExercises: state.selectedExercises));

    // final result = await _repository.getExercisesForWorkout(workoutId);

    // result.fold(
    //   (failure) {
    //     emit(state.copyWith(
    //       status: WorkoutsStatus.error,
    //       errorMessage: 'Failed to load workout exercises: ${failure.message}',
    //     ));
    //   },
    //   (exercisesData) {
    //     final selectedExercises = exercisesData
    //         .map((exercise) => Exercise.fromJson(exercise))
    //         .toList();
    //     emit(state.copyWith(
    //       status: WorkoutsStatus.success,
    //       selectedExercises: selectedExercises,
    //     ));
    //   },
    // );
  }

  // Set current exercise
  void setCurrentExercise(Exercise exercise) {
    if (state.currentWorkout == null) return;

    // Find the corresponding WorkoutExercise
    final workoutExercise = state.currentWorkout!.workoutExercises.firstWhere(
      (we) => we.exercise?.id == exercise.id,
      orElse: () => throw Exception('WorkoutExercise not found'),
    );
    if (exercise.category == "" &&
        workoutExercise.id.startsWith('temp')) // custom
    {
      workoutExercise.id = exercise.workoutExerciseID!;
    }
    // Get sets from the workout exercise
    final sets = workoutExercise.sets
        .map((set) => SetModel.fromJson(set.toJson()))
        .toList();

    emit(state.copyWith(
      currentExercise: exercise,
      currentWorkoutExercise: workoutExercise,
      sets: sets,
    ));
  }

  // Add set to exercise
  Future<void> addSetToExercise({
    required int reps,
    required double weight,
    int? restTime,
    String? note,
    String? timeUnitId,
    String? weightUnitId,
  }) async {
    if (state.currentWorkout == null || state.currentWorkoutExercise == null) {
      emit(state.copyWith(
        status: WorkoutsStatus.error,
        errorMessage: 'No workout or exercise selected',
      ));
      return;
    }

    emit(state.copyWith(status: WorkoutsStatus.loading, clearError: true));

    final setData = {
      'weight': weight,
      'repetitions': reps,
      'duration': null,
      if (restTime != null) 'restTime': restTime,
      if (note != null && note.isNotEmpty) 'note': note,
      if (timeUnitId != null) 'timeUnitId': timeUnitId,
      if (weightUnitId != null) 'weightUnitId': weightUnitId,
    };

    final result = await _repository.addSetToExercise(
      state.currentWorkoutExercise!.id,
      setData,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: WorkoutsStatus.error,
          errorMessage: 'Failed to add set: ${failure.message}',
        ));
      },
      (newSets) {
        // Convert new sets to SetModel
        final updatedSets = [
          ...state.sets,
          ...newSets.map((set) => SetModel.fromJson(set.toJson()))
        ];

        // Update the workout exercise with new sets
        final updatedWorkoutExercise = WorkoutExercise(
          id: state.currentWorkoutExercise!.id,
          workoutId: state.currentWorkoutExercise!.workoutId,
          exerciseId: state.currentWorkoutExercise!.exerciseId,
          exercise: state.currentWorkoutExercise!.exercise,
          customExerciseId: state.currentWorkoutExercise!.customExerciseId,
          customExercise: state.currentWorkoutExercise!.customExercise,
          sets: updatedSets,
        );

        // Update the workout with the updated exercise
        final updatedWorkoutExercises =
            state.currentWorkout!.workoutExercises.map((we) {
          if (we.id == updatedWorkoutExercise.id) {
            return updatedWorkoutExercise;
          }
          return we;
        }).toList();

        final updatedWorkout = WorkoutModel(
          id: state.currentWorkout!.id,
          planId: state.currentWorkout!.planId,
          userId: state.currentWorkout!.userId,
          title: state.currentWorkout!.title,
          date: state.currentWorkout!.date,
          workoutExercises: updatedWorkoutExercises,
        );

        // Update the workouts list
        final updatedWorkouts = state.workouts.map((w) {
          if (w.id == updatedWorkout.id) {
            return updatedWorkout;
          }
          return w;
        }).toList();

        // Update the selected exercises to ensure they have the latest workout exercise ID
        final updatedSelectedExercises = state.selectedExercises.map((e) {
          if (e?.id ==
              (updatedWorkoutExercise.exercise?.id ??
                  updatedWorkoutExercise.customExercise?.id)) {
            return e?.copyWith(workoutExerciseID: updatedWorkoutExercise.id);
          }
          return e;
        }).toList();

        emit(state.copyWith(
          status: WorkoutsStatus.success,
          sets: updatedSets,
          currentWorkoutExercise: updatedWorkoutExercise,
          currentWorkout: updatedWorkout,
          workouts: updatedWorkouts,
          selectedExercises: updatedSelectedExercises,
        ));
      },
    );
  }

  // Update the `addDurationSetToExercise` method in `workouts_cubit.dart` to not convert units
  Future<void> addDurationSetToExercise({
    required int duration,
    required double weight,
    int? restTime,
    String? note,
    String? timeUnitId,
    String? weightUnitId,
  }) async {
    if (state.currentWorkout == null || state.currentWorkoutExercise == null) {
      emit(state.copyWith(
        status: WorkoutsStatus.error,
        errorMessage: 'No workout or exercise selected',
      ));
      return;
    }

    emit(state.copyWith(status: WorkoutsStatus.loading, clearError: true));

    final setData = {
      'weight': weight,
      'repetitions': null,
      'duration': duration,
      if (restTime != null) 'restTime': restTime,
      if (note != null && note.isNotEmpty) 'note': note,
      if (timeUnitId != null) 'timeUnitId': timeUnitId,
      if (weightUnitId != null) 'weightUnitId': weightUnitId,
    };

    final result = await _repository.addSetToExercise(
      state.currentWorkoutExercise!.id,
      setData,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: WorkoutsStatus.error,
          errorMessage: 'Failed to add set: ${failure.message}',
        ));
      },
      (newSets) {
        // Convert new sets to SetModel
        final updatedSets = [
          ...state.sets,
          ...newSets.map((set) => SetModel.fromJson(set.toJson()))
        ];

        // Update the workout exercise with new sets
        final updatedWorkoutExercise = WorkoutExercise(
          id: state.currentWorkoutExercise!.id,
          workoutId: state.currentWorkoutExercise!.workoutId,
          exerciseId: state.currentWorkoutExercise!.exerciseId,
          exercise: state.currentWorkoutExercise!.exercise,
          customExerciseId: state.currentWorkoutExercise!.customExerciseId,
          customExercise: state.currentWorkoutExercise!.customExercise,
          sets: newSets,
        );

        // Update the workout with the updated exercise
        final updatedWorkoutExercises =
            state.currentWorkout!.workoutExercises.map((we) {
          if (we.id == updatedWorkoutExercise.id) {
            return updatedWorkoutExercise;
          }
          return we;
        }).toList();

        final updatedWorkout = WorkoutModel(
          id: state.currentWorkout!.id,
          planId: state.currentWorkout!.planId,
          userId: state.currentWorkout!.userId,
          title: state.currentWorkout!.title,
          date: state.currentWorkout!.date,
          workoutExercises: updatedWorkoutExercises,
        );

        // Update the workouts list
        final updatedWorkouts = state.workouts.map((w) {
          if (w.id == updatedWorkout.id) {
            return updatedWorkout;
          }
          return w;
        }).toList();

        emit(state.copyWith(
          status: WorkoutsStatus.success,
          sets: updatedSets,
          currentWorkoutExercise: updatedWorkoutExercise,
          currentWorkout: updatedWorkout,
          workouts: updatedWorkouts,
        ));
      },
    );
  }

  // Reset state
  void reset() {
    emit(const WorkoutsState());
  }

  // Edit set
  Future<void> editSet({
    required String setId,
    required double weight,
    required int? reps,
    required int? duration,
    int? restTime,
    String? note,
    String? timeUnitId,
    String? weightUnitId,
  }) async {
    if (state.currentWorkout == null || state.currentWorkoutExercise == null) {
      emit(state.copyWith(
        status: WorkoutsStatus.error,
        errorMessage: 'No workout or exercise selected',
      ));
      return;
    }

    emit(state.copyWith(status: WorkoutsStatus.loading, clearError: true));

    final setData = {
      'weight': weight,
      if (reps != null) 'repetitions': reps,
      if (duration != null) 'duration': duration,
      if (restTime != null) 'restTime': restTime,
      if (note != null) 'note': note,
      if (timeUnitId != null) 'timeUnitId': timeUnitId,
      if (weightUnitId != null) 'weightUnitId': weightUnitId,
    };

    final result = await _repository.updateSet(
      state.currentWorkoutExercise!.id,
      setId,
      setData,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: WorkoutsStatus.error,
          errorMessage: 'Failed to update set: ${failure.message}',
        ));
      },
      (updatedSet) {
        // Find the index of the set to update
        final setIndex = state.sets.indexWhere((s) => s.id == setId);
        if (setIndex == -1) {
          emit(state.copyWith(
            status: WorkoutsStatus.error,
            errorMessage: 'Set not found',
          ));
          return;
        }

        // Create updated sets list
        final updatedSets = List<SetModel>.from(state.sets);
        updatedSets[setIndex] = updatedSet.first;

        // Update the workout exercise with updated sets
        final updatedWorkoutExercise = WorkoutExercise(
          id: state.currentWorkoutExercise!.id,
          workoutId: state.currentWorkoutExercise!.workoutId,
          exerciseId: state.currentWorkoutExercise!.exerciseId,
          exercise: state.currentWorkoutExercise!.exercise,
          customExerciseId: state.currentWorkoutExercise!.customExerciseId,
          customExercise: state.currentWorkoutExercise!.customExercise,
          sets: updatedSets,
        );

        // Update the workout with the updated exercise
        final updatedWorkoutExercises =
            state.currentWorkout!.workoutExercises.map((we) {
          if (we.id == updatedWorkoutExercise.id) {
            return updatedWorkoutExercise;
          }
          return we;
        }).toList();

        final updatedWorkout = WorkoutModel(
          id: state.currentWorkout!.id,
          planId: state.currentWorkout!.planId,
          userId: state.currentWorkout!.userId,
          title: state.currentWorkout!.title,
          date: state.currentWorkout!.date,
          workoutExercises: updatedWorkoutExercises,
        );

        // Update the workouts list
        final updatedWorkouts = state.workouts.map((w) {
          if (w.id == updatedWorkout.id) {
            return updatedWorkout;
          }
          return w;
        }).toList();

        emit(state.copyWith(
          status: WorkoutsStatus.success,
          sets: updatedSets,
          currentWorkoutExercise: updatedWorkoutExercise,
          currentWorkout: updatedWorkout,
          workouts: updatedWorkouts,
        ));
      },
    );
  }

  // Delete set
  Future<void> deleteSet(String setId) async {
    if (state.currentWorkout == null || state.currentExercise == null) {
      emit(state.copyWith(
        status: WorkoutsStatus.error,
        errorMessage: 'No workout or exercise selected',
      ));
      return;
    }

    emit(state.copyWith(status: WorkoutsStatus.loading, clearError: true));

    final result = await _repository.deleteSet(setId);

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: WorkoutsStatus.error,
          errorMessage: 'Failed to delete set: ${failure.message}',
        ));
      },
      (sets) {
        state.currentWorkout!.workoutExercises
            .firstWhere((we) => we.id == state.currentWorkoutExercise!.id)
            .sets
            .removeWhere((s) => s.id == setId);

        emit(state.copyWith(
            status: WorkoutsStatus.success,
            sets: state.sets.where((s) => s.id != setId).toList()));
      },
    );
  }

  // // Load workouts for current plan
  // Future<void> loadWorkouts() async {
  //   if (state.currentPlan == null) {
  //     emit(state.copyWith(
  //       status: WorkoutsStatus.error,
  //       errorMessage: 'No plan selected',
  //     ));
  //     return;
  //   }

  //   emit(state.copyWith(status: WorkoutsStatus.loading, clearError: true));

  //   final result = await _repository.getWorkoutsForPlan(state.currentPlan!.id);

  //   result.fold(
  //     (failure) {
  //       emit(state.copyWith(
  //         status: WorkoutsStatus.error,
  //         errorMessage: 'Failed to load workouts: ${failure.message}',
  //       ));
  //     },
  //     (workouts) {
  //       emit(state.copyWith(
  //         status: WorkoutsStatus.success,
  //       ));
  //     },
  //   );
  // }

  // Delete workout
  Future<void> deleteWorkout(String workoutId) async {
    emit(state.copyWith(
        status: WorkoutsStatus.deletingWorkout, clearError: true));

    final result = await _repository.deleteWorkout(workoutId);

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: WorkoutsStatus.error,
          errorMessage: 'Failed to delete workout: ${failure.message}',
        ));
      },
      (_) {
        final updatedWorkouts = List<WorkoutModel>.from(state.workouts)
          ..removeWhere((workout) => workout.id == workoutId);

        emit(state.copyWith(
          status: WorkoutsStatus.success,
          workouts: updatedWorkouts,
          clearCurrentWorkout: state.currentWorkout?.id == workoutId,
        ));
      },
    );
  }

  // Add multiple exercises to workout
  Future<void> addExercisesToWorkout(
    List<String> exerciseIds, {
    List<String>? customExerciseIds,
  }) async {
    if (state.currentWorkout == null) {
      emit(state.copyWith(
        status: WorkoutsStatus.error,
        errorMessage: 'No workout selected',
      ));
      return;
    }

    emit(state.copyWith(status: WorkoutsStatus.loading, clearError: true));

    final result = await _repository.addExercisesToWorkout(
      state.currentWorkout!.id,
      exerciseIds,
      customExerciseIds: customExerciseIds ?? [],
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: WorkoutsStatus.error,
          errorMessage: 'Failed to add exercises: ${failure.message}',
        ));
      },
      (updatedWorkoutExercises) {
        // Convert workout exercises to Exercise models
        final newExercises = updatedWorkoutExercises
            .map((we) {
              // If we have the exercise object, use it
              if (we.exercise != null) {
                return we.exercise!;
              }
              // If we have a custom exercise, use it
              if (we.customExercise != null) {
                return we.customExercise!;
              }
              // If neither exists, return null
              return null;
            })
            .where((e) => e != null)
            .cast<Exercise>()
            .toList();

        // Combine existing exercises with new ones, avoiding duplicates
        final existingExercises = List<Exercise>.from(state.selectedExercises)
            .where((e) => e != null)
            .cast<Exercise>()
            .toList();
        final allExercises = [...existingExercises];

        // Add only new exercises that don't already exist
        for (final newExercise in newExercises) {
          if (!allExercises.any((e) => e.id == newExercise.id)) {
            allExercises.add(newExercise);
          } else {
            allExercises.removeWhere(
              (element) => element.id == newExercise.id,
            );
            allExercises.add(newExercise);
          }
        }

        // Combine existing workout exercises with new ones
        final existingWorkoutExercises =
            List<WorkoutExercise>.from(state.currentWorkout!.workoutExercises);
        final allWorkoutExercises = [...existingWorkoutExercises];

        // Add new workout exercises, replacing any that have the same exerciseId
        for (final newWorkoutExercise in updatedWorkoutExercises) {
          // Find and replace temporary exercises with real ones
          final existingIndex = allWorkoutExercises.indexWhere((we) {
            // Check if this is a temporary exercise that needs to be replaced
            if (we.id.startsWith('temp_')) {
              // For regular exercises
              if (we.exerciseId == newWorkoutExercise.exerciseId) {
                return true;
              }
              // For custom exercises
              if (we.customExerciseId == newWorkoutExercise.customExerciseId) {
                return true;
              }
            }
            return false;
          });

          if (existingIndex != -1) {
            // Replace the temporary workout exercise with the real one
            allWorkoutExercises[existingIndex] = newWorkoutExercise;

            // Update the exercise's workoutExerciseID in the selectedExercises list
            final exerciseIndex = allExercises.indexWhere((e) =>
                e.id ==
                (newWorkoutExercise.exercise?.id ??
                    newWorkoutExercise.customExercise?.id));
            if (exerciseIndex != -1) {
              allExercises[exerciseIndex] = allExercises[exerciseIndex]
                  .copyWith(workoutExerciseID: newWorkoutExercise.id);
            }
          } else {
            allWorkoutExercises.add(newWorkoutExercise);
          }
        }

        // Update the current workout with all exercises
        final updatedWorkout = WorkoutModel(
          id: state.currentWorkout!.id,
          planId: state.currentWorkout!.planId,
          userId: state.currentWorkout!.userId,
          title: state.currentWorkout!.title,
          date: state.currentWorkout!.date,
          workoutExercises: allWorkoutExercises,
        );

        // Update the workouts list
        final updatedWorkouts = state.workouts.map((w) {
          if (w.id == updatedWorkout.id) {
            return updatedWorkout;
          }
          return w;
        }).toList();

        // Update the state with all changes
        emit(state.copyWith(
          status: WorkoutsStatus.success,
          selectedExercises: allExercises,
          currentWorkout: updatedWorkout,
          workouts: updatedWorkouts,
        ));
      },
    );
  }

  void addExerciseToWorkoutLocally(Exercise exercise) {
    if (state.currentWorkout == null) return;

    // Create a new WorkoutExercise for the exercise
    final workoutExercise = WorkoutExercise(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      workoutId: state.currentWorkout!.id,
      exerciseId: exercise.id,
      exercise: exercise,
      sets: [],
    );

    // Update the current workout with the new exercise
    final updatedWorkout = WorkoutModel(
      id: state.currentWorkout!.id,
      planId: state.currentWorkout!.planId,
      userId: state.currentWorkout!.userId,
      title: state.currentWorkout!.title,
      date: state.currentWorkout!.date,
      workoutExercises: [
        ...state.currentWorkout!.workoutExercises,
        workoutExercise
      ],
    );

    // Update the workouts list
    final updatedWorkouts = state.workouts.map((w) {
      if (w.id == updatedWorkout.id) {
        return updatedWorkout;
      }
      return w;
    }).toList();

    // Map exercises and filter out any null values
    final updatedExercises = updatedWorkout.workoutExercises
        .map((we) => we.exercise)
        .where((e) => e != null)
        .cast<Exercise>()
        .toList();

    emit(state.copyWith(
      currentWorkout: updatedWorkout,
      workouts: updatedWorkouts,
      selectedExercises: updatedExercises,
      status: WorkoutsStatus
          .addingExercise, // Set status to indicate exercise is being added
    ));
  }

  // Create custom exercise
  Future<void> createCustomExercise({
    required String title,
    required String description,
    required String primaryMuscle,
    String? videoUrl,
  }) async {
    emit(state.copyWith(status: WorkoutsStatus.loading, clearError: true));

    final result = await _repository.createCustomExercise(
      title: title,
      description: description,
      primaryMuscle: primaryMuscle,
      videoUrl: videoUrl,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: WorkoutsStatus.error,
          errorMessage: 'Failed to create custom exercise: ${failure.message}',
        ));
      },
      (exercise) {
        // Add the custom exercise to the workout
        addExerciseToWorkoutLocally(exercise);
        emit(state.copyWith(
          status: WorkoutsStatus.success,
        ));
      },
    );
  }
}
