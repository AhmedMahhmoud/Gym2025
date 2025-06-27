import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gym/core/theme/app_colors.dart';
import 'package:gym/core/utils/shared_utils.dart';
import 'package:gym/features/exercises/view/cubit/exercises_cubit.dart';
import 'package:gym/features/exercises/view/widgets/custom_exercise_form.dart';
import 'package:gym/features/workouts/cubits/workouts_cubit.dart';
import 'package:gym/Shared/ui/custom_snackbar.dart';
import 'package:gym/routes/route_names.dart';
import 'package:gym/features/exercises/data/models/exercises.dart';

class AddExerciseBottomSheet extends StatefulWidget {
  const AddExerciseBottomSheet({super.key});

  @override
  State<AddExerciseBottomSheet> createState() => _AddExerciseBottomSheetState();
}

class _AddExerciseBottomSheetState extends State<AddExerciseBottomSheet>
    with SingleTickerProviderStateMixin {
  bool _isSelectingCategory = true;
  FilterType _selectedFilterType = FilterType.none;
  String? _selectedCategory;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final List<String> _selectedExerciseIds = [];
  final List<String> _selectedCustomExerciseIds = [];
  late TabController _tabController;
  bool _isCustomExercise = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _isCustomExercise = _tabController.index == 1;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
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

      // Track the exercise ID based on whether it's a custom exercise
      if (_isCustomExercise) {
        _selectedCustomExerciseIds.add(exercise.id);
      } else {
        _selectedExerciseIds.add(exercise.id);
      }

      CustomSnackbar.show(
        context,
        '${exercise.name} added to workout',
        isError: false,
      );
      // Force rebuild of the bottom sheet
      setState(() {});
    } catch (e) {
      CustomSnackbar.show(
        context,
        'Failed to add exercise',
        isError: true,
      );
    }
  }

  Future<void> _handleClose() async {
    if (_selectedExerciseIds.isNotEmpty ||
        _selectedCustomExerciseIds.isNotEmpty) {
      final workoutsCubit = context.read<WorkoutsCubit>();
      await workoutsCubit.addExercisesToWorkout(
        _selectedExerciseIds,
        customExerciseIds: _selectedCustomExerciseIds,
      );
      _selectedExerciseIds.clear();
      _selectedCustomExerciseIds.clear();
    }
    Navigator.pop(context);
  }

  List<Exercise> _getFilteredExercises(ExercisesState state) {
    if (_isCustomExercise) {
      return state.filteredCustomExercises;
    }

    if (_selectedFilterType == FilterType.none) return [];

    Map<String, List<Exercise>> groupedExercises;

    if (_selectedFilterType == FilterType.muscle) {
      groupedExercises = state.groupedByMuscle;
    } else {
      groupedExercises = state.groupedByCategory;
    }

    final exercises = groupedExercises[_selectedCategory] ?? [];

    // Use the cubit's search query (which is the same as _searchQuery now)
    if (state.searchQuery.isEmpty) return exercises;

    return exercises
        .where((exercise) =>
            exercise.name
                .toLowerCase()
                .contains(state.searchQuery.toLowerCase()) ||
            exercise.description
                .toLowerCase()
                .contains(state.searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExercisesCubit, ExercisesState>(
      builder: (context, state) {
        return StatefulBuilder(
          builder: (context, setState) {
            return WillPopScope(
              onWillPop: () async {
                await _handleClose();
                return true;
              },
              child: Container(
                height: MediaQuery.of(context).size.height * 0.7,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                        const Text(
                          'Add workout exercise',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          children: [
                            if (!_isSelectingCategory && !_isCustomExercise)
                              IconButton(
                                onPressed: _goBackToCategories,
                                icon: const Icon(Icons.arrow_back),
                              ),
                            IconButton(
                              onPressed: _handleClose,
                              icon: const Icon(FontAwesomeIcons.circleXmark),
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 5),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Tab Bar
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: AppColors.primary,
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey,
                        tabs: const [
                          Tab(text: 'All Exercises'),
                          Tab(text: 'Custom Exercises'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Main content area
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // All Exercises Tab
                          _isSelectingCategory
                              ? _buildCategorySelection(state)
                              : _buildExerciseSelection(context, state),
                          // Custom Exercises Tab
                          _buildCustomExerciseSelection(context, state),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCategorySelection(ExercisesState state) {
    return SingleChildScrollView(
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
    );
  }

  Widget _buildExerciseSelection(BuildContext context, ExercisesState state) {
    final filteredExercises = _getFilteredExercises(state);
    final workoutsCubit = context.read<WorkoutsCubit>();
    final selectedExercises = workoutsCubit.state.selectedExercises;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search field
        TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
            // Update the ExercisesCubit search query for consistent filtering
            context.read<ExercisesCubit>().setSearchQuery(value);
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
                    final isAdded =
                        selectedExercises.any((e) => e.id == exercise.id);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: isAdded
                          ? AppColors.background.withOpacity(0.5)
                          : AppColors.background,
                      child: ListTile(
                        title: Text(
                          exercise.name,
                          style: TextStyle(
                            color:
                                Colors.white.withOpacity(isAdded ? 0.7 : 1.0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          exercise.primaryMuscle ?? '',
                          style: TextStyle(
                            color:
                                Colors.white70.withOpacity(isAdded ? 0.7 : 1.0),
                          ),
                        ),
                        leading: IconButton(
                          icon: Icon(
                            FontAwesomeIcons.circleInfo,
                            color:
                                Colors.white70.withOpacity(isAdded ? 0.7 : 1.0),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              RouteNames.exercise_details_route,
                              arguments: [
                                exercise,
                                SharedUtils.extractThumbnail(exercise.videoUrl)
                              ],
                            );
                          },
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            isAdded ? Icons.check_circle : Icons.add_circle,
                            color: isAdded ? Colors.green : AppColors.primary,
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
    );
  }

  Widget _buildCustomExerciseSelection(
      BuildContext context, ExercisesState state) {
    final customExercises = state.filteredCustomExercises;
    final workoutsCubit = context.read<WorkoutsCubit>();
    final selectedExercises = workoutsCubit.state.selectedExercises;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search field
        TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
            // Update the ExercisesCubit search query to filter custom exercises
            context.read<ExercisesCubit>().setSearchQuery(value);
          },
          decoration: InputDecoration(
            hintText: 'Search custom exercises...',
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
        const SizedBox(height: 12),

        // Add custom exercise row
        Row(
          children: [
            const Expanded(
              child: Text(
                'Add new custom exercise?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _navigateToCustomExerciseForm(context),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Custom Exercises list
        Expanded(
          child: customExercises.isEmpty
              ? const Center(
                  child: Text(
                    'No custom exercises found',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  itemCount: customExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = customExercises[index];
                    final isAdded =
                        selectedExercises.any((e) => e.id == exercise.id);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: isAdded
                          ? AppColors.background.withOpacity(0.5)
                          : AppColors.background,
                      child: ListTile(
                        title: Text(
                          exercise.name,
                          style: TextStyle(
                            color:
                                Colors.white.withOpacity(isAdded ? 0.7 : 1.0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          exercise.primaryMuscle ?? '',
                          style: TextStyle(
                            color:
                                Colors.white70.withOpacity(isAdded ? 0.7 : 1.0),
                          ),
                        ),
                        leading: IconButton(
                          icon: Icon(
                            FontAwesomeIcons.circleInfo,
                            color:
                                Colors.white70.withOpacity(isAdded ? 0.7 : 1.0),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              RouteNames.exercise_details_route,
                              arguments: [
                                exercise,
                                SharedUtils.extractThumbnail(exercise.videoUrl)
                              ],
                            );
                          },
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            isAdded ? Icons.check_circle : Icons.add_circle,
                            color: isAdded ? Colors.green : AppColors.primary,
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
    );
  }

  // Navigate to custom exercise form and handle the result
  Future<void> _navigateToCustomExerciseForm(BuildContext context) async {
    // Navigate to custom exercise form and wait for result
    final Exercise? newExercise = await Navigator.push<Exercise>(
      context,
      MaterialPageRoute(
        builder: (context) => const CustomExerciseForm(),
      ),
    );

    // If an exercise was created, add it to the current state without API call
    if (mounted && newExercise != null) {
      // Get current cubit and state
      final exercisesCubit = context.read<ExercisesCubit>();
      final currentState = exercisesCubit.state;

      // Create updated custom exercises list with the new exercise
      final updatedCustomExercises = [...currentState.customExercises];

      // Check if exercise already exists to avoid duplicates
      if (!updatedCustomExercises.any((e) => e.id == newExercise.id)) {
        updatedCustomExercises.add(newExercise);

        // Update state directly without API call
        exercisesCubit.emit(currentState.copyWith(
          customExercises: updatedCustomExercises,
        ));
      }
    }
  }
}
