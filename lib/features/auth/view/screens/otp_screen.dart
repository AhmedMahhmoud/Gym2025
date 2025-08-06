import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackletics/Shared/ui/custom_back_btn.dart';
import 'package:trackletics/Shared/ui/custom_text_form_field.dart';
import 'package:trackletics/core/utils/validators/validations.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:trackletics/Shared/ui/custom_snackbar.dart';
import 'package:trackletics/Shared/ui/rounded_primary_btn.dart';
import 'package:trackletics/core/theme/app_colors.dart';
import 'package:trackletics/features/auth/data/repositories/otp_repository.dart';
import 'package:trackletics/features/auth/view/cubit/otp_cubit.dart';
import 'package:trackletics/features/auth/view/screens/auth_screen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen(
      {required this.email, required this.isResetPassword, super.key});
  final String email;
  final bool isResetPassword;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String otpCode = '';
  late Timer _timer;
  int _remainingTime = 60;
  final StreamController<ErrorAnimationType> _errorController =
      StreamController<ErrorAnimationType>();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    _errorController.close();
    _newPasswordController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _remainingTime = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() => _remainingTime--);
      } else {
        timer.cancel();
      }
    });
  }

  String _formatTime(int seconds) {
    return '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OtpCubit(otpRepository: OtpRepository()),
      child: BlocConsumer<OtpCubit, OtpState>(
        listener: (context, state) {
          void showSnackbar(String message, {bool isError = false}) {
            CustomSnackbar.show(context, message, isError: isError);
          }

          void navigateToAuthScreen() {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const AuthScreen()),
              (route) => false,
            );
          }

          switch (state) {
            case OtpSuccessState(successMsg: var msg):
            case ResetPasswordLoaded(successMsg: var msg):
            case VerifyResetPasswordLoaded(successMsg: var msg?):
              showSnackbar(msg);
              navigateToAuthScreen();
              break;

            case OtpErrorState(errorMessage: var errorMsg):
            case ResetPasswordError(errorMessage: var errorMsg):
            case VerifyResetPasswordError(errorMessage: var errorMsg?):
              showSnackbar(errorMsg, isError: true);
              break;

            case ResendOtpSuccessState(successMsg: var msg):
              showSnackbar(msg);
              break;

            default:
              debugPrint('Unhandled OTP state: $state');
              break;
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.06),
                  if (widget.isResetPassword) ...[
                    const CustomBackBtn(),
                    const SizedBox(height: 15),
                  ],
                  const Text(
                    'Verification',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const SizedBox(
                    width: 270,
                    child: Text(
                      'Check your email. We\'ve sent you the PIN at your email.',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (widget.isResetPassword)
                    AppTextField(
                      hintText: 'New password',
                      controller: _newPasswordController,
                      isPassword: true,
                      validator: (p0) => AppValidator.validatePassword(p0!),
                      prefixIcon: const Icon(Icons.lock),
                    ),

                  /// **OTP Input Field using `pin_code_fields`**
                  PinCodeTextField(
                    appContext: context,
                    length: 6,
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    animationType: AnimationType.scale,
                    cursorColor: Colors.white,
                    pastedTextStyle: const TextStyle(color: Colors.white),
                    errorAnimationController:
                        _errorController, // Shake animation controller
                    textStyle: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.underline,
                      activeColor: AppColors.primary,
                      inactiveColor: AppColors.surface,
                      selectedColor: AppColors.primary,
                      fieldHeight: 60,
                      fieldWidth: 50,
                    ),
                    animationDuration: const Duration(milliseconds: 300),
                    backgroundColor: AppColors.background,
                    enableActiveFill: false,
                    onCompleted: (value) {
                      otpCode = value;
                    },
                    onChanged: (value) {
                      setState(() {
                        otpCode = value;
                      });
                    },
                    beforeTextPaste: (text) {
                      return RegExp(r'^\d{6}$').hasMatch(text ?? '');
                    },
                  ),

                  const SizedBox(height: 25),

                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Didn\'t Receive code?',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            if (_remainingTime > 0) ...[
                              Text(' ${_formatTime(_remainingTime)}'),
                            ]
                          ],
                        ),
                        Builder(
                          builder: (context) {
                            final otpCubit = context.read<OtpCubit>();
                            return TextButton(
                              onPressed: _remainingTime > 0
                                  ? null
                                  : () {
                                      _startTimer();
                                      if (widget.isResetPassword) {
                                        otpCubit
                                            .verifyResetPassword(widget.email);
                                      } else {
                                        otpCubit.resendOTP(widget.email);
                                      }
                                    },
                              child: Text(
                                'Resend',
                                style: TextStyle(
                                  color: _remainingTime > 0
                                      ? AppColors.textSecondary
                                      : AppColors.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  Center(
                    child: PrimaryRoundedButton(
                      text:
                          widget.isResetPassword ? 'Reset password' : 'Verify',
                      onPressed: () {
                        final otpCubit = context.read<OtpCubit>();
                        if (otpCode.length == 6) {
                          if (widget.isResetPassword) {
                            otpCubit.resetPassword(widget.email, otpCode,
                                _newPasswordController.text);
                          } else {
                            otpCubit.verifyOtp(widget.email, otpCode);
                          }
                        } else {
                          _errorController.add(ErrorAnimationType
                              .shake); // Trigger shake animation
                          CustomSnackbar.show(
                            context,
                            'Please enter a 6-digit code',
                            isError: true,
                          );
                        }
                      },
                      isLoading: state is OtpLoadingState,
                      width: 220,
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
