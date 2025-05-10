import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gym/Shared/ui/custom_text_form_field.dart';
import 'package:gym/core/theme/app_colors.dart';
import 'package:gym/core/utils/validators/validations.dart';
import 'package:gym/features/auth/view/cubit/auth_cubit.dart';
import 'package:gym/features/auth/view/widgets/auth_toggle_btns.dart';
import 'package:gym/features/auth/view/widgets/sign_btns_row.dart';
import 'package:gym/routes/route_names.dart';

class SignInView extends StatelessWidget {
  const SignInView({
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
            autovalidateMode: AutovalidateMode.disabled,
            hintText: 'Email',
            suffixIcon: const Icon(FontAwesomeIcons.envelope),
            validator: (p0) => AppValidator.validateEmail(p0),
            onSaved: (p0) => authCubit.signUpModel.mail = p0!,
          ),
          const SizedBox(
            height: 10,
          ),
          AppTextField(
            hintText: 'Password',
            autovalidateMode: AutovalidateMode.disabled,
            onSaved: (p0) => authCubit.signUpModel.password = p0!,
            isPassword: true,
            validator: (p0) => AppValidator.validatePassword(p0!),
          ),
          const SizedBox(
            height: 10,
          ),
          GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, RouteNames.forgot_password_route),
            child: const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Forgot Password',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          const LoginButtonsRow(
            authtype: AuthType.login,
          ),
        ],
      ),
    );
  }
}
