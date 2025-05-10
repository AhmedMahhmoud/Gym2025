class ExerciseModel {
  final String id;
  final String name;
  final String? description;
  final String? muscleGroup;
  final String? imageUrl;

  ExerciseModel({
    required this.id,
    required this.name,
    this.description,
    this.muscleGroup,
    this.imageUrl,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      muscleGroup: json['muscleGroup'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'muscleGroup': muscleGroup,
      'imageUrl': imageUrl,
    };
  }
}