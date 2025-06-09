import 'package:dartz/dartz.dart';
import 'package:gym/core/error/failures.dart';
import 'package:gym/core/network/dio_service.dart';
import 'package:gym/core/network/error_handler.dart';
import 'package:gym/features/workouts/data/models/plan_response.dart';
import 'package:gym/features/workouts/data/models/set_model.dart';
import 'package:gym/features/workouts/data/static_data_provider.dart';
import 'package:gym/features/exercises/data/models/exercises.dart';
import 'package:gym/features/workouts/data/models/workout_model.dart';
import 'package:dio/dio.dart';

class WorkoutsRepository {
  final DioService _dioService;
  final bool useStaticData;

  WorkoutsRepository({
    required DioService dioService,
    this.useStaticData = true, // Default to using static data
  }) : _dioService = dioService;

  // Create a new plan
  Future<Either<Failure, PlanResponse>> createPlan(String title,
      {String? notes}) async {
    try {
      final response = await _dioService.post(
        '/api/Plans',
        data: {
          'title': title,
          if (notes != null) 'notes': notes,
        },
      );
      return Right(PlanResponse.fromJson(response.data));
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // Create a new workout in a plan
  Future<Either<Failure, WorkoutModel>> createWorkout(
      String planId, String title,
      {String? notes}) async {
    try {
      final response = await _dioService.post(
        '/api/Workouts',
        data: {
          'title': title,
          'planId': planId,
          if (notes != null) 'notes': notes, // Add notes to request if not null
        },
      );

      return Right(WorkoutModel.fromJson(response.data));
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

  Future<Either<Failure, void>> deleteWorkoutExercise(
      String workoutExcId) async {
    try {
      await _dioService.delete('/api/Workouts/exercise/$workoutExcId');
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // Add set to exercise
  // Add set to exercise
  Future<Either<Failure, List<SetModel>>> addSetToExercise(
    String workoutExerciseId,
    Map<String, dynamic> setData,
  ) async {
    try {
      final response = await _dioService.post(
        '/api/Workouts/exercise/$workoutExerciseId/sets',
        data: {
          'weight': setData['weight'],
          'repetitions': setData['repetitions'],
          'duration': setData['duration'],
          if (setData['restTime'] != null) 'restTime': setData['restTime'],
          if (setData['note'] != null) 'note': setData['note'],
          if (setData['timeUnitId'] != null)
            'timeUnitId': setData['timeUnitId'],
          if (setData['weightUnitId'] != null)
            'weightUnitId': setData['weightUnitId'],
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse the single set response
        final set = SetModel.fromJson({
          ...response.data,
          'workoutExerciseId': workoutExerciseId,
        });
        return Right([set]); // Return as a list with single item
      }
      return Left(BadRequestFailure(message: 'Failed to add set'));
    } catch (e) {
      return Left(BadRequestFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<SetModel>>> addDurationSetToExercise({
    required String workoutExerciseId,
    required Map<String, dynamic> setData,
  }) async {
    try {
      final response = await _dioService.post(
        '/api/Workouts/exercise/$workoutExerciseId/sets',
        data: {
          'weight': setData['weight'],
          'duration': setData['duration'],
          if (setData['restTime'] != null) 'restTime': setData['restTime'],
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final set = SetModel.fromJson({
          ...response.data,
          'workoutExerciseId': workoutExerciseId,
        });
        return Right([set]);
      }
      return Left(BadRequestFailure(message: 'Failed to add set'));
    } catch (e) {
      return Left(BadRequestFailure(message: e.toString()));
    }
  }

  // Get all plans
  Future<Either<Failure, List<PlanResponse>>> getPlans() async {
    try {
      final response = await _dioService.get('/api/Plans');
      return Right(PlanResponse.fromJsonList(response.data));
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // Get workouts for a plan
  Future<Either<Failure, List<WorkoutModel>>> getWorkoutsForPlan(
      String planId) async {
    try {
      final response = await _dioService.get('/api/Workouts/$planId');
      final List<dynamic> workoutsData = response.data;
      final workouts = workoutsData
          .map((workout) => WorkoutModel.fromJson(workout))
          .toList();
      return Right(workouts);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // Get exercises for a workout
  Future<Either<Failure, List<Map<String, dynamic>>>> getExercisesForWorkout(
      String workoutId) async {
    try {
      final response = await _dioService.get('/api/Workouts/$workoutId');
      final workout = WorkoutModel.fromJson(response.data);
      return Right(workout.workoutExercises
          .map((we) => we.exercise?.toJson() ?? {})
          .toList());
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // Update set
  Future<Either<Failure, List<SetModel>>> updateSet(
    String workoutExerciseId,
    String setId,
    Map<String, dynamic> setData,
  ) async {
    try {
      final response = await _dioService.put(
        '/api/Workouts/set/$setId',
        data: {
          'weight': setData['weight'],
          'repetitions': setData['repetitions'],
          'duration': setData['duration'],
          if (setData['restTime'] != null) 'restTime': setData['restTime'],
          if (setData['note'] != null) 'note': setData['note'],
          if (setData['timeUnitId'] != null)
            'timeUnitId': setData['timeUnitId'],
          if (setData['weightUnitId'] != null)
            'weightUnitId': setData['weightUnitId'],
        },
      );

      if (response.statusCode == 200) {
        final set = SetModel.fromJson({
          ...response.data,
          'workoutExerciseId': workoutExerciseId,
        });
        return Right([set]);
      }
      return Left(BadRequestFailure(message: 'Failed to update set'));
    } catch (e) {
      return Left(BadRequestFailure(message: e.toString()));
    }
  }

  // Delete set

  Future<Either<Failure, void>> deleteSet(
    String setId,
  ) async {
    try {
      await _dioService.delete(
        '/api/Workouts/set/$setId',
      );
      return Right([]); // Return empty list after successful deletion
    } catch (e) {
      return Left(BadRequestFailure(message: e.toString()));
    }
  }

  // Delete plan
  Future<Either<Failure, void>> deletePlan(String planId) async {
    try {
      final response = await _dioService.delete('/api/Plans/$planId');
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // Delete workout
  Future<Either<Failure, void>> deleteWorkout(String workoutId) async {
    try {
      await _dioService.delete('/api/Workouts/$workoutId');
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // Add multiple exercises to workout
  Future<Either<Failure, List<WorkoutExercise>>> addExercisesToWorkout(
    String workoutId,
    List<String> exerciseIds,
  ) async {
    try {
      final response = await _dioService.post(
        '/api/Workouts/$workoutId/exercises',
        data: {'ExerciseId': exerciseIds, 'CustomExerciseId': []},
      );

      final List<dynamic> exercisesData = response.data;
      return Right(exercisesData
          .map((e) => WorkoutExercise.fromAddingWorkoutExercise(e))
          .toList());
    } catch (e) {
      print(e.toString());
      return Left(ErrorHandler.handle(e));
    }
  }

  Future<Either<Failure, WorkoutModel>> getWorkout(String workoutId) async {
    try {
      final response = await _dioService.get('/workouts/$workoutId');
      return Right(WorkoutModel.fromJson(response.data));
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Failed to get workout'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
