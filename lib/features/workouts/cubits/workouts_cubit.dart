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
    emit(state.copyWith(
      currentPlan: plan,
      clearCurrentWorkout: true,
      clearCurrentExercise: true,
    ));
    // Only load workouts if we don't have any for this plan
    if (state.workouts.isEmpty) {
      loadWorkoutsForPlan(plan.id);
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
        final workouts = workoutsData;
        emit(state.copyWith(
          status: WorkoutsStatus.success,
          workouts: workouts,
        ));
      },
    );
  }

  // Create a new workout
  Future<void> createWorkout(String title) async {
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
    print('Setting current workout: ${workout.title}');
    print('Workout exercises count: ${workout.workoutExercises.length}');

    // Extract exercises from workoutExercises
    final exercises =
        workout.workoutExercises.map((we) => we.exercise).toList();

    print('Extracted exercises count: ${exercises.length}');
    print(
        'First exercise name: ${exercises.isNotEmpty ? exercises.first.name : 'No exercises'}');

    emit(state.copyWith(
      currentWorkout: workout,
      clearCurrentExercise: true,
      selectedExercises: exercises,
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
  Future<void> loadExercisesForWorkout(String workoutId) async {
    emit(state.copyWith(status: WorkoutsStatus.loading, clearError: true));

    final result = await _repository.getExercisesForWorkout(workoutId);

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: WorkoutsStatus.error,
          errorMessage: 'Failed to load workout exercises: ${failure.message}',
        ));
      },
      (exercisesData) {
        final selectedExercises = exercisesData
            .map((exercise) => Exercise.fromJson(exercise))
            .toList();
        emit(state.copyWith(
          status: WorkoutsStatus.success,
          selectedExercises: selectedExercises,
        ));
      },
    );
  }

  // Add exercise to workout
  Future<void> addExerciseToWorkout(String exerciseId) async {
    if (state.currentWorkout == null) {
      emit(state.copyWith(
        status: WorkoutsStatus.error,
        errorMessage: 'No workout selected',
      ));
      return;
    }

    emit(state.copyWith(status: WorkoutsStatus.loading, clearError: true));

    final result = await _repository.addExerciseToWorkout(
      state.currentWorkout!.id,
      exerciseId,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: WorkoutsStatus.error,
          errorMessage: 'Failed to add exercise: ${failure.message}',
        ));
      },
      (response) async {
        // Reload exercises for the workout to get the updated list
        await _loadExercisesAfterAddingExercise(exerciseId);
      },
    );
  }

  // Helper method to load exercises after adding one
  Future<void> _loadExercisesAfterAddingExercise(String exerciseId) async {
    final exercisesResult =
        await _repository.getExercisesForWorkout(state.currentWorkout!.id);

    exercisesResult.fold(
      (failure) {
        emit(state.copyWith(
          status: WorkoutsStatus.error,
          errorMessage: 'Failed to reload exercises: ${failure.message}',
        ));
      },
      (exercisesData) {
        final selectedExercises = exercisesData
            .map((exercise) => Exercise.fromJson(exercise))
            .toList();

        // Find the exercise in the full list to set as current
        final exercise = state.exercises.firstWhere(
          (e) => e.id == exerciseId,
          orElse: () => throw Exception('Exercise not found'),
        );

        emit(state.copyWith(
          status: WorkoutsStatus.success,
          selectedExercises: selectedExercises,
          currentExercise: exercise,
        ));
      },
    );
  }

  // Set current exercise
  void setCurrentExercise(Exercise exercise) {
    if (state.currentWorkout == null) return;

    // Find the corresponding WorkoutExercise
    final workoutExercise = state.currentWorkout!.workoutExercises.firstWhere(
      (we) => we.exercise.id == exercise.id,
      orElse: () => throw Exception('WorkoutExercise not found'),
    );

    // Get sets from the workout exercise
    final sets =
        workoutExercise.sets.map((set) => SetModel.fromJson(set)).toList();

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
  }) async {
    if (state.currentWorkout == null || state.currentWorkoutExercise == null) {
      emit(state.copyWith(
        status: WorkoutsStatus.error,
        errorMessage: 'No workout or exercise selected',
      ));
      return;
    }

    emit(state.copyWith(status: WorkoutsStatus.addingSet, clearError: true));

    final setData = {
      'weight': weight,
      'repetitions': reps,
      'duration': null,
      if (restTime != null) 'restTime': restTime,
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
        // Append new sets to existing sets
        final updatedSets = [...state.sets, ...newSets];

        // Update the workout exercise with new sets
        final updatedWorkoutExercise = WorkoutExercise(
          id: state.currentWorkoutExercise!.id,
          workoutId: state.currentWorkoutExercise!.workoutId,
          exerciseId: state.currentWorkoutExercise!.exerciseId,
          exercise: state.currentWorkoutExercise!.exercise,
          customExerciseId: state.currentWorkoutExercise!.customExerciseId,
          customExercise: state.currentWorkoutExercise!.customExercise,
          sets: updatedSets.map((set) => set.toJson()).toList(),
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

  // Add duration-based set to exercise
  Future<void> addDurationSetToExercise({
    required int duration,
    required double weight,
    int? restTime,
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
        // Append new sets to existing sets
        final updatedSets = [...state.sets, ...newSets];

        // Update the workout exercise with new sets
        final updatedWorkoutExercise = WorkoutExercise(
          id: state.currentWorkoutExercise!.id,
          workoutId: state.currentWorkoutExercise!.workoutId,
          exerciseId: state.currentWorkoutExercise!.exerciseId,
          exercise: state.currentWorkoutExercise!.exercise,
          customExerciseId: state.currentWorkoutExercise!.customExerciseId,
          customExercise: state.currentWorkoutExercise!.customExercise,
          sets: updatedSets.map((set) => set.toJson()).toList(),
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

    emit(state.copyWith(
      currentWorkout: updatedWorkout,
      workouts: updatedWorkouts,
      selectedExercises:
          updatedWorkout.workoutExercises.map((we) => we.exercise).toList(),
    ));
  }

  // Edit set
  Future<void> editSet({
    required String setId,
    required double weight,
    required int? reps,
    required int? duration,
    int? restTime,
  }) async {
    if (state.currentWorkout == null || state.currentExercise == null) {
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
    };

    final result = await _repository.updateSet(
      state.currentWorkout!.id,
      state.currentExercise!.id,
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
      (sets) {
        emit(state.copyWith(
          status: WorkoutsStatus.success,
          sets: sets,
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

    final result = await _repository.deleteSet(
      state.currentWorkout!.id,
      state.currentExercise!.id,
      setId,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: WorkoutsStatus.error,
          errorMessage: 'Failed to delete set: ${failure.message}',
        ));
      },
      (sets) {
        emit(state.copyWith(
          status: WorkoutsStatus.success,
          sets: sets,
        ));
      },
    );
  }

  // Load workouts for current plan
  Future<void> loadWorkouts() async {
    if (state.currentPlan == null) {
      emit(state.copyWith(
        status: WorkoutsStatus.error,
        errorMessage: 'No plan selected',
      ));
      return;
    }

    emit(state.copyWith(status: WorkoutsStatus.loading, clearError: true));

    final result = await _repository.getWorkoutsForPlan(state.currentPlan!.id);

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: WorkoutsStatus.error,
          errorMessage: 'Failed to load workouts: ${failure.message}',
        ));
      },
      (workouts) {
        emit(state.copyWith(
          status: WorkoutsStatus.success,
          workouts: workouts,
        ));
      },
    );
  }

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
  Future<void> addExercisesToWorkout(List<String> exerciseIds) async {
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
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: WorkoutsStatus.error,
          errorMessage: 'Failed to add exercises: ${failure.message}',
        ));
      },
      (updatedWorkoutExercises) {
        // Create a new workout with the updated exercises
        final updatedWorkout = WorkoutModel(
          id: state.currentWorkout!.id,
          planId: state.currentWorkout!.planId,
          title: state.currentWorkout!.title,
          date: state.currentWorkout!.date,
          workoutExercises: updatedWorkoutExercises,
        );

        // Update only the workouts for the current plan
        final updatedWorkouts = state.workouts.map((w) {
          if (w.id == updatedWorkout.id) {
            return updatedWorkout;
          }
          return w;
        }).toList();

        // Update the state with the new workout and exercises
        emit(state.copyWith(
          status: WorkoutsStatus.success,
          currentWorkout: updatedWorkout,
          workouts: updatedWorkouts,
          selectedExercises:
              updatedWorkoutExercises.map((we) => we.exercise).toList(),
        ));
      },
    );
  }
}

// Add this method to your WorkoutsCubit class
