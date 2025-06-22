import 'package:equatable/equatable.dart';

enum ProfileStatus {
  initial,
  loading,
  success,
  error,
  updating,
}

class ProfileState extends Equatable {
  final ProfileStatus status;
  final String displayName;
  final String? profileImage;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.displayName = 'Fitness Enthusiast',
    this.profileImage,
    this.errorMessage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    String? displayName,
    String? profileImage,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      displayName: displayName ?? this.displayName,
      profileImage: profileImage ?? this.profileImage,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, displayName, profileImage, errorMessage];
}
