import 'package:flutter/material.dart';
import 'package:trackletics/core/showcase/tour_coordinator.dart';

/// Helper class for showcase-related utilities
class ShowcaseHelper {
  /// Manually trigger the showcase tour (useful for testing or help button)
  static Future<void> startTour({
    required Function(int) navigateToTab,
  }) async {
    await TourCoordinator.instance.forceTour(
      navigateToTab: navigateToTab,
    );
  }

  /// Check if tour should be shown
  static Future<bool> shouldShowTour() async {
    return await TourCoordinator.instance.shouldShowTour();
  }

  /// Reset the tour (for testing)
  static Future<void> resetTour() async {
    await TourCoordinator.instance.resetTourState();
  }

  /// Add a floating action button for testing the showcase
  static Widget buildTestShowcaseButton(Function(int) navigateToTab) {
    return Positioned(
      top: 50,
      right: 20,
      child: FloatingActionButton.small(
        onPressed: () => startTour(navigateToTab: navigateToTab),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.help_outline, color: Colors.white),
      ),
    );
  }
}
