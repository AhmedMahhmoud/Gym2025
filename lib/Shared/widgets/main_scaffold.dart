import 'package:flutter/material.dart';
import 'package:gym/features/home/view/screens/home.dart';
import 'package:gym/features/workouts/workouts.dart';
import 'package:gym/shared/widgets/floating_bottom_nav_bar.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({Key? key}) : super(key: key);

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  // Define the screens for navigation
  final List<Widget> _screens = [
    const Home(),
    const WorkoutsFeature(),
    const Scaffold(
      body: Center(child: Text('Profile Screen')),
    ),
  ];

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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: FloatingBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavItemTapped,
        items: _navItems, // Ensure the items are passed correctly
        backgroundColor: Theme.of(context).primaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        margin: const EdgeInsets.fromLTRB(30, 0, 30, 16),
      ),
      extendBody: true, // Ensure the floating effect works
    );
  }
}
