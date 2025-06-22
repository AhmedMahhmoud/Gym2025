import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym/features/home/view/screens/home.dart';
import 'package:gym/features/profile/cubit/profile_cubit.dart';
import 'package:gym/features/profile/view/screens/profile_screen.dart';
import 'package:gym/features/workouts/workouts.dart';
import 'package:gym/shared/widgets/floating_bottom_nav_bar.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({Key? key}) : super(key: key);

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  final List<bool> _initialized = [
    true,
    false,
    false
  ]; // Track initialization state

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
    if (!_initialized[index] && index != _currentIndex) {
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
  }
}
