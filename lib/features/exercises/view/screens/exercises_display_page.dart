import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:trackletics/Shared/ui/custom_snackbar.dart';
import 'package:trackletics/core/theme/app_colors.dart';
import 'package:trackletics/features/exercises/data/repo/exercises_repo.dart';
import 'package:trackletics/features/exercises/view/widgets/exersises_display_listview.dart';
import 'package:trackletics/features/exercises/view/widgets/exersises_search_field.dart';
import 'package:trackletics/features/exercises/view/widgets/custom_exercise_form.dart';
import 'package:trackletics/features/exercises/view/widgets/exercises_filter_bottomsheet.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:trackletics/core/showcase/showcase_keys.dart';
import 'package:trackletics/features/exercises/view/widgets/exersises_search_field.dart';
import '../cubit/exercises_cubit.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen>
    with SingleTickerProviderStateMixin {
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

    // Load both regular and custom exercises
    final exercisesCubit = context.read<ExercisesCubit>();
    exercisesCubit.loadExercises();
    exercisesCubit.loadCustomExercises();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: context.read<ExercisesCubit>(),
        child: const ExerciseFilterBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ExercisesCubit, ExercisesState>(
      listener: (context, state) {
        if (state.status == ExerciseStatus.error) {
          CustomSnackbar.show(context, state.errorMessage.toString(),
              isError: true);
        }
      },
      builder: (context, state) {
        context.read<ExercisesCubit>();

        return Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // Search field and filter button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Showcase(
                        key: ShowcaseKeys.exerciseSearchField,
                        description:
                            'Search for exercises by name or description to quickly find what you need!',
                        title: 'Exercise Search',
                        child: ExerciseSearchField(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Filter icon button
                    Showcase(
                      key: ShowcaseKeys.exerciseFilterButton,
                      description:
                          'Filter exercises by muscle groups or categories to find specific workouts!',
                      title: 'Exercise Filter',
                      child: Container(
                        decoration: BoxDecoration(
                          color: state.selectedFilterType != FilterType.none
                              ? AppColors.primary.withOpacity(0.2)
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: state.selectedFilterType != FilterType.none
                                ? AppColors.primary
                                : Colors.grey,
                          ),
                        ),
                        child: IconButton(
                          onPressed:
                              _isCustomExercise ? null : _showFilterBottomSheet,
                          icon: Stack(
                            children: [
                              Icon(
                                Icons.filter_list,
                                color: _isCustomExercise
                                    ? Colors.grey.withOpacity(0.5)
                                    : (state.selectedFilterType !=
                                            FilterType.none
                                        ? AppColors.primary
                                        : Colors.grey),
                              ),
                              // Active filter indicator
                              if (state.selectedFilterType != FilterType.none)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Active filter indicator
              if (state.selectedFilterType != FilterType.none &&
                  state.selectedChip != null)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          state.selectedFilterType == FilterType.muscle
                              ? Icons.fitness_center
                              : Icons.category,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${state.selectedFilterType == FilterType.muscle ? 'Muscle' : 'Category'}: ${state.selectedChip}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () =>
                              context.read<ExercisesCubit>().clearFilter(),
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              // Add TabBar
              Showcase(
                key: ShowcaseKeys.allExercisesTab,
                description:
                    'Switch between all exercises and your custom exercises! Tap "All Exercises" to browse the library.',
                title: 'Exercise Tabs',
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
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
              ),
              const SizedBox(height: 20),
              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // All Exercises Tab
                    ExerciseListView(
                      exercises: state.filteredExercises,
                      isLoading: state.status == ExerciseStatus.loading,
                      isCustomTab: false,
                    ),
                    // Custom Exercises Tab
                    ExerciseListView(
                      exercises: state.filteredCustomExercises,
                      isLoading: state.status == ExerciseStatus.loading,
                      isCustomTab: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: _isCustomExercise
              ? Showcase(
                  key: ShowcaseKeys.addCustomExerciseFAB,
                  description:
                      'Tap here to create your own custom exercise with personalized details!',
                  title: 'Add Custom Exercise',
                  child: FloatingActionButton(
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CustomExerciseForm(),
                        ),
                      );
                    },
                    backgroundColor: AppColors.primary,
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }
}
