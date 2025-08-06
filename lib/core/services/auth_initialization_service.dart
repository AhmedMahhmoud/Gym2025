import 'dart:developer';
import 'package:trackletics/core/services/jwt_service.dart';
import 'package:trackletics/core/services/storage_service.dart';
import 'package:trackletics/core/services/token_manager.dart';

enum AuthInitStatus {
  checking,
  authenticated,
  unauthenticated,
  error,
}

class AuthInitializationService {
  static final AuthInitializationService _instance =
      AuthInitializationService._internal();
  factory AuthInitializationService() => _instance;
  AuthInitializationService._internal();

  final StorageService _storage = StorageService();
  final JwtService _jwtService = JwtService();
  final TokenManager _tokenManager = TokenManager();

  // App version key for storage compatibility
  static const String _appVersionKey = 'app_version';
  static const String _currentAppVersion =
      '1.0.0'; // Update this with each release

  Future<AuthInitStatus> initializeAuth() async {
    try {
      log('Starting auth initialization...');

      // Check if app version has changed
      final storedVersion = await _storage.read<String>(key: _appVersionKey);
      if (storedVersion != _currentAppVersion) {
        log('App version changed from $storedVersion to $_currentAppVersion');
        await _handleVersionChange();
        await _storage.write(key: _appVersionKey, value: _currentAppVersion);
      }

      // Get stored token
      final token = await _tokenManager.getToken();
      if (token == null || token.isEmpty) {
        log('No token found');
        return AuthInitStatus.unauthenticated;
      }

      // Validate token format and expiration
      if (_jwtService.isTokenExpired(token)) {
        log('Token is expired');
        await _clearAuthData();
        return AuthInitStatus.unauthenticated;
      }

      // Try to decode token to check if it's valid
      final userData = _jwtService.extractUserData(token);
      if (userData == null) {
        log('Invalid token format');
        await _clearAuthData();
        return AuthInitStatus.unauthenticated;
      }

      log('Token is valid, user authenticated: ${userData.email}');
      return AuthInitStatus.authenticated;
    } catch (e) {
      log('Error during auth initialization: $e');
      await _clearAuthData(); // Clear potentially corrupted data
      return AuthInitStatus.error;
    }
  }

  Future<void> _handleVersionChange() async {
    log('Handling app version change...');

    // For now, we'll preserve auth data but you can add migration logic here
    // If you need to clear data for breaking changes, uncomment the line below:
    // await _clearAuthData();

    // You can add specific migration logic here based on version changes
    // For example, migrating old storage format to new format
  }

  Future<void> _clearAuthData() async {
    log('Clearing auth data due to validation failure');
    await _tokenManager.clearToken();
    await _storage.clearUserData();
  }

  Future<bool> checkOnboardingStatus() async {
    try {
      return await _storage.getHasSeenOnboarding();
    } catch (e) {
      log('Error checking onboarding status: $e');
      return false;
    }
  }

  // Optional: Force re-authentication (useful for debugging)
  Future<void> forceReauthentication() async {
    await _clearAuthData();
  }
}
