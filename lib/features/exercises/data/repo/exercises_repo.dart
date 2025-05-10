import 'package:dartz/dartz.dart';
import 'package:gym/core/error/failures.dart';
import 'package:gym/core/network/dio_service.dart';
import 'package:gym/core/network/error_handler.dart';
import 'package:gym/features/exercises/data/models/exercises.dart';

class ExercisesRepository {
  ExercisesRepository();
  final DioService _dioService = DioService();
  Future<Either<Failure, List<Exercise>>> fetchExercises() async {
    try {
      final res = await _dioService.get(
        '/api/Exercises/GetAllExercises',
      );

      return Right(Exercise.parseExercises(res.data));
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
