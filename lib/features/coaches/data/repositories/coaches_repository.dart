import 'dart:io';

import 'package:dio/dio.dart';
import 'package:trackletics/core/network/dio_service.dart';
import 'package:trackletics/features/coaches/data/models/coach_model.dart';

class CoachesRepository {
  final DioService _dioService = DioService();

  /// Fetch all coaches from the API.
  Future<List<CoachModel>> getCoaches() async {
    try {
      final response = await _dioService.get('/api/Coaches');
      final data = response.data;
      if (data is! List) return [];
      return data
          .map((e) => CoachModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Failed to load coaches');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Submit an application to become a coach.
  /// Sends [bio], [experience], and [IdDocument] (national ID front) as multipart.
  Future<void> becomeCoach({
    required String bio,
    required String experience,
    required String idDocumentPath,
  }) async {
    try {
      final file = File(idDocumentPath);
      if (!file.existsSync()) {
        throw Exception('ID document file not found');
      }
      final fileName = file.path.split('/').last;

      final formData = FormData.fromMap({
        'bio': bio,
        'experience': experience,
        'IdDocument': await MultipartFile.fromFile(
          idDocumentPath,
          filename: fileName,
        ),
      });

      await _dioService.multipart(
        '/api/Coaches/BecomeCoach',
        formData: formData,
      );
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Failed to submit coach application');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
