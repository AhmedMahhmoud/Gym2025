import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:trackletics/Shared/ui/custom_text_form_field.dart';
import 'package:trackletics/core/theme/app_colors.dart';
import 'package:trackletics/core/utils/validators/validations.dart';
import 'package:trackletics/features/auth/view/cubit/auth_cubit.dart';
import 'package:trackletics/features/auth/view/widgets/auth_toggle_btns.dart';
import 'package:trackletics/features/auth/view/widgets/sign_btns_row.dart';
import 'package:trackletics/features/auth/view/widgets/social_sign_btn.dart';
import 'package:trackletics/routes/route_names.dart';

class SignInView extends StatefulWidget {
  const SignInView({
    super.key,
  });

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  bool _hasNavigatedToGoogleAdditionalInfo = false;
  bool _hasNavigatedToAppleAdditionalInfo = false;

  bool get _showAppleSignIn =>
      !kIsWeb && (Platform.isIOS || Platform.isMacOS);

  @override
  Widget build(BuildContext context) {
    // Access locale to trigger rebuild on language change
    context.locale;

    final AuthCubit authCubit = context.read<AuthCubit>();
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            autovalidateMode: AutovalidateMode.disabled,
            hintText: 'auth.email'.tr(),
            suffixIcon: const Icon(FontAwesomeIcons.envelope),
            validator: (p0) => AppValidator.validateEmail(p0),
            onSaved: (p0) => authCubit.signUpModel.mail = p0!,
          ),
          const SizedBox(
            height: 10,
          ),
          AppTextField(
            hintText: 'auth.password'.tr(),
            autovalidateMode: AutovalidateMode.disabled,
            onSaved: (p0) => authCubit.signUpModel.password = p0!,
            isPassword: true,
          ),
          const SizedBox(
            height: 10,
          ),
          GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, RouteNames.forgot_password_route),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'auth.forgot_password',
                style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.textPrimary
                        : AppColors.primaryLight,
                    fontWeight: FontWeight.w500),
              ).tr(),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          // Sign in with Apple (iOS / macOS) and Google
          BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is GoogleSignInNeedsAdditionalInfo &&
                  !_hasNavigatedToGoogleAdditionalInfo) {
                _hasNavigatedToGoogleAdditionalInfo = true;
                Navigator.pushNamed(
                  context,
                  RouteNames.google_sign_in_additional_info_route,
                  arguments: [
                    state.googleAccount,
                    context.read<AuthCubit>(),
                  ],
                ).then((_) {
                  _hasNavigatedToGoogleAdditionalInfo = false;
                });
              }
              if (state is AppleSignInNeedsAdditionalInfo &&
                  !_hasNavigatedToAppleAdditionalInfo) {
                _hasNavigatedToAppleAdditionalInfo = true;
                Navigator.pushNamed(
                  context,
                  RouteNames.apple_sign_in_additional_info_route,
                  arguments: [
                    state.appleAccount,
                    context.read<AuthCubit>(),
                  ],
                ).then((_) {
                  _hasNavigatedToAppleAdditionalInfo = false;
                });
              }
            },
            builder: (context, state) {
              final loading = state is AuthLoading;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_showAppleSignIn) ...[
                    AppleSignInButton(
                      onPressed: loading
                          ? () {}
                          : () {
                              context.read<AuthCubit>().signInWithApple();
                            },
                    ),
                    const SizedBox(height: 12),
                  ],
                  GoogleSignInButton(
                    onPressed: loading
                        ? () {}
                        : () {
                            context.read<AuthCubit>().signInWithGoogle();
                          },
                  ),
                ],
              );
            },
          ),
          const SizedBox(
            height: 20,
          ),
          // Divider with "OR" text
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: AppColors.divider.withOpacity(0.3),
                  thickness: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'auth.or'.tr(),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: AppColors.divider.withOpacity(0.3),
                  thickness: 1,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          const LoginButtonsRow(
            authtype: AuthType.login,
          ),
        ],
      ),
    );
  }
}
