import 'package:shared_preferences/shared_preferences.dart';

class ShowcaseService {
  static const String _showcaseCompletedKey = 'showcase_tour_completed';

  static ShowcaseService? _instance;
  static ShowcaseService get instance =>
      _instance ??= ShowcaseService._internal();

  ShowcaseService._internal();

  /// Check if the user has completed the showcase tour
  Future<bool> hasCompletedTour() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_showcaseCompletedKey) ?? false;
  }

  /// Mark the showcase tour as completed
  Future<void> markTourCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showcaseCompletedKey, true);
  }

  /// Reset the tour (for testing purposes or settings option)
  Future<void> resetTour() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showcaseCompletedKey, false);
  }

  /// Force show tour again (for demo or help purposes)
  Future<void> forceTour() async {
    await resetTour();
  }
}
