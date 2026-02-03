import 'package:easy_localization/easy_localization.dart';
import '../services/google_sign_in_service.dart';
import '../../../../core/error/failures.dart';

/// Handles Google Sign-In errors and converts them to user-friendly localized messages
class GoogleSignInErrorHandler {
  /// Converts various error types to localized failure messages
  static Failure handleError(dynamic error) {
    if (error is GoogleSignInException) {
      return _handleGoogleSignInException(error);
    } else if (error is Exception) {
      final message = error.toString().toLowerCase();

      // Check for specific error patterns
      if (message.contains('cancel') || message.contains('cancelled')) {
        return ServerFailure(message: 'auth.google_sign_in_cancelled'.tr());
      }

      if (message.contains('network') || message.contains('internet')) {
        return ConnectionFailure(message: 'auth.google_sign_in_network_error'.tr());
      }

      if (message.contains('sign_in_aborted')) {
        return ServerFailure(message: 'auth.google_sign_in_cancelled'.tr());
      }
    }

    // Default error message
    return ServerFailure(message: 'auth.google_sign_in_failed'.tr());
  }

  static Failure _handleGoogleSignInException(GoogleSignInException error) {
    switch (error.code) {
      case 'sign_in_canceled':
        return ServerFailure(message: 'auth.google_sign_in_cancelled'.tr());
      case 'sign_in_failed':
        return ServerFailure(message: 'auth.google_sign_in_failed'.tr());
      case 'network_error':
        return ConnectionFailure(message: 'auth.google_sign_in_network_error'.tr());
      case 'developer_error':
        return ServerFailure(message: 'auth.google_sign_in_developer_error'.tr());
      case 'sign_in_in_progress':
        return ServerFailure(message: 'auth.google_sign_in_in_progress'.tr());
      case 'internal_error':
        return ServerFailure(message: 'auth.google_sign_in_internal_error'.tr());
      default:
        return ServerFailure(message: 'auth.google_sign_in_failed'.tr());
    }
  }
}
