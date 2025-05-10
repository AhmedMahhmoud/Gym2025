import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gym/features/auth/view/screens/auth_screen.dart';
import 'package:gym/features/auth/view/screens/forgot_password.dart';
import 'package:gym/features/auth/view/screens/otp_screen.dart';
import 'package:gym/features/exercises/view/screens/exercise_details_page.dart';
import 'package:gym/features/home/view/screens/home.dart';
import 'package:gym/routes/route_names.dart';
import 'package:gym/shared/widgets/main_scaffold.dart';

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
      RouteNames.exercise_details_route => _createPage<OtpScreen>(
          settings.arguments,
          (args) =>
              ExerciseDetailsPage(exercise: args[0], videoThumbnail: args[1]),
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

  /// A function to return the appropriate page route based on platform.
  static Route<dynamic> _buildPageRoute(Widget child) {
    return Platform.isIOS
        ? CupertinoPageRoute(builder: (_) => child)
        : MaterialPageRoute(builder: (_) => child);
  }
}
