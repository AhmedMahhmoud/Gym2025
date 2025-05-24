class PlanModel {
  final String id;
  final String title;
  final String? notes;

  PlanModel({
    required this.id,
    required this.title,
    this.notes,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'],
      title: json['title'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'notes': notes,
    };
  }
}
