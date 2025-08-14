import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:trackletics/core/services/storage_service.dart';
import 'package:trackletics/core/services/token_manager.dart';
import 'package:trackletics/features/auth/data/models/sign_up_model.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/dio_service.dart';
import '../../../../core/network/error_handler.dart';

class AuthRepository {
  AuthRepository();
  final DioService _dioService = DioService();
  final TokenManager _tokenManager = TokenManager();

  Future<Either<Failure, Unit>> signUp(SignUpModel signModel) async {
    try {
      await _dioService.post(
        '/api/Auth/Register',
        data: {
          'email': signModel.mail,
          'password': signModel.password,
          'inappname': signModel.inAppName,
          'username': signModel.username,
          'gender': signModel.gender,
          'roles': ['user'],
        },
      );

      return const Right(unit);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  Future<Either<Failure, String>> signIn(SignUpModel signModel) async {
    try {
      final res = await _dioService.post(
        '/api/Auth/Login',
        data: {
          'email': signModel.mail,
          'password': signModel.password,
          'roles': ['user'],
        },
      );

      final token = res.data['message']['jwtToken'];

      // Use TokenManager to store token (this updates both cache and storage)
      await _tokenManager.setToken(token);

      return Right(token);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> uploadProfilePicture({
    required String imagePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'profilePicture': await MultipartFile.fromFile(imagePath),
      });

      final response = await _dioService.multipart(
        '/user/profile-picture',
        formData: formData,
        onSendProgress: (sent, total) {
          final progress = (sent / total) * 100;
          // Handle upload progress
        },
      );

      return Right(response.data);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
