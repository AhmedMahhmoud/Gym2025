import 'dart:io';
import 'package:dio/dio.dart';
import 'package:gym/core/network/dio_service.dart';
import 'package:gym/core/services/token_manager.dart';

class ProfileRepository {
  final DioService _dioService = DioService();
  final TokenManager _tokenManager = TokenManager();

  Future<String> uploadProfilePicture(String imagePath) async {
    try {
      final file = File(imagePath);
      final fileName = file.path.split('/').last;

      final formData = FormData.fromMap({
        'profilePicture': await MultipartFile.fromFile(
          imagePath,
          filename: fileName,
        ),
      });

      final response = await _dioService.multipart(
        '/api/Auth/UploadProfilePicture',
        formData: formData,
      );

      if (response.statusCode == 200 && response.data != null) {
        // Handle different response formats
        String? token;

        if (response.data is String) {
          // Direct token string
          token = response.data;
        } else if (response.data is Map<String, dynamic>) {
          // Token in object
          token = response.data['token'] as String?;
        }

        if (token != null && token.isNotEmpty) {
          await _tokenManager.setToken(token);
          return token;
        } else {
          throw Exception('Invalid token format received');
        }
      } else {
        throw Exception('Failed to upload profile picture');
      }
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Failed to upload profile picture');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
