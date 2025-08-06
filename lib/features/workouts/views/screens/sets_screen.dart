import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trackletics/Shared/ui/custom_snackbar.dart';
import 'package:trackletics/core/theme/app_colors.dart';
import 'package:trackletics/features/workouts/cubits/workouts_cubit.dart';
import 'package:trackletics/features/workouts/cubits/workouts_state.dart';
import 'package:trackletics/features/workouts/data/models/set_model.dart';
import 'package:trackletics/features/workouts/views/screens/exercise_sets_screen.dart';
import 'package:trackletics/features/workouts/views/widgets/error_message.dart';
import 'package:trackletics/features/workouts/views/widgets/loading_indicator.dart';
import 'package:trackletics/Shared/ui/sticky_add_button.dart';

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
    bool isDurationInMinutes = true;
    bool isWeightInKg = true;

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
                backgroundColor: Colors.white,
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
                        'Add New Set',
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
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _weightController,
                              decoration: InputDecoration(
                                labelText: 'Weight',
                                labelStyle:
                                    const TextStyle(color: Colors.white70),
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
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ToggleButtons(
                              isSelected: [isWeightInKg, !isWeightInKg],
                              onPressed: (index) {
                                setState(() {
                                  isWeightInKg = index == 0;
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              selectedColor: Colors.white,
                              fillColor: AppColors.primary,
                              children: const [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text('kg'),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text('lbs'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _restTimeController,
                              decoration: InputDecoration(
                                labelText: 'Rest Time',
                                labelStyle:
                                    const TextStyle(color: Colors.white70),
                                hintText: isDurationInMinutes
                                    ? 'e.g., 2'
                                    : 'e.g., 120',
                                filled: true,
                                fillColor: AppColors.background,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: const Icon(Icons.timer,
                                    color: Colors.white70),
                              ),
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ToggleButtons(
                              isSelected: [
                                isDurationInMinutes,
                                !isDurationInMinutes
                              ],
                              onPressed: (index) {
                                setState(() {
                                  isDurationInMinutes = index == 0;
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              selectedColor: Colors.white,
                              fillColor: AppColors.primary,
                              children: const [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text('min'),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text('sec'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
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
                              if (_repsController.text.isNotEmpty) {
                                final reps =
                                    int.tryParse(_repsController.text) ?? 0;
                                double? weight = _weightController.text
                                        .trim()
                                        .isEmpty
                                    ? null
                                    : double.tryParse(_weightController.text);

                                // Only validate weight if provided
                                if (_weightController.text.trim().isNotEmpty &&
                                    (weight == null || weight <= 0)) {
                                  // Show error for invalid weight
                                  return;
                                }

                                // Convert weight if needed and if it exists
                                if (weight != null && !isWeightInKg) {
                                  weight =
                                      weight * 0.453592; // Convert lbs to kg
                                }

                                var restTime =
                                    int.tryParse(_restTimeController.text);
                                // Convert rest time if needed
                                if (restTime != null && isDurationInMinutes) {
                                  restTime = restTime *
                                      60; // Convert minutes to seconds
                                }

                                if (reps > 0) {
                                  context
                                      .read<WorkoutsCubit>()
                                      .addSetToExercise(
                                        reps: reps,
                                        weight: weight,
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
                            child: const Text('Add Set'),
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

  void _showEditSetDialog(SetModel set) {
    _repsController.text = set.repetitions?.toString() ?? '';
    _weightController.text = set.weight?.toString() ?? '';
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
                backgroundColor: Colors.white,
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
                      const SizedBox(height: 24),
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
                              if (_repsController.text.isNotEmpty) {
                                final reps =
                                    int.tryParse(_repsController.text) ?? 0;
                                final weight = _weightController.text
                                        .trim()
                                        .isEmpty
                                    ? null
                                    : double.tryParse(_weightController.text);
                                final restTime =
                                    int.tryParse(_restTimeController.text);

                                // Only validate weight if provided
                                if (_weightController.text.trim().isNotEmpty &&
                                    (weight == null || weight <= 0)) {
                                  // Show error for invalid weight
                                  return;
                                }

                                if (reps > 0) {
                                  context.read<WorkoutsCubit>().editSet(
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

  void _showDeleteConfirmationDialog(SetModel set) {
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
        content: const Text(
          'Are you sure you want to delete this set?',
          style: TextStyle(color: Colors.white70),
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
              context.read<WorkoutsCubit>().deleteSet(set.id);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocSelector<WorkoutsCubit, WorkoutsState, String?>(
          selector: (state) => state.currentExercise?.name,
          builder: (context, name) => Text(name ?? 'Sets'),
        ),
      ),
      body: Stack(children: [
        BlocConsumer<WorkoutsCubit, WorkoutsState>(
          listenWhen: (previous, current) =>
              (current.status == WorkoutsStatus.addingSet &&
                  previous.status != WorkoutsStatus.addingSet) ||
              (current.status == WorkoutsStatus.deletingSet &&
                  previous.status != WorkoutsStatus.deletingSet) ||
              (current.status == WorkoutsStatus.error &&
                  (previous.status == WorkoutsStatus.addingSet ||
                      previous.status == WorkoutsStatus.deletingSet)),
          buildWhen: (previous, current) =>
              current.status == WorkoutsStatus.success ||
              current.status == WorkoutsStatus.addingSet ||
              current.status == WorkoutsStatus.deletingSet,
          listener: (context, state) {
            if (state.status == WorkoutsStatus.error) {
              CustomSnackbar.show(
                  context, state.errorMessage ?? 'An error occurred',
                  isError: true);
            }
          },
          builder: (context, state) {
            if (state.status == WorkoutsStatus.loading && state.sets.isEmpty) {
              return const LoadingIndicator();
            }

            if (state.sets.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.fitness_center,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No sets added yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add your first set to start tracking',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _showAddSetDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Set'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: state.sets.length,
              itemBuilder: (context, index) {
                final set = state.sets[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildSetCard(set, index + 1),
                );
              },
            );
          },
        ),
        // Sticky Add Button
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: BlocBuilder<WorkoutsCubit, WorkoutsState>(
            builder: (context, state) {
              return StickyAddButton(
                onPressed: _showAddSetDialog,
                text: 'Add Set',
                icon: Icons.add,
                isVisible: state.sets.isNotEmpty,
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _buildSetCard(SetModel set, int setNumber) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Set number
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    '$setNumber',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Set details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (set.repetitions != null) ...[
                          const Icon(Icons.repeat,
                              color: Colors.white70, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${set.repetitions} reps',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        if (set.duration != null) ...[
                          const Icon(Icons.timer,
                              color: Colors.white70, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${set.duration}s',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        if (set.weight != null) ...[
                          const SizedBox(width: 16),
                          const Icon(Icons.fitness_center,
                              color: Colors.white70, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${set.weight}kg',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (set.restTime != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.schedule,
                              color: Colors.white54, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'Rest: ${set.restTime}s',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Edit and delete buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(FontAwesomeIcons.edit,
                        color: Colors.white70, size: 16),
                    onPressed: () => _showEditSetDialog(set),
                  ),
                  IconButton(
                    icon: const Icon(FontAwesomeIcons.circleXmark,
                        color: Colors.redAccent, size: 16),
                    onPressed: () => _showDeleteConfirmationDialog(set),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
