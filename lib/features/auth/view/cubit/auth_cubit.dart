import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:trackletics/core/services/storage_service.dart';
import 'package:trackletics/features/auth/data/models/sign_up_model.dart';
import 'package:trackletics/features/auth/data/models/apple_sign_in_model.dart';
import 'package:trackletics/features/auth/data/models/google_sign_in_model.dart';
import 'package:trackletics/features/auth/data/repositories/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required this.authRepository}) : super(const AuthInitial());
  final AuthRepository authRepository;
  final StorageService _storageService = StorageService();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  SignUpModel signUpModel = SignUpModel(
      username: '', inAppName: '', mail: '', password: '', gender: null);
  Future<void> register() async {
    formKey.currentState!.save();
    if (!formKey.currentState!.validate()) return;

    emit(const AuthLoading());
    final result = await authRepository.signUp(signUpModel);

    result.fold(
      (failure) {
        emit(AuthUnauthenticated(errorMessage: failure.message));
        log(failure.message);
      },
      (_) async {
        // Cache registration state, email, and password for auto-login after verification
        await _storageService.setRegistrationInProgress(true);
        await _storageService.setPendingVerificationEmail(signUpModel.mail);
        await _storageService
            .setPendingVerificationPassword(signUpModel.password);
        emit(const AuthNeedsValidation());
      },
    );
  }

  Future<void> login() async {
    formKey.currentState!.save();
    if (!formKey.currentState!.validate()) return;

    emit(const AuthLoading());
    final result = await authRepository.signIn(signUpModel);

    result.fold(
      (failure) {
        emit(AuthUnauthenticated(errorMessage: failure.message));
        log(failure.message);
      },
      (token) async {
        // Clear any pending registration state on successful login
        await _storageService.clearRegistrationState();
        emit(AuthAuthenticated(token: token));
      },
    );
  }

  Future<void> signInWithGoogle() async {
    emit(const AuthLoading());
    final result = await authRepository.signInWithGoogle();

    result.fold(
      (failure) {
        emit(AuthUnauthenticated(errorMessage: failure.message));
        log(failure.message);
      },
      (response) async {
        // Clear any pending registration state
        await _storageService.clearRegistrationState();
        
        // Check if response is a token (existing user) or GoogleAccount (needs additional info)
        if (response is String) {
          // User exists, token received - authenticate directly
          emit(AuthAuthenticated(token: response));
        } else if (response is GoogleSignInModel) {
          // User doesn't exist or needs additional info
          emit(GoogleSignInNeedsAdditionalInfo(googleAccount: response));
        }
      },
    );
  }

  Future<void> completeGoogleSignIn({
    required GoogleSignInModel googleAccount,
    required String inAppName,
    required String gender,
  }) async {
    emit(const AuthLoading());
    final result = await authRepository.completeGoogleSignIn(
      googleAccount: googleAccount,
      inAppName: inAppName,
      gender: gender,
    );

    result.fold(
      (failure) {
        emit(AuthUnauthenticated(errorMessage: failure.message));
        log(failure.message);
      },
      (token) async {
        // Clear any pending registration state
        await _storageService.clearRegistrationState();
        emit(AuthAuthenticated(token: token));
      },
    );
  }

  Future<void> signInWithApple() async {
    emit(const AuthLoading());
    final result = await authRepository.signInWithApple();

    result.fold(
      (failure) {
        emit(AuthUnauthenticated(errorMessage: failure.message));
        log(failure.message);
      },
      (response) async {
        await _storageService.clearRegistrationState();

        if (response is String) {
          emit(AuthAuthenticated(token: response));
        } else if (response is AppleSignInModel) {
          emit(AppleSignInNeedsAdditionalInfo(appleAccount: response));
        }
      },
    );
  }

  Future<void> completeAppleSignIn({
    required AppleSignInModel appleAccount,
    required String inAppName,
    required String gender,
    required String email,
  }) async {
    emit(const AuthLoading());
    final result = await authRepository.completeAppleSignIn(
      appleAccount: appleAccount,
      inAppName: inAppName,
      gender: gender,
      email: email,
    );

    result.fold(
      (failure) {
        emit(AuthUnauthenticated(errorMessage: failure.message));
        log(failure.message);
      },
      (token) async {
        await _storageService.clearRegistrationState();
        emit(AuthAuthenticated(token: token));
      },
    );
  }
}
