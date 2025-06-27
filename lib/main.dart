import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gym/core/network/connectivity.dart';
import 'package:gym/core/network/dio_service.dart';
import 'package:gym/core/services/auth_initialization_service.dart';
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

  // Initialize HydratedBloc for offline data persistence
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );

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
  final AuthInitializationService _authService = AuthInitializationService();
  AuthInitStatus _authStatus = AuthInitStatus.checking;
  bool _hasSeenOnboarding = false;
  final ConnectivityService _connectivityService = ConnectivityService();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      log('Initializing app...');

      // Initialize authentication
      final authStatus = await _authService.initializeAuth();

      // Check onboarding status
      final hasSeenOnboarding = await _authService.checkOnboardingStatus();

      setState(() {
        _authStatus = authStatus;
        _hasSeenOnboarding = hasSeenOnboarding;
      });

      log('App initialized - Auth: $authStatus, Onboarding: $hasSeenOnboarding');
    } catch (e) {
      log('Error initializing app: $e');
      setState(() {
        _authStatus = AuthInitStatus.error;
        _hasSeenOnboarding = false;
      });
    }
  }

  Widget _buildHomeScreen() {
    switch (_authStatus) {
      case AuthInitStatus.checking:
        return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'Initializing...',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        );

      case AuthInitStatus.authenticated:
        return const MainScaffold();

      case AuthInitStatus.unauthenticated:
        return _hasSeenOnboarding
            ? const AuthScreen()
            : const OnboardingScreen();

      case AuthInitStatus.error:
        return Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Something went wrong',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please restart the app',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _initializeApp,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
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
                home: _buildHomeScreen(),
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
