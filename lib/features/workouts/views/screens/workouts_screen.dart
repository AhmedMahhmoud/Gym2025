import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym/Shared/ui/custom_elevated_button.dart';
import 'package:gym/core/theme/app_colors.dart';
import 'package:gym/features/exercises/view/screens/exercises_display_page.dart';
import 'package:gym/features/workouts/cubits/workouts_cubit.dart';
import 'package:gym/features/workouts/cubits/workouts_state.dart';
import 'package:gym/features/workouts/data/models/workout_model.dart';
import 'package:gym/features/workouts/views/widgets/error_message.dart';
import 'package:gym/features/workouts/views/widgets/loading_indicator.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({Key? key}) : super(key: key);

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  final _titleController = TextEditingController();
  bool _isAddingWorkout = false;
  final Map<String, bool> _isDeleting = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<WorkoutsCubit>().state.currentPlan != null) {
        context.read<WorkoutsCubit>().loadWorkoutsForPlan(
            context.read<WorkoutsCubit>().state.currentPlan!.id);
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _navigateToExercises(WorkoutModel workout) {
    context.read<WorkoutsCubit>().setCurrentWorkout(workout);
  }

  void _createWorkout() {
    if (_titleController.text.isNotEmpty &&
        context.read<WorkoutsCubit>().state.currentPlan != null) {
      context.read<WorkoutsCubit>().createWorkout(_titleController.text);
      _titleController.clear();
      setState(() {
        _isAddingWorkout = false;
      });
    }
  }

  void _showDeleteConfirmationDialog(WorkoutModel workout) {
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
            'Delete Workout',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${workout.title}"?',
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
                _deleteWorkout(workout);
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

  void _deleteWorkout(WorkoutModel workout) {
    setState(() {
      _isDeleting[workout.id] = true;
    });

    // Simulate local deletion after animation
    Future.delayed(const Duration(milliseconds: 500), () {
      final updatedWorkouts =
          List<WorkoutModel>.from(context.read<WorkoutsCubit>().state.workouts)
            ..removeWhere((w) => w.id == workout.id);
      context.read<WorkoutsCubit>().emit(
            context.read<WorkoutsCubit>().state.copyWith(
                  workouts: updatedWorkouts,
                  clearCurrentWorkout:
                      context.read<WorkoutsCubit>().state.currentWorkout?.id ==
                          workout.id,
                ),
          );
      setState(() {
        _isDeleting.remove(workout.id);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocSelector<WorkoutsCubit, WorkoutsState, String?>(
          selector: (state) => state.currentPlan?.title,
          builder: (context, title) => Text(title ?? 'Workouts'),
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: BlocConsumer<WorkoutsCubit, WorkoutsState>(
          listener: (context, state) {
            if (state.status == WorkoutsStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'An error occurred'),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.status == WorkoutsStatus.loading &&
                state.workouts.isEmpty) {
              return const LoadingIndicator();
            }

            if (state.status == WorkoutsStatus.error &&
                state.workouts.isEmpty) {
              return ErrorMessage(
                message: state.errorMessage ?? 'Failed to load workouts',
                onRetry: () => state.currentPlan != null
                    ? context
                        .read<WorkoutsCubit>()
                        .loadWorkoutsForPlan(state.currentPlan!.id)
                    : null,
              );
            }

            if (state.workouts.isEmpty && !_isAddingWorkout) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        'You didn\'t add workouts yet for "${state.currentPlan?.title}"',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isAddingWorkout = true;
                        });
                      },
                      text: 'Add Workout',
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                if (_isAddingWorkout)
                  FadeInWidget(
                    duration: const Duration(milliseconds: 500),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: _titleController,
                            labelText: 'Workout Title',
                            hintText: 'e.g., Push',
                          ),
                          const SizedBox(height: 20),
                          ElasticInWidget(
                            child: CustomElevatedButton(
                              onPressed: _createWorkout,
                              text: 'Confirm Workout',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.workouts.length,
                    itemBuilder: (context, index) {
                      final workout = state.workouts[index];
                      final isDeleting = _isDeleting[workout.id] ?? false;
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
                            ? Container(key: ValueKey('${workout.id}_deleting'))
                            : _buildWorkoutCard(workout, index),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton:
          context.read<WorkoutsCubit>().state.workouts.isNotEmpty &&
                  !_isAddingWorkout
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        _isAddingWorkout = true;
                      });
                    },
                    elevation: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.textSecondary,
                            AppColors.backgroundSurface.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.buttonText.withOpacity(0.5),
                            blurRadius: 2,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(15),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                )
              : null,
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
    );
  }

  Widget _buildWorkoutCard(WorkoutModel workout, int index) {
    return Card(
      key: ValueKey(workout.id),
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
            workout.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: Colors.white70,
          ),
          onTap: () => _navigateToExercises(workout),
          onLongPress: () => _showDeleteConfirmationDialog(workout),
        ),
      ),
    );
  }
}
