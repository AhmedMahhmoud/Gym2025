import 'package:dartz/dartz.dart';
import 'package:trackletics/core/error/failures.dart';
import 'package:trackletics/core/network/dio_service.dart';
import 'package:trackletics/core/network/error_handler.dart';
import 'package:trackletics/core/constants/constants.dart';
import 'package:trackletics/core/debug/api_logger_model.dart';
import 'package:trackletics/features/workouts/data/models/plan_response.dart';
import 'package:trackletics/features/workouts/data/models/set_model.dart';
import 'package:trackletics/features/exercises/data/models/exercises.dart';
import 'package:trackletics/features/workouts/data/models/workout_model.dart';
import 'package:dio/dio.dart';

class WorkoutsRepository {
  final DioService _dioService;
  final bool useStaticData;

  WorkoutsRepository({
    required DioService dioService,
    this.useStaticData = true, // Default to using static data
  }) : _dioService = dioService;

  // Create a new plan
  Future<Either<Failure, PlanResponse>> createPlan(
    String title, {
    String? notes,
    Function(ApiLoggerModel)? onLogCreated,
  }) async {
    ApiLoggerModel? logModel;
    try {
      final requestData = {
        'title': title,
        if (notes != null) 'notes': notes,
      };
      
      final response = await _dioService.post(
        '/api/Plans',
        data: requestData,
      );

      // Create log model for success
      logModel = ApiLoggerModel(
        endpoint: '/api/Plans',
        method: 'POST',
        requestData: requestData,
        statusCode: response.statusCode,
        responseData: response.data,
        requestHeaders: response.requestOptions.headers,
        responseHeaders: response.headers.map,
        baseUrl: AppConstants.baseUrl,
        fullUrl: '${AppConstants.baseUrl}/api/Plans',
      );

      // Invoke callback asynchronously
      if (onLogCreated != null) {
        Future.microtask(() => onLogCreated(logModel!));
      }

      return Right(PlanResponse.fromJson(response.data));
    } catch (e) {
      // Create log model for error
      if (e is DioException) {
        final errorLogModel = ApiLoggerModel(
          endpoint: '/api/Plans',
          method: 'POST',
          requestData: {
            'title': title,
            if (notes != null) 'notes': notes,
          },
          statusCode: e.response?.statusCode,
          responseData: e.response?.data,
          requestHeaders: e.requestOptions.headers,
          responseHeaders: e.response?.headers.map,
          errorMessage: e.message,
          errorType: 'DioException',
          baseUrl: AppConstants.baseUrl,
          fullUrl: '${AppConstants.baseUrl}/api/Plans',
        );

        if (onLogCreated != null) {
          Future.microtask(() => onLogCreated(errorLogModel));
        }
      }
      return Left(ErrorHandler.handle(e));
    }
  }

