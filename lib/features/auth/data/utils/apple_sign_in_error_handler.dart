import 'package:easy_localization/easy_localization.dart';

import '../../../../core/error/failures.dart';
import '../services/apple_sign_in_service.dart';

/// Handles Sign in with Apple errors and converts them to localized messages
class AppleSignInErrorHandler {
  static Failure handleError(Object error) {
    if (error is AppleSignInException) {
      return _handleAppleSignInException(error);
    }
    return ServerFailure(message: 'auth.apple_sign_in_failed'.tr());
  }

  static Failure _handleAppleSignInException(AppleSignInException error) {
    switch (error.code) {
      case 'sign_in_canceled':
        return ServerFailure(message: 'auth.apple_sign_in_cancelled'.tr());
      case 'not_available':
      case 'unsupported_platform':
        return ServerFailure(message: 'auth.apple_sign_in_not_available'.tr());
      default:
        return ServerFailure(message: 'auth.apple_sign_in_failed'.tr());
    }
  }
}
