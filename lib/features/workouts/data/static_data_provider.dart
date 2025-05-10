import 'package:gym/features/workouts/data/models/exercise_model.dart';
import 'package:gym/features/workouts/data/models/plan_model.dart';
import 'package:gym/features/workouts/data/models/set_model.dart';
import 'package:gym/features/workouts/data/models/workout_model.dart';

class StaticWorkoutsData {
  // Static Plans
  static List<PlanModel> getPlans() {
    return [
      PlanModel(id: 'plan1', title: 'Push Pull Legs'),
      PlanModel(id: 'plan2', title: 'Upper Lower Split'),
      PlanModel(id: 'plan3', title: 'Full Body Workout'),
    ];
  }

  // Static Workouts for a Plan
  static List<WorkoutModel> getWorkoutsForPlan(String planId) {
    switch (planId) {
      case 'plan1':
        return [
          WorkoutModel(id: 'workout1', planId: 'plan1', title: 'Push Day'),
          WorkoutModel(id: 'workout2', planId: 'plan1', title: 'Pull Day'),
          WorkoutModel(id: 'workout3', planId: 'plan1', title: 'Leg Day'),
        ];
      case 'plan2':
        return [
          WorkoutModel(id: 'workout4', planId: 'plan2', title: 'Upper Body'),
          WorkoutModel(id: 'workout5', planId: 'plan2', title: 'Lower Body'),
        ];
      case 'plan3':
        return [
          WorkoutModel(id: 'workout6', planId: 'plan3', title: 'Full Body A'),
          WorkoutModel(id: 'workout7', planId: 'plan3', title: 'Full Body B'),
        ];
      default:
        return [];
    }
  }

  // Static Exercises
  static List<ExerciseModel> getAllExercises() {
    return [
      ExerciseModel(
        id: 'ex1',
        name: 'Bench Press',
        muscleGroup: 'Chest',
        description: 'Compound exercise for chest, shoulders, and triceps',
      ),
      ExerciseModel(
        id: 'ex2',
        name: 'Squat',
        muscleGroup: 'Legs',
        description: 'Compound exercise for quadriceps, hamstrings, and glutes',
      ),
      ExerciseModel(
        id: 'ex3',
        name: 'Deadlift',
        muscleGroup: 'Back',
        description: 'Compound exercise for back, glutes, and hamstrings',
      ),
      ExerciseModel(
        id: 'ex4',
        name: 'Shoulder Press',
        muscleGroup: 'Shoulders',
        description: 'Compound exercise for shoulders and triceps',
      ),
      ExerciseModel(
        id: 'ex5',
        name: 'Pull-up',
        muscleGroup: 'Back',
        description: 'Compound exercise for back and biceps',
      ),
      ExerciseModel(
        id: 'ex6',
        name: 'Bicep Curl',
        muscleGroup: 'Arms',
        description: 'Isolation exercise for biceps',
      ),
      ExerciseModel(
        id: 'ex7',
        name: 'Tricep Extension',
        muscleGroup: 'Arms',
        description: 'Isolation exercise for triceps',
      ),
      ExerciseModel(
        id: 'ex8',
        name: 'Leg Press',
        muscleGroup: 'Legs',
        description: 'Compound exercise for quadriceps and glutes',
      ),
    ];
  }

  // Static Exercises for a Workout
  static List<ExerciseModel> getExercisesForWorkout(String workoutId) {
    final allExercises = getAllExercises();
    
    switch (workoutId) {
      case 'workout1': // Push Day
        return [
          allExercises.firstWhere((e) => e.id == 'ex1'), // Bench Press
          allExercises.firstWhere((e) => e.id == 'ex4'), // Shoulder Press
          allExercises.firstWhere((e) => e.id == 'ex7'), // Tricep Extension
        ];
      case 'workout2': // Pull Day
        return [
          allExercises.firstWhere((e) => e.id == 'ex3'), // Deadlift
          allExercises.firstWhere((e) => e.id == 'ex5'), // Pull-up
          allExercises.firstWhere((e) => e.id == 'ex6'), // Bicep Curl
        ];
      case 'workout3': // Leg Day
        return [
          allExercises.firstWhere((e) => e.id == 'ex2'), // Squat
          allExercises.firstWhere((e) => e.id == 'ex8'), // Leg Press
        ];
      default:
        return [];
    }
  }

  // Static Sets for an Exercise
  static List<SetModel> getSetsForExercise(String workoutId, String exerciseId) {
    switch (exerciseId) {
      case 'ex1': // Bench Press
        return [
          SetModel(id: 'set1', exerciseId: 'ex1', reps: 12, weight: 60.0, restTime: 60),
          SetModel(id: 'set2', exerciseId: 'ex1', reps: 10, weight: 70.0, restTime: 60),
          SetModel(id: 'set3', exerciseId: 'ex1', reps: 8, weight: 80.0, restTime: 90),
        ];
      case 'ex2': // Squat
        return [
          SetModel(id: 'set4', exerciseId: 'ex2', reps: 12, weight: 80.0, restTime: 90),
          SetModel(id: 'set5', exerciseId: 'ex2', reps: 10, weight: 100.0, restTime: 120),
        ];
      default:
        return [];
    }
  }

  // Helper method to create a new plan
  static PlanModel createPlan(String title) {
    final newId = 'plan${DateTime.now().millisecondsSinceEpoch}';
    return PlanModel(id: newId, title: title);
  }

  // Helper method to create a new workout
  static WorkoutModel createWorkout(String planId, String title) {
    final newId = 'workout${DateTime.now().millisecondsSinceEpoch}';
    return WorkoutModel(id: newId, planId: planId, title: title);
  }

  // Helper method to create a new set
  static SetModel createSet({
    required String exerciseId,
    required int reps,
    required double weight,
    int? restTime,
  }) {
    final newId = 'set${DateTime.now().millisecondsSinceEpoch}';
    return SetModel(
      id: newId,
      exerciseId: exerciseId,
      reps: reps,
      weight: weight,
      restTime: restTime,
    );
  }
}