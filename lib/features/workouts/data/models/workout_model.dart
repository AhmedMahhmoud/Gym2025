import 'package:gym/features/exercises/data/models/exercises.dart';

class WorkoutModel {
  final String id;
  final String planId;
  final String title;
  final DateTime date;
  final List<WorkoutExercise> workoutExercises;

  WorkoutModel({
    required this.id,
    required this.planId,
    required this.title,
    required this.date,
    this.workoutExercises = const [],
  });

  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    return WorkoutModel(
      id: json['id'],
      planId: json['planId'],
      title: json['title'],
      date: DateTime.parse(json['date']),
      workoutExercises: (json['workoutExercises'] as List<dynamic>?)
              ?.map((e) => WorkoutExercise.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'planId': planId,
      'title': title,
      'date': date.toIso8601String(),
      'workoutExercises': workoutExercises.map((e) => e.toJson()).toList(),
    };
  }
}

class WorkoutExercise {
  final String id;
  final String workoutId;
  final String exerciseId;
  final Exercise exercise;
  final String? customExerciseId;
  final dynamic customExercise;
  final List<dynamic> sets;

  WorkoutExercise({
    required this.id,
    required this.workoutId,
    required this.exerciseId,
    required this.exercise,
    this.customExerciseId,
    this.customExercise,
    this.sets = const [],
  });

  factory WorkoutExercise.fromJson(Map<String, dynamic> json,
      {String? workoutID}) {
    return WorkoutExercise(
      id: json['id'],
      workoutId: json['workoutId'] ?? workoutID,
      exerciseId: json['exerciseId'],
      exercise: json['exercise'] != null
          ? Exercise.fromJson(json['exercise'])
          : Exercise(
              id: json['exerciseId'],
              name: json['exerciseTitle'],
              description: '',
              videoUrl: '',
              primaryMuscle: '',
              category: ''),
      customExerciseId: json['customExerciseId'],
      customExercise: json['customExercise'],
      sets: json['sets'] ?? [],
    );
  }
  static List<WorkoutExercise> parseWorkoutExercises(json,
      {String? workoutID}) {
    final list = json as List;
    return list
        .map(
          (e) => WorkoutExercise.fromJson(e, workoutID: workoutID),
        )
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workoutId': workoutId,
      'exerciseId': exerciseId,
      'exercise': exercise.toJson(),
      'customExerciseId': customExerciseId,
      'customExercise': customExercise,
      'sets': sets,
    };
  }
}
