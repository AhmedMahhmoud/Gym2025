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
    // Default message if data is null, not a map, or doesn't contain 'message'
    String defaultMessage;
    String? message =
        (data is Map<String, dynamic> && data.containsKey('message'))
            ? data['message'] as String?
            : null;

    switch (statusCode) {
      case 400:
        defaultMessage = 'Bad request';
        return BadRequestFailure(
          message: message ?? defaultMessage,
          statusCode: statusCode,
        );
      case 401:
        defaultMessage = 'Unauthorized access';
        return UnauthorizedFailure(
          message: message ?? defaultMessage,
        );
      case 404:
        defaultMessage = 'Resource not found';
        return NotFoundFailure(
          message: message ?? defaultMessage,
        );
      default:
        defaultMessage = 'Server error';
        return ServerFailure(
          message: message ?? defaultMessage,
          statusCode: statusCode,
        );
    }
  }
}
