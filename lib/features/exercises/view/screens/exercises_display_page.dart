import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackletics/Shared/ui/custom_snackbar.dart';
import 'package:trackletics/features/exercises/view/widgets/exersises_display_listview.dart';
import 'package:trackletics/features/exercises/view/widgets/exersises_search_field.dart';
import 'package:trackletics/features/exercises/view/widgets/custom_exercise_form.dart';
import 'package:trackletics/features/exercises/view/widgets/exercises_filter_bottomsheet.dart';
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
    exercisesCubit.loadExercises(context);
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
        child: SizedBox(
          height:
              MediaQuery.of(context).size.height * 0.75, // 75% of screen height
          child: const ExerciseFilterBottomSheet(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Access locale to trigger rebuild on language change
    context.locale;

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
                      child: ExerciseSearchField(
                        key: const Key('search_field'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Filter icon button
                    Builder(
                      builder: (context) {
                        final theme = Theme.of(context);
                        final colorScheme = theme.colorScheme;
                        return Container(
                          decoration: BoxDecoration(
                            color: state.selectedFilterType != FilterType.none
                                ? colorScheme.primary.withOpacity(0.2)
                                : colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: state.selectedFilterType != FilterType.none
                                  ? colorScheme.primary
                                  : Colors.grey,
                            ),
                          ),
                          child: IconButton(
                            onPressed: _isCustomExercise
                                ? null
                                : _showFilterBottomSheet,
                            icon: Stack(
                              children: [
                                Icon(
                                  Icons.filter_list,
                                  color: _isCustomExercise
                                      ? Colors.grey.withOpacity(0.5)
                                      : (state.selectedFilterType !=
                                              FilterType.none
                                          ? colorScheme.primary
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
                                        color: colorScheme.primary,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
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
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          state.selectedFilterType == FilterType.muscle
                              ? Icons.fitness_center
                              : Icons.category,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Builder(
                          builder: (context) {
                            final theme = Theme.of(context);
                            return Text(
                              '${state.selectedFilterType == FilterType.muscle ? 'Muscle' : 'Category'}: ${state.selectedChip}',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        Builder(
                          builder: (context) {
                            final theme = Theme.of(context);
                            return GestureDetector(
                              onTap: () =>
                                  context.read<ExercisesCubit>().clearFilter(),
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              // Add TabBar
              Builder(
                builder: (context) {
                  final theme = Theme.of(context);
                  final colorScheme = theme.colorScheme;
                  return Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: TabBar(
                      indicatorPadding:
                          const EdgeInsets.symmetric(horizontal: 0),
                      dividerHeight: 0,
                      controller: _tabController,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: colorScheme.primary,
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey,
                      tabs: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Tab(text: 'workouts.all_exercises'.tr()),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Tab(text: 'workouts.custom_exercises'.tr()),
                        ),
                      ],
                    ),
                  );
                },
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
              ? Builder(
                  builder: (context) {
                    final theme = Theme.of(context);
                    return FloatingActionButton(
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CustomExerciseForm(),
                          ),
                        );
                      },
                      backgroundColor: theme.colorScheme.primary,
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    );
                  },
                )
              : null,
        );
      },
    );
  }
}
