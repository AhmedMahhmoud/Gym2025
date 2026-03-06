import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trackletics/features/auth/view/screens/auth_screen.dart';
import 'package:trackletics/features/auth/view/screens/forgot_password.dart';
import 'package:trackletics/features/auth/view/screens/otp_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackletics/features/auth/view/screens/google_sign_in_additional_info_screen.dart';
import 'package:trackletics/features/auth/view/cubit/auth_cubit.dart';
import 'package:trackletics/features/auth/data/repositories/auth_repository.dart';
import 'package:trackletics/features/exercises/view/screens/exercise_details_page.dart';
import 'package:trackletics/features/exercises/view/screens/admin_missing_videos_screen.dart';
import 'package:trackletics/features/exercises/view/screens/admin_exercise_edit_screen.dart';
import 'package:trackletics/features/coaches/data/repositories/coaches_repository.dart';
import 'package:trackletics/features/coaches/view/cubit/apply_to_become_coach_cubit.dart';
import 'package:trackletics/features/coaches/view/screens/apply_to_become_coach_screen.dart';
import 'package:trackletics/routes/route_names.dart';
import 'package:trackletics/shared/widgets/main_scaffold.dart';
import 'package:trackletics/core/debug/api_logger_page.dart';
import 'package:trackletics/core/debug/api_logger_model.dart';

class OnPageRoute {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final Widget page = switch (settings.name) {
      RouteNames.otp_screen_route => _createPage<OtpScreen>(
          settings.arguments,
          (args) => OtpScreen(email: args[0], isResetPassword: args[1]),
        ),
      RouteNames.auth_screen_route => const AuthScreen(),
      RouteNames.home_route => const MainScaffold(),
      RouteNames.forgot_password_route => const ForgotPasswordScreen(),
      RouteNames.google_sign_in_additional_info_route => _createGoogleSignInPage(
          settings.arguments,
        ),
      RouteNames.exercise_details_route => _createPage<OtpScreen>(
          settings.arguments,
          (args) =>
              ExerciseDetailsPage(exercise: args[0], videoThumbnail: args[1]),
        ),
      RouteNames.admin_exercise_edit_route =>
        _createPage<AdminExerciseEditScreen>(
          settings.arguments,
          (args) => AdminExerciseEditScreen(exercise: args[0]),
        ),
      RouteNames.admin_missing_videos_route => const AdminMissingVideosScreen(),
      RouteNames.apply_to_become_coach_route => BlocProvider(
          create: (_) => ApplyToBecomeCoachCubit(
                coachesRepository: CoachesRepository(),
              ),
          child: const ApplyToBecomeCoachScreen(),
        ),
      RouteNames.api_logger_route => _createPage<ApiLoggerPage>(
          settings.arguments,
          (args) => ApiLoggerPage(logData: args[0] as ApiLoggerModel),
        ),
      _ => _errorPage(settings.name),
    };

    return _buildPageRoute(page);
  }

  /// A generic function to handle argument extraction for any screen.
  static Widget _createPage<T>(
      Object? arguments, Widget Function(List<dynamic>) builder) {
    if (arguments is List<dynamic>) {
      return builder(arguments);
    }
    return _errorPage("Invalid arguments for ${T.toString()}");
  }

  /// Displays an error screen when the route is unknown or has invalid arguments.
  static Widget _errorPage(String? routeName) {
    return Scaffold(
      body: Center(
        child: Text('No route defined or invalid arguments for $routeName'),
      ),
    );
  }

  /// Create Google Sign-In additional info page with AuthCubit
  static Widget _createGoogleSignInPage(Object? arguments) {
    if (arguments is List<dynamic> && arguments.length >= 2) {
      // If AuthCubit is passed, use it; otherwise create a new one
      final googleAccount = arguments[0];
      final authCubit = arguments.length > 1 && arguments[1] is AuthCubit
          ? arguments[1] as AuthCubit
          : AuthCubit(authRepository: AuthRepository());
      
      return BlocProvider<AuthCubit>.value(
        value: authCubit,
        child: GoogleSignInAdditionalInfoScreen(googleAccount: googleAccount),
      );
    }
    return _errorPage("Invalid arguments for GoogleSignInAdditionalInfoScreen");
  }

  /// A function to return the appropriate page route based on platform.
  static Route<dynamic> _buildPageRoute(Widget child) {
    return Platform.isIOS
        ? CupertinoPageRoute(builder: (_) => child)
        : MaterialPageRoute(builder: (_) => child);
  }
}
