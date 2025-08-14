import 'package:dartz/dartz.dart';
import 'package:trackletics/core/error/failures.dart';
import 'package:trackletics/features/exercises/data/models/exercises.dart';
import 'package:trackletics/features/exercises/data/services/exercises_service.dart';

class ExercisesRepository {
  ExercisesRepository({required this.exercisesService});
  final ExercisesService exercisesService;

  Future<Either<Failure, List<Exercise>>> fetchExercises({
    String? role,
    String? gender,
    String? filterOn,
    String? filterQuery,
  }) async {
    try {
      final exercises = await exercisesService.fetchExercises(
        role: role,
        gender: gender,
        filterOn: filterOn,
        filterQuery: filterQuery,
      );
      return Right(exercises);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<Exercise>>> fetchCustomExercises() async {
    try {
      final exercises = await exercisesService.fetchCustomExercises();
      return Right(exercises);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, Exercise>> createCustomExercise({
    required String title,
    required String description,
    required String primaryMuscle,
    String? videoUrl,
  }) async {
    try {
      final exercise = await exercisesService.createCustomExercise(
        title: title,
        description: description,
        primaryMuscle: primaryMuscle,
        videoUrl: videoUrl,
      );
      return Right(exercise);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, void>> deleteCustomExercise(String exerciseId) async {
    try {
      await exercisesService.deleteCustomExercise(exerciseId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, Exercise>> updateCustomExercise({
    required String exerciseId,
    required String title,
    required String description,
    required String primaryMuscle,
    String? videoUrl,
  }) async {
    try {
      final exercise = await exercisesService.updateCustomExercise(
        exerciseId: exerciseId,
        title: title,
        description: description,
        primaryMuscle: primaryMuscle,
        videoUrl: videoUrl,
      );
      return Right(exercise);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, Exercise>> updateExercise({
    required String exerciseName,
    required String title,
    required String description,
    String? videoUrl,
    String? picturePath,
    String? primaryMuscleId,
    String? categoryId,
  }) async {
    try {
      final exercise = await exercisesService.updateExercise(
        exerciseName: exerciseName,
        title: title,
        description: description,
        videoUrl: videoUrl,
        picturePath: picturePath,
        primaryMuscleId: primaryMuscleId,
        categoryId: categoryId,
      );
      return Right(exercise);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
