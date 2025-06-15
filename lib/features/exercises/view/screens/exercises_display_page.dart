import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gym/Shared/ui/custom_snackbar.dart';
import 'package:gym/core/theme/app_colors.dart';
import 'package:gym/features/exercises/data/repo/exercises_repo.dart';
import 'package:gym/features/exercises/view/widgets/exersises_display_listview.dart';
import 'package:gym/features/exercises/view/widgets/exersises_search_field.dart';
import 'package:gym/features/exercises/view/widgets/custom_exercise_form.dart';
import 'package:skeletonizer/skeletonizer.dart';
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
              // Search field for both tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: ExerciseSearchField(),
              ),
              const SizedBox(height: 20),
              // Add TabBar
              Container(
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
                    ),
                    // Custom Exercises Tab
                    ExerciseListView(
                      exercises: state.filteredCustomExercises,
                      isLoading: state.status == ExerciseStatus.loading,
                    ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: _isCustomExercise
              ? FloatingActionButton(
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
                )
              : null,
        );
      },
    );
  }
}
