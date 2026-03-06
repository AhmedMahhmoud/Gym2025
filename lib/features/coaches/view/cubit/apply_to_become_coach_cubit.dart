import 'package:bloc/bloc.dart';
import 'package:trackletics/features/coaches/data/repositories/coaches_repository.dart';

part 'apply_to_become_coach_state.dart';

class ApplyToBecomeCoachCubit extends Cubit<ApplyToBecomeCoachState> {
  ApplyToBecomeCoachCubit({required this.coachesRepository})
      : super(const ApplyToBecomeCoachInitial());

  final CoachesRepository coachesRepository;

  Future<void> submitApplication({
    required String bio,
    required String experience,
  }) async {
    emit(const ApplyToBecomeCoachLoading());

    try {
      await coachesRepository.becomeCoach(
        bio: bio.trim(),
        experience: experience.trim(),
      );
      emit(const ApplyToBecomeCoachSuccess());
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      emit(ApplyToBecomeCoachError(message: message));
    }
  }
}
