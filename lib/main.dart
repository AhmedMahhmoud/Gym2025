import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gym/core/network/connectivity.dart';
import 'package:gym/core/services/storage_service.dart';
import 'package:gym/core/theme/app_colors.dart';
import 'package:gym/features/auth/view/screens/auth_screen.dart';
import 'package:gym/features/home/view/screens/home.dart';
import 'package:gym/features/onboarding/screens/onboarding_screen.dart';
import 'package:gym/shared/widgets/main_scaffold.dart';
import 'core/theme/app_theme.dart';
import 'package:gym/routes/app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? _hasSeenOnboarding;
  final ConnectivityService _connectivityService = ConnectivityService();
  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final seen = await StorageService.getHasSeenOnboarding();
    log('User seen onboarding? $seen');
    setState(() {
      _hasSeenOnboarding = seen; // Update state once data is available
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _connectivityService.connectionStatusStream,
      builder: (context, snapshot) {
        bool isConnected = snapshot.data ?? true;
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            MaterialApp(
              theme: AppTheme.darkTheme,
              debugShowCheckedModeBanner: false,
              onGenerateRoute: OnPageRoute.generateRoute,
              home: _hasSeenOnboarding == null
                  ? const Scaffold(
                      backgroundColor: Colors.black,
                      body: Center(child: CircularProgressIndicator()),
                    ) // 🟡 Show loading while waiting
                  : _hasSeenOnboarding!
                      ? const MainScaffold()
                      : const OnboardingScreen(),
            ),
            Directionality(
              textDirection: TextDirection.ltr,
              child: AnimatedPositioned(
                  bottom: isConnected ? -60 : 10,
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Colors.red[600],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.network_check,
                          color: Colors.white,
                        ),
                        Center(
                          child: Text('There is no internet connection.',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  )),
            )
          ],
        );
      },
    );
  }
}
