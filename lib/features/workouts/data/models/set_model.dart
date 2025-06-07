class SetModel {
  final String id;
  final String workoutId;
  final String exerciseId;
  final double weight;
  final int? reps;
  final int? duration;
  final int? restTime;

  SetModel({
    required this.id,
    required this.workoutId,
    required this.exerciseId,
    required this.weight,
    this.reps,
    this.duration,
    this.restTime,
  });

  factory SetModel.fromJson(Map<String, dynamic> json) {
    return SetModel(
      id: json['id'],
      workoutId: json['workoutId'] ?? '',
      exerciseId: json['exerciseId'] ?? '',
      weight: json['weight'].toDouble(),
      reps: json['repetitions'],
      duration: json['duration'],
      restTime: json['restTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workoutId': workoutId,
      'exerciseId': exerciseId,
      'weight': weight,
      'repetitions': reps,
      'duration': duration,
      'restTime': restTime,
    };
  }
}
