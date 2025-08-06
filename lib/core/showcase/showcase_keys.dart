import 'package:flutter/material.dart';

/// Global keys for showcase elements throughout the app
class ShowcaseKeys {
  // Home/Exercises screen keys
  static final GlobalKey exerciseSearchField = GlobalKey();
  static final GlobalKey exerciseFilterButton = GlobalKey();
  static final GlobalKey allExercisesTab = GlobalKey();
  static final GlobalKey addCustomExerciseFAB = GlobalKey();

  // Bottom navigation keys
  static final GlobalKey bottomNavHome = GlobalKey();
  static final GlobalKey bottomNavWorkouts = GlobalKey();
  static final GlobalKey bottomNavProfile = GlobalKey();

  // Workouts screen keys
  static final GlobalKey addPlanButton = GlobalKey();
  static final GlobalKey plansList = GlobalKey();
  static final GlobalKey stickyAddPlanButton = GlobalKey();

  // Profile screen keys
  static final GlobalKey profileInfo = GlobalKey();
  static final GlobalKey profileSettings = GlobalKey();

    /// Get all keys in the order they should be showcased
  static List<GlobalKey> get tourOrder => [
    // Start with home screen
    exerciseSearchField,
    exerciseFilterButton,
    allExercisesTab,
    
    // Move to workouts
    bottomNavWorkouts,
    addPlanButton,
    
    // End with profile
    bottomNavProfile,
    profileInfo,
  ];
}
