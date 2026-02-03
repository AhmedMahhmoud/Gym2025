import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:trackletics/core/services/token_manager.dart';
import 'package:trackletics/features/auth/data/models/sign_up_model.dart';
import 'package:trackletics/features/auth/data/models/google_sign_in_model.dart';
import 'package:trackletics/features/auth/data/services/google_sign_in_service.dart';
import 'package:trackletics/features/auth/data/utils/google_sign_in_error_handler.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/dio_service.dart';
import '../../../../core/network/error_handler.dart';

class AuthRepository {
  AuthRepository({
    GoogleSignInService? googleSignInService,
  }) : _googleSignInService = googleSignInService ?? GoogleSignInServiceImpl();
  final DioService _dioService = DioService();
  final TokenManager _tokenManager = TokenManager();
  final GoogleSignInService _googleSignInService;

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
          // Handle upload progress if needed
        },
      );

      return Right(response.data);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  /// Sign in with Google
  /// Returns Google account information
  /// TODO: Link with backend API when ready
  Future<Either<Failure, GoogleSignInModel>> signInWithGoogle() async {
    try {
      final googleAccount = await _googleSignInService.signIn();
      // TODO: Call backend API with Google account info to get JWT token
      // For now, just return the Google account info
      return Right(googleAccount);
    } catch (e) {
      return Left(GoogleSignInErrorHandler.handleError(e));
    }
  }
}
