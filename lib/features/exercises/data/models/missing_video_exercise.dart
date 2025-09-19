class MissingVideoExercise {
  MissingVideoExercise({required this.id, required this.title});

  final String id;
  final String title;

  factory MissingVideoExercise.fromJson(Map<String, dynamic> json) {
    return MissingVideoExercise(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? json['name'] ?? '',
    );
  }

  static List<MissingVideoExercise> parseList(dynamic json) {
    final list = json as List;
    return list
        .map((e) => MissingVideoExercise.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
