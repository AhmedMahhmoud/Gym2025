import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:trackletics/core/services/storage_service.dart';
import 'package:trackletics/features/auth/data/models/sign_up_model.dart';
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
      (googleAccount) async {
        // TODO: When backend is linked, call API with Google account info
        // For now, we'll just log the account info
        log('Google Sign-In successful: ${googleAccount.email}');
        // Clear any pending registration state
        await _storageService.clearRegistrationState();
        // TODO: Replace with actual token from backend API
        // emit(AuthAuthenticated(token: token));
        // For now, emit unauthenticated with a message indicating backend needs to be linked
        emit(AuthUnauthenticated(
          errorMessage: 'Backend integration pending. Google account: ${googleAccount.email}',
        ));
      },
    );
  }
}
