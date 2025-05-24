import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym/core/theme/app_colors.dart';
import 'package:gym/features/workouts/cubits/workouts_cubit.dart';
import 'package:gym/features/workouts/cubits/workouts_state.dart';
import 'package:gym/features/workouts/data/models/set_model.dart';
import 'package:gym/features/workouts/views/widgets/error_message.dart';
import 'package:gym/features/workouts/views/widgets/loading_indicator.dart';
import 'package:gym/features/workouts/views/widgets/set_card.dart';
import 'package:gym/features/workouts/views/widgets/add_set_dialog.dart';
import 'package:gym/core/widgets/dialogs/input_dialog_container.dart';

class ExerciseSetsScreen extends StatefulWidget {
  const ExerciseSetsScreen({Key? key}) : super(key: key);

  @override
  State<ExerciseSetsScreen> createState() => _ExerciseSetsScreenState();
}

class _ExerciseSetsScreenState extends State<ExerciseSetsScreen> {
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();
  final _restTimeController = TextEditingController();
  final _durationController = TextEditingController();

  late final WorkoutsCubit _workoutsCubit;

  @override
  void initState() {
    _workoutsCubit = context.read<WorkoutsCubit>();
    super.initState();
  }

  @override
  void dispose() {
    _repsController.dispose();
    _weightController.dispose();
    _restTimeController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _showAddSetDialog() {
    showAnimatedDialog(
      context: context,
      builder: (context) => AddSetDialog(
        onAdd: ({
          required double weight,
          required int? reps,
          required int? duration,
          int? restTime,
        }) {
          if (reps != null) {
            _workoutsCubit.addSetToExercise(
              reps: reps,
              weight: weight,
              restTime: restTime,
            );
          } else if (duration != null) {
            _workoutsCubit.addDurationSetToExercise(
              duration: duration,
              weight: weight,
              restTime: restTime,
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocSelector<WorkoutsCubit, WorkoutsState, String?>(
          selector: (state) => state.currentExercise?.name,
          builder: (context, name) => Text(name ?? 'Exercise Sets'),
        ),
      ),
      body: BlocConsumer<WorkoutsCubit, WorkoutsState>(
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
          if (state.status == WorkoutsStatus.loading && state.sets.isEmpty) {
            return const LoadingIndicator();
          }

          if (state.status == WorkoutsStatus.error && state.sets.isEmpty) {
            return ErrorMessage(
              message: state.errorMessage ?? 'Failed to load sets',
              onRetry: () {
                if (state.currentWorkout != null &&
                    state.currentExercise != null) {
                  _workoutsCubit.loadSetsForExercise(
                    state.currentWorkout!.id,
                    state.currentExercise!.id,
                  );
                }
              },
            );
          }

          if (state.sets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'No sets added yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _showAddSetDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Add Set'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.sets.length,
            itemBuilder: (context, index) {
              final set = state.sets[index];
              return SetCard(
                set: set,
                onEdit: () => _showEditSetDialog(set, _workoutsCubit),
                onDelete: () =>
                    _showDeleteConfirmationDialog(set, _workoutsCubit),
              );
            },
          );
        },
      ),
      floatingActionButton: BlocBuilder<WorkoutsCubit, WorkoutsState>(
        builder: (context, state) {
          if (state.sets.isNotEmpty) {
            return FloatingActionButton(
              onPressed: _showAddSetDialog,
              backgroundColor: AppColors.textSecondary,
              child: const Icon(Icons.add),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showEditSetDialog(SetModel set, WorkoutsCubit cubit) {
    _repsController.text = set.reps?.toString() ?? '';
    _weightController.text = set.weight.toString();
    _restTimeController.text = set.restTime?.toString() ?? '';

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return StatefulBuilder(builder: (context, setState) {
          return ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(animation),
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Edit Set',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _repsController,
                        decoration: InputDecoration(
                          hintText: 'e.g., 12',
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon:
                              const Icon(Icons.repeat, color: Colors.white70),
                        ),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        autofocus: true,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _weightController,
                        decoration: InputDecoration(
                          hintText: 'e.g., 60.5',
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.fitness_center,
                              color: Colors.white70),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _restTimeController,
                        decoration: InputDecoration(
                          hintText: 'e.g., 60',
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon:
                              const Icon(Icons.timer, color: Colors.white70),
                        ),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white70,
                            ),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () {
                              if (_repsController.text.isNotEmpty &&
                                  _weightController.text.isNotEmpty) {
                                final reps =
                                    int.tryParse(_repsController.text) ?? 0;
                                final weight =
                                    double.tryParse(_weightController.text) ??
                                        0.0;
                                final restTime =
                                    int.tryParse(_restTimeController.text);

                                if (reps > 0 && weight > 0) {
                                  cubit.editSet(
                                    setId: set.id,
                                    reps: reps,
                                    weight: weight,
                                    duration: null,
                                    restTime: restTime,
                                  );
                                  Navigator.pop(context);
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            child: const Text('Save Changes'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }

  void _showDeleteConfirmationDialog(SetModel set, WorkoutsCubit cubit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text(
          'Delete Set',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this set?',
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
              cubit.deleteSet(set.id);
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