  // Create a new static plan (admin only)
  Future<Either<Failure, PlanResponse>> createStaticPlan(String title,
      {String? notes}) async {
    try {
      final response = await _dioService.post(
        '/api/Plans/static',
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
    String planId,
    String title, {
    String? notes,
    Function(ApiLoggerModel)? onLogCreated,
  }) async {
    ApiLoggerModel? logModel;
    try {
      final requestData = {
        'title': title,
        'planId': planId,
        if (notes != null) 'note': notes,
      };

      final response = await _dioService.post(
        '/api/Workouts',
        data: requestData,
      );

      // Create log model for success
      logModel = ApiLoggerModel(
        endpoint: '/api/Workouts',
        method: 'POST',
        requestData: requestData,
        statusCode: response.statusCode,
        responseData: response.data,
        requestHeaders: response.requestOptions.headers,
        responseHeaders: response.headers.map,
        baseUrl: AppConstants.baseUrl,
        fullUrl: '${AppConstants.baseUrl}/api/Workouts',
      );

      // Invoke callback asynchronously
      if (onLogCreated != null) {
        Future.microtask(() => onLogCreated(logModel!));
      }

      return Right(WorkoutModel.fromJson(response.data));
    } catch (e) {
      // Create log model for error
      if (e is DioException) {
        final errorLogModel = ApiLoggerModel(
          endpoint: '/api/Workouts',
          method: 'POST',
          requestData: {
            'title': title,
            'planId': planId,
            if (notes != null) 'note': notes,
          },
          statusCode: e.response?.statusCode,
          responseData: e.response?.data,
          requestHeaders: e.requestOptions.headers,
          responseHeaders: e.response?.headers.map,
          errorMessage: e.message,
          errorType: 'DioException',
          baseUrl: AppConstants.baseUrl,
          fullUrl: '${AppConstants.baseUrl}/api/Workouts',
        );

        if (onLogCreated != null) {
          Future.microtask(() => onLogCreated(errorLogModel));
        }
      }
      return Left(ErrorHandler.handle(e));
    }
  }

  // Get all exercises
  Future<Either<Failure, List<Map<String, dynamic>>>> getExercises() async {
    try {
      final response = await _dioService.get('/exercises');
      
      // Check if response data is valid
      if (response.data == null) {
        return Left(ServerFailure(message: 'No data received from server'));
      }
      
      // Handle different response formats
      List<dynamic> exercisesList;
      if (response.data is List) {
        exercisesList = response.data as List;
      } else if (response.data is Map && response.data['data'] != null) {
        exercisesList = response.data['data'] as List;
      } else {
        return Left(ServerFailure(message: 'Invalid response format from server'));
      }
      
      // Safely convert to List<Map<String, dynamic>>
      try {
        final exercises = exercisesList
            .map((e) => e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e))
            .toList();
        return Right(exercises);
      } catch (e) {
        return Left(ServerFailure(
          message: 'Failed to parse exercises data: ${e.toString()}',
        ));
      }
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // Add exercise to workout
  Future<Either<Failure, Map<String, dynamic>>> addExerciseToWorkout(
      String workoutId, String exerciseId) async {
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
    Map<String, dynamic> setData, {
    Function(ApiLoggerModel)? onLogCreated,
  }) async {
    ApiLoggerModel? logModel;
    try {
      final requestData = {
        if (setData['weight'] != null) 'weight': setData['weight'],
        if (setData['repetitions'] != null)
          'repetitions': setData['repetitions'],
        if (setData['duration'] != null) 'duration': setData['duration'],
        if (setData['restTime'] != null) 'restTime': setData['restTime'],
        if (setData['note'] != null && setData['note'].toString().isNotEmpty)
          'note': setData['note'],
        if (setData['restTimeUnitId'] != null)
          'restTimeUnitId': setData['restTimeUnitId'],
        if (setData['durationTimeUnitId'] != null)
          'durationTimeUnitId': setData['durationTimeUnitId'],
        if (setData['weightUnitId'] != null)
          'weightUnitId': setData['weightUnitId'],
      };

      final endpoint = '/api/Workouts/exercise/$workoutExerciseId/sets';
      final baseUrl = AppConstants.baseUrl;
      final fullUrl = '$baseUrl$endpoint';

      print(
          '╔═══════════════════════════════════════════════════════════════════════════╗');
      print(
          '║ ADD SET REQUEST                                                           ║');
      print(
          '╠═══════════════════════════════════════════════════════════════════════════╣');
      print('║ Endpoint: $endpoint                ║');
      print(
          '║ Request Data:                                                             ║');
      print('║ $requestData');
      print(
          '╚═══════════════════════════════════════════════════════════════════════════╝');

      Response? response;

      try {
        response = await _dioService.post(
          endpoint,
          data: requestData,
        );

        print(
            '╔═══════════════════════════════════════════════════════════════════════════╗');
        print(
            '║ ADD SET RESPONSE                                                          ║');
        print(
            '╠═══════════════════════════════════════════════════════════════════════════╣');
        print('║ Status Code: ${response.statusCode}');
        print(
            '║ Response Data:                                                             ║');
        print('║ ${response.data}');
        print(
            '╚═══════════════════════════════════════════════════════════════════════════╝');

        // Create log model for any response
        logModel = ApiLoggerModel(
          endpoint: endpoint,
          method: 'POST',
          requestData: requestData,
          statusCode: response.statusCode,
          responseData: response.data,
          baseUrl: baseUrl,
          fullUrl: fullUrl,
        );

        // Call callback asynchronously to avoid blocking
        if (onLogCreated != null) {
          Future.microtask(() => onLogCreated(logModel!));
        }

        if (response.statusCode == 200 || response.statusCode == 201) {
          // Parse the single set response
          final set = SetModel.fromJson({
            ...response.data,
            'workoutExerciseId': workoutExerciseId,
          });
          return Right([set]); // Return as a list with single item
        }

        // Create error log for non-success status codes
        final errorLogModel = ApiLoggerModel(
          endpoint: endpoint,
          method: 'POST',
          requestData: requestData,
          statusCode: response.statusCode,
          responseData: response.data,
          errorMessage: 'Failed to add set: Status code ${response.statusCode}',
          errorType: 'BadRequest',
          baseUrl: baseUrl,
          fullUrl: fullUrl,
        );

        if (onLogCreated != null) {
          Future.microtask(() => onLogCreated(errorLogModel));
        }

        return Left(BadRequestFailure(message: 'Failed to add set'));
      } on DioException catch (e) {
        rethrow;
      }
    } on DioException catch (e) {
      // Create log model for error
      final endpoint = '/api/Workouts/exercise/$workoutExerciseId/sets';
      final baseUrl = AppConstants.baseUrl;
      final fullUrl = '$baseUrl$endpoint';

      logModel = ApiLoggerModel(
        endpoint: endpoint,
        method: 'POST',
        requestData: {
          if (setData['weight'] != null) 'weight': setData['weight'],
          'repetitions': setData['repetitions'],
          'duration': setData['duration'] ?? 0,
          if (setData['restTime'] != null) 'restTime': setData['restTime'],
          if (setData['note'] != null) 'note': setData['note'],
          if (setData['restTimeUnitId'] != null)
            'restTimeUnitId': setData['restTimeUnitId'],
          if (setData['durationTimeUnitId'] != null)
            'durationTimeUnitId': setData['durationTimeUnitId'],
          if (setData['weightUnitId'] != null)
            'weightUnitId': setData['weightUnitId'],
        },
        statusCode: e.response?.statusCode,
        responseData: e.response?.data,
        responseHeaders: e.response?.headers.map
            .map((key, value) => MapEntry(key, value.toString())),
        errorMessage: e.message ?? e.toString(),
        errorType: e.type.toString(),
        baseUrl: baseUrl,
        fullUrl: fullUrl,
      );

      if (onLogCreated != null && logModel != null) {
        Future.microtask(() => onLogCreated(logModel!));
      }
      return Left(BadRequestFailure(message: e.toString()));
    } catch (e) {
      // Create log model for unknown error
      final endpoint = '/api/Workouts/exercise/$workoutExerciseId/sets';
      final baseUrl = AppConstants.baseUrl;
      final fullUrl = '$baseUrl$endpoint';

      logModel = ApiLoggerModel(
        endpoint: endpoint,
        method: 'POST',
        requestData: setData,
        errorMessage: e.toString(),
        errorType: 'Unknown',
        baseUrl: baseUrl,
        fullUrl: fullUrl,
      );

      if (onLogCreated != null && logModel != null) {
        Future.microtask(() => onLogCreated(logModel!));
      }
      return Left(BadRequestFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<SetModel>>> addDurationSetToExercise({
    required String workoutExerciseId,
    required Map<String, dynamic> setData,
    Function(ApiLoggerModel)? onLogCreated,
  }) async {
    ApiLoggerModel? logModel;
    try {
      final requestData = {
        if (setData['weight'] != null) 'weight': setData['weight'],
        'duration': setData['duration'],
        if (setData['restTime'] != null) 'restTime': setData['restTime'],
        if (setData['note'] != null && setData['note'].toString().isNotEmpty)
          'note': setData['note'],
        if (setData['restTimeUnitId'] != null)
          'restTimeUnitId': setData['restTimeUnitId'],
        if (setData['durationTimeUnitId'] != null)
          'durationTimeUnitId': setData['durationTimeUnitId'],
        if (setData['weightUnitId'] != null)
          'weightUnitId': setData['weightUnitId'],
      };

      final endpoint = '/api/Workouts/exercise/$workoutExerciseId/sets';
      final baseUrl = AppConstants.baseUrl;
      final fullUrl = '$baseUrl$endpoint';

      final response = await _dioService.post(
        endpoint,
        data: requestData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Create log model for success
        logModel = ApiLoggerModel(
          endpoint: endpoint,
          method: 'POST',
          requestData: requestData,
          statusCode: response.statusCode,
          responseData: response.data,
          requestHeaders: response.requestOptions.headers,
          responseHeaders: response.headers.map,
          baseUrl: baseUrl,
          fullUrl: fullUrl,
        );

        // Invoke callback asynchronously
        if (onLogCreated != null) {
          Future.microtask(() => onLogCreated(logModel!));
        }

        final set = SetModel.fromJson({
          ...response.data,
          'workoutExerciseId': workoutExerciseId,
        });
        return Right([set]);
      }
      
      // Create log model for error response
      final errorLogModel = ApiLoggerModel(
        endpoint: endpoint,
        method: 'POST',
        requestData: requestData,
        statusCode: response.statusCode,
        responseData: response.data,
        requestHeaders: response.requestOptions.headers,
        responseHeaders: response.headers.map,
        errorMessage: 'Failed to add set',
        errorType: 'BadResponse',
        baseUrl: baseUrl,
        fullUrl: fullUrl,
      );

      if (onLogCreated != null) {
        Future.microtask(() => onLogCreated(errorLogModel));
      }

      return Left(BadRequestFailure(message: 'Failed to add set'));
    } catch (e) {
      // Create log model for exception
      if (e is DioException) {
        final errorLogModel = ApiLoggerModel(
          endpoint: '/api/Workouts/exercise/$workoutExerciseId/sets',
          method: 'POST',
          requestData: {
            if (setData['weight'] != null) 'weight': setData['weight'],
            'duration': setData['duration'],
            if (setData['restTime'] != null) 'restTime': setData['restTime'],
            if (setData['note'] != null && setData['note'].toString().isNotEmpty)
              'note': setData['note'],
            if (setData['restTimeUnitId'] != null)
              'restTimeUnitId': setData['restTimeUnitId'],
            if (setData['durationTimeUnitId'] != null)
              'durationTimeUnitId': setData['durationTimeUnitId'],
            if (setData['weightUnitId'] != null)
              'weightUnitId': setData['weightUnitId'],
          },
          statusCode: e.response?.statusCode,
          responseData: e.response?.data,
          requestHeaders: e.requestOptions.headers,
          responseHeaders: e.response?.headers.map,
          errorMessage: e.message,
          errorType: 'DioException',
          baseUrl: AppConstants.baseUrl,
          fullUrl: '${AppConstants.baseUrl}/api/Workouts/exercise/$workoutExerciseId/sets',
        );

        if (onLogCreated != null) {
          Future.microtask(() => onLogCreated(errorLogModel));
        }
      }
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
          if (setData['weight'] != null) 'weight': setData['weight'],
          'repetitions': setData['repetitions'],
          'duration': setData['duration'] ?? 0,
          if (setData['restTime'] != null) 'restTime': setData['restTime'],
          if (setData['note'] != null) 'note': setData['note'],
          if (setData['restTimeUnitId'] != null)
            'restTimeUnitId': setData['restTimeUnitId'],
          if (setData['durationTimeUnitId'] != null)
            'durationTimeUnitId': setData['durationTimeUnitId'],
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
    List<String> exerciseIds, {
    List<String> customExerciseIds = const [],
    Function(ApiLoggerModel)? onLogCreated,
  }) async {
    ApiLoggerModel? logModel;
    try {
      // Create copies of the lists to avoid reference issues
      final requestData = {
        'ExerciseId': List<String>.from(exerciseIds),
        'CustomExerciseId': List<String>.from(customExerciseIds),
      };

      final response = await _dioService.post(
        '/api/Workouts/$workoutId/exercises',
        data: requestData,
      );

      // Create log model for success
      logModel = ApiLoggerModel(
        endpoint: '/api/Workouts/$workoutId/exercises',
        method: 'POST',
        requestData: requestData,
        statusCode: response.statusCode,
        responseData: response.data,
        requestHeaders: response.requestOptions.headers,
        responseHeaders: response.headers.map,
        baseUrl: AppConstants.baseUrl,
        fullUrl: '${AppConstants.baseUrl}/api/Workouts/$workoutId/exercises',
      );

      // Invoke callback asynchronously
      if (onLogCreated != null) {
        Future.microtask(() => onLogCreated(logModel!));
      }

      final List<dynamic> exercisesData = response.data;
      return Right(exercisesData
          .map((e) => WorkoutExercise.fromAddingWorkoutExercise(e))
          .toList());
    } catch (e) {
      // Create log model for error
      if (e is DioException) {
        final errorLogModel = ApiLoggerModel(
          endpoint: '/api/Workouts/$workoutId/exercises',
          method: 'POST',
          requestData: {
            'ExerciseId': List<String>.from(exerciseIds),
            'CustomExerciseId': List<String>.from(customExerciseIds),
          },
          statusCode: e.response?.statusCode,
          responseData: e.response?.data,
          requestHeaders: e.requestOptions.headers,
          responseHeaders: e.response?.headers.map,
          errorMessage: e.message,
          errorType: 'DioException',
          baseUrl: AppConstants.baseUrl,
          fullUrl: '${AppConstants.baseUrl}/api/Workouts/$workoutId/exercises',
        );

        if (onLogCreated != null) {
          Future.microtask(() => onLogCreated(errorLogModel));
        }
      }
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

  // Create custom exercise
  Future<Either<Failure, Exercise>> createCustomExercise({
    required String title,
    required String description,
    required String primaryMuscle,
    String? videoUrl,
  }) async {
    try {
      final response = await _dioService.post(
        '/api/customExercises',
        data: {
          'title': title,
          'description': description,
          'primaryMuscle': primaryMuscle,
          if (videoUrl != null && videoUrl.isNotEmpty) 'videoUrl': videoUrl,
        },
      );

      return Right(Exercise.fromJson(response.data));
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  Future<Either<Failure, String>> updateWorkout(
    String workoutId, {
    String? title,
    String? notes,
  }) async {
    try {
      final response = await _dioService.put(
        '/api/Workouts/UpdateWorkoutInfo/$workoutId',
        data: {
          if (title != null) 'title': title,
          if (notes != null) 'note': notes,
        },
      );
      return Right(response.data['message']);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // Update plan
  Future<Either<Failure, String>> updatePlan(
    String planId, {
    String? title,
    String? notes,
  }) async {
    try {
      final response = await _dioService.put(
        '/api/Plans/UpdatePlanInfo/$planId',
        data: {
          if (title != null) 'title': title,
          if (notes != null) 'notes': notes,
        },
      );
      return Right(response.data['message']);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // Update workout order for a plan
  Future<Either<Failure, void>> updateWorkoutOrder(
    String planId,
    List<Map<String, dynamic>> workoutOrders,
  ) async {
    try {
      await _dioService.put(
        '/api/Plans/$planId/workouts/reorder',
        data: {'workoutOrders': workoutOrders},
      );
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // Reorder exercises within a workout
  Future<Either<Failure, void>> reorderExercises(
    String workoutId,
    List<Map<String, dynamic>> exerciseOrders,
  ) async {
    try {
      await _dioService.put(
        '/api/Workouts/ReorderExercises',
        data: {
          'workoutId': workoutId,
          'exerciseOrders': exerciseOrders,
        },
      );
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
