import 'package:dio/dio.dart';
import '../error/failures.dart';

class ErrorHandler {
  static Failure handle(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    } else {
      return const ServerFailure(
        message: 'Unexpected error occurred',
      );
    }
  }

  static Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure(
          message: 'Connection timeout. Please try again.',
        );

      case DioExceptionType.connectionError:
        return const ConnectionFailure(
          message: 'No internet connection',
        );

      case DioExceptionType.badResponse:
        return _handleResponseError(
            error.response?.statusCode, error.response?.data);

      default:
        return ServerFailure(
          message: error.message ?? 'Something went wrong',
        );
    }
  }

  static Failure _handleResponseError(int? statusCode, dynamic data) {
    switch (statusCode) {
      case 400:
        return BadRequestFailure(
          message: data['message'] ?? 'Bad request',
          statusCode: statusCode,
        );
      case 401:
        return UnauthorizedFailure(
          message: data['message'] ?? 'Unauthorized access',
        );
      case 404:
        return NotFoundFailure(
          message: data['message'] ?? 'Resource not found',
        );
      default:
        return ServerFailure(
          message: data['message'] ?? 'Server error',
          statusCode: statusCode,
        );
    }
  }
}
