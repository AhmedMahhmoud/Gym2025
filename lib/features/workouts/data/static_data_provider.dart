import 'package:gym/features/exercises/data/models/exercises.dart';
import 'package:gym/features/workouts/data/models/plan_model.dart';
import 'package:gym/features/workouts/data/models/set_model.dart';
import 'package:gym/features/workouts/data/models/workout_model.dart';

class StaticWorkoutsData {
  static final Map<String, List<SetModel>> _exerciseSets = {};

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
        return [];
      case 'plan2':
        return [];
      case 'plan3':
        return [];
      default:
        return [];
    }
  }

  // Static Exercises
  static List<Exercise> getAllExercises() {
    return [
      Exercise(
        id: 'ex1',
        name: 'Bench Press',
        primaryMuscle: 'Chest',
        description: 'Compound exercise for chest, shoulders, and triceps',
        videoUrl: '',
        category: 'Compound',
      ),
      Exercise(
        id: 'ex2',
        name: 'Squat',
        primaryMuscle: 'Legs',
        description: 'Compound exercise for quadriceps, hamstrings, and glutes',
        videoUrl: '',
        category: 'Compound',
      ),
      Exercise(
        id: 'ex3',
        name: 'Deadlift',
        primaryMuscle: 'Back',
        description: 'Compound exercise for back, glutes, and hamstrings',
        videoUrl: '',
        category: 'Compound',
      ),
      Exercise(
        id: 'ex4',
        name: 'Shoulder Press',
        primaryMuscle: 'Shoulders',
        description: 'Compound exercise for shoulders and triceps',
        videoUrl: '',
        category: 'Compound',
      ),
      Exercise(
        id: 'ex5',
        name: 'Pull-up',
        primaryMuscle: 'Back',
        description: 'Compound exercise for back and biceps',
        videoUrl: '',
        category: 'Compound',
      ),
      Exercise(
        id: 'ex6',
        name: 'Bicep Curl',
        primaryMuscle: 'Arms',
        description: 'Isolation exercise for biceps',
        videoUrl: '',
        category: 'Isolation',
      ),
      Exercise(
        id: 'ex7',
        name: 'Tricep Extension',
        primaryMuscle: 'Arms',
        description: 'Isolation exercise for triceps',
        videoUrl: '',
        category: 'Isolation',
      ),
      Exercise(
        id: 'ex8',
        name: 'Leg Press',
        primaryMuscle: 'Legs',
        description: 'Compound exercise for quadriceps and glutes',
        videoUrl: '',
        category: 'Compound',
      ),
    ];
  }

  // Static Exercises for a Workout
  static List<Exercise> getExercisesForWorkout(String workoutId) {
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
  static List<SetModel> getSetsForExercise(
      String workoutId, String exerciseId) {
    final key = '$workoutId-$exerciseId';
    return _exerciseSets[key] ?? [];
  }

  // Helper method to create a new plan
  static PlanModel createPlan(String title) {
    final newId = 'plan${DateTime.now().millisecondsSinceEpoch}';
    return PlanModel(id: newId, title: title);
  }

  // Helper method to create a new workout

  // Helper method to create a new set

  static void updateSetsForExercise(
      String workoutId, String exerciseId, List<SetModel> sets) {
    final key = '$workoutId-$exerciseId';
    _exerciseSets[key] = sets;
  }
}
