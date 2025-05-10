class Exercise {
  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        videoUrl: json['videoUrl'] ?? '',
        primaryMuscle: json['primaryMuscle'] ?? '',
        category: json['category'] ?? '',
      );

  factory Exercise.fake() {
    return Exercise(
      name: 'Loading...',
      description: 'Loading...',
      videoUrl: '', // Avoid loading actual images
      primaryMuscle: '',
      category: '', id: '',
    );
  }
  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.videoUrl,
    required this.primaryMuscle,
    required this.category,
  });
  final String id;
  final String name;
  final String description;
  final String videoUrl;
  final String primaryMuscle;
  final String category;

  static List<Exercise> parseExercises(json) {
    final list = json as List;
    return list.map((e) => Exercise.fromJson(e)).toList();
  }
}
