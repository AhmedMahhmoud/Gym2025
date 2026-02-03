import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:trackletics/Shared/ui/custom_text_form_field.dart';
import 'package:trackletics/Shared/ui/custom_dropdown.dart';
import 'package:trackletics/core/theme/app_colors.dart';
import 'package:trackletics/core/utils/validators/validations.dart';
import 'package:trackletics/features/auth/view/cubit/auth_cubit.dart';
import 'package:trackletics/features/auth/view/widgets/auth_toggle_btns.dart';
import 'package:trackletics/features/auth/view/widgets/sign_btns_row.dart';

class SignupView extends StatefulWidget {
  const SignupView({
    super.key,
  });

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
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
            hintText: 'auth.email'.tr(),
            onSaved: (p0) => authCubit.signUpModel.mail = p0!,
            suffixIcon: const Icon(FontAwesomeIcons.envelope),
            validator: (p0) => AppValidator.validateEmail(p0),
          ),
          const SizedBox(
            height: 10,
          ),
          AppTextField(
            hintText: 'auth.username'.tr(),
            onSaved: (p0) => authCubit.signUpModel.username = p0!,
            suffixIcon: const Icon(FontAwesomeIcons.user),
            validator: (p0) => AppValidator.validateUsername(p0),
          ),
          const SizedBox(
            height: 10,
          ),
          AppTextField(
            hintText: 'auth.in_app_name'.tr(),
            onSaved: (p0) => authCubit.signUpModel.inAppName = p0!,
            suffixIcon: const Icon(FontAwesomeIcons.dumbbell),
          ),
          const SizedBox(
            height: 10,
          ),
          AppDropdown<String>(
            hintText: 'auth.select_gender'.tr(),
            value: authCubit.signUpModel.gender,
            onChanged: (value) {
              authCubit.signUpModel.gender = value;
            },
            onSaved: (value) {
              authCubit.signUpModel.gender = value;
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
          const SizedBox(
            height: 10,
          ),
          AppTextField(
            hintText: 'auth.password'.tr(),
            onSaved: (p0) => authCubit.signUpModel.password = p0!,
            isPassword: true,
            validator: (p0) => AppValidator.validatePassword(p0!),
            onChanged: (p0) => authCubit.signUpModel.password = p0!,
          ),
          const SizedBox(
            height: 10,
          ),
          AppTextField(
            hintText: 'auth.confirm_password'.tr(),
            isPassword: true,
            textInputAction: TextInputAction.done,
            validator: (p0) {
              if (p0 != authCubit.signUpModel.password) {
                return 'validation.passwords_dont_match'.tr();
              }
              AppValidator.validatePassword(p0!);
              return null;
            },
          ),
          const SizedBox(
            height: 20,
          ),
          const LoginButtonsRow(
            authtype: AuthType.signup,
          ),
        ],
      ),
    );
  }
}
