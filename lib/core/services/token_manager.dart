import 'dart:developer';
import 'package:gym/core/services/storage_service.dart';

class TokenManager {
  static final TokenManager _instance = TokenManager._internal();
  factory TokenManager() => _instance;
  TokenManager._internal();

  String? _cachedToken;
  final StorageService _storage = StorageService();

  Future<String?> getToken() async {
    if (_cachedToken != null) {
      log('TokenManager: Returning cached token');
      return _cachedToken;
    }

    _cachedToken = await _storage.getAuthToken();
    log('TokenManager: Fetched token from storage: ${_cachedToken != null ? "Token exists" : "No token"}');
    return _cachedToken;
  }

  Future<void> setToken(String token) async {
    log('TokenManager: Setting new token');
    _cachedToken = token;
    await _storage.setAuthToken(token);
    log('TokenManager: Token cached and stored successfully');
  }

  Future<void> clearToken() async {
    log('TokenManager: Clearing token');
    _cachedToken = null;
    await _storage.delete(key: 'auth_token', type: StorageType.secure);
    log('TokenManager: Token cleared from cache and storage');
  }
}
