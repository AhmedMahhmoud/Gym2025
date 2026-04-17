import 'dart:io';

import 'package:flutter/services.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../models/apple_sign_in_model.dart';

/// Service responsible for Sign in with Apple (iOS / macOS native flow)
abstract class AppleSignInService {
  Future<AppleSignInModel> signIn();
}

class AppleSignInServiceImpl implements AppleSignInService {
  @override
  Future<AppleSignInModel> signIn() async {
    if (!Platform.isIOS && !Platform.isMacOS) {
      throw AppleSignInException(
        'unsupported_platform',
        'Sign in with Apple is only available on iOS and macOS',
      );
    }

    try {
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        throw AppleSignInException(
          'not_available',
          'Sign in with Apple is not available on this device',
        );
      }

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final email = credential.email ?? '';
      final given = credential.givenName ?? '';
      final family = credential.familyName ?? '';
      final displayName = [given, family]
          .where((s) => s.isNotEmpty)
          .join(' ')
          .trim();

      final userId = credential.userIdentifier;
      if (userId == null || userId.isEmpty) {
        throw AppleSignInException(
          'invalid_credential',
          'Missing Apple user identifier',
        );
      }

      return AppleSignInModel(
        email: email,
        displayName: displayName,
        id: userId,
        photoUrl: null,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw AppleSignInException(
          'sign_in_canceled',
          'Apple sign-in was canceled by user',
        );
      }
      throw AppleSignInException(
        e.code.name,
        e.message,
      );
    } on PlatformException catch (e) {
      final code = e.code.toLowerCase();
      if (code.contains('cancel') || code == '1001') {
        throw AppleSignInException(
          'sign_in_canceled',
          'Apple sign-in was canceled by user',
        );
      }
      throw AppleSignInException(
        e.code,
        e.message ?? e.toString(),
      );
    } catch (e) {
      if (e is AppleSignInException) rethrow;
      throw AppleSignInException('unknown', e.toString());
    }
  }
}

/// Custom exception for Sign in with Apple errors
class AppleSignInException implements Exception {
  AppleSignInException(this.code, this.message);

  final String code;
  final String message;
}
