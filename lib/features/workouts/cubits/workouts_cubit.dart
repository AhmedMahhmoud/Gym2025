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
    emit(state.copyWith(status: WorkoutsStatus.loading, clearError: true));

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
    emit(state.copyWith(status: WorkoutsStatus.loading, clearError: true));

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
    emit(state.copyWith(status: WorkoutsStatus.loading, clearError: true));

    // final result = await _repository.deletePlan(planId);

    // result.fold(
    //   (failure) {
    //     emit(state.copyWith(
    //       status: WorkoutsStatus.error,
    //       errorMessage: 'Failed to delete plan: ${failure.message}',
    //     ));
    //   },
    //   (_) {
    //     final updatedPlans = List<PlanModel>.from(state.plans)
    //       ..removeWhere((plan) => plan.id == planId);

    //     emit(state.copyWith(
    //       status: WorkoutsStatus.success,
    //       plans: updatedPlans,
    //       clearCurrentPlan: state.currentPlan?.id == planId,
    //     ));
    //   },
    // );
  }

  // Set current plan
  void setCurrentPlan(PlanResponse plan) {
    emit(state.copyWith(
      currentPlan: plan,
      clearCurrentWorkout: true,
      clearCurrentExercise: true,
    ));
    loadWorkoutsForPlan(plan.id);
  }

  // Load workouts for a plan
  Future<void> loadWorkoutsForPlan(String planId) async {
    emit(state.copyWith(status: WorkoutsStatus.loading, clearError: true));

    final result = await _repository.getWorkoutsForPlan(planId);

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: WorkoutsStatus.error,
          errorMessage: 'Failed to load workouts: ${failure.message}',
        ));
      },
      (workoutsData) {
        final workouts = workoutsData
            .map((workout) => WorkoutModel.fromJson(workout))
            .toList();
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

    emit(state.copyWith(status: WorkoutsStatus.loading, clearError: true));

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
      (response) {
        final newWorkout = WorkoutModel.fromJson(response);
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
    emit(state.copyWith(
      currentWorkout: workout,
      clearCurrentExercise: true,
    ));
    loadExercisesForWorkout(workout.id);
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
    emit(state.copyWith(currentExercise: exercise));
    loadSetsForExercise(exercise.workoutId, exercise.id);
  }

  // Load sets for an exercise
  Future<void> loadSetsForExercise(String workoutId, String exerciseId) async {
    print('Loading sets for workout $workoutId and exercise $exerciseId');
    emit(state.copyWith(status: WorkoutsStatus.loading, clearError: true));

    final result = await _repository.getSetsForExercise(workoutId, exerciseId);

    result.fold(
      (failure) {
        print('Failed to load sets: ${failure.message}');
        emit(state.copyWith(
          status: WorkoutsStatus.error,
          errorMessage: 'Failed to load sets: ${failure.message}',
        ));
      },
      (setsData) {
        print('Successfully loaded ${setsData.length} sets');
        final sets = setsData.map((set) => SetModel.fromJson(set)).toList();
        emit(state.copyWith(
          status: WorkoutsStatus.success,
          sets: sets,
        ));
      },
    );
  }

  // Add set to exercise
  Future<void> addSetToExercise({
    required int reps,
    required double weight,
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
      'reps': reps,
      'weight': weight,
      if (restTime != null) 'restTime': restTime,
    };

    final result = await _repository.addSetToExercise(
      state.currentWorkout!.id,
      state.currentExercise!.id,
      setData,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: WorkoutsStatus.error,
          errorMessage: 'Failed to add set: ${failure.message}',
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

  // Add duration-based set to exercise
  Future<void> addDurationSetToExercise({
    required int duration,
    required double weight,
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
      'duration': duration,
      'weight': weight,
      if (restTime != null) 'restTime': restTime,
    };

    final result = await _repository.addSetToExercise(
      state.currentWorkout!.id,
      state.currentExercise!.id,
      setData,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: WorkoutsStatus.error,
          errorMessage: 'Failed to add set: ${failure.message}',
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

  // Reset state
  void reset() {
    emit(const WorkoutsState());
  }

  void addExerciseToWorkoutLocally(Exercise exercise) {
    final updatedExercises = List<Exercise>.from(state.selectedExercises)
      ..add(exercise);
    emit(state.copyWith(selectedExercises: updatedExercises));
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
      if (reps != null) 'reps': reps,
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
}

// Add this method to your WorkoutsCubit class
