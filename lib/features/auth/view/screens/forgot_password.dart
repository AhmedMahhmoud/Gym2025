import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gym/Shared/ui/custom_back_btn.dart';
import 'package:gym/Shared/ui/custom_snackbar.dart';
import 'package:gym/Shared/ui/custom_text_form_field.dart';
import 'package:gym/Shared/ui/rounded_primary_btn.dart';
import 'package:gym/core/theme/app_colors.dart';
import 'package:gym/core/utils/validators/validations.dart';
import 'package:gym/features/auth/data/repositories/otp_repository.dart';
import 'package:gym/features/auth/view/cubit/otp_cubit.dart';
import 'package:gym/routes/route_names.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OtpCubit(otpRepository: OtpRepository()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.sizeOf(context).height * 0.06),
                const CustomBackBtn(),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  'Reset your password ',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                AppTextField(
                  hintText: 'Enter your email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (p0) => AppValidator.validateEmail(p0),
                  suffixIcon: const Icon(Icons.mail),
                ),
                const Spacer(),
                BlocConsumer<OtpCubit, OtpState>(
                  listener: (context, state) {
                    if (state is VerifyResetPasswordError) {
                      CustomSnackbar.show(context, state.errorMessage!,
                          isError: true);
                    } else if (state is VerifyResetPasswordLoaded) {
                      CustomSnackbar.show(context, state.successMsg ?? '',
                          isError: false);
                      Navigator.pushNamed(context, RouteNames.otp_screen_route,
                          arguments: [_emailController.text, true]);
                    }
                  },
                  builder: (context, state) => Center(
                      child: PrimaryRoundedButton(
                    isLoading: state is VerifyResetPasswordLoading,
                    text: 'Verify',
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<OtpCubit>().verifyResetPassword(
                              _emailController.text,
                            );
                      }
                    },
                    width: 250,
                  )),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
