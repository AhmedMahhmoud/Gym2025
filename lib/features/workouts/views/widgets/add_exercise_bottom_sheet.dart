import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trackletics/core/theme/app_colors.dart';
import 'package:trackletics/core/utils/shared_utils.dart';
import 'package:trackletics/features/exercises/view/cubit/exercises_cubit.dart';
import 'package:trackletics/features/exercises/view/widgets/custom_exercise_form.dart';
import 'package:trackletics/features/exercises/view/widgets/update_custom_exercise_form.dart';
import 'package:trackletics/features/workouts/cubits/workouts_cubit.dart';
import 'package:trackletics/features/workouts/cubits/workouts_state.dart';
import 'package:trackletics/Shared/ui/custom_snackbar.dart';
import 'package:trackletics/routes/route_names.dart';
import 'package:trackletics/features/exercises/data/models/exercises.dart';
import 'package:trackletics/features/profile/cubit/profile_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
// import 'package:trackletics/core/debug/api_logger_model.dart';

class AddExerciseBottomSheet extends StatefulWidget {
  const AddExerciseBottomSheet({super.key});

  @override
  State<AddExerciseBottomSheet> createState() => _AddExerciseBottomSheetState();
}

class _AddExerciseBottomSheetState extends State<AddExerciseBottomSheet>
    with SingleTickerProviderStateMixin {
  final TextEditingController _allExercisesSearchController =
      TextEditingController();
  final TextEditingController _customExercisesSearchController =
      TextEditingController();
  final List<String> _selectedExerciseIds = [];
  final List<String> _selectedCustomExerciseIds = [];
  late TabController _tabController;
  bool _isCustomExercise = false;

  // Local filter state for add exercise bottom sheet
  FilterType _localFilterType = FilterType.none;
  String? _localSelectedChip;
  String? _localSelectedMuscle;
  String? _localSelectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _isCustomExercise = _tabController.index == 1;
      });
      // Clear search controllers when switching tabs to maintain independent search states
      if (_isCustomExercise) {
        _allExercisesSearchController.clear();
      } else {
        _customExercisesSearchController.clear();
      }
    });
  }

  @override
  void dispose() {
    _allExercisesSearchController.dispose();
    _customExercisesSearchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  String _getFilterButtonText(ExercisesState state) {
    if (_localFilterType == FilterType.both) {
      if (_localSelectedMuscle != null && _localSelectedCategory != null) {
        return 'Dual: $_localSelectedMuscle + $_localSelectedCategory';
      } else if (_localSelectedMuscle != null) {
        return 'Muscle: $_localSelectedMuscle';
      } else if (_localSelectedCategory != null) {
        return 'Category: $_localSelectedCategory';
      }
    } else if (_localFilterType != FilterType.none &&
        _localSelectedChip != null) {
      return '${_localFilterType.name}: $_localSelectedChip';
    }
    return 'workouts.filter'.tr();
  }

  List<Exercise> _getLocallyFilteredExercises(List<Exercise> exercises) {
    var filteredExercises = exercises;

    // Apply local dual filtering (both muscle and category)
    if (_localFilterType == FilterType.both) {
      // If both are selected, filter by both
      if (_localSelectedMuscle != null && _localSelectedCategory != null) {
        // Filter by both muscle and category
        final muscleExercises = exercises
            .where((exercise) => exercise.primaryMuscle == _localSelectedMuscle)
            .toList();
        final categoryExercises = exercises
            .where((exercise) => exercise.category == _localSelectedCategory)
            .toList();

        // Find intersection of both filters
        filteredExercises = muscleExercises
            .where((muscleExercise) => categoryExercises.any(
                (categoryExercise) => categoryExercise.id == muscleExercise.id))
            .toList();
      }
      // If only muscle is selected
      else if (_localSelectedMuscle != null) {
        filteredExercises = exercises
            .where((exercise) => exercise.primaryMuscle == _localSelectedMuscle)
            .toList();
      }
      // If only category is selected
      else if (_localSelectedCategory != null) {
        filteredExercises = exercises
            .where((exercise) => exercise.category == _localSelectedCategory)
            .toList();
      }
    }
    // Apply local single filter (muscle or category using old chip method)
    else if (_localFilterType != FilterType.none &&
        _localSelectedChip != null) {
      switch (_localFilterType) {
        case FilterType.muscle:
          filteredExercises = exercises
              .where((exercise) => exercise.primaryMuscle == _localSelectedChip)
              .toList();
          break;
        case FilterType.category:
          filteredExercises = exercises
              .where((exercise) => exercise.category == _localSelectedChip)
              .toList();
          break;
        case FilterType.none:
        case FilterType.both:
          break;
      }
    }

    // Apply search filter
    if (_allExercisesSearchController.text.isNotEmpty) {
      final query = _allExercisesSearchController.text.trim().toLowerCase();
      final queryWords =
          query.split(' ').where((word) => word.isNotEmpty).toList();

      filteredExercises = filteredExercises.where((exercise) {
        final exerciseName = exercise.name.toLowerCase();
        final exerciseWords =
            exerciseName.split(' ').where((word) => word.isNotEmpty).toList();

        if (queryWords.length == 1) {
          final singleQuery = queryWords.first;
          return exerciseWords.any((word) => word.startsWith(singleQuery));
        } else {
          return queryWords.every((queryWord) => exerciseWords
              .any((exerciseWord) => exerciseWord.startsWith(queryWord)));
        }
      }).toList();
    }

    return filteredExercises;
  }

  List<Exercise> _getLocallyFilteredCustomExercises(List<Exercise> exercises) {
    var filteredExercises = exercises;

    // Apply search filter for custom exercises
    if (_customExercisesSearchController.text.isNotEmpty) {
      final query = _customExercisesSearchController.text.trim().toLowerCase();
      final queryWords =
          query.split(' ').where((word) => word.isNotEmpty).toList();

      filteredExercises = filteredExercises.where((exercise) {
        final exerciseName = exercise.name.toLowerCase();
        final exerciseWords =
            exerciseName.split(' ').where((word) => word.isNotEmpty).toList();

        if (queryWords.length == 1) {
          final singleQuery = queryWords.first;
          return exerciseWords.any((word) => word.startsWith(singleQuery));
        } else {
          return queryWords.every((queryWord) => exerciseWords
              .any((exerciseWord) => exerciseWord.startsWith(queryWord)));
        }
      }).toList();
    }

    return filteredExercises;
  }

  void _showFilterOptions(BuildContext context, ExercisesState state) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildLocalFilterBottomSheet(context, state),
    );
  }

  Widget _buildLocalFilterBottomSheet(
      BuildContext context, ExercisesState state) {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header (fixed)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'workouts.filter_exercises'.tr(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                setModalState(() {
                                  _localFilterType = FilterType.none;
                                  _localSelectedChip = null;
                                  _localSelectedMuscle = null;
                                  _localSelectedCategory = null;
                                });
                                setState(() {});
                              },
                              child: const Icon(FontAwesomeIcons.refresh),
                            ),
                            const SizedBox(width: 15),
                            InkWell(
                              onTap: () => Navigator.pop(context),
                              child: const Icon(FontAwesomeIcons.circleXmark),
                            ),
                          ],
                        )
                      ],
                    ),
                    const Divider(),
                  ],
                ),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Show current filter selections if any
                      if (_localFilterType == FilterType.both &&
                          (_localSelectedMuscle != null ||
                              _localSelectedCategory != null))
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.filter_alt,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Theme.of(context).colorScheme.primary,
                                  size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _localSelectedMuscle != null &&
                                          _localSelectedCategory != null
                                      ? 'Dual Filter: $_localSelectedMuscle + $_localSelectedCategory'
                                      : _localSelectedMuscle != null
                                          ? 'Muscle Selected: $_localSelectedMuscle (select category for dual filter)'
                                          : 'Category Selected: $_localSelectedCategory (select muscle for dual filter)',
                                  style: TextStyle(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Theme.of(context).colorScheme.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Filter by muscle
                      Text('workouts.by_muscle'.tr(),
                          style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 17)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: state.groupedByMuscle.keys.map((muscle) {
                          final isSelected =
                              (_localFilterType == FilterType.muscle &&
                                      _localSelectedChip == muscle) ||
                                  (_localFilterType == FilterType.both &&
                                      _localSelectedMuscle == muscle);
                          return FilterChip(
                            checkmarkColor: Colors.white,
                            label: Text(muscle),
                            selected: isSelected,
                            onSelected: (_) {
                              setModalState(() {
                                if (isSelected) {
                                  _localSelectedMuscle = null;
                                  if (_localSelectedCategory == null) {
                                    _localFilterType = FilterType.none;
                                  }
                                } else {
                                  _localSelectedMuscle = muscle;
                                  _localFilterType = FilterType.both;
                                  _localSelectedChip = null;
                                }
                              });
                              setState(() {});
                            },
                            selectedColor:
                                Theme.of(context).colorScheme.primary,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                            ),
                            backgroundColor:
                                Theme.of(context).colorScheme.surface,
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 16),
                      const Divider(),

                      // Filter by category
                      Text('workouts.by_category'.tr(),
                          style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 17)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: state.groupedByCategory.keys.map((category) {
                          final isSelected =
                              (_localFilterType == FilterType.category &&
                                      _localSelectedChip == category) ||
                                  (_localFilterType == FilterType.both &&
                                      _localSelectedCategory == category);
                          return FilterChip(
                            checkmarkColor: Colors.white,
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (_) {
                              setModalState(() {
                                if (isSelected) {
                                  _localSelectedCategory = null;
                                  if (_localSelectedMuscle == null) {
                                    _localFilterType = FilterType.none;
                                  }
                                } else {
                                  _localSelectedCategory = category;
                                  _localFilterType = FilterType.both;
                                  _localSelectedChip = null;
                                }
                              });
                              setState(() {});
                            },
                            selectedColor:
                                Theme.of(context).colorScheme.primary,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                            ),
                            backgroundColor:
                                Theme.of(context).colorScheme.surface,
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Fixed bottom button
              Container(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'exercises.apply_filter'.tr(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addExerciseToWorkout(BuildContext context, Exercise exercise) {
    final workoutsCubit = context.read<WorkoutsCubit>();
    final selectedExercises = workoutsCubit.state.selectedExercises;

    // Check if user is admin when viewing static plans
    if (workoutsCubit.state.isViewingStaticPlans) {
      final isAdmin = context.read<ProfileCubit>().state.isAdmin;
      if (!isAdmin) {
        CustomSnackbar.show(
          context,
          'workouts.only_admins_can_add'.tr(),
          isError: true,
        );
        return;
      }
    }

    // Check if exercise already exists in the workout (already saved to backend)
    final exerciseExistsInWorkout =
        selectedExercises.any((e) => e.id == exercise.id);

    if (exerciseExistsInWorkout) {
      CustomSnackbar.show(
        context,
        'workouts.exercise_already_added'
            .tr(namedArgs: {'name': exercise.name}),
        isError: true,
      );
      return;
    }

    try {
      // Check if exercise is already in the selection list (toggle off)
      bool wasSelected = false;
      if (_isCustomExercise) {
        if (_selectedCustomExerciseIds.contains(exercise.id)) {
          _selectedCustomExerciseIds.remove(exercise.id);
          wasSelected = true;
        } else {
          _selectedCustomExerciseIds.add(exercise.id);
        }
      } else {
        if (_selectedExerciseIds.contains(exercise.id)) {
          _selectedExerciseIds.remove(exercise.id);
          wasSelected = true;
        } else {
          _selectedExerciseIds.add(exercise.id);
        }
      }

      if (wasSelected) {
        CustomSnackbar.show(
          context,
          'workouts.exercise_removed_from_selection'
              .tr(namedArgs: {'name': exercise.name}),
          isError: false,
        );
      } else {
        CustomSnackbar.show(
          context,
          'workouts.exercise_added_to_workout'
              .tr(namedArgs: {'name': exercise.name}),
          isError: false,
        );
      }
      // Force rebuild of the bottom sheet
      setState(() {});
    } catch (e) {
      CustomSnackbar.show(
        context,
        'workouts.failed_to_add_exercise'.tr(),
        isError: true,
      );
    }
  }

  Future<void> _saveAndClose() async {
    // Clear search controllers
    _allExercisesSearchController.clear();
    _customExercisesSearchController.clear();

    // Reset search query in ExercisesCubit
    context.read<ExercisesCubit>().setSearchQuery('');

    // Clear local filters
    _localFilterType = FilterType.none;
    _localSelectedChip = null;
    _localSelectedMuscle = null;
    _localSelectedCategory = null;

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

    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _handleClose() async {
    // Save and close (same behavior as before)
    await _saveAndClose();
  }

  List<Exercise> _getFilteredExercises(ExercisesState state) {
    if (_isCustomExercise) {
      return _getLocallyFilteredCustomExercises(state.customExercises);
    }

    // Use local filtering instead of global state filtering
    return _getLocallyFilteredExercises(state.allExercises);
  }

  @override
  Widget build(BuildContext context) {
    // Access locale to trigger rebuild on language change
    context.locale;

    return BlocConsumer<WorkoutsCubit, WorkoutsState>(
      listener: (context, workoutsState) {
        // Show error if adding exercises failed
        if (workoutsState.status == WorkoutsStatus.error &&
            workoutsState.errorMessage != null &&
            workoutsState.errorMessage!.contains('Failed to add exercises')) {
          CustomSnackbar.show(
            context,
            workoutsState.errorMessage!,
            isError: true,
          );
        }
      },
      builder: (context, workoutsState) {
        return BlocBuilder<ExercisesCubit, ExercisesState>(
          builder: (context, state) {
            return StatefulBuilder(
              builder: (context, setState) {
                final isAddingExercises =
                    workoutsState.status == WorkoutsStatus.loading;

                return WillPopScope(
                  onWillPop: () async {
                    if (!isAddingExercises) {
                      await _saveAndClose();
                    }
                    return !isAddingExercises;
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.9,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Column(
                      children: [
                        // Drag handle (non-functional, just visual)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[600],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Header with selected count
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'workouts.add_workout_exercise'
                                                .tr(),
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                        if (isAddingExercises)
                                          SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    if (_selectedExerciseIds.isNotEmpty ||
                                        _selectedCustomExerciseIds.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          isAddingExercises
                                              ? 'workouts.adding_exercises'.tr()
                                              : 'workouts.selected_count'.tr(
                                                  namedArgs: {
                                                    'count': (_selectedExerciseIds
                                                                .length +
                                                            _selectedCustomExerciseIds
                                                                .length)
                                                        .toString(),
                                                  },
                                                ),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed:
                                    isAddingExercises ? null : _handleClose,
                                icon: const Icon(FontAwesomeIcons.circleXmark),
                              )
                            ],
                          ),
                        ),
                        const Divider(),
                        const SizedBox(height: 16),

                        // Tab Bar
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TabBar(
                            indicatorPadding:
                                const EdgeInsets.symmetric(horizontal: 0),
                            dividerHeight: 0,
                            dividerColor: Colors.transparent,
                            controller: _tabController,
                            indicator: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: AppColors.primaryLight),
                            labelColor: Colors.white,
                            unselectedLabelColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey
                                    : Colors.black54,
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            unselectedLabelStyle: const TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                            ),
                            tabs: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Tab(
                                  text: 'workouts.all_exercises'.tr(),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Tab(
                                  text: 'workouts.custom_exercises'.tr(),
                                ),
                              ),
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
                              _buildExerciseSelection(context, state, null),
                              // Custom Exercises Tab
                              _buildCustomExerciseSelection(
                                  context, state, null),
                            ],
                          ),
                        ),

                        // Save button at the bottom
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            border: Border(
                              top: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surface
                                    .withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                          ),
                          child: SafeArea(
                            top: false,
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:
                                    isAddingExercises ? null : _saveAndClose,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryLight,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: isAddingExercises
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : Text(
                                        'workouts.save'.tr(),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
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
      },
    );
  }

  Widget _buildExerciseSelection(BuildContext context, ExercisesState state,
      ScrollController? scrollController) {
    final filteredExercises = _getFilteredExercises(state);
    final workoutsCubit = context.read<WorkoutsCubit>();
    final selectedExercises = workoutsCubit.state.selectedExercises;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _allExercisesSearchController,
            onChanged: (value) {
              // Update local state only, don't affect global ExercisesCubit
              setState(() {});
              // Don't call setSearchQuery to avoid affecting the main exercises screen
            },
            decoration: InputDecoration(
              hintText: 'workouts.search_exercises'.tr(),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Filter button and current filter display
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showFilterOptions(context, state),
                  icon: const Icon(Icons.filter_list, size: 18),
                  label: Text(
                    _getFilterButtonText(state),
                    style: const TextStyle(fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    foregroundColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              if (_localFilterType != FilterType.none ||
                  _localSelectedMuscle != null ||
                  _localSelectedCategory != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _localFilterType = FilterType.none;
                      _localSelectedChip = null;
                      _localSelectedMuscle = null;
                      _localSelectedCategory = null;
                    });
                  },
                  icon: const Icon(Icons.clear, color: Colors.red),
                  tooltip: 'workouts.clear_filter'.tr(),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Exercise list
        Expanded(
          child: filteredExercises.isEmpty
              ? Center(
                  child: Text(
                    'workouts.no_exercises_found'.tr(),
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.black87,
                    ),
                  ),
                )
              : ListView.builder(
                  controller: scrollController ?? ScrollController(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = filteredExercises[index];
                    // Check both local selection and already added exercises from cubit
                    final isAdded =
                        _selectedExerciseIds.contains(exercise.id) ||
                            selectedExercises.any((e) => e.id == exercise.id);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: isAdded
                          ? Theme.of(context)
                              .colorScheme
                              .surface
                              .withOpacity(0.5)
                          : Theme.of(context).colorScheme.surface,
                      child: ListTile(
                        title: Text(
                          exercise.name,
                          style: TextStyle(
                            color: Theme.of(context).brightness ==
                                    Brightness.dark
                                ? Colors.white.withOpacity(isAdded ? 0.7 : 1.0)
                                : Colors.black.withOpacity(isAdded ? 0.7 : 1.0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          exercise.primaryMuscle,
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white70
                                        .withOpacity(isAdded ? 0.7 : 1.0)
                                    : Colors.black87
                                        .withOpacity(isAdded ? 0.7 : 1.0),
                          ),
                        ),
                        leading: IconButton(
                          icon: Icon(
                            FontAwesomeIcons.circleInfo,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white70
                                        .withOpacity(isAdded ? 0.7 : 1.0)
                                    : Colors.black87
                                        .withOpacity(isAdded ? 0.7 : 1.0),
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
                              color: isAdded
                                  ? Colors.green
                                  : AppColors.primaryLight),
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

  Widget _buildCustomExerciseSelection(BuildContext context,
      ExercisesState state, ScrollController? scrollController) {
    final customExercises =
        _getLocallyFilteredCustomExercises(state.customExercises);
    final workoutsCubit = context.read<WorkoutsCubit>();
    final selectedExercises = workoutsCubit.state.selectedExercises;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _customExercisesSearchController,
            onChanged: (value) {
              // Update local state only, don't affect global ExercisesCubit
              setState(() {});
            },
            decoration: InputDecoration(
              hintText: 'workouts.search_custom_exercises'.tr(),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Add custom exercise row (only for admins when viewing static plans)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: BlocBuilder<WorkoutsCubit, WorkoutsState>(
            builder: (context, workoutsState) {
              final isViewingStaticPlans = workoutsState.isViewingStaticPlans;
              final isAdmin = context.read<ProfileCubit>().state.isAdmin;

              if (isViewingStaticPlans && !isAdmin) {
                return const SizedBox.shrink();
              }

              return Row(
                children: [
                  Expanded(
                    child: Text(
                      'workouts.add_new_custom_exercise'.tr(),
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
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
                        color: AppColors.primaryLight,
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
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // Custom Exercises list
        Expanded(
          child: customExercises.isEmpty
              ? Center(
                  child: Text(
                    'workouts.no_custom_exercises_found'.tr(),
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.black87,
                    ),
                  ),
                )
              : ListView.builder(
                  controller: scrollController ?? ScrollController(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: customExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = customExercises[index];
                    // Check both local selection and already added exercises from cubit
                    final isAdded =
                        _selectedCustomExerciseIds.contains(exercise.id) ||
                            selectedExercises.any((e) => e.id == exercise.id);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: isAdded
                          ? Theme.of(context)
                              .colorScheme
                              .surface
                              .withOpacity(0.5)
                          : Theme.of(context).colorScheme.surface,
                      child: ListTile(
                        title: Text(
                          exercise.name,
                          style: TextStyle(
                            color: Theme.of(context).brightness ==
                                    Brightness.dark
                                ? Colors.white.withOpacity(isAdded ? 0.7 : 1.0)
                                : Colors.black.withOpacity(isAdded ? 0.7 : 1.0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          exercise.primaryMuscle,
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white70
                                        .withOpacity(isAdded ? 0.7 : 1.0)
                                    : Colors.black87
                                        .withOpacity(isAdded ? 0.7 : 1.0),
                          ),
                        ),
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                FontAwesomeIcons.circleInfo,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white70
                                        .withOpacity(isAdded ? 0.7 : 1.0)
                                    : Colors.black87
                                        .withOpacity(isAdded ? 0.7 : 1.0),
                              ),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  RouteNames.exercise_details_route,
                                  arguments: [
                                    exercise,
                                    SharedUtils.extractThumbnail(
                                        exercise.videoUrl)
                                  ],
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: Colors.orange
                                    .withOpacity(isAdded ? 0.7 : 1.0),
                                size: 20,
                              ),
                              onPressed: () =>
                                  _editCustomExercise(context, exercise),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(
                              isAdded ? Icons.check_circle : Icons.add_circle,
                              color: isAdded
                                  ? Colors.green
                                  : Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : AppColors.primaryLight),
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

  // Navigate to update custom exercise form and handle the result
  Future<void> _editCustomExercise(
      BuildContext context, Exercise exercise) async {
    // Navigate to update custom exercise form and wait for result
    final Exercise? updatedExercise = await Navigator.push<Exercise>(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateCustomExerciseForm(exercise: exercise),
      ),
    );

    // If an exercise was updated, refresh the custom exercises list
    if (mounted && updatedExercise != null) {
      // Refresh the custom exercises to get the updated data
      await context.read<ExercisesCubit>().loadCustomExercises();
    }
  }

  // Navigate to custom exercise form and handle the result
  Future<void> _navigateToCustomExerciseForm(BuildContext context) async {
    // Navigate to custom exercise form and wait for result
    await Navigator.push<Exercise>(
      context,
      MaterialPageRoute(
        builder: (context) => const CustomExerciseForm(),
      ),
    );

    // The CustomExerciseForm already handles updating the ExercisesCubit state
    // through the createCustomExercise method, so we don't need to do anything here
    // The new exercise will be automatically available in the state
  }
}
