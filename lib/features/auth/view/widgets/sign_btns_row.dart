import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gym/Shared/ui/custom_snackbar.dart';
import 'package:gym/Shared/ui/rounded_primary_btn.dart';
import 'package:gym/features/auth/view/cubit/auth_cubit.dart';
import 'package:gym/features/auth/view/widgets/auth_toggle_btns.dart';
import 'package:gym/features/auth/view/widgets/social_sign_btn.dart';
import 'package:gym/routes/route_names.dart';

class LoginButtonsRow extends StatelessWidget {
  const LoginButtonsRow({
    super.key,
    required this.authtype,
  });
  final AuthType authtype;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Social Buttons (Apple & Google)
        Row(
          children: [
            SocialLoginButton(
              icon: Icons.apple,
              onPressed: () {
                // TODO: Handle Apple Login
              },
            ),
            const SizedBox(width: 15),
            SocialLoginButton(
              icon: Icons.g_mobiledata,
              onPressed: () {
                // TODO: Handle Google Login
              },
            ),
          ],
        ),
        const SizedBox(
          width: 50,
        ),
        // Primary Rounded Login Button
        BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthUnauthenticated) {
              CustomSnackbar.show(context, state.errorMessage ?? 'Error',
                  isError: true);
            } else if (state is AuthNeedsValidation) {
              Navigator.pushReplacementNamed(
                  context, RouteNames.otp_screen_route, arguments: [
                context.read<AuthCubit>().signUpModel.mail,
                false
              ]);
            } else if (state is AuthAuthenticated) {
              Navigator.pushReplacementNamed(context, RouteNames.home_route);
            }
          },
          builder: (context, state) {
            return PrimaryRoundedButton(
              isLoading: state is AuthLoading,
              text: authtype == AuthType.login ? 'Login' : 'Sign up',
              icon: FontAwesomeIcons.arrowRight,
              onPressed: () {
                if (authtype == AuthType.signup) {
                  context.read<AuthCubit>().register();
                } else {
                  context.read<AuthCubit>().login();
                }
              },
            );
          },
        ),
      ],
    );
  }
}
