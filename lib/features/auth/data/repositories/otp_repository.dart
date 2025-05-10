import 'package:dartz/dartz.dart';
import 'package:gym/core/error/failures.dart';
import 'package:gym/core/network/dio_service.dart';
import 'package:gym/core/network/error_handler.dart';

class OtpRepository {
  final DioService _dioService = DioService();
  Future<Either<Failure, String>> verifyOtp(String mail, String otp) async {
    try {
      final res = await _dioService.post(
        '/api/Auth/VerifyPin',
        data: {'email': mail, 'pin': otp},
      );

      return Right(res.data['message']);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  Future<Either<Failure, String>> resendOtp(String mail) async {
    try {
      final res = await _dioService.post(
        '/api/Auth/Re-sendConfirmationMail',
        data: {
          'email': mail,
        },
      );

      return Right(res.data['message']);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  Future<Either<Failure, String>> verifyResetPassword(String email) async {
    try {
      final res = await _dioService.post(
        '/api/Auth/ResetPasswordRequest',
        data: {
          'email': email,
        },
      );
      return Right(res.data['message']);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  Future<Either<Failure, String>> resetPassword(
      String email, String otp, String password) async {
    try {
      final res = await _dioService.post(
        '/api/Auth/ResetPassword',
        data: {
          'email': email,
          'pin': otp,
          'newPassword': password,
        },
      );
      return Right(res.data['message']);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
