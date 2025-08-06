import 'package:flutter/material.dart';
import 'package:trackletics/main.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:trackletics/core/showcase/showcase_keys.dart';

/// Dedicated class to handle showcase starting with proper context management
class ShowcaseStarter {
  static Future<void> startShowcase() async {
    // Wait for the widget tree to be fully built
    await Future.delayed(const Duration(milliseconds: 2000));

    if (!navKey.currentState!.context.mounted) return;

    try {
      // Multiple attempts with different timing
      for (int i = 0; i < 3; i++) {
        await Future.delayed(Duration(milliseconds: 500 * (i + 1)));
        if (navKey.currentState!.context.mounted) {
          _attemptShowcaseStart();
        }
      }
    } catch (e) {
      print('Showcase starter error: $e');
    }
  }

  static void _attemptShowcaseStart() {
    try {
      final showcaseWidget = ShowCaseWidget.of(navKey.currentState!.context);
      if (showcaseWidget != null) {
        showcaseWidget.startShowCase([
          ShowcaseKeys.exerciseSearchField,
          ShowcaseKeys.exerciseFilterButton,
          ShowcaseKeys.allExercisesTab,
        ]);
        print('Showcase started successfully!');
        return; // Exit if successful
      } else {
        print('ShowCaseWidget not found in context');
      }
    } catch (e) {
      print('Showcase start attempt failed: $e');
    }
  }
}
