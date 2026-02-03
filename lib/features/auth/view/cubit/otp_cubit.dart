import 'package:bloc/bloc.dart';
import 'package:trackletics/core/services/storage_service.dart';
import 'package:trackletics/features/auth/data/models/sign_up_model.dart';
import 'package:trackletics/features/auth/data/repositories/auth_repository.dart';
import 'package:trackletics/features/auth/data/repositories/otp_repository.dart';

part 'otp_state.dart';

class OtpCubit extends Cubit<OtpState> {
  OtpCubit({required this.otpRepository}) : super(OtpInitial());
  final OtpRepository otpRepository;
  final StorageService _storageService = StorageService();
  final AuthRepository _authRepository = AuthRepository();

  Future<void> verifyOtp(String mail, String otp) async {
    emit(OtpLoadingState());
    final res = await otpRepository.verifyOtp(mail, otp);
    res.fold(
      (l) => emit(OtpErrorState(errorMessage: l.message)),
      (r) async {
        // After successful OTP verification, attempt auto-login
        await _performAutoLogin(mail);
      },
    );
  }

  Future<void> _performAutoLogin(String email) async {
    try {
      // Get stored password
      final password = await _storageService.getPendingVerificationPassword();

      if (password == null || password.isEmpty) {
        // No stored password, emit success without auto-login
        // Clear registration state
        await _storageService.clearRegistrationState();
        emit(
            const OtpSuccessState(successMsg: 'Account verified successfully'));
        return;
      }

      // Emit auto-login loading state
      emit(const AutoLoginLoadingState());

      // Create sign model for login
      final signModel = SignUpModel(
        mail: email,
        password: password,
        username: '', // Not needed for login
        inAppName: '', // Not needed for login
      );

      // Attempt to login
      final loginResult = await _authRepository.signIn(signModel);

      loginResult.fold(
        (failure) async {
          // Login failed, but OTP verification was successful
          // Clear registration state
          await _storageService.clearRegistrationState();
          emit(AutoLoginErrorState(
            errorMessage:
                'Account verified but auto-login failed: ${failure.message}',
          ));
        },
        (token) async {
          // Login successful, clear registration state
          await _storageService.clearRegistrationState();
          emit(AutoLoginSuccessState(token: token));
        },
      );
    } catch (e) {
      // Handle any unexpected errors
      await _storageService.clearRegistrationState();
      emit(AutoLoginErrorState(
        errorMessage: 'Auto-login failed: ${e.toString()}',
      ));
    }
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
