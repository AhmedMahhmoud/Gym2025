part of 'exercises_cubit.dart';

enum ExerciseStatus { initial, loading, success, error }

enum FilterType {
  none,
  muscle,
  category,
}

class ExercisesState {
  const ExercisesState({
    this.status = ExerciseStatus.initial,
    this.allExercises = const [],
    this.customExercises = const [],
    this.groupedByMuscle = const {},
    this.groupedByCategory = const {},
    this.selectedFilterType = FilterType.none,
    this.selectedChip,
    this.searchQuery = '',
    this.errorMessage,
    this.missingVideos = const [],
    this.missingVideosStatus = ExerciseStatus.initial,
  });

  final ExerciseStatus status;
  final List<Exercise> allExercises;
  final List<Exercise> customExercises;
  final Map<String, List<Exercise>> groupedByMuscle;
  final Map<String, List<Exercise>> groupedByCategory;
  final FilterType selectedFilterType;
  final String? selectedChip;
  final String searchQuery;
  final String? errorMessage;
  final List<MissingVideoExercise> missingVideos;
  final ExerciseStatus missingVideosStatus;

  List<Exercise> get filteredExercises {
    var exercises = allExercises;

    // Apply category/muscle filter FIRST (if it's from API filtering)
    if (selectedFilterType != FilterType.none && selectedChip != null) {
      switch (selectedFilterType) {
        case FilterType.muscle:
          exercises = groupedByMuscle[selectedChip] ?? [];
          break;
        case FilterType.category:
          exercises = groupedByCategory[selectedChip] ?? [];
          break;
        case FilterType.none:
          break;
      }
    }

    // Apply search filter AFTER category/muscle filter
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();
      final queryWords =
          query.split(' ').where((word) => word.isNotEmpty).toList();

      exercises = exercises.where((exercise) {
        // Search only in exercise name/title
        final exerciseName = exercise.name.toLowerCase();
        final exerciseWords =
            exerciseName.split(' ').where((word) => word.isNotEmpty).toList();

        // If single word query, check if any word in exercise name starts with the query
        if (queryWords.length == 1) {
          final singleQuery = queryWords.first;
          return exerciseWords.any((word) => word.startsWith(singleQuery));
        } else {
          // Multiple word query - check if all query words match words in exercise name
          // Each query word must start with a word in the exercise name
          return queryWords.every((queryWord) => exerciseWords
              .any((exerciseWord) => exerciseWord.startsWith(queryWord)));
        }
      }).toList();
    }

    return exercises;
  }

  List<Exercise> get filteredCustomExercises {
    var exercises = customExercises;

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();
      final queryWords =
          query.split(' ').where((word) => word.isNotEmpty).toList();

      exercises = exercises.where((exercise) {
        // Search only in exercise name/title
        final exerciseName = exercise.name.toLowerCase();
        final exerciseWords =
            exerciseName.split(' ').where((word) => word.isNotEmpty).toList();

        // If single word query, check if any word in exercise name starts with the query
        if (queryWords.length == 1) {
          final singleQuery = queryWords.first;
          return exerciseWords.any((word) => word.startsWith(singleQuery));
        } else {
          // Multiple word query - check if all query words match words in exercise name
          // Each query word must start with a word in the exercise name
          return queryWords.every((queryWord) => exerciseWords
              .any((exerciseWord) => exerciseWord.startsWith(queryWord)));
        }
      }).toList();
    }

    return exercises;
  }

  ExercisesState copyWith({
    ExerciseStatus? status,
    List<Exercise>? allExercises,
    List<Exercise>? customExercises,
    Map<String, List<Exercise>>? groupedByMuscle,
    Map<String, List<Exercise>>? groupedByCategory,
    FilterType? selectedFilterType,
    String? selectedChip,
    String? searchQuery,
    String? errorMessage,
    List<MissingVideoExercise>? missingVideos,
    ExerciseStatus? missingVideosStatus,
  }) {
    return ExercisesState(
      status: status ?? this.status,
      allExercises: allExercises ?? this.allExercises,
      customExercises: customExercises ?? this.customExercises,
      groupedByMuscle: groupedByMuscle ?? this.groupedByMuscle,
      groupedByCategory: groupedByCategory ?? this.groupedByCategory,
      selectedFilterType: selectedFilterType ?? this.selectedFilterType,
      selectedChip: selectedChip ?? this.selectedChip,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
      missingVideos: missingVideos ?? this.missingVideos,
      missingVideosStatus: missingVideosStatus ?? this.missingVideosStatus,
    );
  }
}
