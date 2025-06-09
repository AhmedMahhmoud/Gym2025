import 'package:gym/features/workouts/data/models/workout_model.dart';

class PlanResponse {
  final String id;
  final String userId;
  final String title;
  final String? notes;
  final List<WorkoutModel> workouts;

  PlanResponse({
    required this.id,
    required this.userId,
    required this.title,
    this.notes,
    required this.workouts,
  });

  PlanResponse copyWith({
    String? id,
    String? userId,
    String? title,
    String? notes,
    List<WorkoutModel>? workouts,
  }) {
    return PlanResponse(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      workouts: workouts ?? this.workouts,
    );
  }

  factory PlanResponse.fromJson(Map<String, dynamic> json) {
    return PlanResponse(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      notes: json['notes'],
      workouts: (json['workouts'] as List<dynamic>?)
              ?.map((e) => WorkoutModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'notes': notes,
      'workouts': workouts.map((e) => e.toJson()).toList(),
    };
  }

  static List<PlanResponse> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => PlanResponse.fromJson(json)).toList();
  }
}
