import 'package:gym/core/services/storage_service.dart';

class TokenManager {
  static final TokenManager _instance = TokenManager._internal();
  factory TokenManager() => _instance;
  TokenManager._internal();

  String? _cachedToken;
  final StorageService _storage = StorageService();

  Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;
    _cachedToken = await _storage.getAuthToken();
    return _cachedToken;
  }

  Future<void> setToken(String token) async {
    _cachedToken = token;
    await _storage.setAuthToken(token);
  }

  Future<void> clearToken() async {
    _cachedToken = null;
    await _storage.delete(key: 'auth_token', type: StorageType.secure);
  }
}
