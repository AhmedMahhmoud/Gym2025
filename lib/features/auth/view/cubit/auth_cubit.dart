import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:gym/features/auth/data/models/sign_up_model.dart';
import 'package:gym/features/auth/data/repositories/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required this.authRepository}) : super(const AuthInitial());
  final AuthRepository authRepository;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  SignUpModel signUpModel = SignUpModel(username: '', mail: '', password: '');
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
      (_) => emit(const AuthNeedsValidation()),
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
      (token) => emit(AuthAuthenticated(token: token)),
    );
  }
}
