// class ExerciseModel {
//   factory ExerciseModel.fromJson(Map<String, dynamic> json) {
//     return ExerciseModel(
//       id: json['id'] as String,
//       name: json['name'] as String,
//       muscleGroup: json['muscleGroup'] as String?,
//       description: json['description'] as String?,
//       weight:
//           json['weight'] != null ? (json['weight'] as num).toDouble() : null,
//       repetitions: json['repetitions'] as int?,
//       imageUrl: json['imageUrl'] as String?,
//     );
//   }
  
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'muscleGroup': muscleGroup,
//       'description': description,
//       'weight': weight,
//       'repetitions': repetitions,
//       'imageUrl': imageUrl,
//     };
//   }
  
//   final String id;
//   final String name;
//   final String? muscleGroup;
//   final String? description;
//   final double? weight;
//   final int? repetitions;
//   final String? imageUrl;

//   ExerciseModel({
//     required this.id,
//     required this.name,
//     this.muscleGroup,
//     this.description,
//     this.weight,
//     this.repetitions,
//     this.imageUrl,
//   });

//   ExerciseModel copyWith({
//     String? id,
//     String? name,
//     String? muscleGroup,
//     String? description,
//     double? weight,
//     int? repetitions,
//     String? imageUrl,
//   }) {
//     return ExerciseModel(
//       id: id ?? this.id,
//       name: name ?? this.name,
//       muscleGroup: muscleGroup ?? this.muscleGroup,
//       description: description ?? this.description,
//       weight: weight ?? this.weight,
//       repetitions: repetitions ?? this.repetitions,
//       imageUrl: imageUrl ?? this.imageUrl,
//     );
//   }
// }
