part of 'auth_cubit.dart';

/// 🔹 AuthStatus Enum for High-Level Status Tracking
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  requrieValidation,
  wrongVerifyReset,
  verifyResetLoading,
  verifyResetSuccess,
}

/// 🔹 Sealed Class for State Management
sealed class AuthState {
  const AuthState({required this.status});
  final AuthStatus status;
}

/// ✅ Initial State (User has not interacted)
final class AuthInitial extends AuthState {
  const AuthInitial() : super(status: AuthStatus.initial);
}

/// ✅ Loading State (Auth request in progress)
final class AuthLoading extends AuthState {
  const AuthLoading() : super(status: AuthStatus.loading);
}

/// ✅ Authenticated State (User successfully logged in)
final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.token})
      : super(status: AuthStatus.authenticated);
  final String? token;
}

final class AuthNeedsValidation extends AuthState {
  const AuthNeedsValidation() : super(status: AuthStatus.requrieValidation);
}

/// ✅ Unauthenticated State (Login failed or user logged out)
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated({this.errorMessage})
      : super(status: AuthStatus.unauthenticated);
  final String? errorMessage;
}

