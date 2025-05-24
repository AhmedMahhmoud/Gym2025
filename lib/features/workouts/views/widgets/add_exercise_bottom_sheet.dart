import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gym/core/theme/app_colors.dart';
import 'package:gym/core/utils/shared_utils.dart';
import 'package:gym/features/exercises/view/cubit/exercises_cubit.dart';
import 'package:gym/features/workouts/cubits/workouts_cubit.dart';
import 'package:gym/Shared/ui/custom_snackbar.dart';
import 'package:gym/routes/route_names.dart';
import 'package:gym/features/exercises/data/models/exercises.dart';

class AddExerciseBottomSheet extends StatefulWidget {
  const AddExerciseBottomSheet({super.key});

  @override
  State<AddExerciseBottomSheet> createState() => _AddExerciseBottomSheetState();
}

class _AddExerciseBottomSheetState extends State<AddExerciseBottomSheet> {
  bool _isSelectingCategory = true;
  FilterType _selectedFilterType = FilterType.none;
  String? _selectedCategory;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectCategory(FilterType type, String category) {
    setState(() {
      _selectedFilterType = type;
      _selectedCategory = category;
      _isSelectingCategory = false;
    });
  }

  void _goBackToCategories() {
    setState(() {
      _isSelectingCategory = true;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  void _addExerciseToWorkout(BuildContext context, Exercise exercise) {
    final workoutsCubit = context.read<WorkoutsCubit>();
    final selectedExercises = workoutsCubit.state.selectedExercises;

    // Check if exercise already exists in the workout
    final exerciseExists = selectedExercises.any((e) => e.id == exercise.id);

    if (exerciseExists) {
      CustomSnackbar.show(
        context,
        '${exercise.name} is already added to this workout',
        isError: true,
      );
      return;
    }

    try {
      workoutsCubit.addExerciseToWorkoutLocally(exercise);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add exercise')),
      );
    }
  }

  List<Exercise> _getFilteredExercises(ExercisesState state) {
    if (_selectedFilterType == FilterType.none) return [];

    Map<String, List<Exercise>> groupedExercises;

    if (_selectedFilterType == FilterType.muscle) {
      groupedExercises = state.groupedByMuscle;
    } else {
      groupedExercises = state.groupedByCategory;
    }

    final exercises = groupedExercises[_selectedCategory] ?? [];

    if (_searchQuery.isEmpty) return exercises;

    return exercises
        .where((exercise) =>
            exercise.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExercisesCubit, ExercisesState>(
      builder: (context, state) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isSelectingCategory
                        ? 'Select Category'
                        : 'Select Exercise',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      if (!_isSelectingCategory)
                        IconButton(
                          onPressed: _goBackToCategories,
                          icon: const Icon(Icons.arrow_back),
                        ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(FontAwesomeIcons.circleXmark),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 5),
              const Divider(),
              if (_isSelectingCategory) ...[
                _buildCategorySelection(state),
              ] else ...[
                _buildExerciseSelection(context, state),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategorySelection(ExercisesState state) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'By Muscle',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: state.groupedByMuscle.keys.map((muscle) {
                return FilterChip(
                  label: Text(muscle),
                  selected: false,
                  onSelected: (_) => _selectCategory(FilterType.muscle, muscle),
                  selectedColor: AppColors.primary,
                  labelStyle: const TextStyle(color: AppColors.textPrimary),
                  backgroundColor: AppColors.background,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const Text(
              'By Category',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: state.groupedByCategory.keys.map((category) {
                return FilterChip(
                  label: Text(category),
                  selected: false,
                  onSelected: (_) =>
                      _selectCategory(FilterType.category, category),
                  selectedColor: AppColors.primary,
                  labelStyle: const TextStyle(color: AppColors.textPrimary),
                  backgroundColor: AppColors.background,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseSelection(BuildContext context, ExercisesState state) {
    final filteredExercises = _getFilteredExercises(state);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search field
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search exercises...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 16),

          // Category title
          Text(
            _selectedCategory ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),

          // Exercise list
          Expanded(
            child: filteredExercises.isEmpty
                ? const Center(
                    child: Text(
                      'No exercises found',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredExercises.length,
                    itemBuilder: (context, index) {
                      final exercise = filteredExercises[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: AppColors.background,
                        child: ListTile(
                          title: Text(
                            exercise.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            exercise.primaryMuscle ?? '',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          leading: IconButton(
                              icon: const Icon(
                                FontAwesomeIcons.circleInfo,
                                color: Colors.white70,
                              ),
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, RouteNames.exercise_details_route,
                                    arguments: [
                                      exercise,
                                      SharedUtils.extractThumbnail(
                                          exercise.videoUrl)
                                    ]);
                              }),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.add_circle,
                              color: AppColors.primary,
                            ),
                            onPressed: () =>
                                _addExerciseToWorkout(context, exercise),
                          ),
                          onTap: () => _addExerciseToWorkout(context, exercise),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
