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
        // Cache registration state and email for recovery
        await _storageService.setRegistrationInProgress(true);
        await _storageService.setPendingVerificationEmail(signUpModel.mail);
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
}
