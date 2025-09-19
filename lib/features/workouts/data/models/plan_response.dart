import 'package:trackletics/features/workouts/data/models/workout_model.dart';

class PlanResponse {
  final String id;
  final String userId;
  final String title;
  final String? notes;
  final bool isStatic;
  final List<WorkoutModel> workouts;

  PlanResponse({
    required this.id,
    required this.userId,
    required this.title,
    this.notes,
    this.isStatic = false,
    required this.workouts,
  });

  PlanResponse copyWith({
    String? id,
    String? userId,
    String? title,
    String? notes,
    bool? isStatic,
    List<WorkoutModel>? workouts,
  }) {
    return PlanResponse(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      isStatic: isStatic ?? this.isStatic,
      workouts: workouts ?? this.workouts,
    );
  }

  factory PlanResponse.fromJson(Map<String, dynamic> json) {
    return PlanResponse(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      notes: json['notes'],
      isStatic: json['isStatic'] ?? false,
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
      'isStatic': isStatic,
      'workouts': workouts.map((e) => e.toJson()).toList(),
    };
  }

  static List<PlanResponse> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => PlanResponse.fromJson(json)).toList();
  }
}
