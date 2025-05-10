import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym/features/workouts/cubits/workouts_cubit.dart';
import 'package:gym/features/workouts/cubits/workouts_state.dart';
import 'package:gym/features/workouts/views/widgets/error_message.dart';
import 'package:gym/features/workouts/views/widgets/loading_indicator.dart';
import 'package:gym/features/workouts/views/widgets/set_card.dart';

class SetsScreen extends StatefulWidget {
  const SetsScreen({Key? key}) : super(key: key);

  @override
  State<SetsScreen> createState() => _SetsScreenState();
}

class _SetsScreenState extends State<SetsScreen> {
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();
  final _restTimeController = TextEditingController();

  @override
  void dispose() {
    _repsController.dispose();
    _weightController.dispose();
    _restTimeController.dispose();
    super.dispose();
  }

  void _showAddSetDialog() {
    _repsController.clear();
    _weightController.clear();
    _restTimeController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Set'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _repsController,
              decoration: const InputDecoration(
                labelText: 'Reps',
                hintText: 'e.g., 12',
              ),
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                hintText: 'e.g., 60.5',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _restTimeController,
              decoration: const InputDecoration(
                labelText: 'Rest Time (seconds)',
                hintText: 'e.g., 60',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_repsController.text.isNotEmpty &&
                  _weightController.text.isNotEmpty) {
                final reps = int.tryParse(_repsController.text) ?? 0;
                final weight = double.tryParse(_weightController.text) ?? 0.0;
                final restTime = int.tryParse(_restTimeController.text);

                if (reps > 0 && weight > 0) {
                  context.read<WorkoutsCubit>().addSetToExercise(
                        reps: reps,
                        weight: weight,
                        restTime: restTime,
                      );
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocSelector<WorkoutsCubit, WorkoutsState, String?>(
          selector: (state) => state.currentExercise?.name,
          builder: (context, name) => Text(name ?? 'Sets'),
        ),
      ),
      body: BlocConsumer<WorkoutsCubit, WorkoutsState>(
        listener: (context, state) {
          if (state.status == WorkoutsStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.errorMessage ?? 'An error occurred')),
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
                  context.read<WorkoutsCubit>().loadSetsForExercise(
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
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _showAddSetDialog,
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
              return SetCard(set: set);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSetDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
