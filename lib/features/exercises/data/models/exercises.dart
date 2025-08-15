class Exercise {
  factory Exercise.fromJson(Map<String, dynamic> json,
          {String? workoutExerciseID, String? gender, bool isCustom = false}) =>
      Exercise(
        id: json['id'] ?? '',
        workoutExerciseID: workoutExerciseID,
        name: json['title'] ?? json['name'] ?? '',
        description: json['description'] ?? '',
        videoUrl: isCustom
            ? json['videoUrl']
            : gender == 'male'
                ? json['videoUrl'] ?? ''
                : json['femaleVideoUrl'] ?? '',
        maleVideoUrl: json['videoUrl'] ?? '',
        femaleVideoUrl: json['femaleVideoUrl'] ?? '',
        primaryMuscle: json['primaryMuscle'] ?? json['muscleGroup'] ?? '',
        primaryMuscleId: json['primaryMuscleId'] ?? '',
        category: json['category'] ?? '',
        categoryId: json['categoryId'] ?? '',
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
      'maleVideoUrl': maleVideoUrl,
      'femaleVideoUrl': femaleVideoUrl,
      'primaryMuscle': primaryMuscle,
      'primaryMuscleId': primaryMuscleId,
      'muscleGroup': primaryMuscle,
      'category': category,
      'categoryId': categoryId,
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
      maleVideoUrl: '',
      femaleVideoUrl: '',
      primaryMuscle: '',
      primaryMuscleId: '',
      category: '',
      categoryId: '',
      id: '',
    );
  }

  Exercise(
      {required this.id,
      required this.name,
      required this.description,
      required this.videoUrl,
      this.maleVideoUrl = '',
      this.femaleVideoUrl = '',
      required this.primaryMuscle,
      required this.primaryMuscleId,
      required this.category,
      required this.categoryId,
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
  final String maleVideoUrl;
  final String femaleVideoUrl;
  final String primaryMuscle;
  final String primaryMuscleId;
  final String category;
  final String categoryId;
  final double? weight;
  final int? repetitions;
  final String? imageUrl;
  final String workoutId;

  // Get video URL based on gender (for admin mode)
  String getVideoUrlByGender(String gender) {
    return gender == 'male' ? maleVideoUrl : femaleVideoUrl;
  }

  // Check if exercise has both male and female videos
  bool get hasBothVideos =>
      maleVideoUrl.isNotEmpty && femaleVideoUrl.isNotEmpty;

  // Check if exercise has male video
  bool get hasMaleVideo => maleVideoUrl.isNotEmpty;

  // Check if exercise has female video
  bool get hasFemaleVideo => femaleVideoUrl.isNotEmpty;

  static List<Exercise> parseExercises(json, String? gender, bool isCustom) {
    final list = json as List;
    return list
        .map((e) => Exercise.fromJson(e, gender: gender, isCustom: isCustom))
        .toList();
  }

  Exercise copyWith({
    String? id,
    String? name,
    String? description,
    String? videoUrl,
    String? maleVideoUrl,
    String? femaleVideoUrl,
    String? primaryMuscle,
    String? primaryMuscleId,
    String? category,
    String? categoryId,
    double? weight,
    int? repetitions,
    String? imageUrl,
    String? workoutId,
    String? workoutExerciseID,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      maleVideoUrl: maleVideoUrl ?? this.maleVideoUrl,
      femaleVideoUrl: femaleVideoUrl ?? this.femaleVideoUrl,
      primaryMuscle: primaryMuscle ?? this.primaryMuscle,
      primaryMuscleId: primaryMuscleId ?? this.primaryMuscleId,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      weight: weight ?? this.weight,
      repetitions: repetitions ?? this.repetitions,
      imageUrl: imageUrl ?? this.imageUrl,
      workoutId: workoutId ?? this.workoutId,
      workoutExerciseID: workoutExerciseID ?? this.workoutExerciseID,
    );
  }
}
