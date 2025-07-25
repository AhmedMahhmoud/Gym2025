import 'dart:io';
import 'package:dio/dio.dart';
import 'package:gym/core/network/dio_service.dart';
import 'package:gym/core/services/token_manager.dart';

class ProfileRepository {
  final DioService _dioService = DioService();
  final TokenManager _tokenManager = TokenManager();

  /// Upload profile picture and/or update display name
  /// Both parameters are optional - only send what's being updated
  Future<String> uploadProfile({
    String? imagePath,
    String? inAppName,
  }) async {
    try {
      final Map<String, dynamic> formDataMap = {};

      // Add image if provided
      if (imagePath != null && imagePath.isNotEmpty) {
        final file = File(imagePath);
        final fileName = file.path.split('/').last;

        formDataMap['profilePicture'] = await MultipartFile.fromFile(
          imagePath,
          filename: fileName,
        );
      }

      // Add name if provided
      if (inAppName != null && inAppName.isNotEmpty) {
        formDataMap['inAppName'] = inAppName;
      }

      // Ensure at least one field is provided
      if (formDataMap.isEmpty) {
        throw Exception('At least one field (image or name) must be provided');
      }

      final formData = FormData.fromMap(formDataMap);

      final response = await _dioService.multipart(
        '/api/Auth/UpdateProfile',
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
        throw Exception('Failed to update profile');
      }
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Failed to update profile');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Legacy method for backward compatibility
  /// @deprecated Use uploadProfile instead
  Future<String> uploadProfilePicture(String imagePath) async {
    return uploadProfile(imagePath: imagePath);
  }
}
