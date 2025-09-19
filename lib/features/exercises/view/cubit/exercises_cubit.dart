import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackletics/core/services/token_manager.dart';
import 'package:trackletics/features/exercises/data/models/exercises.dart';
import 'package:trackletics/features/exercises/data/models/missing_video_exercise.dart';
import 'package:trackletics/features/exercises/data/repo/exercises_repo.dart';
import 'package:trackletics/features/profile/cubit/profile_cubit.dart';

part 'exercises_state.dart';

class ExercisesCubit extends Cubit<ExercisesState> {
  ExercisesCubit({required this.exerciseRepository})
      : super(const ExercisesState());
  final ExercisesRepository exerciseRepository;

  // Single-flight guards (shared across all instances)
  static Future<void>? _inflightLoad;
  static bool _hasFetchedOnce = false;

  /// Reset static variables - useful after signout to ensure fresh data
  static void resetStaticData() {
    _inflightLoad = null;
    _hasFetchedOnce = false;
  }

  Future<void> loadExercises([
    BuildContext? context,
    bool force = false,
    bool waitForProfile = false,
  ]) async {
    if (!force && _hasFetchedOnce) return;
    if (!force && _inflightLoad != null) {
      await _inflightLoad; // Wait for the in-flight call to finish
      return;
    }

    final completer = Completer<void>();
    _inflightLoad = completer.future;

    emit(state.copyWith(status: ExerciseStatus.loading));
    try {
      // Optionally wait for ProfileCubit to provide roles/gender
      if (waitForProfile && context != null) {
        try {
          final profileCubit = context.read<ProfileCubit>();
          final current = profileCubit.state;
          bool ready = (current.roles.isNotEmpty) || (current.gender != null);
          if (!ready) {
            await profileCubit.stream.firstWhere((s) {
              try {
                return s.roles.isNotEmpty ||
                    (s.gender != null && s.gender!.isNotEmpty);
              } catch (_) {
                return false;
              }
            });
          }
        } catch (_) {}
      }

      // Always read claims from TokenManager to avoid timing/race
      final tokenManager = TokenManager();
      String role = 'user';
      final roles = await tokenManager.getRoles();
      if (roles.isNotEmpty) role = roles.first;
      final String? gender = await tokenManager.getGender();

      String? filterOn;
      String? filterQuery;
      if (state.selectedFilterType != FilterType.none &&
          state.selectedChip != null &&
          state.selectedChip!.isNotEmpty) {
        filterOn = state.selectedFilterType == FilterType.muscle
            ? 'muscle'
            : 'category';
        filterQuery = state.selectedChip;
      }

      final data = await exerciseRepository.fetchExercises(
        role: role,
        gender: gender,
        filterOn: filterOn,
        filterQuery: filterQuery,
      );
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
            byMuscle
                .putIfAbsent(exercise.primaryMuscle, () => [])
                .add(exercise);
            byCategory.putIfAbsent(exercise.category, () => []).add(exercise);
          }

          _hasFetchedOnce = true;
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
    } finally {
      completer.complete();
      _inflightLoad = null;
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

  Future<void> updateCustomExercise({
    required String exerciseId,
    required String title,
    required String description,
    required String primaryMuscle,
    String? videoUrl,
  }) async {
    emit(state.copyWith(status: ExerciseStatus.loading));
    try {
      final result = await exerciseRepository.updateCustomExercise(
        exerciseId: exerciseId,
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
        (updatedExercise) {
          final updatedCustomExercises = state.customExercises.map((exercise) {
            if (exercise.id == exerciseId) {
              return updatedExercise;
            }
            return exercise;
          }).toList();

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
    // Refetch from server with filter
    loadExercises(null, true);
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
    // Refetch all from server without filter
    _hasFetchedOnce = false;
    loadExercises(null, true);
  }

  Future<void> updateExercise({
    required String exerciseId,
    required String title,
    required String description,
    String? videoUrl,
    String? maleVideoUrl,
    String? femaleVideoUrl,
    String? picturePath,
    String? primaryMuscleId,
    String? categoryId,
  }) async {
    emit(state.copyWith(status: ExerciseStatus.loading));
    try {
      final result = await exerciseRepository.updateExercise(
        exerciseId: exerciseId,
        title: title,
        description: description,
        videoUrl: videoUrl,
        maleVideoUrl: maleVideoUrl,
        femaleVideoUrl: femaleVideoUrl,
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
          final updatedAllExercises = state.allExercises.map((exercise) {
            if (exercise.id == exerciseId) {
              return updatedExercise;
            }
            return exercise;
          }).toList();

          final byMuscle = <String, List<Exercise>>{};
          final byCategory = <String, List<Exercise>>{};

          for (final exercise in updatedAllExercises) {
            byMuscle
                .putIfAbsent(exercise.primaryMuscle, () => [])
                .add(exercise);
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

  Future<void> loadMissingVideos() async {
    emit(state.copyWith(missingVideosStatus: ExerciseStatus.loading));
    try {
      final data = await exerciseRepository.fetchExercisesMissingVideos();
      data.fold(
        (failure) {
          emit(state.copyWith(
            missingVideosStatus: ExerciseStatus.error,
            errorMessage: failure.message,
          ));
        },
        (missing) {
          emit(state.copyWith(
            missingVideosStatus: ExerciseStatus.success,
            missingVideos: missing,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        missingVideosStatus: ExerciseStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
