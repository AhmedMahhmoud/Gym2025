import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:gym/core/services/storage_service.dart';
import 'package:gym/features/auth/data/models/sign_up_model.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/dio_service.dart';
import '../../../../core/network/error_handler.dart';

class AuthRepository {
  AuthRepository();
  final DioService _dioService = DioService();

  Future<Either<Failure, Unit>> signUp(SignUpModel signModel) async {
    try {
      await _dioService.post(
        '/api/Auth/Register',
        data: {
          'email': signModel.mail,
          'password': signModel.password,
          'username': signModel.username,
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
      final storage = StorageService();
      await storage.setAuthToken(res.data['message']['jwtToken']);
      return Right(res.data['message']['jwtToken']);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> uploadProfilePicture({
    required String imagePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'profile_picture': await MultipartFile.fromFile(imagePath),
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
