import 'package:dartz/dartz.dart';
import 'package:gym/core/error/failures.dart';
import 'package:gym/core/network/dio_service.dart';
import 'package:gym/core/network/error_handler.dart';
import 'package:gym/features/workouts/data/static_data_provider.dart';

class WorkoutsRepository {
  final DioService _dioService;
  final bool useStaticData;

  WorkoutsRepository({
    required DioService dioService,
    this.useStaticData = true, // Default to using static data
  }) : _dioService = dioService;

  // Create a new plan
  Future<Either<Failure, Map<String, dynamic>>> createPlan(String title) async {
    if (useStaticData) {
      try {
        final newPlan = StaticWorkoutsData.createPlan(title);
        return Right(newPlan.toJson());
      } catch (e) {
        return Left(BadRequestFailure(message: 'Failed to create plan: $e'));
      }
    }

    try {
      final response = await _dioService.post(
        '/plans',
        data: {'title': title},
      );
      return Right(response.data);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // Create a new workout in a plan
  Future<Either<Failure, Map<String, dynamic>>> createWorkout(
      String planId, String title) async {
    if (useStaticData) {
      try {
        final newWorkout = StaticWorkoutsData.createWorkout(planId, title);
        return Right(newWorkout.toJson());
      } catch (e) {
        return Left(BadRequestFailure(message: 'Failed to create workout: $e'));
      }
    }

    try {
      final response = await _dioService.post(
        '/workouts',
        data: {
          'planId': planId,
          'title': title,
        },
      );
      return Right(response.data);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // Get all exercises
  Future<Either<Failure, List<Map<String, dynamic>>>> getExercises() async {
    if (useStaticData) {
      try {
        final exercises = StaticWorkoutsData.getAllExercises();
        return Right(exercises.map((e) => e.toJson()).toList());
      } catch (e) {
        return Left(BadRequestFailure(message: 'Failed to get exercises: $e'));
      }
    }

    try {
      final response = await _dioService.get('/exercises');
      return Right(
          List<Map<String, dynamic>>.from(response.data['data'] ?? []));
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // Add exercise to workout
  Future<Either<Failure, Map<String, dynamic>>> addExerciseToWorkout(
      String workoutId, String exerciseId) async {
    if (useStaticData) {
      try {
        // In static data, we'll just return the exercise data
        final allExercises = StaticWorkoutsData.getAllExercises();
        final exercise = allExercises.firstWhere((e) => e.id == exerciseId);
        return Right(exercise.toJson());
      } catch (e) {
        return Left(BadRequestFailure(message: 'Failed to add exercise: $e'));
      }
    }

    try {
      final response = await _dioService.post(
        '/workouts/$workoutId/exercises',
        data: {'exerciseId': exerciseId},
      );
      return Right(response.data);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // Add set to exercise
  Future<Either<Failure, Map<String, dynamic>>> addSetToExercise(
      String workoutId, String exerciseId, Map<String, dynamic> setData) async {
    if (useStaticData) {
      try {
        final newSet = StaticWorkoutsData.createSet(
          exerciseId: exerciseId,
          reps: setData['reps'],
          weight: setData['weight'],
          restTime: setData['restTime'],
        );
        return Right(newSet.toJson());
      } catch (e) {
        return Left(BadRequestFailure(message: 'Failed to add set: $e'));
      }
    }

    try {
      final response = await _dioService.post(
        '/workouts/$workoutId/exercises/$exerciseId/sets',
        data: setData,
      );
      return Right(response.data);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // Get all plans
  Future<Either<Failure, List<Map<String, dynamic>>>> getPlans() async {
    if (useStaticData) {
      try {
        final plans = StaticWorkoutsData.getPlans();
        return Right(plans.map((p) => p.toJson()).toList());
      } catch (e) {
        return Left(BadRequestFailure(message: 'Failed to get plans: $e'));
      }
    }

    try {
      final response = await _dioService.get('/plans');
      return Right(
          List<Map<String, dynamic>>.from(response.data['data'] ?? []));
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // Get workouts for a plan
  Future<Either<Failure, List<Map<String, dynamic>>>> getWorkoutsForPlan(
      String planId) async {
    if (useStaticData) {
      try {
        final workouts = StaticWorkoutsData.getWorkoutsForPlan(planId);
        return Right(workouts.map((w) => w.toJson()).toList());
      } catch (e) {
        return Left(BadRequestFailure(message: 'Failed to get workouts: $e'));
      }
    }

    try {
      final response = await _dioService.get('/plans/$planId/workouts');
      return Right(
          List<Map<String, dynamic>>.from(response.data['data'] ?? []));
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // Get exercises for a workout
  Future<Either<Failure, List<Map<String, dynamic>>>> getExercisesForWorkout(
      String workoutId) async {
    if (useStaticData) {
      try {
        final exercises = StaticWorkoutsData.getExercisesForWorkout(workoutId);
        return Right(exercises.map((e) => e.toJson()).toList());
      } catch (e) {
        return Left(
            BadRequestFailure(message: 'Failed to get workout exercises: $e'));
      }
    }

    try {
      final response = await _dioService.get('/workouts/$workoutId/exercises');
      return Right(
          List<Map<String, dynamic>>.from(response.data['data'] ?? []));
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // Get sets for an exercise
  Future<Either<Failure, List<Map<String, dynamic>>>> getSetsForExercise(
      String workoutId, String exerciseId) async {
    if (useStaticData) {
      try {
        final sets =
            StaticWorkoutsData.getSetsForExercise(workoutId, exerciseId);
        return Right(sets.map((s) => s.toJson()).toList());
      } catch (e) {
        return Left(BadRequestFailure(message: 'Failed to get sets: $e'));
      }
    }

    try {
      final response = await _dioService
          .get('/workouts/$workoutId/exercises/$exerciseId/sets');
      return Right(
          List<Map<String, dynamic>>.from(response.data['data'] ?? []));
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
