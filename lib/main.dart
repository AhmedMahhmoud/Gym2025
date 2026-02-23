import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trackletics/firebase_options.dart';
import 'package:trackletics/core/network/connectivity.dart';
import 'package:trackletics/core/network/dio_service.dart';
import 'package:trackletics/core/services/auth_initialization_service.dart';
import 'package:trackletics/core/services/jwt_service.dart';
import 'package:trackletics/core/services/storage_service.dart';
import 'package:trackletics/core/services/token_manager.dart';
import 'package:trackletics/features/auth/view/screens/auth_screen.dart';
import 'package:trackletics/features/auth/view/screens/otp_screen.dart';
import 'package:trackletics/features/exercises/data/repo/exercises_repo.dart';
import 'package:trackletics/features/exercises/data/services/exercises_service.dart';
import 'package:trackletics/features/exercises/view/cubit/exercises_cubit.dart';
import 'package:trackletics/features/onboarding/screens/onboarding_screen.dart';
import 'package:trackletics/features/profile/cubit/profile_cubit.dart';
import 'package:trackletics/features/profile/data/repositories/profile_repository.dart';
import 'package:trackletics/shared/widgets/main_scaffold.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'package:trackletics/routes/app_routes.dart';
import 'package:trackletics/features/workouts/data/units_service.dart';
import 'dart:ui' as ui;

//create a global navigator key
final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize easy_localization
  await EasyLocalization.ensureInitialized();

  await StorageService().checkForAppUpdateAndClearIfNeeded();
  // Initialize HydratedBloc for offline data persistence
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );

  // Initialize units service
  await UnitsService().initialize();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
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
  String? _pendingVerificationEmail;
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

      // Get pending verification email if needed
      String? pendingEmail;
      if (authStatus == AuthInitStatus.pendingVerification) {
        pendingEmail = await _authService.getPendingVerificationEmail();
      }

      setState(() {
        _authStatus = authStatus;
        _hasSeenOnboarding = hasSeenOnboarding;
        _pendingVerificationEmail = pendingEmail;
      });

      log('App initialized - Auth: $authStatus, Onboarding: $hasSeenOnboarding, Pending Email: $pendingEmail');
    } catch (e) {
      log('Error initializing app: $e');
      setState(() {
        _authStatus = AuthInitStatus.error;
        _hasSeenOnboarding = false;
        _pendingVerificationEmail = null;
      });
    }
  }

  Widget _buildHomeScreen() {
    switch (_authStatus) {
      case AuthInitStatus.checking:
        return Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height: 16),
                const Text(
                  'initializing',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ).tr(),
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

      case AuthInitStatus.pendingVerification:
        return OtpScreen(
          email: _pendingVerificationEmail ?? '',
          isResetPassword: false,
        );

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
                  'something_went_wrong',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ).tr(),
                const SizedBox(height: 8),
                const Text(
                  'please_restart_app',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ).tr(),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _initializeApp,
                  child: const Text('retry').tr(),
                ),
              ],
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to locale changes to rebuild the widget
    final currentLocale = context.locale;

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
                  create: (context) => ThemeCubit(),
                ),
                BlocProvider(
                  create: (context) => ProfileCubit(
                    repository: ProfileRepository(),
                    jwtService: JwtService(),
                    tokenManager: TokenManager(),
                  ),
                ),
                BlocProvider(
                  create: (context) => ExercisesCubit(
                    exerciseRepository: ExercisesRepository(
                      exercisesService:
                          ExercisesService(dioService: DioService()),
                    ),
                  )..loadExercises(context),
                ),
              ],
              child: BlocBuilder<ThemeCubit, ThemeMode>(
                builder: (context, themeMode) {
                  return MaterialApp(
                    navigatorKey: navKey,
                    theme: AppTheme.getTheme(currentLocale.languageCode, isDark: false),
                    darkTheme: AppTheme.getTheme(currentLocale.languageCode, isDark: true),
                    themeMode: themeMode,
                    debugShowCheckedModeBanner: false,
                    onGenerateRoute: OnPageRoute.generateRoute,
                    home: _buildHomeScreen(),
                    localizationsDelegates: context.localizationDelegates,
                    supportedLocales: context.supportedLocales,
                    locale: currentLocale,
                  );
                },
              ),
            ),
            Directionality(
              textDirection: ui.TextDirection.ltr,
              child: AnimatedPositioned(
                bottom: isConnected ? -60 : 10,
                duration: const Duration(milliseconds: 500),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.network_check,
                        color: Colors.white,
                      ),
                      Center(
                        child: const Text(
                          'no_internet_connection',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ).tr(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
