import 'package:equatable/equatable.dart';
import 'package:trackletics/features/workouts/cubits/workouts_cubit.dart';
import 'package:trackletics/features/exercises/data/models/exercises.dart';
import 'package:trackletics/features/workouts/data/models/plan_model.dart';
import 'package:trackletics/features/workouts/data/models/plan_response.dart';
import 'package:trackletics/features/workouts/data/models/set_model.dart';
import 'package:trackletics/features/workouts/data/models/workout_model.dart';

enum WorkoutsStatus {
  initial,
  loading,
  success,
  error,
  loadingPlans,
  loadingWorkouts,
  loadingExercises,
  loadingSets,
  addingSet,
  addingExercise,
  creatingPlan,
  creatingWorkout,
  deletingPlan,
  deletingWorkout,
  deletingExercise,
  deletingSet,
  updatingPlan,
  updatingWorkout,
}

class WorkoutsState extends Equatable {
  final WorkoutsStatus status;
  final String? errorMessage;
  final List<PlanResponse> plans;
  final List<WorkoutModel> workouts;
  final List<Exercise> exercises;
  final List<Exercise> selectedExercises;
  final List<SetModel> sets;
  final PlanResponse? currentPlan;
  final WorkoutModel? currentWorkout;
  final Exercise? currentExercise;
  final WorkoutExercise? currentWorkoutExercise;

  const WorkoutsState({
    this.status = WorkoutsStatus.initial,
    this.errorMessage,
    this.plans = const [],
    this.workouts = const [],
    this.exercises = const [],
    this.selectedExercises = const [],
    this.sets = const [],
    this.currentPlan,
    this.currentWorkout,
    this.currentExercise,
    this.currentWorkoutExercise,
  });

  WorkoutsState copyWith({
    WorkoutsStatus? status,
    String? errorMessage,
    List<PlanResponse>? plans,
    List<WorkoutModel>? workouts,
    List<Exercise>? exercises,
    List<Exercise>? selectedExercises,
    List<SetModel>? sets,
    PlanResponse? currentPlan,
    WorkoutModel? currentWorkout,
    Exercise? currentExercise,
    WorkoutExercise? currentWorkoutExercise,
    bool clearError = false,
    bool clearCurrentPlan = false,
    bool clearCurrentWorkout = false,
    bool clearCurrentExercise = false,
  }) {
    return WorkoutsState(
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      plans: plans ?? this.plans,
      workouts: workouts ?? this.workouts,
      exercises: exercises ?? this.exercises,
      selectedExercises: selectedExercises ?? this.selectedExercises,
      sets: sets ?? this.sets,
      currentPlan: clearCurrentPlan ? null : currentPlan ?? this.currentPlan,
      currentWorkout:
          clearCurrentWorkout ? null : currentWorkout ?? this.currentWorkout,
      currentExercise:
          clearCurrentExercise ? null : currentExercise ?? this.currentExercise,
      currentWorkoutExercise:
          currentWorkoutExercise ?? this.currentWorkoutExercise,
    );
  }

  @override
  List<Object?> get props => [
        status,
        errorMessage,
        plans,
        workouts,
        exercises,
        selectedExercises,
        sets,
        currentPlan,
        currentWorkout,
        currentExercise,
        currentWorkoutExercise,
      ];
}
