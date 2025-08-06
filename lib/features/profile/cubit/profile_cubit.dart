import 'dart:developer';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:trackletics/core/constants/constants.dart';
import 'package:trackletics/core/services/jwt_service.dart';
import 'package:trackletics/core/services/token_manager.dart';
import 'package:trackletics/features/profile/cubit/profile_state.dart';
import 'package:trackletics/features/profile/data/repositories/profile_repository.dart';

class ProfileCubit extends HydratedCubit<ProfileState> {
  final ProfileRepository _repository = ProfileRepository();
  final JwtService _jwtService = JwtService();
  final TokenManager _tokenManager = TokenManager();

  ProfileCubit() : super(const ProfileState()) {
    _initializeProfile();
  }

  /// Initialize profile data only if user is authenticated
  Future<void> _initializeProfile() async {
    try {
      final token = await _tokenManager.getToken();
      if (token != null && token.isNotEmpty) {
        // Only load data if we have a valid token
        await loadUserDataFromToken();
      } else {
        // No token - ensure we start with clean state
        log('ProfileCubit: No token found during initialization, starting with clean state');
        emit(const ProfileState());
      }
    } catch (e) {
      log('ProfileCubit: Error during initialization: $e');
      emit(const ProfileState());
    }
  }

  @override
  ProfileState? fromJson(Map<String, dynamic> json) {
    try {
      // Check if we should restore data (only if we have a valid token)
      return _shouldRestoreData()
          ? ProfileState(
              status: ProfileStatus.values[json['status'] ?? 0],
              displayName: json['displayName'] ?? 'Fitness Enthusiast',
              profileImage: json['profileImage'],
              profileImageUrl: json['profileImageUrl'],
              email: json['email'],
              userId: json['userId'],
              errorMessage: json['errorMessage'],
              // Note: We don't persist userData for security reasons
            )
          : null; // Return null to start with clean state
    } catch (e) {
      log('Error deserializing profile state: $e');
      return null;
    }
  }

  /// Check if we should restore hydrated data
  bool _shouldRestoreData() {
    // Don't restore data if user is not authenticated
    // This is a synchronous check, so we'll be conservative
    return false; // Always start fresh to avoid cross-user data issues
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
    log('ProfileCubit: Starting to load user data from token (forceRefresh: $forceRefresh)');
    emit(state.copyWith(status: ProfileStatus.loading, clearError: true));

    try {
      final token = await _tokenManager.getToken();
      if (token == null || token.isEmpty) {
        log('ProfileCubit: No authentication token found');
        // No token means user is not authenticated - clear all data
        emit(const ProfileState(
          status: ProfileStatus.error,
          errorMessage: 'No authentication token found',
        ));
        return;
      }

      log('ProfileCubit: Token found, extracting user data');
      final userData = _jwtService.extractUserData(token);
      if (userData == null) {
        log('ProfileCubit: Failed to extract user data from token');
        // Invalid token - clear all data
        emit(const ProfileState(
          status: ProfileStatus.error,
          errorMessage: 'Failed to decode user data from token',
        ));
        return;
      }

      log('ProfileCubit: User data extracted successfully - User: ${userData.email}, Name: ${userData.inAppName}');

      final profileImageUrl =
          userData.getFullProfilePictureUrl(AppConstants.baseUrl);
      final displayName = userData.inAppName.isNotEmpty
          ? userData.inAppName
          : userData.email.split('@').first;

      log('ProfileCubit: Emitting new profile state with displayName: $displayName');
      emit(state.copyWith(
        status: ProfileStatus.success,
        userData: userData,
        displayName: displayName,
        email: userData.email,
        userId: userData.userId,
        profileImageUrl: profileImageUrl,
        // Clear any previous local profile image when loading fresh data
        profileImage: null,
      ));
    } catch (e) {
      log('ProfileCubit: Error loading user data: $e');
      // On error, clear all data instead of falling back to cached data
      emit(const ProfileState(
        status: ProfileStatus.error,
        errorMessage: 'Error loading user data',
      ));
    }
  }

  /// Update display name using the new API
  Future<void> updateDisplayName(String newName) async {
    emit(state.copyWith(
      status: ProfileStatus.updating,
      clearError: true,
    ));

    try {
      await _repository.uploadProfile(inAppName: newName);

      // Reload user data from the updated token
      await loadUserDataFromToken();

      // Update local state immediately
      emit(state.copyWith(
        status: ProfileStatus.success,
        displayName: newName,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Update profile image using the new API
  Future<void> updateProfileImage(String imagePath) async {
    emit(state.copyWith(
      status: ProfileStatus.uploading,
      clearError: true,
    ));

    try {
      await _repository.uploadProfile(imagePath: imagePath);

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

  /// Update both image and name in a single API call
  Future<void> updateProfile({
    String? imagePath,
    String? inAppName,
  }) async {
    emit(state.copyWith(
      status: ProfileStatus.uploading,
      clearError: true,
    ));

    try {
      await _repository.uploadProfile(
        imagePath: imagePath,
        inAppName: inAppName,
      );

      // Reload user data from the updated token
      await loadUserDataFromToken();

      // Update local state
      emit(state.copyWith(
        status: ProfileStatus.success,
        displayName: inAppName ?? state.displayName,
        profileImage: imagePath ?? state.profileImage,
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
    log('ProfileCubit: Refreshing user data');
    await loadUserDataFromToken(forceRefresh: true);
  }

  /// Force a complete refresh after login - clears state and reloads
  Future<void> forceCompleteRefresh() async {
    log('ProfileCubit: Force complete refresh - clearing state and reloading');

    // First emit loading state
    emit(state.copyWith(status: ProfileStatus.loading, clearError: true));

    // Small delay to ensure token is properly set
    await Future.delayed(const Duration(milliseconds: 200));

    // Force reload user data
    await loadUserDataFromToken(forceRefresh: true);
  }

  void reset() {
    log('ProfileCubit: Resetting all data and clearing hydrated storage');
    // First clear hydrated storage
    clear();
    // Then emit clean state
    emit(const ProfileState());
  }

  /// Completely clear all ProfileCubit data and hydrated storage
  Future<void> clearAllData() async {
    log('ProfileCubit: Clearing all data and hydrated storage');

    // Clear hydrated storage
    clear();

    // Emit completely clean state
    emit(const ProfileState());

    // Force save the clean state to hydrated storage
    await Future.delayed(const Duration(milliseconds: 100));
  }

  // Force update profile data from server
  Future<void> forceRefresh() async {
    await loadUserDataFromToken(forceRefresh: true);
  }
}
