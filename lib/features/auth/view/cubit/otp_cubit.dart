import 'package:bloc/bloc.dart';
import 'package:trackletics/features/auth/data/repositories/otp_repository.dart';

part 'otp_state.dart';

class OtpCubit extends Cubit<OtpState> {
  OtpCubit({required this.otpRepository}) : super(OtpInitial());
  final OtpRepository otpRepository;

  Future<void> verifyOtp(String mail, String otp) async {
    emit(OtpLoadingState());
    final res = await otpRepository.verifyOtp(mail, otp);
    res.fold(
      (l) => emit(OtpErrorState(errorMessage: l.message)),
      (r) => emit(OtpSuccessState(successMsg: r)),
    );
  }

  Future<void> resendOTP(
    String mail,
  ) async {
    emit(OtpLoadingState());
    final res = await otpRepository.resendOtp(mail);
    res.fold(
      (l) => emit(OtpErrorState(errorMessage: l.message)),
      (r) => emit(ResendOtpSuccessState(successMsg: r)),
    );
  }

  Future<void> verifyResetPassword(String mail) async {
    emit(VerifyResetPasswordLoading());
    await otpRepository.verifyResetPassword(mail).then((value) {
      value.fold((l) => emit(VerifyResetPasswordError(errorMessage: l.message)),
          (r) => emit(VerifyResetPasswordLoaded(successMsg: r)));
    });
  }

  Future<void> resetPassword(String mail, String otp, String password) async {
    emit(OtpLoadingState());
    await otpRepository.resetPassword(mail, otp, password).then((value) {
      value.fold((l) => emit(ResetPasswordError(errorMessage: l.message)),
          (r) => emit(ResetPasswordLoaded(successMsg: r)));
    });
  }
}
