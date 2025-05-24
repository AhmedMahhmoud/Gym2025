import 'package:dartz/dartz.dart';
import 'package:gym/core/error/failures.dart';
import 'package:gym/core/network/dio_service.dart';
import 'package:gym/core/network/error_handler.dart';
import 'package:gym/features/workouts/data/models/plan_response.dart';
import 'package:gym/features/workouts/data/models/set_model.dart';
import 'package:gym/features/workouts/data/static_data_provider.dart';
import 'package:gym/features/exercises/data/models/exercises.dart';

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
  Future<Either<Failure, List<SetModel>>> addSetToExercise(
    String workoutId,
    String exerciseId,
    Map<String, dynamic> setData,
  ) async {
    try {
      // Create a new set with a unique ID
      final newSet = SetModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        workoutId: workoutId,
        exerciseId: exerciseId,
        weight: setData['weight'] as double,
        reps: setData['reps'] as int?,
        duration: setData['duration'] as int?,
        restTime: setData['restTime'] as int?,
      );

      // Get existing sets and add the new one
      final existingSets =
          StaticWorkoutsData.getSetsForExercise(workoutId, exerciseId);
      final updatedSets = [...existingSets, newSet];

      // Update the static data
      StaticWorkoutsData.updateSetsForExercise(
          workoutId, exerciseId, updatedSets);

      return Right(updatedSets);
    } catch (e) {
      return Left(BadRequestFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<SetModel>>> addDurationSetToExercise({
    required String workoutId,
    required String exerciseId,
    required Map<String, dynamic> setData,
  }) async {
    try {
      // Create a new set with a unique ID
      final newSet = SetModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        workoutId: workoutId,
        exerciseId: exerciseId,
        weight: setData['weight'] as double,
        reps: setData['reps'] as int?,
        duration: setData['duration'] as int?,
        restTime: setData['restTime'] as int?,
      );

      // Get existing sets and add the new one
      final existingSets =
          StaticWorkoutsData.getSetsForExercise(workoutId, exerciseId);
      final updatedSets = [...existingSets, newSet];

      // Update the static data
      StaticWorkoutsData.updateSetsForExercise(
          workoutId, exerciseId, updatedSets);

      return Right(updatedSets);
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

  // Update set
  Future<Either<Failure, List<SetModel>>> updateSet(
    String workoutId,
    String exerciseId,
    String setId,
    Map<String, dynamic> setData,
  ) async {
    try {
      // Get existing sets
      final existingSets =
          StaticWorkoutsData.getSetsForExercise(workoutId, exerciseId);

      // Find and update the set
      final updatedSets = existingSets.map((set) {
        if (set.id == setId) {
          return SetModel(
            id: setId,
            workoutId: workoutId,
            exerciseId: exerciseId,
            weight: setData['weight'] as double,
            reps: setData['reps'] as int?,
            duration: setData['duration'] as int?,
            restTime: setData['restTime'] as int?,
          );
        }
        return set;
      }).toList();

      // Update the static data
      StaticWorkoutsData.updateSetsForExercise(
          workoutId, exerciseId, updatedSets);

      return Right(updatedSets);
    } catch (e) {
      return Left(BadRequestFailure(message: e.toString()));
    }
  }

  // Delete set
  Future<Either<Failure, List<SetModel>>> deleteSet(
    String workoutId,
    String exerciseId,
    String setId,
  ) async {
    try {
      // Get existing sets
      final existingSets =
          StaticWorkoutsData.getSetsForExercise(workoutId, exerciseId);

      // Remove the set
      final updatedSets = existingSets.where((set) => set.id != setId).toList();

      // Update the static data
      StaticWorkoutsData.updateSetsForExercise(
          workoutId, exerciseId, updatedSets);

      return Right(updatedSets);
    } catch (e) {
      return Left(BadRequestFailure(message: e.toString()));
    }
  }
}
