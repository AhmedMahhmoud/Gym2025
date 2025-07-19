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

  Future<void> loadCustomExercises() async {
    emit(state.copyWith(status: ExerciseStatus.loading));
    try {
      final data = await exerciseRepository.fetchCustomExercises();
      data.fold(
        (failure) {
          emit(
            state.copyWith(
                status: ExerciseStatus.error, errorMessage: failure.message),
          );
        },
        (customExercises) {
          emit(
            state.copyWith(
              status: ExerciseStatus.success,
              customExercises: customExercises,
            ),
          );
        },
      );
    } catch (e) {
      emit(state.copyWith(
          status: ExerciseStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> createCustomExercise({
    required String title,
    required String description,
    required String primaryMuscle,
    String? videoUrl,
  }) async {
    emit(state.copyWith(status: ExerciseStatus.loading));
    try {
      final result = await exerciseRepository.createCustomExercise(
        title: title,
        description: description,
        primaryMuscle: primaryMuscle,
        videoUrl: videoUrl,
      );

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              status: ExerciseStatus.error,
              errorMessage: failure.message,
            ),
          );
        },
        (exercise) {
          // Add the new exercise to custom exercises list
          final updatedCustomExercises = [...state.customExercises, exercise];

          emit(
            state.copyWith(
              status: ExerciseStatus.success,
              customExercises: updatedCustomExercises,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ExerciseStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> deleteCustomExercise(String exerciseId) async {
    emit(state.copyWith(status: ExerciseStatus.loading));
    try {
      final result = await exerciseRepository.deleteCustomExercise(exerciseId);

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              status: ExerciseStatus.error,
              errorMessage: failure.message,
            ),
          );
        },
        (_) {
          // Remove the exercise from custom exercises list
          final updatedCustomExercises = state.customExercises
              .where((exercise) => exercise.id != exerciseId)
              .toList();

          emit(
            state.copyWith(
              status: ExerciseStatus.success,
              customExercises: updatedCustomExercises,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ExerciseStatus.error,
          errorMessage: e.toString(),
        ),
      );
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

  Future<void> updateExercise({
    required String exerciseName,
    required String title,
    required String description,
    String? videoUrl,
    String? picturePath,
    String? primaryMuscleId,
    String? categoryId,
  }) async {
    emit(state.copyWith(status: ExerciseStatus.loading));
    try {
      final result = await exerciseRepository.updateExercise(
        exerciseName: exerciseName,
        title: title,
        description: description,
        videoUrl: videoUrl,
        picturePath: picturePath,
        primaryMuscleId: primaryMuscleId,
        categoryId: categoryId,
      );

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              status: ExerciseStatus.error,
              errorMessage: failure.message,
            ),
          );
        },
        (updatedExercise) {
          // Update the exercise in the allExercises list
          final updatedAllExercises = state.allExercises.map((exercise) {
            if (exercise.name == exerciseName) {
              return updatedExercise;
            }
            return exercise;
          }).toList();

          // Rebuild the grouped data
          final byMuscle = <String, List<Exercise>>{};
          final byCategory = <String, List<Exercise>>{};

          for (final exercise in updatedAllExercises) {
            // Group by muscle
            byMuscle
                .putIfAbsent(exercise.primaryMuscle, () => [])
                .add(exercise);

            // Group by category
            byCategory.putIfAbsent(exercise.category, () => []).add(exercise);
          }

          emit(
            state.copyWith(
              status: ExerciseStatus.success,
              allExercises: updatedAllExercises,
              groupedByMuscle: byMuscle,
              groupedByCategory: byCategory,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ExerciseStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
