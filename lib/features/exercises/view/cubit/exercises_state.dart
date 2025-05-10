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
    this.errorMessage,
    this.groupedByMuscle = const {},
    this.groupedByCategory = const {},
    this.searchQuery = '',
    this.selectedFilterType = FilterType.none,
    this.selectedChip,
  });
  final ExerciseStatus status;
  final List<Exercise> allExercises;
  final String? errorMessage;
  final Map<String, List<Exercise>> groupedByMuscle;
  final Map<String, List<Exercise>> groupedByCategory;
  final String searchQuery;
  final String? selectedChip;
  final FilterType selectedFilterType;
  ExercisesState copyWith({
    ExerciseStatus? status,
    List<Exercise>? allExercises,
    Map<String, List<Exercise>>? groupedByMuscle,
    Map<String, List<Exercise>>? groupedByCategory,
    String? errorMessage,
    String? searchQuery,
    FilterType? selectedFilterType,
    String? selectedChip,
  }) {
    return ExercisesState(
      status: status ?? this.status,
      allExercises: allExercises ?? this.allExercises,
      groupedByMuscle: groupedByMuscle ?? this.groupedByMuscle,
      groupedByCategory: groupedByCategory ?? this.groupedByCategory,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFilterType: selectedFilterType ?? this.selectedFilterType,
      selectedChip: selectedChip ?? selectedChip,
    );
  }

  List<Exercise> get filteredExercises {
    List<Exercise> baseList = allExercises;

    // Filter by chip and type
    if (selectedFilterType == FilterType.muscle && selectedChip != null) {
      baseList = groupedByMuscle[selectedChip!] ?? [];
    } else if (selectedFilterType == FilterType.category &&
        selectedChip != null) {
      baseList = groupedByCategory[selectedChip!] ?? [];
    }

    // Apply search query filter
    if (searchQuery.isNotEmpty) {
      baseList = baseList
          .where((ex) =>
              ex.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              ex.primaryMuscle
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()))
          .toList();
    }

    return baseList;
  }
}
