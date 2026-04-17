import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:trackletics/Shared/ui/custom_text_form_field.dart';
import 'package:trackletics/Shared/ui/custom_dropdown.dart';
import 'package:trackletics/Shared/ui/custom_snackbar.dart';
import 'package:trackletics/Shared/ui/rounded_primary_btn.dart';
import 'package:trackletics/core/theme/app_colors.dart';
import 'package:trackletics/core/utils/validators/validations.dart';
import 'package:trackletics/features/auth/data/models/apple_sign_in_model.dart';
import 'package:trackletics/features/auth/view/cubit/auth_cubit.dart';
import 'package:trackletics/routes/route_names.dart';

class AppleSignInAdditionalInfoScreen extends StatefulWidget {
  const AppleSignInAdditionalInfoScreen({
    super.key,
    required this.appleAccount,
  });

  final AppleSignInModel appleAccount;

  @override
  State<AppleSignInAdditionalInfoScreen> createState() =>
      _AppleSignInAdditionalInfoScreenState();
}

class _AppleSignInAdditionalInfoScreenState
    extends State<AppleSignInAdditionalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  String? _inAppName;
  String? _gender;

  bool get _emailFromApple => widget.appleAccount.email.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.appleAccount.email;
    if (_emailFromApple) {
      _emailController.addListener(() {
        if (_emailController.text != widget.appleAccount.email) {
          _emailController.text = widget.appleAccount.email;
        }
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.locale;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'auth.complete_profile'.tr(),
          style: const TextStyle(color: AppColors.textPrimary),
        ),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            CustomSnackbar.show(context, state.errorMessage ?? 'Error',
                isError: true);
          } else if (state is AuthAuthenticated) {
            Navigator.pushReplacementNamed(context, RouteNames.home_route);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'auth.apple_sign_in_complete_profile_message'.tr(),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                  if (!_emailFromApple) ...[
                    const SizedBox(height: 16),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryLight.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.primaryLight,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'auth.apple_email_not_shared_hint'.tr(),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 30),
                  AppTextField(
                    hintText: 'auth.email'.tr(),
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    readOnly: _emailFromApple,
                    suffixIcon: const Icon(FontAwesomeIcons.envelope),
                    validator: (value) {
                      if (!_emailFromApple) {
                        return AppValidator.validateEmail(value);
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    hintText: 'auth.in_app_name'.tr(),
                    suffixIcon: const Icon(FontAwesomeIcons.dumbbell),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'validation.required'.tr();
                      }
                      if (value.length < 2) {
                        return 'validation.min_length'
                            .tr(namedArgs: {'min': '2'});
                      }
                      return null;
                    },
                    onSaved: (value) => _inAppName = value,
                  ),
                  const SizedBox(height: 20),
                  AppDropdown<String>(
                    hintText: 'auth.select_gender'.tr(),
                    value: _gender,
                    onChanged: (value) {
                      setState(() {
                        _gender = value;
                      });
                    },
                    onSaved: (value) {
                      _gender = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'validation.required'.tr();
                      }
                      return null;
                    },
                    prefixIcon: Icon(
                      FontAwesomeIcons.venusMars,
                      color: AppColors.textSecondary.withOpacity(0.6),
                    ),
                    items: [
                      DropdownMenuItem<String>(
                        value: 'male',
                        child: Text('auth.male'.tr()),
                      ),
                      DropdownMenuItem<String>(
                        value: 'female',
                        child: Text('auth.female'.tr()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryRoundedButton(
                      width: MediaQuery.of(context).size.width - 40,
                      borderRadius: 18,
                      isLoading: state is AuthLoading,
                      text: 'auth.complete_sign_in'.tr(),
                      icon: FontAwesomeIcons.check,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          final email = _emailController.text.trim();
                          context.read<AuthCubit>().completeAppleSignIn(
                                appleAccount: widget.appleAccount,
                                inAppName: _inAppName!,
                                gender: _gender!,
                                email: email,
                              );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
