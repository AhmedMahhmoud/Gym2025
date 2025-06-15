import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gym/Shared/ui/custom_snackbar.dart';
import 'package:gym/core/theme/app_colors.dart';
import 'package:gym/features/exercises/data/repo/exercises_repo.dart';
import 'package:gym/features/exercises/view/cubit/exercises_cubit.dart';
import 'package:gym/features/workouts/cubits/workouts_cubit.dart';
import 'package:gym/features/workouts/cubits/workouts_state.dart';
import 'package:gym/features/workouts/data/models/exercise_model.dart';
import 'package:gym/features/workouts/views/screens/exercise_sets_screen.dart';
import 'package:gym/features/workouts/views/widgets/add_exercise_bottom_sheet.dart';
import 'package:gym/features/workouts/views/widgets/animated_widgets.dart';
import 'package:gym/features/workouts/views/widgets/error_message.dart';
import 'package:gym/features/workouts/views/widgets/loading_indicator.dart';
import 'package:gym/features/exercises/data/models/exercises.dart';
import 'package:skeletonizer/skeletonizer.dart';

class WorkoutDetailsScreen extends StatefulWidget {
  const WorkoutDetailsScreen({Key? key}) : super(key: key);

  @override
  State<WorkoutDetailsScreen> createState() => _WorkoutDetailsScreenState();
}

class _WorkoutDetailsScreenState extends State<WorkoutDetailsScreen> {
  final Map<String, bool> _isDeleting = {};
  late final WorkoutsCubit _workoutsCubit;

  @override
  void initState() {
    super.initState();
    _workoutsCubit = context.read<WorkoutsCubit>();
    _workoutsCubit.loadExercisesForWorkout();
  }

  void _navigateToExerciseSets(Exercise exercise) {
    _workoutsCubit.setCurrentExercise(exercise);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => BlocProvider.value(
          value: _workoutsCubit,
          child: const ExerciseSetsScreen(),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(Exercise exercise) {
    showDialog(
      context: context,
      builder: (context) => FadeInWidget(
        duration: const Duration(milliseconds: 300),
        child: AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Delete Exercise',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${exercise.name}"?',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteExercise(exercise);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.redAccent,
                      Colors.redAccent.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteExercise(Exercise exercise) {
    setState(() {
      _isDeleting[exercise.id] = true;
    });

    // Remove the exercise from the list
    _workoutsCubit.deleteWorkoutExercise(exercise.workoutExerciseID!);
    final updatedExercises =
        List<Exercise>.from(_workoutsCubit.state.selectedExercises)
          ..removeWhere((e) => e.id == exercise.id);
    _workoutsCubit.state.currentWorkout?.workoutExercises.removeWhere(
      (element) => element.customExerciseId == exercise.id,
    );
    // Update the state
    _workoutsCubit.updateExercisesOrder(updatedExercises);

    setState(() {
      _isDeleting.remove(exercise.id);
    });
  }

  void _showAddExerciseBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => BlocProvider.value(
        value: _workoutsCubit,
        child: const AddExerciseBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocSelector<WorkoutsCubit, WorkoutsState, String?>(
          selector: (state) => state.currentWorkout?.title,
          builder: (context, title) => Text(title ?? 'Workout Details'),
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: BlocConsumer<WorkoutsCubit, WorkoutsState>(
          listener: (context, state) {
            if (state.status == WorkoutsStatus.error) {
              CustomSnackbar.show(context, state.errorMessage ?? '',
                  isError: true);
            }
          },
          builder: (context, state) {
            print(
                'WorkoutDetailsScreen - Current workout: ${state.currentWorkout?.title}');
            print(
                'WorkoutDetailsScreen - Selected exercises count: ${state.selectedExercises.length}');

            if (state.status == WorkoutsStatus.loading &&
                state.selectedExercises.isEmpty) {
              return const LoadingIndicator();
            }

            if (state.status == WorkoutsStatus.error &&
                state.selectedExercises.isEmpty) {
              return ErrorMessage(
                message: state.errorMessage ?? 'Failed to load exercises',
                onRetry: () => state.currentWorkout != null
                    ? _workoutsCubit.loadExercisesForWorkout()
                    : null,
              );
            }

            if (state.selectedExercises.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'No exercises added yet',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _showAddExerciseBottomSheet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Add Exercise'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.selectedExercises.where((e) => e != null).length,
              itemBuilder: (context, index) {
                final exercise = state.selectedExercises[index];
                final isDeleting = _isDeleting[exercise?.id] ?? false;
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchOutCurve: Curves.easeOut,
                  switchInCurve: Curves.easeIn,
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    if (!isDeleting) {
                      return FadeInWidget(
                        duration: Duration(milliseconds: 500 + (index * 100)),
                        child: child,
                      );
                    }
                    return FadeOut(
                      curve: Curves.easeOut,
                      child: child,
                    );
                  },
                  child: isDeleting
                      ? Container(key: ValueKey('${exercise?.id}_deleting'))
                      : Skeletonizer(
                          enabled: state.status == WorkoutsStatus.loading,
                          child: _buildExerciseCard(exercise!, index)),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: BlocBuilder<WorkoutsCubit, WorkoutsState>(
        builder: (context, state) {
          if (state.selectedExercises.isNotEmpty) {
            return FloatingActionButton(
              onPressed: _showAddExerciseBottomSheet,
              backgroundColor: AppColors.textSecondary,
              child: const Icon(Icons.add),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildExerciseCard(Exercise exercise, int index) {
    return Card(
      key: ValueKey(exercise.id),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          title: Text(
            exercise.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          subtitle: Text(
            exercise.primaryMuscle!,
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: Colors.white70,
          ),
          onTap: () => _navigateToExerciseSets(exercise),
          onLongPress: () => _showDeleteConfirmationDialog(exercise),
        ),
      ),
    );
  }
}
