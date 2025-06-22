import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym/features/profile/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(const ProfileState());

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

  void updateProfileImage(String imagePath) {
    emit(state.copyWith(
      status: ProfileStatus.updating,
      clearError: true,
    ));

    // Simulate API call delay
    Future.delayed(const Duration(milliseconds: 500), () {
      emit(state.copyWith(
        status: ProfileStatus.success,
        profileImage: imagePath,
      ));
    });
  }

  void reset() {
    emit(const ProfileState());
  }
}
