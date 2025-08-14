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
        // Search in multiple fields
        final searchableText = [
          exercise.name,
          exercise.description,
          exercise.primaryMuscle,
          exercise.category,
        ].join(' ').toLowerCase();

        // If single word query, check for word boundaries or exact matches
        if (queryWords.length == 1) {
          final singleQuery = queryWords.first;

          // Check for exact word match (word boundaries)
          final wordBoundaryPattern = RegExp(
              r'\b' + RegExp.escape(singleQuery) + r'\b',
              caseSensitive: false);
          if (wordBoundaryPattern.hasMatch(searchableText)) {
            return true;
          }

          // Check for starts with (for partial matches)
          if (searchableText.contains(singleQuery)) {
            return true;
          }
        } else {
          // Multiple word query - all words must be found
          return queryWords.every((word) => searchableText.contains(word));
        }

        return false;
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
        // Search in multiple fields
        final searchableText = [
          exercise.name,
          exercise.description,
          exercise.primaryMuscle,
          exercise.category,
        ].join(' ').toLowerCase();

        // If single word query, check for word boundaries or exact matches
        if (queryWords.length == 1) {
          final singleQuery = queryWords.first;

          // Check for exact word match (word boundaries)
          final wordBoundaryPattern = RegExp(
              r'\b' + RegExp.escape(singleQuery) + r'\b',
              caseSensitive: false);
          if (wordBoundaryPattern.hasMatch(searchableText)) {
            return true;
          }

          // Check for starts with (for partial matches)
          if (searchableText.contains(singleQuery)) {
            return true;
          }
        } else {
          // Multiple word query - all words must be found
          return queryWords.every((word) => searchableText.contains(word));
        }

        return false;
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
    );
  }
}
