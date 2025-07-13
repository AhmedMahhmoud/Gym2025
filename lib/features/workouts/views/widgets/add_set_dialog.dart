import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gym/Shared/ui/custom_snackbar.dart';
import 'package:gym/core/theme/app_colors.dart';
import 'package:gym/core/widgets/dialogs/input_dialog_container.dart';
import 'package:gym/features/workouts/data/units_service.dart';

class AddSetDialog extends StatefulWidget {
  final Function({
    double? weight,
    required int? reps,
    required int? duration,
    int? restTime,
    String? note,
    String? timeUnitId,
    String? weightUnitId,
  }) onAdd;

  const AddSetDialog({
    required this.onAdd,
    super.key,
  });

  @override
  State<AddSetDialog> createState() => _AddSetDialogState();
}

class _AddSetDialogState extends State<AddSetDialog> {
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();
  final _restTimeController = TextEditingController();
  final _durationController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isRepsBased = true;
  bool _isWeightInKg = true;
  bool _isDurationInMinutes = true;
  bool _isLoading = false;

  // Units service
  final _unitsService = UnitsService();

  @override
  void dispose() {
    _repsController.dispose();
    _weightController.dispose();
    _restTimeController.dispose();
    _durationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _addSet() async {
    // Don't allow multiple submissions
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final weight = _weightController.text.trim().isEmpty
          ? null
          : double.tryParse(_weightController.text);
      final reps = int.tryParse(_repsController.text);
      final duration = int.tryParse(_durationController.text);
      final restTime = int.tryParse(_restTimeController.text);
      final note = _noteController.text.trim();

      // Only validate weight if it's provided
      if (_weightController.text.trim().isNotEmpty &&
          (weight == null || weight <= 0)) {
        CustomSnackbar.show(context, 'Please enter a valid weight',
            isError: true);
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Get unit IDs based on selection without conversion
      final weightUnitId = weight != null
          ? (_isWeightInKg
              ? _unitsService.getDefaultWeightUnit()?.id
              : _unitsService.weightUnits
                  .where((unit) => unit.title == 'Lbs')
                  .firstOrNull
                  ?.id)
          : null;

      final timeUnitId = _isDurationInMinutes
          ? _unitsService.timeUnits
              .where((unit) => unit.title == 'Min')
              .firstOrNull
              ?.id
          : _unitsService.getDefaultTimeUnit()?.id;

      if (_isRepsBased) {
        if (reps == null || reps <= 0) {
          CustomSnackbar.show(context, 'Please enter a valid number of reps',
              isError: true);
          setState(() {
            _isLoading = false;
          });
          return;
        }
        widget.onAdd(
          weight: weight,
          reps: reps,
          duration: null,
          restTime: restTime,
          note: note.isNotEmpty ? note : null,
          timeUnitId: timeUnitId,
          weightUnitId: weightUnitId,
        );
      } else {
        if (duration == null || duration <= 0) {
          CustomSnackbar.show(context, 'Please enter a valid duration',
              isError: true);
          setState(() {
            _isLoading = false;
          });
          return;
        }
        widget.onAdd(
          weight: weight,
          reps: null,
          duration: duration,
          restTime: restTime,
          note: note.isNotEmpty ? note : null,
          timeUnitId: timeUnitId,
          weightUnitId: weightUnitId,
        );
      }

      // Add a small delay to show the loading indicator
      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        CustomSnackbar.show(context, 'Failed to add set. Please try again.',
            isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      Icons.add,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Add Set',
                    style: TextStyle(
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
            // Loading indicator
            if (_isLoading)
              Container(
                height: 4,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Set Type Toggle
                    _buildSectionCard(
                      title: 'Set Type',
                      icon: Icons.tune,
                      child: _buildSetTypeToggle(),
                    ),
                    const SizedBox(height: 20),

                    // Weight Section
                    _buildSectionCard(
                      title: 'Weight',
                      icon: Icons.fitness_center,
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildModernTextField(
                              controller: _weightController,
                              hintText: 'e.g., 60.5 (optional)',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              prefixIcon: Icons.fitness_center,
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildModernToggle(
                            values: ['kg', 'lbs'],
                            selectedIndex: _isWeightInKg ? 0 : 1,
                            onChanged: (index) {
                              setState(() {
                                _isWeightInKg = index == 0;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Reps/Duration Section
                    _buildSectionCard(
                      title: _isRepsBased ? 'Repetitions' : 'Duration',
                      icon: _isRepsBased ? Icons.repeat : Icons.timer_outlined,
                      child: _isRepsBased
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
                                  selectedIndex: _isDurationInMinutes ? 0 : 1,
                                  onChanged: (index) {
                                    setState(() {
                                      _isDurationInMinutes = index == 0;
                                    });
                                  },
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 20),

                    // Rest Time Section
                    _buildSectionCard(
                      title: 'Rest Time',
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
                            selectedIndex: _isDurationInMinutes ? 0 : 1,
                            onChanged: (index) {
                              setState(() {
                                _isDurationInMinutes = index == 0;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Notes Section
                    _buildSectionCard(
                      title: 'Notes',
                      icon: Icons.note,
                      child: _buildModernTextField(
                        controller: _noteController,
                        hintText: 'Add a note (optional)',
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
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
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
                            onPressed: _isLoading ? null : _addSet,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isLoading
                                  ? AppColors.primary.withOpacity(0.6)
                                  : AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'Adding Set...',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  )
                                : const Text(
                                    'Add Set',
                                    style: TextStyle(
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
  }

  Widget _buildSetTypeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isRepsBased = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isRepsBased ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.repeat,
                      color: _isRepsBased
                          ? Colors.white
                          : Colors.white.withOpacity(0.7),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Reps',
                      style: TextStyle(
                        color: _isRepsBased
                            ? Colors.white
                            : Colors.white.withOpacity(0.7),
                        fontWeight:
                            _isRepsBased ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isRepsBased = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isRepsBased ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      color: !_isRepsBased
                          ? Colors.white
                          : Colors.white.withOpacity(0.7),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Duration',
                      style: TextStyle(
                        color: !_isRepsBased
                            ? Colors.white
                            : Colors.white.withOpacity(0.7),
                        fontWeight:
                            !_isRepsBased ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
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
                value,
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
