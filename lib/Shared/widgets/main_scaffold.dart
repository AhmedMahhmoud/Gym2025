import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackletics/features/auth/view/cubit/auth_cubit.dart';
import 'package:trackletics/features/home/view/screens/home.dart';
import 'package:trackletics/features/profile/cubit/profile_cubit.dart';
import 'package:trackletics/features/profile/view/screens/profile_screen.dart';
import 'package:trackletics/features/workouts/workouts.dart';
import 'package:trackletics/main.dart';
import 'package:trackletics/shared/widgets/floating_bottom_nav_bar.dart';
import 'package:trackletics/core/showcase/tour_coordinator.dart';
import 'package:trackletics/core/showcase/showcase_keys.dart';
import 'package:trackletics/core/showcase/showcase_starter.dart';
import 'dart:async';
import 'package:showcaseview/showcaseview.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  final Map<int, bool> _initialized = {};
  bool _isInit = true;
  int _showcaseStep = 0; // 0: home, 1: workouts, 2: profile
  BuildContext? _builderContext;

  void _startShowCase(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        try {
          // Start with home screen showcase
          ShowCaseWidget.of(context).startShowCase([
            ShowcaseKeys.exerciseSearchField,
            ShowcaseKeys.exerciseFilterButton,
            ShowcaseKeys.allExercisesTab,
          ]);
          print('Showcase started successfully!');
        } catch (e) {
          print('Showcase start failed: $e');
        }
      }
    });
  }

  void _startProfileShowcase(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        try {
          // Wait longer to ensure the profile page is fully loaded
          await Future.delayed(const Duration(milliseconds: 1000));
          ShowCaseWidget.of(context).startShowCase([
            ShowcaseKeys.profileInfo,
          ]);
          print('Profile showcase started successfully!');
        } catch (e) {
          print('Profile showcase start failed: $e');
        }
      }
    });
  }

  void _fetchRequirements(BuildContext context) async {
    try {
      // Refresh ProfileCubit data when MainScaffold loads (after successful login)
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        await context.read<ProfileCubit>().forceCompleteRefresh();

        // Start showcase tour for first-time users only
        bool shouldShow = await TourCoordinator.instance.shouldShowTour();
        print('Should show tour: $shouldShow');
        if (shouldShow) {
          // START SHOWCASE WIDGET with proper context
          _startShowCase(context);
        }
      }
    } catch (e) {
      print('Error in _fetchRequirements: $e');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  // Define the navigation bar items
  final List<FloatingNavBarItem> _navItems = [
    FloatingNavBarItem(
      icon: Icons.home_rounded,
      label: 'Home',
    ),
    FloatingNavBarItem(
      icon: Icons.fitness_center_rounded,
      label: 'Workouts',
    ),
    FloatingNavBarItem(
      icon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  void _onNavItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      _initialized[index] = true; // Mark the page as initialized when accessed
    });
  }

  Widget _buildPage(int index) {
    // Only build the page if it's been initialized or is the current page
    if (!(_initialized[index] ?? false) && index != _currentIndex) {
      return const SizedBox
          .shrink(); // Return empty widget for uninitialized pages
    }

    switch (index) {
      case 0:
        return const Home();
      case 1:
        return const WorkoutsFeature();
      case 2:
        return const ProfileScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      onStart: (index, key) {
        // Called when each showcase step starts
        print('Showcase started: $key at index $index');
      },
      onComplete: (index, key) {
        // Called when each showcase step completes
        print('Showcase step completed: $key at index $index');

        // Handle multi-screen tour progression
        if (key == ShowcaseKeys.allExercisesTab && _showcaseStep == 0) {
          // Navigate to profile screen and show profile info
          _showcaseStep = 1;
          setState(() {
            _currentIndex = 2;
            _initialized[2] = true;
          });
          // Wait for navigation to complete before starting profile showcase
          if (_builderContext != null) {
            Future.delayed(const Duration(milliseconds: 500), () {
              _startProfileShowcase(_builderContext!);
            });
          }
        } else if (key == ShowcaseKeys.profileInfo && _showcaseStep == 1) {
          // Complete the tour
          TourCoordinator.instance.completeTour();
          _showcaseStep = 0; // Reset for next time
        }
      },
      blurValue: 1,
      autoPlayDelay: const Duration(seconds: 3),
      builder: (context) => Builder(
        builder: (builderContext) {
          // Store the builder context for multi-screen navigation
          _builderContext = builderContext;

          // Start showcase with the correct Builder context on first build
          if (_isInit) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _fetchRequirements(builderContext);
            });
            _isInit = false;
          }

          return Scaffold(
            body: IndexedStack(
              index: _currentIndex,
              children: List.generate(_navItems.length, _buildPage),
            ),
            bottomNavigationBar: FloatingBottomNavBar(
              currentIndex: _currentIndex,
              onTap: _onNavItemTapped,
              items: _navItems,
              backgroundColor: Theme.of(context).primaryColor,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white70,
              margin: const EdgeInsets.fromLTRB(30, 0, 30, 16),
            ),
            extendBody: true,
          );
        },
      ),
    );
  }
}
