import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:gym/features/exercises/data/models/exercises.dart';
import 'package:gym/features/exercises/data/repo/exercises_repo.dart';

part 'exercises_state.dart';

class ExercisesCubit extends Cubit<ExercisesState> {
  ExercisesCubit({required this.exerciseRepository})
      : super(const ExercisesState());
  final ExercisesRepository exerciseRepository;

  Future<void> loadExercises() async {
    emit(state.copyWith(status: ExerciseStatus.loading));
    try {
      final data = await exerciseRepository.fetchExercises();
      data.fold(
        (failure) {
          emit(
            state.copyWith(
                status: ExerciseStatus.error, errorMessage: failure.message),
          );
        },
        (exercises) {
          final byMuscle = <String, List<Exercise>>{};
          final byCategory = <String, List<Exercise>>{};

          for (final exercise in exercises) {
            // Group by muscle
            byMuscle
                .putIfAbsent(exercise.primaryMuscle, () => [])
                .add(exercise);

            // Group by category
            byCategory.putIfAbsent(exercise.category, () => []).add(exercise);
          }
          log(exercises.toString());
          emit(
            state.copyWith(
              status: ExerciseStatus.success,
              allExercises: exercises,
              groupedByMuscle: byMuscle,
              groupedByCategory: byCategory,
            ),
          );
        },
      );
    } catch (e) {
      emit(state.copyWith(
          status: ExerciseStatus.error, errorMessage: e.toString()));
    }
  }

  void setFilter({
    required FilterType type,
    required String chipValue,
  }) {
    emit(state.copyWith(
      selectedFilterType: type,
      selectedChip: chipValue,
    ));
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void setFilterType(FilterType type) {
    emit(state.copyWith(
      selectedFilterType: type,
      selectedChip: null, // Reset chip when changing filter type
    ));
  }

  void selectChip(String chip) {
    emit(state.copyWith(selectedChip: chip));
  }

  void clearFilter() {
    emit(state.copyWith(
      selectedFilterType: FilterType.none,
      selectedChip: null,
    ));
  }
}
