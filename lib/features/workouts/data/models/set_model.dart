class SetModel {
  final String id;
  final String workoutId;
  final String exerciseId;
  final int? reps;
  final int? duration;
  final double weight;
  final int? restTime; // in seconds

  SetModel({
    required this.id,
    required this.workoutId,
    required this.exerciseId,
    this.reps,
    this.duration,
    required this.weight,
    this.restTime,
  });

  factory SetModel.fromJson(Map<String, dynamic> json) {
    return SetModel(
      id: json['id'] as String,
      workoutId: json['workoutId'] as String,
      exerciseId: json['exerciseId'] as String,
      reps: json['reps'] as int?,
      duration: json['duration'] as int?,
      weight: (json['weight'] as num).toDouble(),
      restTime: json['restTime'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workoutId': workoutId,
      'exerciseId': exerciseId,
      'reps': reps,
      'duration': duration,
      'weight': weight,
      'restTime': restTime,
    };
  }
}
