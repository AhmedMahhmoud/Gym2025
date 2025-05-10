part of 'otp_cubit.dart';

sealed class OtpState {
  const OtpState();
}

final class OtpInitial extends OtpState {}

final class OtpLoadingState extends OtpState {}

final class OtpSuccessState extends OtpState {
  const OtpSuccessState({required this.successMsg});
  final String successMsg;
}

final class ResendOtpSuccessState extends OtpState {
  const ResendOtpSuccessState({required this.successMsg});
  final String successMsg;
}

final class OtpErrorState extends OtpState {
  const OtpErrorState({required this.errorMessage});
  final String errorMessage;
}

final class VerifyResetPasswordLoading extends OtpState {
  VerifyResetPasswordLoading();
}

final class VerifyResetPasswordError extends OtpState {
  const VerifyResetPasswordError({this.errorMessage});
  final String? errorMessage;
}

final class VerifyResetPasswordLoaded extends OtpState {
  const VerifyResetPasswordLoaded({this.successMsg});
  final String? successMsg;
}

final class ResetPasswordError extends OtpState {
  const ResetPasswordError({required this.errorMessage});
  final String errorMessage;
}

final class ResetPasswordLoaded extends OtpState {
  const ResetPasswordLoaded({required this.successMsg});
  final String successMsg;
}
