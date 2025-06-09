class Exercise {
  factory Exercise.fromJson(Map<String, dynamic> json,
          {String? workoutExerciseID}) =>
      Exercise(
        id: json['id'] ?? '',
        workoutExerciseID: workoutExerciseID,
        name: json['title'] ?? json['name'] ?? '',
        description: json['description'] ?? '',
        videoUrl: json['videoUrl'] ?? '',
        primaryMuscle: json['primaryMuscle'] ?? json['muscleGroup'] ?? '',
        category: json['category'] ?? '',
        weight:
            json['weight'] != null ? (json['weight'] as num).toDouble() : null,
        repetitions: json['repetitions'] as int?,
        imageUrl: json['imageUrl'] ?? '',
        workoutId: json['workoutId'] ?? '',
      );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': name,
      'description': description,
      'videoUrl': videoUrl,
      'primaryMuscle': primaryMuscle,
      'muscleGroup': primaryMuscle,
      'category': category,
      'weight': weight,
      'repetitions': repetitions,
      'imageUrl': imageUrl,
      'workoutId': workoutId,
    };
  }

  factory Exercise.fake() {
    return Exercise(
      name: 'Loading...',
      description: 'Loading...',
      videoUrl: '', // Avoid loading actual images
      primaryMuscle: '',
      category: '',
      id: '',
    );
  }

  Exercise(
      {required this.id,
      required this.name,
      required this.description,
      required this.videoUrl,
      required this.primaryMuscle,
      required this.category,
      this.weight,
      this.repetitions,
      this.imageUrl,
      this.workoutId = '',
      this.workoutExerciseID});

  final String id;
  final String name;
  final String description;
  final String? workoutExerciseID;
  final String videoUrl;
  final String primaryMuscle;
  final String category;
  final double? weight;
  final int? repetitions;
  final String? imageUrl;
  final String workoutId;

  static List<Exercise> parseExercises(json) {
    final list = json as List;
    return list.map((e) => Exercise.fromJson(e)).toList();
  }

  Exercise copyWith({
    String? id,
    String? name,
    String? description,
    String? videoUrl,
    String? primaryMuscle,
    String? category,
    double? weight,
    int? repetitions,
    String? imageUrl,
    String? workoutId,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      primaryMuscle: primaryMuscle ?? this.primaryMuscle,
      category: category ?? this.category,
      weight: weight ?? this.weight,
      repetitions: repetitions ?? this.repetitions,
      imageUrl: imageUrl ?? this.imageUrl,
      workoutId: workoutId ?? this.workoutId,
    );
  }
}
