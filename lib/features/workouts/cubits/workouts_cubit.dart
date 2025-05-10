import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym/features/workouts/cubits/workouts_state.dart';
import 'package:gym/features/workouts/data/models/exercise_model.dart';
import 'package:gym/features/workouts/data/models/plan_model.dart';
import 'package:gym/features/workouts/data/models/set_model.dart';
import 'package:gym/features/workouts/data/models/workout_model.dart';
import 'package:gym/features/workouts/data/workouts_repository.dart';

class WorkoutsCubit extends Cubit<WorkoutsState> {
  final WorkoutsRepository _repository;

  WorkoutsCubit({required WorkoutsRepository repository})
      : _repository = repository,
        super(const WorkoutsState());

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
        final plans =
            plansData.map((plan) => PlanModel.fromJson(plan)).toList();
        emit(state.copyWith(
          status: WorkoutsStatus.success,
          plans: plans,
        ));
      },
    );
  }

  // Create a new plan
  Future<void> createPlan(String title) async {
    emit(state.copyWith(status: WorkoutsStatus.loading, clearError: true));

    final result = await _repository.createPlan(title);

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: WorkoutsStatus.error,
          errorMessage: 'Failed to create plan: ${failure.message}',
        ));
      },
      (response) {
        final newPlan = PlanModel.fromJson(response);
        final updatedPlans = List<PlanModel>.from(state.plans)..add(newPlan);

        emit(state.copyWith(
          status: WorkoutsStatus.success,
          plans: updatedPlans,
          currentPlan: newPlan,
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
  void setCurrentPlan(PlanModel plan) {
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
            .map((exercise) => ExerciseModel.fromJson(exercise))
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
            .map((exercise) => ExerciseModel.fromJson(exercise))
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
            .map((exercise) => ExerciseModel.fromJson(exercise))
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
  void setCurrentExercise(ExerciseModel exercise) {
    emit(state.copyWith(currentExercise: exercise));
    if (state.currentWorkout != null) {
      loadSetsForExercise(state.currentWorkout!.id, exercise.id);
    }
  }

  // Load sets for an exercise
  Future<void> loadSetsForExercise(String workoutId, String exerciseId) async {
    emit(state.copyWith(status: WorkoutsStatus.loading, clearError: true));

    final result = await _repository.getSetsForExercise(workoutId, exerciseId);

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: WorkoutsStatus.error,
          errorMessage: 'Failed to load sets: ${failure.message}',
        ));
      },
      (setsData) {
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
      (response) async {
        await _loadSetsAfterAddingSet();
      },
    );
  }

  // Helper method to load sets after adding one
  Future<void> _loadSetsAfterAddingSet() async {
    final setsResult = await _repository.getSetsForExercise(
      state.currentWorkout!.id,
      state.currentExercise!.id,
    );

    setsResult.fold(
      (failure) {
        emit(state.copyWith(
          status: WorkoutsStatus.error,
          errorMessage: 'Failed to reload sets: ${failure.message}',
        ));
      },
      (setsData) {
        final sets = setsData.map((set) => SetModel.fromJson(set)).toList();
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
}
