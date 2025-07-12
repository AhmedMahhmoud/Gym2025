import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym/Shared/ui/custom_snackbar.dart';
import 'package:gym/core/theme/app_colors.dart';
import 'package:gym/features/workouts/cubits/workouts_cubit.dart';
import 'package:gym/features/workouts/cubits/workouts_state.dart';
import 'package:gym/features/workouts/data/models/set_model.dart';
import 'package:gym/features/workouts/data/units_service.dart';
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
  final _noteController = TextEditingController(); // Add this line

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
    _noteController.dispose(); // Add this line
    super.dispose();
  }

  void _showAddSetDialog() {
    showAnimatedDialog(
      context: context,
      builder: (context) => AddSetDialog(
        onAdd: ({
          double? weight,
          required int? reps,
          required int? duration,
          int? restTime,
          String? note,
          String? timeUnitId,
          String? weightUnitId,
        }) {
          if (reps != null) {
            _workoutsCubit.addSetToExercise(
              reps: reps,
              weight: weight,
              restTime: restTime,
              note: note,
              timeUnitId: timeUnitId,
              weightUnitId: weightUnitId,
            );
          } else if (duration != null) {
            _workoutsCubit.addDurationSetToExercise(
              duration: duration,
              weight: weight,
              restTime: restTime,
              note: note,
              timeUnitId: timeUnitId,
              weightUnitId: weightUnitId,
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
        actions: [
          IconButton(
            onPressed: _showAddSetDialog,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<WorkoutsCubit, WorkoutsState>(
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
    );
  }

  void _showEditSetDialog(SetModel set, WorkoutsCubit cubit) {
    _repsController.text = set.repetitions?.toString() ?? '';
    _weightController.text = set.weight?.toString() ?? '';
    _restTimeController.text = set.restTime?.toString() ?? '';
    _noteController.text = set.note ?? '';
    _durationController.text =
        set.duration?.toString() ?? ''; // Initialize duration controller

    // Initialize unit selections based on set data
    bool isWeightInKg = set.weightUnitId == null ||
        UnitsService().getWeightUnitById(set.weightUnitId!)?.title == 'Kg';
    bool isDurationInMinutes = set.timeUnitId != null &&
        UnitsService().getTimeUnitById(set.timeUnitId!)?.title == 'Min';
    bool isRepsBased = set.repetitions != null;

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
                      // Weight field with unit toggle
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
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
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ToggleButtons(
                              isSelected: [isWeightInKg, !isWeightInKg],
                              onPressed: (index) {
                                setState(() {
                                  isWeightInKg = index == 0;
                                });
                              },
                              borderRadius: BorderRadius.circular(8),
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
                      // Reps field
                      if (isRepsBased)
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
                      // Duration field for duration-based sets
                      if (!isRepsBased)
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _durationController,
                                decoration: InputDecoration(
                                  hintText: 'e.g., 60',
                                  filled: true,
                                  fillColor: AppColors.background,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: const Icon(Icons.timer_outlined,
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
                                borderRadius: BorderRadius.circular(8),
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
                                borderRadius: BorderRadius.circular(8),
                                selectedColor: Colors.white,
                                fillColor: AppColors.primary,
                                children: const [
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 12),
                                    child: Text('min'),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 12),
                                    child: Text('sec'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),
                      // Rest time field with unit toggle
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _restTimeController,
                              decoration: InputDecoration(
                                hintText: 'e.g., 60',
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
                              borderRadius: BorderRadius.circular(8),
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
                              borderRadius: BorderRadius.circular(8),
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
                      const SizedBox(height: 16),
                      // Note field
                      TextField(
                        controller: _noteController,
                        decoration: InputDecoration(
                          hintText: 'Add a note (optional)',
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon:
                              const Icon(Icons.note, color: Colors.white70),
                        ),
                        style: const TextStyle(color: Colors.white),
                        maxLines: 2,
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
                              final reps = isRepsBased
                                  ? int.tryParse(_repsController.text) ?? 0
                                  : null;
                              final weight =
                                  _weightController.text.trim().isEmpty
                                      ? null
                                      : double.tryParse(_weightController.text);
                              final restTime =
                                  int.tryParse(_restTimeController.text);

                              // Only validate weight if provided
                              if (_weightController.text.trim().isNotEmpty &&
                                  (weight == null || weight <= 0)) {
                                // Could show error snackbar here
                                return;
                              }

                              // Parse duration for duration-based sets
                              final duration = !isRepsBased
                                  ? int.tryParse(_durationController.text) ?? 0
                                  : null;

                              // Get unit IDs based on selection without conversion (only if weight exists)
                              final weightUnitId = weight != null
                                  ? (isWeightInKg
                                      ? UnitsService()
                                          .getDefaultWeightUnit()
                                          ?.id
                                      : UnitsService()
                                          .weightUnits
                                          .where((unit) => unit.title == 'Lbs')
                                          .firstOrNull
                                          ?.id)
                                  : null;

                              final timeUnitId = isDurationInMinutes
                                  ? UnitsService()
                                      .timeUnits
                                      .where((unit) => unit.title == 'Min')
                                      .firstOrNull
                                      ?.id
                                  : UnitsService().getDefaultTimeUnit()?.id;

                              final note = _noteController.text.trim();

                              if ((isRepsBased && reps != null && reps > 0) ||
                                  (!isRepsBased &&
                                      duration != null &&
                                      duration > 0)) {
                                cubit.editSet(
                                  setId: set.id,
                                  reps: reps,
                                  weight: weight,
                                  duration: duration, // Pass the duration value
                                  restTime: restTime,
                                  note: note.isNotEmpty ? note : null,
                                  timeUnitId: timeUnitId,
                                  weightUnitId: weightUnitId,
                                );
                                Navigator.pop(context);
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
