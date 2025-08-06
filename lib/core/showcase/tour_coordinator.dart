import 'package:flutter/material.dart';
import 'package:trackletics/main.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:trackletics/core/services/showcase_service.dart';
import 'package:trackletics/core/showcase/showcase_keys.dart';
import 'package:trackletics/core/showcase/showcase_starter.dart';

class TourCoordinator {
  static TourCoordinator? _instance;
  static TourCoordinator get instance =>
      _instance ??= TourCoordinator._internal();

  TourCoordinator._internal();

  final ShowcaseService _showcaseService = ShowcaseService.instance;
  int _currentStep = 0;

  /// Start the complete app tour
  Future<void> startFullTour({
    required Function(int) navigateToTab,
  }) async {
    // Check if tour was already completed
    bool hasCompleted = await _showcaseService.hasCompletedTour();
    if (hasCompleted) return;

    _currentStep = 0;
    await _showHomeScreenTour();
  }

  /// Show home screen (exercises) tour
  Future<void> _showHomeScreenTour() async {
    // Use the dedicated showcase starter
    await ShowcaseStarter.startShowcase();
  }

  /// Show workouts screen tour
  Future<void> _showWorkoutsTour(
      BuildContext context, Function(int) navigateToTab) async {
    // Navigate to workouts tab
    navigateToTab(1);

    await Future.delayed(
        const Duration(milliseconds: 800)); // Allow navigation to complete

    if (context.mounted) {
      try {
        ShowCaseWidget.of(navKey.currentState!.context).startShowCase([
          ShowcaseKeys.addPlanButton,
        ]);
      } catch (e) {
        print('Showcase error: $e');
      }
    }
  }

  /// Show profile screen tour
  Future<void> _showProfileTour(
      BuildContext context, Function(int) navigateToTab) async {
    // Navigate to profile tab
    navigateToTab(2);

    await Future.delayed(
        const Duration(milliseconds: 800)); // Allow navigation to complete

    if (context.mounted) {
      try {
        ShowCaseWidget.of(navKey.currentState!.context).startShowCase([
          ShowcaseKeys.profileInfo,
        ]);
      } catch (e) {
        print('Showcase error: $e');
      }
    }
  }

  /// Complete the tour
  Future<void> completeTour() async {
    await _showcaseService.markTourCompleted();
    _currentStep = 0;
  }

  /// Force start tour (for demo or help)
  Future<void> forceTour({
    required Function(int) navigateToTab,
  }) async {
    await _showcaseService.resetTour();
    await startFullTour(navigateToTab: navigateToTab);
  }

  /// Check if user should see the tour
  Future<bool> shouldShowTour() async {
    return !(await _showcaseService.hasCompletedTour());
  }

  /// Get current tour step
  int get currentStep => _currentStep;

  /// Reset tour state (for testing)
  Future<void> resetTourState() async {
    await _showcaseService.resetTour();
  }
}
