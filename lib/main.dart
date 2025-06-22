import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gym/core/network/connectivity.dart';
import 'package:gym/core/network/dio_service.dart';
import 'package:gym/core/services/storage_service.dart';
import 'package:gym/core/theme/app_colors.dart';
import 'package:gym/features/auth/view/screens/auth_screen.dart';
import 'package:gym/features/exercises/data/repo/exercises_repo.dart';
import 'package:gym/features/exercises/data/services/exercises_service.dart';
import 'package:gym/features/exercises/view/cubit/exercises_cubit.dart';
import 'package:gym/features/home/view/screens/home.dart';
import 'package:gym/features/onboarding/screens/onboarding_screen.dart';
import 'package:gym/features/profile/cubit/profile_cubit.dart';
import 'package:gym/shared/widgets/main_scaffold.dart';
import 'core/theme/app_theme.dart';
import 'package:gym/routes/app_routes.dart';
import 'package:gym/features/workouts/data/units_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize units service
  await UnitsService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final storage = StorageService();
  bool? _hasSeenOnboarding;
  bool? _isSignedIn;
  final ConnectivityService _connectivityService = ConnectivityService();
  @override
  void initState() {
    super.initState();
    _checkIsTokenAvailable();
  }

  Future<bool> _checkOnboardingStatus() async {
    final seen = await storage.getHasSeenOnboarding();
    log('User seen onboarding? $seen');
    return seen;
  }

  _checkIsTokenAvailable() async {
    final String? isTokenActive = await storage.getAuthToken();
    if (isTokenActive == null) {
      _isSignedIn = false;
      _hasSeenOnboarding = await _checkOnboardingStatus();
      setState(() {});
    } else {
      _hasSeenOnboarding = true;
      _isSignedIn = true;
      setState(() {});
    }
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
            MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => ProfileCubit(),
                ),
                BlocProvider(
                  create: (context) => ExercisesCubit(
                    exerciseRepository: ExercisesRepository(
                        exercisesService:
                            ExercisesService(dioService: DioService())),
                  )..loadExercises(),
                )
              ],
              child: MaterialApp(
                theme: AppTheme.darkTheme,
                debugShowCheckedModeBanner: false,
                onGenerateRoute: OnPageRoute.generateRoute,
                home: _isSignedIn == null
                    ? const Scaffold(
                        backgroundColor: Colors.black,
                        body: Center(child: CircularProgressIndicator()),
                      ) // 🟡 Show loading while waiting
                    : _isSignedIn!
                        ? const MainScaffold()
                        : !_hasSeenOnboarding!
                            ? const OnboardingScreen()
                            : const AuthScreen(),
              ),
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
