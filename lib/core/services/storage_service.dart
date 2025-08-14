import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum StorageType {
  secure,
  nonSecure,
}

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const _secureStorage = FlutterSecureStorage();
  SharedPreferences? _prefs;

  // Initialize SharedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Storage Keys
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';
  static const String _authTokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  static const String _themeModeKey = 'theme_mode';
  static const String _languageKey = 'language';

  // Write Methods
  Future<void> write({
    required String key,
    required dynamic value,
    StorageType type = StorageType.nonSecure,
  }) async {
    if (type == StorageType.secure) {
      await _secureStorage.write(key: key, value: value.toString());
    } else {
      if (_prefs == null) await init();
      if (value is String) {
        await _prefs!.setString(key, value);
      } else if (value is bool) {
        await _prefs!.setBool(key, value);
      } else if (value is int) {
        await _prefs!.setInt(key, value);
      } else if (value is double) {
        await _prefs!.setDouble(key, value);
      } else if (value is List<String>) {
        await _prefs!.setStringList(key, value);
      }
    }
  }

  // Read Methods
  Future<T?> read<T>({
    required String key,
    StorageType type = StorageType.nonSecure,
    T? defaultValue,
  }) async {
    if (type == StorageType.secure) {
      final value = await _secureStorage.read(key: key);
      if (value == null) return defaultValue;
      return _convertValue<T>(value, defaultValue);
    } else {
      if (_prefs == null) await init();
      if (T == String) {
        return _prefs!.getString(key) as T? ?? defaultValue;
      } else if (T == bool) {
        return _prefs!.getBool(key) as T? ?? defaultValue;
      } else if (T == int) {
        return _prefs!.getInt(key) as T? ?? defaultValue;
      } else if (T == double) {
        return _prefs!.getDouble(key) as T? ?? defaultValue;
      } else if (T == List<String>) {
        return _prefs!.getStringList(key) as T? ?? defaultValue;
      }
      return defaultValue;
    }
  }

  Future<void> checkForAppUpdateAndClearIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final currentVersion = (await PackageInfo.fromPlatform()).version;
    final savedVersion = prefs.getString('app_version');

    if (savedVersion != currentVersion) {
      await prefs.clear();
      await const FlutterSecureStorage().deleteAll();
      await prefs.setString('app_version', currentVersion);
    }
  }

  // Delete Methods
  Future<void> delete({
    required String key,
    StorageType type = StorageType.nonSecure,
  }) async {
    if (type == StorageType.secure) {
      await _secureStorage.delete(key: key);
    } else {
      if (_prefs == null) await init();
      await _prefs!.remove(key);
    }
  }

  // Clear All Data
  Future<void> clearAll({StorageType type = StorageType.nonSecure}) async {
    if (type == StorageType.secure) {
      await _secureStorage.deleteAll();
    } else {
      if (_prefs == null) await init();
      await _prefs!.clear();
    }
  }

  // Helper method to convert string values to appropriate types
  T? _convertValue<T>(String value, T? defaultValue) {
    if (T == String) {
      return value as T;
    } else if (T == bool) {
      return (value == 'true') as T;
    } else if (T == int) {
      return int.tryParse(value) as T? ?? defaultValue;
    } else if (T == double) {
      return double.tryParse(value) as T? ?? defaultValue;
    }
    return defaultValue;
  }

  // Convenience Methods for Common Operations

  // Auth Token
  Future<void> setAuthToken(String token) async {
    await write(key: _authTokenKey, value: token, type: StorageType.secure);
    log('auth cached token');
  }

  Future<String?> getAuthToken() async {
    return await read<String>(key: _authTokenKey, type: StorageType.secure);
  }

  // User ID
  Future<void> setUserId(String userId) async {
    await write(key: _userIdKey, value: userId, type: StorageType.secure);
  }

  Future<String?> getUserId() async {
    return await read<String>(key: _userIdKey, type: StorageType.secure);
  }

  // User Email
  Future<void> setUserEmail(String email) async {
    await write(key: _userEmailKey, value: email, type: StorageType.secure);
  }

  Future<String?> getUserEmail() async {
    return await read<String>(key: _userEmailKey, type: StorageType.secure);
  }

  // User Name
  Future<void> setUserName(String name) async {
    await write(key: _userNameKey, value: name, type: StorageType.secure);
  }

  Future<String?> getUserName() async {
    return await read<String>(key: _userNameKey, type: StorageType.secure);
  }

  // Theme Mode
  Future<void> setThemeMode(String themeMode) async {
    await write(key: _themeModeKey, value: themeMode);
  }

  Future<String?> getThemeMode() async {
    return await read<String>(key: _themeModeKey, defaultValue: 'system');
  }

  // Language
  Future<void> setLanguage(String language) async {
    await write(key: _languageKey, value: language);
  }

  Future<String?> getLanguage() async {
    return await read<String>(key: _languageKey, defaultValue: 'en');
  }

  // Onboarding
  Future<void> setHasSeenOnboarding(bool value) async {
    await write(key: _hasSeenOnboardingKey, value: value);
  }

  Future<bool> getHasSeenOnboarding() async {
    return await read<bool>(key: _hasSeenOnboardingKey, defaultValue: false) ??
        false;
  }

  // Clear User Data
  Future<void> clearUserData() async {
    await delete(key: _authTokenKey, type: StorageType.secure);
    await delete(key: _userIdKey, type: StorageType.secure);
    await delete(key: _userEmailKey, type: StorageType.secure);
    await delete(key: _userNameKey, type: StorageType.secure);
  }

  // Clear All Data (both secure and non-secure)
  Future<void> clearAllData() async {
    await clearAll(type: StorageType.secure);
    await clearAll(type: StorageType.nonSecure);
  }

  // Clear only user-related data while preserving app settings
  Future<void> clearUserDataOnly() async {
    // Clear secure storage (tokens, user data)
    await clearAll(type: StorageType.secure);

    // Clear only user-related data from non-secure storage
    // Preserve onboarding status, theme, language, etc.
    if (_prefs == null) await init();

    // List of keys to preserve (app settings)
    final keysToPreserve = [
      _hasSeenOnboardingKey,
      _themeModeKey,
      _languageKey,
      'app_version', // Preserve app version
    ];

    // Get all keys
    final allKeys = _prefs!.getKeys();

    // Remove only user-related keys, preserve app settings
    for (final key in allKeys) {
      if (!keysToPreserve.contains(key)) {
        await _prefs!.remove(key);
      }
    }
  }
}
