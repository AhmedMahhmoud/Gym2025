abstract class IWorkoutSet {
  String get id;
  double? get weight;
  int? get repetitions;
  int? get duration;
  int? get restTime;
  String get workoutExerciseId;
  String? get note;
  String? get timeUnitId;
  String? get weightUnitId;
  Map<String, dynamic> toJson();
}

class SetModel implements IWorkoutSet {
  @override
  final String id;
  @override
  final double? weight;
  @override
  final int? repetitions;
  @override
  final int? duration;
  @override
  final int? restTime;
  @override
  final String workoutExerciseId;
  @override
  final String? note;
  @override
  final String? timeUnitId;
  @override
  final String? weightUnitId;

  SetModel({
    required this.id,
    this.weight,
    this.repetitions,
    this.duration,
    this.restTime,
    required this.workoutExerciseId,
    this.note,
    this.timeUnitId,
    this.weightUnitId,
  });

  factory SetModel.fromJson(Map<String, dynamic> json) {
    return SetModel(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      weight: json['weight']?.toDouble(),
      repetitions: json['repetitions'],
      duration: json['duration'],
      restTime: json['restTime'],
      workoutExerciseId: json['workoutExerciseId'] ?? '',
      note: json['note'],
      timeUnitId: json['timeUnitId'],
      weightUnitId: json['weightUnitId'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (weight != null) 'weight': weight,
      'repetitions': repetitions,
      'duration': duration,
      'restTime': restTime,
      'workoutExerciseId': workoutExerciseId,
      if (note != null) 'note': note,
      if (timeUnitId != null) 'timeUnitId': timeUnitId,
      if (weightUnitId != null) 'weightUnitId': weightUnitId,
    };
  }
}
