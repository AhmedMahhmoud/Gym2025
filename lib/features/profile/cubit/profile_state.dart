import 'package:equatable/equatable.dart';
import 'package:trackletics/core/services/jwt_service.dart';

enum ProfileStatus {
  initial,
  loading,
  success,
  error,
  updating,
  uploading,
}

class ProfileState extends Equatable {
  final ProfileStatus status;
  final String displayName;
  final String? profileImage;
  final String? profileImageUrl; // URL from JWT token
  final String? email;
  final String? userId;
  final String? errorMessage;
  final UserTokenData? userData;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.displayName = 'Fitness Enthusiast',
    this.profileImage,
    this.profileImageUrl,
    this.email,
    this.userId,
    this.errorMessage,
    this.userData,
  });

  /// Check if user has admin role
  bool get isAdmin => userData?.isAdmin ?? false;

  /// Check if user has a specific role
  bool hasRole(String role) => userData?.hasRole(role) ?? false;

  /// Get all user roles
  List<String> get roles => userData?.roles ?? [];

  ProfileState copyWith({
    ProfileStatus? status,
    String? displayName,
    String? profileImage,
    String? profileImageUrl,
    String? email,
    String? userId,
    String? errorMessage,
    UserTokenData? userData,
    bool clearError = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      displayName: displayName ?? this.displayName,
      profileImage: profileImage ?? this.profileImage,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      email: email ?? this.email,
      userId: userId ?? this.userId,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      userData: userData ?? this.userData,
    );
  }

  @override
  List<Object?> get props => [
        status,
        displayName,
        profileImage,
        profileImageUrl,
        email,
        userId,
        errorMessage,
        userData,
      ];
}
