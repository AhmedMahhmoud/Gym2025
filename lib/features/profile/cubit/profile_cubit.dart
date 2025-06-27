import 'dart:developer';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:gym/core/constants/constants.dart';
import 'package:gym/core/services/jwt_service.dart';
import 'package:gym/core/services/token_manager.dart';
import 'package:gym/features/profile/cubit/profile_state.dart';
import 'package:gym/features/profile/data/repositories/profile_repository.dart';

class ProfileCubit extends HydratedCubit<ProfileState> {
  final ProfileRepository _repository = ProfileRepository();
  final JwtService _jwtService = JwtService();
  final TokenManager _tokenManager = TokenManager();

  ProfileCubit() : super(const ProfileState()) {
    loadUserDataFromToken();
  }

  @override
  ProfileState? fromJson(Map<String, dynamic> json) {
    try {
      return ProfileState(
        status: ProfileStatus.values[json['status'] ?? 0],
        displayName: json['displayName'] ?? 'Fitness Enthusiast',
        profileImage: json['profileImage'],
        profileImageUrl: json['profileImageUrl'],
        email: json['email'],
        userId: json['userId'],
        errorMessage: json['errorMessage'],
        // Note: We don't persist userData for security reasons
      );
    } catch (e) {
      log('Error deserializing profile state: $e');
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(ProfileState state) {
    try {
      return {
        'status': state.status.index,
        'displayName': state.displayName,
        'profileImage': state.profileImage,
        'profileImageUrl': state.profileImageUrl,
        'email': state.email,
        'userId': state.userId,
        'errorMessage': state.errorMessage,
        // Note: We don't persist userData for security reasons
      };
    } catch (e) {
      log('Error serializing profile state: $e');
      return null;
    }
  }

  /// Load user data from JWT token
  Future<void> loadUserDataFromToken({bool forceRefresh = false}) async {
    emit(state.copyWith(status: ProfileStatus.loading, clearError: true));

    try {
      final token = await _tokenManager.getToken();
      if (token == null || token.isEmpty) {
        emit(state.copyWith(
          status: ProfileStatus.error,
          errorMessage: 'No authentication token found',
        ));
        return;
      }

      final userData = _jwtService.extractUserData(token);
      if (userData == null) {
        emit(state.copyWith(
          status: ProfileStatus.error,
          errorMessage: 'Failed to decode user data from token',
        ));
        return;
      }

      final profileImageUrl =
          userData.getFullProfilePictureUrl(AppConstants.baseUrl);
      final displayName = userData.inAppName.isNotEmpty
          ? userData.inAppName
          : userData.email.split('@').first;

      emit(state.copyWith(
        status: ProfileStatus.success,
        userData: userData,
        displayName: displayName,
        email: userData.email,
        userId: userData.userId,
        profileImageUrl: profileImageUrl,
      ));
    } catch (e) {
      // If we have cached data, keep it and just show error
      if (state.email != null && !forceRefresh) {
        emit(state.copyWith(
          status: ProfileStatus.success,
          errorMessage: 'Using cached data: ${e.toString()}',
        ));
      } else {
        emit(state.copyWith(
          status: ProfileStatus.error,
          errorMessage: 'Error loading user data: $e',
        ));
      }
    }
  }

  void updateDisplayName(String newName) {
    emit(state.copyWith(
      status: ProfileStatus.updating,
      clearError: true,
    ));

    // Simulate API call delay
    Future.delayed(const Duration(milliseconds: 500), () {
      emit(state.copyWith(
        status: ProfileStatus.success,
        displayName: newName,
      ));
    });
  }

  Future<void> updateProfileImage(String imagePath) async {
    emit(state.copyWith(
      status: ProfileStatus.uploading,
      clearError: true,
    ));

    try {
      await _repository.uploadProfilePicture(imagePath);

      // Reload user data from the updated token
      await loadUserDataFromToken();

      // Keep the local image path for immediate UI update
      emit(state.copyWith(
        status: ProfileStatus.success,
        profileImage: imagePath,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Refresh user data from token (useful after login or token update)
  Future<void> refreshUserData() async {
    await loadUserDataFromToken(forceRefresh: true);
  }

  void reset() {
    emit(const ProfileState());
    clear(); // Clear hydrated storage
  }

  // Force update profile data from server
  Future<void> forceRefresh() async {
    await loadUserDataFromToken(forceRefresh: true);
  }
}
