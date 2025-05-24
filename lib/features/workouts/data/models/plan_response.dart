import 'package:gym/features/workouts/data/models/workout_model.dart';

class PlanResponse {
  final String id;
  final String userId;
  final String title;
  final String? notes;
  final List<dynamic> workouts;

  PlanResponse({
    required this.id,
    required this.userId,
    required this.title,
    this.notes,
    required this.workouts,
  });

  factory PlanResponse.fromJson(Map<String, dynamic> json) {
    return PlanResponse(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      notes: json['notes'],
      workouts: json['workouts'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'notes': notes,
      'workouts': workouts,
    };
  }

  static List<PlanResponse> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => PlanResponse.fromJson(json)).toList();
  }
}
