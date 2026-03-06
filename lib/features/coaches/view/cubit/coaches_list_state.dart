part of 'coaches_list_cubit.dart';

enum CoachesListStatus { initial, loading, success, error }

class CoachesListState {
  const CoachesListState({
    this.status = CoachesListStatus.initial,
    this.coaches = const [],
    this.errorMessage,
  });

  final CoachesListStatus status;
  final List<CoachModel> coaches;
  final String? errorMessage;

  CoachesListState copyWith({
    CoachesListStatus? status,
    List<CoachModel>? coaches,
    String? errorMessage,
  }) {
    return CoachesListState(
      status: status ?? this.status,
      coaches: coaches ?? this.coaches,
      errorMessage: errorMessage,
    );
  }
}
