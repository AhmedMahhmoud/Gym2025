import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trackletics/Shared/ui/custom_snackbar.dart';
import 'package:trackletics/Shared/ui/rounded_primary_btn.dart';
import 'package:trackletics/features/auth/view/cubit/auth_cubit.dart';
import 'package:trackletics/features/auth/view/widgets/auth_toggle_btns.dart';
import 'package:trackletics/features/auth/view/widgets/social_sign_btn.dart';
import 'package:trackletics/routes/route_names.dart';

class LoginButtonsRow extends StatelessWidget {
  const LoginButtonsRow({
    super.key,
    required this.authtype,
  });
  final AuthType authtype;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Social Buttons (Apple & Google)

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
              width: 300,
              borderRadius: 18,
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
