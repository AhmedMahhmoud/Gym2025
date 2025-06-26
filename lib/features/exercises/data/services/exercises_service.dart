import 'package:gym/core/network/dio_service.dart';
import 'package:gym/features/exercises/data/models/exercises.dart';

class ExercisesService {
  ExercisesService({required this.dioService});
  final DioService dioService;

  Future<List<Exercise>> fetchExercises() async {
    final res = await dioService.get('/api/Exercises/GetAllExercises');
    return Exercise.parseExercises(res.data);
  }

  Future<List<Exercise>> fetchCustomExercises() async {
    final res = await dioService.get('/api/customExercises');
    final exercises = Exercise.parseExercises(res.data);
    // Mark all exercises from custom endpoint as custom
    return exercises
        .map((e) => Exercise(
              id: e.id,
              name: e.name,
              description: e.description,
              primaryMuscle: e.primaryMuscle,
              category: e.category,
              videoUrl: e.videoUrl,
              imageUrl: e.imageUrl,
              workoutId: e.workoutId,
            ))
        .toList();
  }

  Future<Exercise> createCustomExercise({
    required String title,
    required String description,
    required String primaryMuscle,
    String? videoUrl,
  }) async {
    final res = await dioService.post(
      '/api/customExercises',
      data: {
        'title': title,
        'name': title, // Use title as name for custom exercises
        'description': description,
        'primaryMuscle': primaryMuscle,
        if (videoUrl != null) 'videoUrl': videoUrl,
      },
    );
    final exercise = Exercise.fromJson(res.data);
    // Mark the created exercise as custom
    return Exercise(
      id: exercise.id,
      name: exercise.name,
      description: exercise.description,
      primaryMuscle: exercise.primaryMuscle,
      category: exercise.category,
      videoUrl: exercise.videoUrl,
      imageUrl: exercise.imageUrl,
      workoutId: exercise.workoutId,
    );
  }

  Future<void> deleteCustomExercise(String exerciseId) async {
    await dioService.delete('/api/customExercises/$exerciseId');
  }
}
