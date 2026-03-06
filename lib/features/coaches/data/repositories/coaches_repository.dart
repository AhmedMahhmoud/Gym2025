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
      return (data as List)
          .map((e) => CoachModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Failed to load coaches');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Submit an application to become a coach.
  /// Sends [bio] and [experience] to the API.
  Future<void> becomeCoach({
    required String bio,
    required String experience,
  }) async {
    try {
      await _dioService.post(
        '/api/Coaches/BecomeCoach',
        data: {
          'bio': bio,
          'experience': experience,
        },
      );
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Failed to submit coach application');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
