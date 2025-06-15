import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym/Shared/ui/custom_elevated_button.dart';
import 'package:gym/core/theme/app_colors.dart';
import 'package:gym/features/exercises/view/screens/exercises_display_page.dart';
import 'package:gym/features/workouts/cubits/workouts_cubit.dart';
import 'package:gym/features/workouts/cubits/workouts_state.dart';
import 'package:gym/features/workouts/data/models/workout_model.dart';
import 'package:gym/features/workouts/views/screens/workout_details_screen.dart';
import 'package:gym/features/workouts/views/widgets/error_message.dart';
import 'package:gym/features/workouts/views/widgets/loading_indicator.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({Key? key}) : super(key: key);

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController(); // Add notes controller
  bool _isAddingWorkout = false;
  final Map<String, bool> _isDeleting = {};
  late WorkoutsCubit _workoutsCubit;

  @override
  void initState() {
    super.initState();
    _workoutsCubit = context.read<WorkoutsCubit>();
    if (_workoutsCubit.state.workouts.isEmpty) {
      // _workoutsCubit.loadWorkouts();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose(); // Dispose notes controller
    super.dispose();
  }

  void _navigateToExercises(WorkoutModel workout) {
    _workoutsCubit.setCurrentWorkout(workout);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => BlocProvider.value(
          value: _workoutsCubit,
          child: const WorkoutDetailsScreen(),
        ),
      ),
    );
  }

  void _createWorkout() {
    if (_titleController.text.isNotEmpty) {
      setState(() {
        _isAddingWorkout = true;
      });

      _workoutsCubit
          .createWorkout(
        _titleController.text,
        notes: _notesController.text.isNotEmpty
            ? _notesController.text
            : null, // Pass notes
      )
          .then((newWorkout) {
        _titleController.clear();
        _notesController.clear(); // Clear notes
        setState(() {
          _isAddingWorkout = false;
        });
      }).catchError((error) {
        setState(() {
          _isAddingWorkout = false;
        });
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

    _workoutsCubit.deleteWorkout(workout.id).then((_) {
      setState(() {
        _isDeleting.remove(workout.id);
      });
    }).catchError((error) {
      setState(() {
        _isDeleting.remove(workout.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete workout: $error'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_workoutsCubit.state.currentPlan?.title ?? 'Workouts'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        bottom: true,
        child: BlocConsumer<WorkoutsCubit, WorkoutsState>(
          listenWhen: (previous, current) =>
              (current.status == WorkoutsStatus.creatingWorkout &&
                  previous.status != WorkoutsStatus.creatingWorkout) ||
              (current.status == WorkoutsStatus.deletingWorkout &&
                  previous.status != WorkoutsStatus.deletingWorkout) ||
              (current.status == WorkoutsStatus.error &&
                  (previous.status == WorkoutsStatus.creatingWorkout ||
                      previous.status == WorkoutsStatus.deletingWorkout)),
          listener: (context, state) {
            if (state.status == WorkoutsStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'An error occurred'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.status == WorkoutsStatus.loading ||
                state.status == WorkoutsStatus.loadingWorkouts) {
              return SizedBox(
                height: MediaQuery.sizeOf(context).height / 1.5,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Loading workouts ...',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state.status == WorkoutsStatus.error &&
                state.workouts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.errorMessage ?? 'Failed to load workouts',
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _workoutsCubit.loadWorkoutsForPlan(
                          _workoutsCubit.state.currentPlan!.id),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                if (_isAddingWorkout)
                  FadeIn(
                    duration: const Duration(milliseconds: 500),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              labelText: 'Workout Title',
                              floatingLabelStyle: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                              hintText: 'e.g., Push Day',
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.1),
                              labelStyle: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                              hintStyle: const TextStyle(color: Colors.white38),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            onTapOutside: (event) =>
                                FocusScope.of(context).unfocus(),
                            autofocus: true,
                          ),
                          const SizedBox(height: 16),
                          // Add notes field
                          TextField(
                            controller: _notesController,
                            decoration: InputDecoration(
                              labelText: 'Notes (Optional)',
                              floatingLabelStyle: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                              hintText: 'e.g., Focus on chest and triceps',
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.1),
                              labelStyle: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                              hintStyle: const TextStyle(color: Colors.white38),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            onTapOutside: (event) =>
                                FocusScope.of(context).unfocus(),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Add cancel button
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isAddingWorkout = false;
                                    _titleController.clear();
                                    _notesController.clear();
                                  });
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white70,
                                ),
                                child: const Text('Cancel'),
                              ),
                              const SizedBox(width: 16),
                              if (state.status == WorkoutsStatus.loading)
                                Container(
                                  width: double.infinity,
                                  height: 4,
                                  margin: const EdgeInsets.only(bottom: 20),
                                  child: const LinearProgressIndicator(
                                    backgroundColor: AppColors.primary,
                                  ),
                                )
                              else
                                ElasticIn(
                                  duration: const Duration(milliseconds: 800),
                                  child: ElevatedButton(
                                    onPressed: _createWorkout,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 40,
                                        vertical: 15,
                                      ),
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ).copyWith(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                        Colors.transparent,
                                      ),
                                      overlayColor: MaterialStateProperty.all(
                                        Colors.white.withOpacity(0.1),
                                      ),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Theme.of(context).primaryColor,
                                            Theme.of(context)
                                                .primaryColor
                                                .withOpacity(0.7),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(30),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Theme.of(context)
                                                .primaryColor
                                                .withOpacity(0.5),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 30,
                                        vertical: 15,
                                      ),
                                      child: const Text(
                                        'Create Workout',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                Expanded(
                  child: state.workouts.isEmpty && !_isAddingWorkout
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FadeIn(
                                duration: const Duration(milliseconds: 800),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 30),
                                  child: Text(
                                    "Add New Workout",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white70,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              SlideInUp(
                                duration: const Duration(milliseconds: 1000),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _isAddingWorkout = true;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 40,
                                      vertical: 15,
                                    ),
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ).copyWith(
                                    backgroundColor: MaterialStateProperty.all(
                                      Colors.transparent,
                                    ),
                                    overlayColor: MaterialStateProperty.all(
                                      Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.textSecondary,
                                          AppColors.backgroundSurface
                                              .withOpacity(0.7),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.buttonText
                                              .withOpacity(0.5),
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
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
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
                                  return FadeIn(
                                    duration: const Duration(milliseconds: 500),
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
                                      key: ValueKey('${workout.id}_deleting'))
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
      floatingActionButton: context
              .watch<WorkoutsCubit>()
              .state
              .workouts
              .isNotEmpty
          ? Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _isAddingWorkout = true;
                  });
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.5),
                        blurRadius: 10,
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
