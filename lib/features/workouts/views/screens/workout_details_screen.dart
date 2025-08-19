import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trackletics/Shared/ui/custom_snackbar.dart';
import 'package:trackletics/core/theme/app_colors.dart';
import 'package:trackletics/core/utils/shared_utils.dart';
// import 'package:trackletics/features/exercises/data/repo/exercises_repo.dart';
// import 'package:trackletics/features/exercises/view/cubit/exercises_cubit.dart';
import 'package:trackletics/features/workouts/cubits/workouts_cubit.dart';
import 'package:trackletics/features/workouts/cubits/workouts_state.dart';
// import 'package:trackletics/features/workouts/data/models/exercise_model.dart';
import 'package:trackletics/features/workouts/views/screens/exercise_sets_screen.dart';
import 'package:trackletics/features/workouts/views/widgets/add_exercise_bottom_sheet.dart';
import 'package:trackletics/features/workouts/views/widgets/animated_widgets.dart';
// import 'package:trackletics/Shared/ui/sticky_add_button.dart';
import 'package:trackletics/features/workouts/views/widgets/error_message.dart';
import 'package:trackletics/features/workouts/views/widgets/loading_indicator.dart';
import 'package:trackletics/features/exercises/data/models/exercises.dart';
import 'package:trackletics/routes/route_names.dart';
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
    if (context.read<WorkoutsCubit>().state.isGuidedMode) return;
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
    if (context.read<WorkoutsCubit>().state.isGuidedMode) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => BlocProvider.value(
        value: _workoutsCubit,
        child: const AddExerciseBottomSheet(),
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
            exercise.primaryMuscle,
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(
                  FontAwesomeIcons.circleInfo,
                  color: Colors.white70,
                ),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    RouteNames.exercise_details_route,
                    arguments: [
                      exercise,
                      SharedUtils.extractThumbnail(exercise.videoUrl.isEmpty
                          ? exercise.maleVideoUrl
                          : exercise.videoUrl)
                    ],
                  );
                },
              ),
              if (!context.read<WorkoutsCubit>().state.isGuidedMode)
                IconButton(
                  icon: const Icon(FontAwesomeIcons.circleXmark,
                      color: Colors.redAccent),
                  onPressed: () => _showDeleteConfirmationDialog(exercise),
                ),
              const Icon(
                Icons.chevron_right,
                color: Colors.white70,
              ),
            ],
          ),
          onTap: () => _navigateToExerciseSets(exercise),
        ),
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
        bottom: false,
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
                    if (!state.isGuidedMode)
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

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.selectedExercises.length,
                    itemBuilder: (context, index) {
                      final exercise = state.selectedExercises[index];
                      final isDeleting = _isDeleting[exercise.id] ?? false;

                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        switchOutCurve: Curves.easeOut,
                        switchInCurve: Curves.easeIn,
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          if (!isDeleting) {
                            return FadeInWidget(
                              duration:
                                  Duration(milliseconds: 500 + (index * 100)),
                              child: child,
                            );
                          }
                          return FadeOut(
                            curve: Curves.easeOut,
                            child: child,
                          );
                        },
                        child: isDeleting
                            ? Container(
                                key: ValueKey('${exercise.id}_deleting'))
                            : Skeletonizer(
                                enabled: state.status == WorkoutsStatus.loading,
                                child: _buildExerciseCard(exercise, index),
                              ),
                      );
                    },
                  ),
                ),
                // Add button integrated into the scrollable content
                if (state.selectedExercises.isNotEmpty && !state.isGuidedMode)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.8),
                            AppColors.primary.withOpacity(0.9),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: _showAddExerciseBottomSheet,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Add Exercise',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
