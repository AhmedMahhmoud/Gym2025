import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();

  // Storage Keys
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';

  // Write Methods
  static Future<void> setHasSeenOnboarding(bool value) async {
    await _storage.write(key: _hasSeenOnboardingKey, value: value.toString());
  }

  // Read Methods
  static Future<bool> getHasSeenOnboarding() async {
    final value = await _storage.read(key: _hasSeenOnboardingKey);
    return value == 'true';
  }

  // Delete Methods
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
