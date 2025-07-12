import 'package:gym/features/exercises/data/models/exercises.dart';
import 'package:gym/features/workouts/data/models/set_model.dart';

class WorkoutModel {
  final String id;
  final String planId;
  final String userId;
  final String title;
  final DateTime date;
  final String? notes;
  final int? sortOrder;
  final List<WorkoutExercise> workoutExercises;

  WorkoutModel({
    required this.id,
    required this.planId,
    required this.userId,
    required this.title,
    required this.date,
    this.notes,
    this.sortOrder,
    this.workoutExercises = const [],
  });

  WorkoutModel copyWith({
    String? id,
    String? planId,
    String? userId,
    String? title,
    String? notes,
    DateTime? date,
    int? sortOrder,
    List<WorkoutExercise>? workoutExercises,
  }) {
    return WorkoutModel(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      date: date ?? this.date,
      sortOrder: sortOrder ?? this.sortOrder,
      workoutExercises: workoutExercises ?? this.workoutExercises,
    );
  }

  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    return WorkoutModel(
      id: json['id'],
      planId: json['planId'],
      userId: json['userId'],
      title: json['title'],
      notes: json['note'],
      sortOrder: json['sortOrder'],
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
      'userId': userId,
      'title': title,
      'date': date.toIso8601String(),
      'notes': notes,
      'sortOrder': sortOrder,
      'workoutExercises': workoutExercises.map((e) => e.toJson()).toList(),
    };
  }
}

class WorkoutExercise {
  String id;
  final String workoutId;
  final String? exerciseId;
  final Exercise? exercise;
  final String? customExerciseId;
  final Exercise? customExercise;
  final List<IWorkoutSet> sets;

  WorkoutExercise({
    required this.id,
    required this.workoutId,
    this.exerciseId,
    this.exercise,
    this.customExerciseId,
    this.customExercise,
    this.sets = const [],
  });

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      id: json['id'],
      workoutId: json['workoutId'] ?? '',
      exerciseId: json['exerciseId'] ?? '',
      exercise: json['exercise'] != null
          ? Exercise.fromJson(json['exercise'], workoutExerciseID: json['id'])
          : null,
      customExerciseId: json['customExerciseId'].toString() ?? '',
      customExercise: json['customExercise'] != null
          ? Exercise.fromJson(json['customExercise'])
          : null,
      sets: (json['sets'] as List<dynamic>?)
              ?.map((e) => SetModel.fromJson(e))
              .toList() ??
          [],
    );
  }
  factory WorkoutExercise.fromAddingWorkoutExercise(Map<String, dynamic> json) {
    // Check if this is a custom exercise
    if (json['customExerciseId'] != null && json['customExercise'] != null) {
      return WorkoutExercise(
        id: json['id'],
        workoutId: json['workoutId'] ?? '',
        exerciseId: null,
        exercise: null,
        customExerciseId: json['customExerciseId'].toString(),
        customExercise: Exercise.fromJson(json['customExercise'],
            workoutExerciseID: json['id']),
        sets: [],
      );
    } else {
      // Regular exercise
      return WorkoutExercise(
        id: json['id'],
        workoutId: json['workoutId'] ?? '',
        exerciseId: json['exerciseId'] ?? '',
        exercise: json['exercise'] != null
            ? Exercise.fromJson(json['exercise'], workoutExerciseID: json['id'])
            : null,
        customExerciseId: null,
        customExercise: null,
        sets: [],
      );
    }
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workoutId': workoutId,
      'exerciseId': exerciseId,
      'exercise': exercise?.toJson(),
      'customExerciseId': customExerciseId,
      'customExercise': customExercise?.toJson(),
      'sets': sets.map((e) => e.toJson()).toList(),
    };
  }
}

class WorkoutSet {
  final String id;
  final double? weight;
  final int? repetitions;
  final int? duration;
  final int? restTime;
  final String workoutExerciseId;
  final String? timeUnitId;
  final String? weightUnitId;
  final dynamic timeUnit;
  final dynamic weightUnit;

  WorkoutSet({
    required this.id,
    this.weight,
    this.repetitions,
    this.duration,
    this.restTime,
    required this.workoutExerciseId,
    this.timeUnitId,
    this.weightUnitId,
    this.timeUnit,
    this.weightUnit,
  });

  factory WorkoutSet.fromJson(Map<String, dynamic> json) {
    return WorkoutSet(
      id: json['id'],
      weight: json['weight']?.toDouble(),
      repetitions: json['repetitions'],
      duration: json['duration'],
      restTime: json['restTime'],
      workoutExerciseId: json['workoutExerciseId'],
      timeUnitId: json['timeUnitId'],
      weightUnitId: json['weightUnitId'],
      timeUnit: json['timeUnit'],
      weightUnit: json['weightUnit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (weight != null) 'weight': weight,
      'repetitions': repetitions,
      'duration': duration,
      'restTime': restTime,
      'workoutExerciseId': workoutExerciseId,
      'timeUnitId': timeUnitId,
      'weightUnitId': weightUnitId,
      'timeUnit': timeUnit,
      'weightUnit': weightUnit,
    };
  }
}
