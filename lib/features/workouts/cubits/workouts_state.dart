import 'package:equatable/equatable.dart';
import 'package:gym/features/workouts/data/models/exercise_model.dart';
import 'package:gym/features/workouts/data/models/plan_model.dart';
import 'package:gym/features/workouts/data/models/set_model.dart';
import 'package:gym/features/workouts/data/models/workout_model.dart';

enum WorkoutsStatus { initial, loading, success, error }

class WorkoutsState extends Equatable {
  final WorkoutsStatus status;
  final String? errorMessage;
  final List<PlanModel> plans;
  final List<WorkoutModel> workouts;
  final List<ExerciseModel> exercises;
  final List<ExerciseModel> selectedExercises;
  final List<SetModel> sets;
  final PlanModel? currentPlan;
  final WorkoutModel? currentWorkout;
  final ExerciseModel? currentExercise;

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
  });

  WorkoutsState copyWith({
    WorkoutsStatus? status,
    String? errorMessage,
    List<PlanModel>? plans,
    List<WorkoutModel>? workouts,
    List<ExerciseModel>? exercises,
    List<ExerciseModel>? selectedExercises,
    List<SetModel>? sets,
    PlanModel? currentPlan,
    WorkoutModel? currentWorkout,
    ExerciseModel? currentExercise,
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
      currentWorkout: clearCurrentWorkout ? null : currentWorkout ?? this.currentWorkout,
      currentExercise: clearCurrentExercise ? null : currentExercise ?? this.currentExercise,
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
      ];
}