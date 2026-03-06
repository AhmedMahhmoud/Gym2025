import 'package:bloc/bloc.dart';
import 'package:trackletics/features/coaches/data/models/coach_model.dart';
import 'package:trackletics/features/coaches/data/repositories/coaches_repository.dart';

part 'coaches_list_state.dart';

class CoachesListCubit extends Cubit<CoachesListState> {
  CoachesListCubit({required this.coachesRepository})
      : super(const CoachesListState()) {
    loadCoaches();
  }

  final CoachesRepository coachesRepository;

  /// Fetch coaches from API. Call on tab open or after successful apply.
  Future<void> loadCoaches() async {
    emit(state.copyWith(status: CoachesListStatus.loading, errorMessage: null));

    try {
      final coaches = await coachesRepository.getCoaches();
      emit(state.copyWith(
        status: CoachesListStatus.success,
        coaches: coaches,
        errorMessage: null,
      ));
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      emit(state.copyWith(
        status: CoachesListStatus.error,
        errorMessage: message,
      ));
    }
  }
}
