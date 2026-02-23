import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/google_sign_in_model.dart';

/// Service responsible for Google Sign-In operations
/// Follows Single Responsibility Principle - only handles Google authentication
abstract class GoogleSignInService {
  Future<GoogleSignInModel> signIn();
  Future<void> signOut();
}

class GoogleSignInServiceImpl implements GoogleSignInService {
  final GoogleSignIn _googleSignIn;

  // Web client ID from Firebase Console (OAuth 2.0 Client ID with client_type: 3)
  // This is required for Google Sign-In to work with Firebase
  static const String _serverClientId =
      '350976597492-75jp6uim9onorbrq41v174ul3eumt3q8.apps.googleusercontent.com';

  GoogleSignInServiceImpl({
    GoogleSignIn? googleSignIn,
  }) : _googleSignIn = googleSignIn ??
            GoogleSignIn(
              // Server client ID is required for backend verification
              // This is the Web client ID from Firebase Console
              serverClientId: _serverClientId,
              // Request email and profile scopes
              scopes: ['email', 'profile'],
            );

  @override
  Future<GoogleSignInModel> signIn() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in - throw a specific exception
        throw GoogleSignInException(
          'sign_in_canceled',
          'Google sign-in was canceled by user',
        );
      }

      // Return Google account information
      return GoogleSignInModel(
        email: googleUser.email,
        displayName: googleUser.displayName ?? '',
        id: googleUser.id,
        photoUrl: googleUser.photoUrl,
      );
    } on PlatformException catch (e) {
      // Handle Google Sign-In PlatformException with specific error codes
      final errorCode = e.code;
      final errorMessage = e.message ?? '';
      final errorDetails = e.details?.toString() ?? '';
      final fullError = '$errorCode $errorMessage $errorDetails'.toLowerCase();

      String code;
      String message;

      // Check for ApiException with status code 10 (DEVELOPER_ERROR)
      if (fullError.contains('apiexception') ||
          fullError.contains('api_exception') ||
          errorCode == '10' ||
          errorMessage.contains('10:') ||
          errorDetails.contains('10')) {
        code = 'developer_error';
        message =
            'Google Sign-In configuration error. Please check SHA-1 fingerprint and OAuth client setup';
      } else {
        switch (errorCode) {
          case 'sign_in_canceled':
          case 'sign_in_cancelled':
            code = 'sign_in_canceled';
            message = 'Google sign-in was canceled by user';
            break;
          case 'sign_in_failed':
            code = 'sign_in_failed';
            message = 'Failed to sign in with Google';
            break;
          case 'network_error':
            code = 'network_error';
            message = 'Network error occurred during sign-in';
            break;
          case '12500': // SIGN_IN_CURRENTLY_IN_PROGRESS
            code = 'sign_in_in_progress';
            message = 'Another sign-in is already in progress';
            break;
          case '7': // NETWORK_ERROR
            code = 'network_error';
            message = 'Network error occurred during sign-in';
            break;
          case '8': // INTERNAL_ERROR
            code = 'internal_error';
            message = 'An internal error occurred';
            break;
          default:
            code = 'sign_in_failed';
            message =
                'Failed to sign in with Google: ${e.message ?? e.toString()}';
        }
      }

      throw GoogleSignInException(code, message);
    } on GoogleSignInException {
      rethrow;
    } catch (e) {
      // Catch any unexpected errors and wrap them
      final errorString = e.toString().toLowerCase();
      String code;
      String message;

      // Check for ApiException with status code 10 (DEVELOPER_ERROR)
      if ((errorString.contains('apiexception') ||
              errorString.contains('api_exception')) &&
          (errorString.contains(': 10') ||
              errorString.contains(':10') ||
              errorString.contains(' 10'))) {
        code = 'developer_error';
        message =
            'Google Sign-In configuration error. Please check SHA-1 fingerprint and OAuth client setup';
      } else if (errorString.contains('cancel') ||
          errorString.contains('cancelled')) {
        code = 'sign_in_canceled';
        message = 'Google sign-in was canceled by user';
      } else if (errorString.contains('network') ||
          errorString.contains('internet')) {
        code = 'network_error';
        message = 'Network error occurred during sign-in';
      } else {
        code = 'sign_in_failed';
        message = 'Failed to sign in with Google: ${e.toString()}';
      }

      throw GoogleSignInException(code, message);
    }
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}

/// Custom exception for Google Sign-In errors
class GoogleSignInException implements Exception {
  final String code;
  final String message;

  GoogleSignInException(this.code, this.message);

  @override
  String toString() => message;
}
