# Gym App Showcase Tour Implementation 🎯

This document explains the complete showcaseview implementation for guiding first-time users through the Gym app's key features.

## Overview

The showcase tour provides an interactive guided experience that highlights:
- **Home Screen**: Exercise search, filtering, and tabs
- **Workouts Screen**: Creating workout plans
- **Profile Screen**: User profile management

## Architecture

### Core Components

1. **ShowcaseService** (`lib/core/services/showcase_service.dart`)
   - Manages tour completion state using SharedPreferences
   - Tracks whether user has completed the tour

2. **ShowcaseKeys** (`lib/core/showcase/showcase_keys.dart`)
   - Contains all GlobalKey references for showcase elements
   - Defines the tour order and key elements

3. **TourCoordinator** (`lib/core/showcase/tour_coordinator.dart`)
   - Orchestrates the step-by-step tour flow
   - Handles navigation between screens during tour
   - Manages tour progression and completion

4. **ShowcaseHelper** (`lib/core/showcase/showcase_helper.dart`)
   - Utility functions for manual tour triggering
   - Testing and debugging helpers

### Implementation Details

#### Tour Flow

```
1. Home Screen (Exercises)
   ├── Search Field
   ├── Filter Button
   └── Exercise Tabs

2. Workouts Screen
   └── Add Plan Button

3. Profile Screen
   └── Profile Information Card
```

#### Key Features

- **Automatic Tour**: Triggers on first app launch
- **Step-by-Step Navigation**: Automatically moves between tabs
- **Persistent State**: Remembers tour completion
- **Manual Trigger**: Can be restarted for help/demo

## Usage

### For First-Time Users

The tour automatically starts when:
- User opens the app for the first time
- Tour completion state is `false`
- User successfully logs in

### Manual Tour Trigger

```dart
// Trigger tour manually (e.g., from help button)
await ShowcaseHelper.startTour(context, navigateToTab: (index) {
  // Handle tab navigation
});
```

### Check Tour Status

```dart
bool shouldShow = await ShowcaseHelper.shouldShowTour();
```

### Reset Tour (Testing)

```dart
await ShowcaseHelper.resetTour();
```

## Showcase Elements

### Home Screen Elements

| Element | Key | Description |
|---------|-----|-------------|
| Search Field | `exerciseSearchField` | Exercise search functionality |
| Filter Button | `exerciseFilterButton` | Exercise filtering options |
| Exercise Tabs | `allExercisesTab` | Tab navigation between exercise types |
| Add FAB | `addCustomExerciseFAB` | Add custom exercise button |

### Navigation Elements

| Element | Key | Description |
|---------|-----|-------------|
| Home Tab | `bottomNavHome` | Home navigation |
| Workouts Tab | `bottomNavWorkouts` | Workouts navigation |
| Profile Tab | `bottomNavProfile` | Profile navigation |

### Workouts Screen Elements

| Element | Key | Description |
|---------|-----|-------------|
| Add Plan Button | `addPlanButton` | Create new workout plan |
| Sticky Add Button | `stickyAddPlanButton` | Alternative add plan access |

### Profile Screen Elements

| Element | Key | Description |
|---------|-----|-------------|
| Profile Info | `profileInfo` | User profile information card |

## Integration Points

### MainScaffold Integration

The main scaffold wraps the entire app with `ShowCaseWidget` and:
- Initializes tour on app start
- Provides navigation callbacks
- Handles showcase completion events

### Screen-Specific Integration

Each screen wraps relevant UI elements with `Showcase` widgets:

```dart
Showcase(
  key: ShowcaseKeys.exerciseSearchField,
  description: 'Search for exercises by name or description!',
  title: 'Exercise Search',
  child: ExerciseSearchField(),
)
```

## Customization

### Tour Messages

Update descriptions in each `Showcase` widget:

```dart
description: 'Your custom message here!',
title: 'Feature Title',
```

### Tour Order

Modify `ShowcaseKeys.tourOrder` to change sequence:

```dart
static List<GlobalKey> get tourOrder => [
  exerciseSearchField,
  exerciseFilterButton,
  // Add or reorder as needed
];
```

### Tour Timing

Adjust delays in `TourCoordinator`:

```dart
await Future.delayed(const Duration(milliseconds: 800));
```

## Testing

### Debug Mode

Add test button for easy tour triggering:

```dart
// In your debug scaffold
ShowcaseHelper.buildTestShowcaseButton(context, navigateToTab)
```

### Reset Tour State

```dart
await ShowcaseHelper.resetTour();
```

## Troubleshooting

### Common Issues

1. **ParentDataWidget Errors**
   - Ensure `Showcase` widgets don't break parent-child relationships
   - Don't wrap `Tab` widgets directly - wrap the `TabBar` instead

2. **Tour Not Starting**
   - Check if tour completion state is properly reset
   - Verify `shouldShowTour()` returns `true`

3. **Navigation Issues**
   - Ensure navigation callbacks are properly implemented
   - Check tab initialization states

### Performance Considerations

- Tour only runs once per user (unless manually triggered)
- Minimal impact on app startup
- Uses SharedPreferences for lightweight state management

## Dependencies

- `showcaseview: ^3.0.0`
- `shared_preferences: ^2.5.3` (for state persistence)

## Future Enhancements

Potential improvements:
- Multi-language support for tour messages
- Dynamic tour content based on user type
- Analytics tracking for tour completion rates
- Conditional tours for specific features
- Tour customization settings

---

*Happy showcasing! 🎉* 