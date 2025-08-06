import 'package:flutter/material.dart';
import 'package:trackletics/main.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:trackletics/core/services/showcase_service.dart';
import 'package:trackletics/core/showcase/showcase_keys.dart';

class ShowcaseManager {
  static ShowcaseManager? _instance;
  static ShowcaseManager get instance =>
      _instance ??= ShowcaseManager._internal();

  ShowcaseManager._internal();

  final ShowcaseService _showcaseService = ShowcaseService.instance;

  /// Start the showcase tour
  Future<void> startTour() async {
    // Check if tour was already completed
    bool hasCompleted = await _showcaseService.hasCompletedTour();
    if (hasCompleted) return;

    await Future.delayed(
        const Duration(milliseconds: 500)); // Allow UI to settle

    if (navKey.currentState!.context.mounted) {
      ShowCaseWidget.of(navKey.currentState!.context).startShowCase([
        ShowcaseKeys.exerciseSearchField,
        ShowcaseKeys.exerciseFilterButton,
        ShowcaseKeys.allExercisesTab,
      ]);
    }
  }

  /// Continue tour to workouts section
  Future<void> continueToWorkouts(Function() navigateToWorkouts) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Navigate to workouts tab
    navigateToWorkouts();

    await Future.delayed(const Duration(milliseconds: 500));

    if (navKey.currentState!.context.mounted) {
      ShowCaseWidget.of(navKey.currentState!.context).startShowCase([
        ShowcaseKeys.addPlanButton,
      ]);
    }
  }

  /// Continue tour to profile section
  Future<void> continueToProfile(
      BuildContext context, Function() navigateToProfile) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Navigate to profile tab
    navigateToProfile();

    await Future.delayed(const Duration(milliseconds: 500));

    if (context.mounted) {
      ShowCaseWidget.of(navKey.currentState!.context).startShowCase([
        ShowcaseKeys.profileInfo,
      ]);
    }
  }

  /// Mark tour as completed
  Future<void> completeTour() async {
    await _showcaseService.markTourCompleted();
  }

  /// Force start tour (for demo or help)
  Future<void> forceTour() async {
    await _showcaseService.resetTour();
    await startTour();
  }

  /// Check if user should see the tour
  Future<bool> shouldShowTour() async {
    return !(await _showcaseService.hasCompletedTour());
  }
}
