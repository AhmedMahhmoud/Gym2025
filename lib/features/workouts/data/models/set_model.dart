class SetModel {
  final String id;
  final String exerciseId;
  final int reps;
  final double weight;
  final int? restTime; // in seconds

  SetModel({
    required this.id,
    required this.exerciseId,
    required this.reps,
    required this.weight,
    this.restTime,
  });

  factory SetModel.fromJson(Map<String, dynamic> json) {
    return SetModel(
      id: json['id'],
      exerciseId: json['exerciseId'],
      reps: json['reps'],
      weight: json['weight'].toDouble(),
      restTime: json['restTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'reps': reps,
      'weight': weight,
      'restTime': restTime,
    };
  }
}