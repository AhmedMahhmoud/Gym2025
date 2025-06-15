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

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      exercises = exercises
          .where((exercise) =>
              exercise.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              exercise.description
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()))
          .toList();
    }

    // Apply category/muscle filter
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

    return exercises;
  }

  List<Exercise> get filteredCustomExercises {
    var exercises = customExercises;

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      exercises = exercises
          .where((exercise) =>
              exercise.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              exercise.description
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()))
          .toList();
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
