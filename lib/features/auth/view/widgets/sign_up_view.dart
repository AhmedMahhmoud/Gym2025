import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trackletics/Shared/ui/custom_text_form_field.dart';
import 'package:trackletics/core/utils/validators/validations.dart';
import 'package:trackletics/features/auth/view/cubit/auth_cubit.dart';
import 'package:trackletics/features/auth/view/widgets/auth_toggle_btns.dart';
import 'package:trackletics/features/auth/view/widgets/sign_btns_row.dart';

class SignupView extends StatelessWidget {
  const SignupView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final AuthCubit authCubit = context.read<AuthCubit>();
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            hintText: 'Email',
            onSaved: (p0) => authCubit.signUpModel.mail = p0!,
            suffixIcon: const Icon(FontAwesomeIcons.envelope),
            validator: (p0) => AppValidator.validateEmail(p0),
          ),
          const SizedBox(
            height: 10,
          ),
          AppTextField(
            hintText: 'Username',
            onSaved: (p0) => authCubit.signUpModel.username = p0!,
            suffixIcon: const Icon(FontAwesomeIcons.user),
          ),
          const SizedBox(
            height: 10,
          ),
          AppTextField(
            hintText: 'In App Name',
            onSaved: (p0) => authCubit.signUpModel.inAppName = p0!,
            suffixIcon: const Icon(FontAwesomeIcons.dumbbell),
          ),
          const SizedBox(
            height: 10,
          ),
          AppTextField(
            hintText: 'Password',
            onSaved: (p0) => authCubit.signUpModel.password = p0!,
            isPassword: true,
            validator: (p0) => AppValidator.validatePassword(p0!),
            onChanged: (p0) => authCubit.signUpModel.password = p0!,
          ),
          const SizedBox(
            height: 10,
          ),
          AppTextField(
            hintText: 'Confirm Password',
            isPassword: true,
            textInputAction: TextInputAction.done,
            validator: (p0) {
              if (p0 != authCubit.signUpModel.password) {
                return 'Passwords do not match';
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
