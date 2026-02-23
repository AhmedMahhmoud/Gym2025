import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:trackletics/core/services/token_manager.dart';
import 'package:trackletics/features/auth/data/models/sign_up_model.dart';
import 'package:trackletics/features/auth/data/models/google_sign_in_model.dart';
import 'package:trackletics/features/auth/data/models/google_login_request.dart';
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
  /// First tries to authenticate existing user with only email/googleUserId
  /// If backend requires additional info, returns Google account info for additional info collection
  Future<Either<Failure, dynamic>> signInWithGoogle() async {
    try {
      final googleAccount = await _googleSignInService.signIn();
      
      // Try to authenticate with existing user first - send ONLY email and googleUserId
      // Backend should check if user exists and return token if user is complete
      // If user needs additional info, backend should return error indicating required fields
      try {
        // Send only email and googleUserId - let backend tell us if additional info is needed
        final requestData = {
          'email': googleAccount.email,
          'googleUserId': googleAccount.id,
          if (googleAccount.photoUrl != null) 'profilePictureUrl': googleAccount.photoUrl,
        };

        final res = await _dioService.post(
          '/api/Auth/GoogleLogin',
          data: requestData,
        );

        // If we get here with successful response, user exists and is complete
        if (res.statusCode == 200 || res.statusCode == 201) {
          final token = res.data['message']['jwtToken'];
          await _tokenManager.setToken(token);
          return Right(token); // Return token for existing user
        } else {
          // Unexpected response - user might need additional info
          return Right(googleAccount);
        }
      } on DioException catch (dioError) {
        // Check if error indicates user needs additional info
        final statusCode = dioError.response?.statusCode;
        final errorData = dioError.response?.data;
        
        // If 400 (bad request - missing required fields like inAppName/gender) 
        // or 404 (user not found), user needs to provide additional info
        if (statusCode == 400 || statusCode == 404) {
          bool needsAdditionalInfo = false;
          
          if (errorData is Map) {
            // Check for validation errors in 'errors' field (ASP.NET Core format)
            final errors = errorData['errors'];
            if (errors is Map) {
              // Check if Gender or InAppName fields are mentioned in errors
              final hasGenderError = errors.containsKey('Gender') || 
                                    errors.containsKey('gender') ||
                                    errors.values.toString().toLowerCase().contains('gender');
              final hasInAppNameError = errors.containsKey('InAppName') || 
                                       errors.containsKey('inAppName') ||
                                       errors.containsKey('Inappname') ||
                                       errors.values.toString().toLowerCase().contains('inappname');
              
              if (hasGenderError || hasInAppNameError) {
                needsAdditionalInfo = true;
              }
            }
            
            // Also check error message if present
            final errorMessage = errorData['message']?.toString().toLowerCase() ?? 
                                errorData['title']?.toString().toLowerCase() ?? '';
            
            if (errorMessage.contains('validation error') ||
                errorMessage.contains('required') ||
                errorMessage.contains('missing') ||
                errorMessage.contains('inappname') ||
                errorMessage.contains('gender')) {
              needsAdditionalInfo = true;
            }
          }
          
          if (needsAdditionalInfo || statusCode == 404) {
            // User needs to provide additional info
            return Right(googleAccount);
          }
        }
        // Other errors (like 401, 500, etc.) - return the error
        return Left(ErrorHandler.handle(dioError));
      } catch (e) {
        // Other errors - assume user needs additional info
        return Right(googleAccount);
      }
    } catch (e) {
      return Left(GoogleSignInErrorHandler.handleError(e));
    }
  }

  /// Complete Google Sign-In with additional user info
  /// This is called when user provides inAppName and gender
  Future<Either<Failure, String>> completeGoogleSignIn({
    required GoogleSignInModel googleAccount,
    required String inAppName,
    required String gender,
  }) async {
    try {
      final request = GoogleLoginRequest(
        email: googleAccount.email,
        googleUserId: googleAccount.id,
        inAppName: inAppName,
        gender: gender,
        profilePictureUrl: googleAccount.photoUrl,
      );

      final res = await _dioService.post(
        '/api/Auth/GoogleLogin',
        data: request.toJson(),
      );

      // Check if response is successful
      if (res.statusCode == 200 || res.statusCode == 201) {
        final token = res.data['message']['jwtToken'];

        // Use TokenManager to store token (this updates both cache and storage)
        await _tokenManager.setToken(token);

        return Right(token);
      } else {
        // Unexpected response status
        return Left(ServerFailure(
          message: 'Unexpected response from server',
          statusCode: res.statusCode,
        ));
      }
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
