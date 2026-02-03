import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackletics/Shared/ui/custom_snackbar.dart';
import 'package:trackletics/core/theme/app_colors.dart';
import 'package:trackletics/features/workouts/cubits/workouts_cubit.dart';
import 'package:trackletics/features/workouts/cubits/workouts_state.dart';
import 'package:trackletics/features/workouts/data/models/set_model.dart';
import 'package:trackletics/features/workouts/data/units_service.dart';
// import 'package:trackletics/features/workouts/views/widgets/error_message.dart';
import 'package:trackletics/features/workouts/views/widgets/loading_indicator.dart';
import 'package:trackletics/features/workouts/views/widgets/set_card.dart';
import 'package:trackletics/features/workouts/views/widgets/add_set_dialog.dart';
import 'package:trackletics/core/widgets/dialogs/input_dialog_container.dart';
// import 'package:trackletics/core/debug/api_logger_model.dart';
// import 'package:trackletics/routes/route_names.dart';
// import 'package:trackletics/Shared/ui/sticky_add_button.dart';

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
    if (context.read<WorkoutsCubit>().state.isGuidedMode) return;
    showAnimatedDialog(
      context: context,
      builder: (dialogContext) => AddSetDialog(
        onAdd: ({
          double? weight,
          required int? reps,
          required int? duration,
          int? restTime,
          String? note,
          String? restTimeUnitId,
          String? durationTimeUnitId,
          String? weightUnitId,
        }) {
          // Logger navigation commented out
          // void navigateToLogger(ApiLoggerModel logData) {
          //   // Close the dialog first, then navigate to logger using parent context
          //   Navigator.pop(dialogContext);
          //   // Use a small delay to ensure dialog is closed before navigation
          //   Future.delayed(const Duration(milliseconds: 100), () {
          //     if (parentContext.mounted) {
          //       Navigator.pushNamed(
          //         parentContext,
          //         RouteNames.api_logger_route,
          //         arguments: [logData],
          //       );
          //     }
          //   });
          // }

          if (reps != null) {
            _workoutsCubit.addSetToExercise(
              reps: reps,
              weight: weight,
              restTime: restTime,
              note: note,
              restTimeUnitId: restTimeUnitId,
              durationTimeUnitId: durationTimeUnitId,
              weightUnitId: weightUnitId,
              // onLogCreated: (logData) =>
              //     navigateToLogger(logData as ApiLoggerModel),
            );
          } else if (duration != null) {
            _workoutsCubit.addDurationSetToExercise(
              duration: duration,
              weight: weight,
              restTime: restTime,
              note: note,
              restTimeUnitId: restTimeUnitId,
              durationTimeUnitId: durationTimeUnitId,
              weightUnitId: weightUnitId,
              // onLogCreated: (logData) =>
              //     navigateToLogger(logData as ApiLoggerModel),
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
                  Text(
                    'workouts.no_sets_added_yet'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!state.isGuidedMode)
                    ElevatedButton(
                      onPressed: _showAddSetDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text('workouts.add_set_button'.tr()),
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
                  itemCount: state.sets.length,
                  itemBuilder: (context, index) {
                    final set = state.sets[index];
                    return SetCard(
                      set: set,
                      onEdit: state.isGuidedMode
                          ? null
                          : () => _showEditSetDialog(set, _workoutsCubit),
                      onDelete: state.isGuidedMode
                          ? null
                          : () => _showDeleteConfirmationDialog(
                              set, _workoutsCubit),
                    );
                  },
                ),
              ),
              // Add button integrated into the scrollable content
              if (state.sets.isNotEmpty && !state.isGuidedMode)
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
                        onTap: _showAddSetDialog,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'workouts.add_set'.tr(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
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
    bool isDurationInMinutes = set.durationTimeUnitId != null &&
        UnitsService().getTimeUnitById(set.durationTimeUnitId!)?.title == 'Min';
    bool isRestTimeInMinutes = set.restTimeUnitId != null &&
        UnitsService().getTimeUnitById(set.restTimeUnitId!)?.title == 'Min';
    bool isRepsBased = set.repetitions != null;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(16),
            child: Container(
              width: double.maxFinite,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.1),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'workouts.edit_set'.tr(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  // Scrollable content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Weight Section
                          _buildSectionCard(
                            title: 'workouts.weight'.tr(),
                            icon: Icons.fitness_center,
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildModernTextField(
                                    controller: _weightController,
                                    hintText: 'e.g., 60.5',
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    prefixIcon: Icons.fitness_center,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _buildModernToggle(
                                  values: ['kg', 'lbs'],
                                  selectedIndex: isWeightInKg ? 0 : 1,
                                  onChanged: (index) {
                                    setState(() {
                                      isWeightInKg = index == 0;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Reps/Duration Section
                          _buildSectionCard(
                            title: isRepsBased
                                ? 'workouts.repetitions'.tr()
                                : 'workouts.duration'.tr(),
                            icon: isRepsBased
                                ? Icons.repeat
                                : Icons.timer_outlined,
                            child: isRepsBased
                                ? _buildModernTextField(
                                    controller: _repsController,
                                    hintText: 'e.g., 12',
                                    keyboardType: TextInputType.number,
                                    prefixIcon: Icons.repeat,
                                  )
                                : Row(
                                    children: [
                                      Expanded(
                                        child: _buildModernTextField(
                                          controller: _durationController,
                                          hintText: 'e.g., 60',
                                          keyboardType: TextInputType.number,
                                          prefixIcon: Icons.timer_outlined,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      _buildModernToggle(
                                        values: ['min', 'sec'],
                                        selectedIndex:
                                            isDurationInMinutes ? 0 : 1,
                                        onChanged: (index) {
                                          setState(() {
                                            isDurationInMinutes = index == 0;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                          ),
                          const SizedBox(height: 20),

                          // Rest Time Section
                          _buildSectionCard(
                            title: 'workouts.rest_time'.tr(),
                            icon: Icons.timer,
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildModernTextField(
                                    controller: _restTimeController,
                                    hintText: 'e.g., 60',
                                    keyboardType: TextInputType.number,
                                    prefixIcon: Icons.timer,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _buildModernToggle(
                                  values: ['min', 'sec'],
                                  selectedIndex: isRestTimeInMinutes ? 0 : 1,
                                  onChanged: (index) {
                                    setState(() {
                                      isRestTimeInMinutes = index == 0;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Notes Section
                          _buildSectionCard(
                            title: 'workouts.notes'.tr(),
                            icon: Icons.note,
                            child: _buildModernTextField(
                              controller: _noteController,
                              hintText: 'workouts.notes_hint'.tr(),
                              prefixIcon: Icons.note,
                              maxLines: 3,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Action buttons
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white70,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'common.cancel'.tr(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  onPressed: () {
                                    final reps = isRepsBased
                                        ? int.tryParse(_repsController.text) ??
                                            0
                                        : null;
                                    final weight =
                                        _weightController.text.trim().isEmpty
                                            ? null
                                            : double.tryParse(
                                                _weightController.text);
                                    final restTime =
                                        int.tryParse(_restTimeController.text);

                                    // Only validate weight if provided
                                    if (_weightController.text
                                            .trim()
                                            .isNotEmpty &&
                                        (weight == null || weight <= 0)) {
                                      return;
                                    }

                                    // Parse duration for duration-based sets
                                    final duration = !isRepsBased
                                        ? int.tryParse(
                                                _durationController.text) ??
                                            0
                                        : null;

                                    // Validate duration format for duration-based sets
                                    if (!isRepsBased &&
                                        (_durationController.text
                                                .contains('.') ||
                                            _durationController.text
                                                .contains(':'))) {
                                      // Show error and return without closing dialog
                                      CustomSnackbar.show(
                                          context,
                                          'workouts.invalid_duration_format'
                                              .tr(),
                                          isError: true);
                                      return;
                                    }

                                    // Get unit IDs based on selection
                                    final weightUnitId = weight != null
                                        ? (isWeightInKg
                                            ? UnitsService()
                                                .getDefaultWeightUnit()
                                                ?.id
                                            : UnitsService()
                                                .weightUnits
                                                .where((unit) =>
                                                    unit.title == 'Lbs')
                                                .firstOrNull
                                                ?.id)
                                        : null;

                                    // Get rest time unit ID
                                    final restTimeUnitId = restTime != null
                                        ? (isRestTimeInMinutes
                                            ? UnitsService()
                                                .timeUnits
                                                .where((unit) =>
                                                    unit.title == 'Min')
                                                .firstOrNull
                                                ?.id
                                            : UnitsService()
                                                .getDefaultTimeUnit()
                                                ?.id)
                                        : null;

                                    // Get duration unit ID (only for duration-based sets)
                                    final durationTimeUnitId =
                                        !isRepsBased && duration != null
                                            ? (isDurationInMinutes
                                                ? UnitsService()
                                                    .timeUnits
                                                    .where((unit) =>
                                                        unit.title == 'Min')
                                                    .firstOrNull
                                                    ?.id
                                                : UnitsService()
                                                    .getDefaultTimeUnit()
                                                    ?.id)
                                            : null;

                                    final note = _noteController.text.trim();

                                    if ((isRepsBased &&
                                            reps != null &&
                                            reps > 0) ||
                                        (!isRepsBased &&
                                            duration != null &&
                                            duration > 0)) {
                                      cubit.editSet(
                                        setId: set.id,
                                        reps: reps,
                                        weight: weight,
                                        duration: duration,
                                        restTime: restTime,
                                        note: note.isNotEmpty ? note : null,
                                        restTimeUnitId: restTimeUnitId,
                                        durationTimeUnitId: durationTimeUnitId,
                                        weightUnitId: weightUnitId,
                                      );
                                      Navigator.pop(context);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'workouts.save_changes'.tr(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
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
                ],
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
        title: Text(
          'workouts.delete_set'.tr(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'workouts.delete_set_confirmation'.tr(),
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'common.cancel'.tr(),
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              cubit.deleteSet(set.id);
              Navigator.pop(context);
            },
            child: Text(
              'workouts.delete'.tr(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    int? maxLines,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        prefixIcon: Icon(prefixIcon, color: AppColors.primary.withOpacity(0.7)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildModernToggle({
    required List<String> values,
    required int selectedIndex,
    required Function(int) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: values.asMap().entries.map((entry) {
          final index = entry.key;
          final value = entry.value;
          final isSelected = index == selectedIndex;

          return GestureDetector(
            onTap: () => onChanged(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                value.tr(),
                style: TextStyle(
                  color:
                      isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
