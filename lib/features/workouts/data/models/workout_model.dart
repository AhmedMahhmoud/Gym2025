class WorkoutModel {
  final String id;
  final String planId;
  final String title;

  WorkoutModel({
    required this.id,
    required this.planId,
    required this.title,
  });

  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    return WorkoutModel(
      id: json['id'],
      planId: json['planId'],
      title: json['title'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'planId': planId,
      'title': title,
    };
  }
}