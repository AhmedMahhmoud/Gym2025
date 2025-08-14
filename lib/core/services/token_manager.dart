import 'dart:developer';
import 'package:trackletics/core/services/storage_service.dart';
import 'package:trackletics/core/services/jwt_service.dart';

class TokenManager {
  static final TokenManager _instance = TokenManager._internal();
  factory TokenManager() => _instance;
  TokenManager._internal();

  String? _cachedToken;
  String? _cachedGender;
  List<String>? _cachedRoles;
  final StorageService _storage = StorageService();
  final JwtService _jwtService = JwtService();

  Future<String?> getToken() async {
    if (_cachedToken != null) {
      log('TokenManager: Returning cached token');
      return _cachedToken;
    }

    _cachedToken = await _storage.getAuthToken();
    log('TokenManager: Fetched token from storage: ${_cachedToken != null ? "Token exists" : "No token"}');

    // Populate cached claims on first read
    if (_cachedToken != null && _cachedToken!.isNotEmpty) {
      _populateClaimsFromToken(_cachedToken!);
    }

    return _cachedToken;
  }

  Future<void> setToken(String token) async {
    log('TokenManager: Setting new token');
    _cachedToken = token;
    await _storage.setAuthToken(token);
    log('TokenManager: Token cached and stored successfully');

    // Populate cached claims when token changes
    _populateClaimsFromToken(token);
  }

  Future<void> clearToken() async {
    log('TokenManager: Clearing token');
    _cachedToken = null;
    _cachedGender = null;
    _cachedRoles = null;
    await _storage.delete(key: 'auth_token', type: StorageType.secure);
    log('TokenManager: Token cleared from cache and storage');
  }

  void _populateClaimsFromToken(String token) {
    final userData = _jwtService.extractUserData(token);
    _cachedGender = userData?.gender;
    _cachedRoles = userData?.roles;
    log('TokenManager: Cached claims -> gender: ${_cachedGender ?? 'null'}, roles: ${_cachedRoles?.join(',') ?? '[]'}');
  }

  /// Returns cached gender if available, otherwise decodes it from token and caches it
  Future<String?> getGender() async {
    if (_cachedGender != null) return _cachedGender;
    final token = await getToken();
    if (token == null || token.isEmpty) return null;
    _populateClaimsFromToken(token);
    return _cachedGender;
  }

  /// Returns cached roles if available, otherwise decodes them from token and caches
  Future<List<String>> getRoles() async {
    if (_cachedRoles != null) return _cachedRoles!;
    final token = await getToken();
    if (token == null || token.isEmpty) return <String>[];
    _populateClaimsFromToken(token);
    return _cachedRoles ?? <String>[];
  }
}
