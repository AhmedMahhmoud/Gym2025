import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym/core/constants/constants.dart';
import 'package:gym/core/services/jwt_service.dart';
import 'package:gym/core/services/token_manager.dart';
import 'package:gym/features/profile/cubit/profile_state.dart';
import 'package:gym/features/profile/data/repositories/profile_repository.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repository = ProfileRepository();
  final JwtService _jwtService = JwtService();
  final TokenManager _tokenManager = TokenManager();

  ProfileCubit() : super(const ProfileState()) {
    loadUserDataFromToken();
  }

  /// Load user data from JWT token
  Future<void> loadUserDataFromToken() async {
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
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: 'Error loading user data: $e',
      ));
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
    await loadUserDataFromToken();
  }

  void reset() {
    emit(const ProfileState());
  }
}
