import 'package:trackletics/core/network/dio_service.dart';
import 'package:trackletics/features/exercises/data/models/exercises.dart';
import 'package:trackletics/features/exercises/data/models/missing_video_exercise.dart';

class ExercisesService {
  ExercisesService({required this.dioService});
  final DioService dioService;

  Future<List<Exercise>> fetchExercises({
    String? role,
    String? gender,
    String? filterOn,
    String? filterQuery,
  }) async {
    final query = <String, dynamic>{};
    if (role != null && role.isNotEmpty) query['role'] = role;
    if (gender != null && gender.isNotEmpty) query['gender'] = gender;
    if (filterOn != null && filterOn.isNotEmpty) query['filterOn'] = filterOn;
    if (filterQuery != null && filterQuery.isNotEmpty) {
      query['filterQuery'] = filterQuery;
    }

    final res = await dioService.get(
      '/api/Exercises/GetAllExercises',
      queryParameters: query.isEmpty ? null : query,
    );
    return Exercise.parseExercises(res.data, gender!, false);
  }

  Future<List<Exercise>> fetchCustomExercises() async {
    final res = await dioService.get('/api/customExercises');
    final exercises = Exercise.parseExercises(res.data, null, true);
    // Mark all exercises from custom endpoint as custom
    return exercises
        .map((e) => Exercise(
              id: e.id,
              name: e.name,
              primaryMuscleId: e.primaryMuscleId,
              categoryId: e.categoryId,
              description: e.description,
              primaryMuscle: e.primaryMuscle,
              category: e.category,
              videoUrl: e.videoUrl,
              maleVideoUrl: e.maleVideoUrl,
              femaleVideoUrl: e.femaleVideoUrl,
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
      categoryId: exercise.categoryId,
      primaryMuscleId: exercise.primaryMuscleId,
      description: exercise.description,
      primaryMuscle: exercise.primaryMuscle,
      category: exercise.category,
      videoUrl: exercise.videoUrl,
      maleVideoUrl: exercise.maleVideoUrl,
      femaleVideoUrl: exercise.femaleVideoUrl,
      imageUrl: exercise.imageUrl,
      workoutId: exercise.workoutId,
    );
  }

  Future<void> deleteCustomExercise(String exerciseId) async {
    await dioService.delete('/api/customExercises/$exerciseId');
  }

  Future<Exercise> updateCustomExercise({
    required String exerciseId,
    required String title,
    required String description,
    required String primaryMuscle,
    String? videoUrl,
  }) async {
    final res = await dioService.put(
      '/api/customExercises/$exerciseId',
      data: {
        'title': title,
        'description': description,
        'videoUrl': videoUrl,
        'primaryMuscle': primaryMuscle,
      },
    );
    final exercise = Exercise.fromJson(res.data);
    // Mark the updated exercise as custom
    return Exercise(
      id: exercise.id,
      name: exercise.name,
      categoryId: exercise.categoryId,
      primaryMuscleId: exercise.primaryMuscleId,
      description: exercise.description,
      primaryMuscle: exercise.primaryMuscle,
      category: exercise.category,
      videoUrl: exercise.videoUrl,
      maleVideoUrl: exercise.maleVideoUrl,
      femaleVideoUrl: exercise.femaleVideoUrl,
      imageUrl: exercise.imageUrl,
      workoutId: exercise.workoutId,
    );
  }

  Future<Exercise> updateExercise({
    required String exerciseId,
    required String title,
    required String description,
    String? videoUrl,
    String? maleVideoUrl,
    String? femaleVideoUrl,
    String? picturePath,
    String? primaryMuscleId,
    String? categoryId,
  }) async {
    final res = await dioService.put(
      '/api/Exercises/UpdateExercise/$exerciseId',
      data: {
        'title': title,
        'description': description,
        'videoUrl': maleVideoUrl,
        'femaleVideoUrl': femaleVideoUrl,
        'picturePath': picturePath,
        if (primaryMuscleId != null) 'primaryMuscleId': primaryMuscleId,
        if (categoryId != null) 'categoryId': categoryId,
      },
    );

    return Exercise.fromJson(res.data);
  }

  Future<List<MissingVideoExercise>> fetchExercisesMissingVideos() async {
    final res = await dioService.get('/api/Exercises/CheckIsVideoAvailable');
    return MissingVideoExercise.parseList(res.data);
  }
}
