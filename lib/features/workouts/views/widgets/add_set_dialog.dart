import 'package:flutter/material.dart';
import 'package:trackletics/Shared/ui/custom_snackbar.dart';
import 'package:trackletics/core/theme/app_colors.dart';
import 'package:trackletics/features/workouts/data/units_service.dart';
import 'package:easy_localization/easy_localization.dart';

class AddSetDialog extends StatefulWidget {
  final Function({
    double? weight,
    required int? reps,
    required int? duration,
    int? restTime,
    String? note,
    String? restTimeUnitId,
    String? durationTimeUnitId,
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
  bool _isRestTimeInMinutes = true;
  bool _isLoading = false;
  bool _hasDurationError = false;
  bool _hasRestTimeError = false;

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
      // Ensure units are loaded before proceeding
      if (_unitsService.timeUnits.isEmpty ||
          _unitsService.weightUnits.isEmpty) {
        await _unitsService.initialize();
      }

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
        CustomSnackbar.show(context, 'workouts.valid_weight_required'.tr(),
            isError: true);
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Get unit IDs based on selection - with case-insensitive matching and fallbacks
      // MUST be set if weight is provided
      String? weightUnitId;
      if (weight != null && _unitsService.weightUnits.isNotEmpty) {
        if (_isWeightInKg) {
          // Try to find 'kg' (case-insensitive)
          final unit = _unitsService.weightUnits
              .where((unit) => unit.title.toLowerCase() == 'kg')
              .firstOrNull;
          weightUnitId = unit?.id;

          // Fallback to default weight unit (Kg) if not found
          if (weightUnitId == null) {
            final defaultUnit = _unitsService.getDefaultWeightUnit();
            weightUnitId = defaultUnit?.id;

            // Final fallback to first weight unit
            if (weightUnitId == null && _unitsService.weightUnits.isNotEmpty) {
              weightUnitId = _unitsService.weightUnits.first.id;
            }
          }
        } else {
          // Try to find 'lbs' (case-insensitive)
          final unit = _unitsService.weightUnits
              .where((unit) => unit.title.toLowerCase() == 'lbs')
              .firstOrNull;
          weightUnitId = unit?.id;

          // Fallback to first weight unit if 'lbs' not found
          if (weightUnitId == null && _unitsService.weightUnits.isNotEmpty) {
            weightUnitId = _unitsService.weightUnits.first.id;
          }
        }
      }

      // Get rest time unit ID - MUST be set if restTime is provided
      String? restTimeUnitId;
      if (restTime != null && _unitsService.timeUnits.isNotEmpty) {
        if (_isRestTimeInMinutes) {
          // Try to find 'min' (case-insensitive)
          final unit = _unitsService.timeUnits
              .where((unit) =>
                  unit.title.toLowerCase() == 'min' ||
                  unit.title.toLowerCase().contains('min'))
              .firstOrNull;
          restTimeUnitId = unit?.id;

          // Fallback to first time unit if not found
          if (restTimeUnitId == null && _unitsService.timeUnits.isNotEmpty) {
            restTimeUnitId = _unitsService.timeUnits.first.id;
          }
        } else {
          // Use default time unit (usually 'Sec')
          final unit = _unitsService.getDefaultTimeUnit();
          restTimeUnitId = unit?.id;

          // Fallback to first time unit if default not found
          if (restTimeUnitId == null && _unitsService.timeUnits.isNotEmpty) {
            restTimeUnitId = _unitsService.timeUnits.first.id;
          }
        }
      }

      // Get duration unit ID (only for duration-based sets) - MUST be set if duration is provided
      String? durationTimeUnitId;
      if (!_isRepsBased &&
          duration != null &&
          _unitsService.timeUnits.isNotEmpty) {
        if (_isDurationInMinutes) {
          // Try to find 'min' (case-insensitive)
          final unit = _unitsService.timeUnits
              .where((unit) =>
                  unit.title.toLowerCase() == 'min' ||
                  unit.title.toLowerCase().contains('min'))
              .firstOrNull;
          durationTimeUnitId = unit?.id;

          // Fallback to first time unit if not found
          if (durationTimeUnitId == null &&
              _unitsService.timeUnits.isNotEmpty) {
            durationTimeUnitId = _unitsService.timeUnits.first.id;
          }
        } else {
          // Use default time unit (usually 'Sec')
          final unit = _unitsService.getDefaultTimeUnit();
          durationTimeUnitId = unit?.id;

          // Fallback to first time unit if default not found
          if (durationTimeUnitId == null &&
              _unitsService.timeUnits.isNotEmpty) {
            durationTimeUnitId = _unitsService.timeUnits.first.id;
          }
        }
      }

      if (_isRepsBased) {
        // Validate rest time format - must be a whole number (for reps-based sets too)
        bool hasRestTimeFormatError = _restTimeController.text.isNotEmpty &&
            (_restTimeController.text.contains('.') ||
                _restTimeController.text.contains(':'));

        if (hasRestTimeFormatError) {
          CustomSnackbar.show(context, 'workouts.invalid_duration_format'.tr(),
              isError: true);
          setState(() {
            _isLoading = false;
            _hasRestTimeError = true;
          });
          return;
        }

        if (reps == null || reps <= 0) {
          CustomSnackbar.show(context, 'workouts.valid_reps_required'.tr(),
              isError: true);
          setState(() {
            _isLoading = false;
          });
          return;
        }
        // Clear errors on successful validation
        setState(() {
          _hasDurationError = false;
          _hasRestTimeError = false;
        });

        widget.onAdd(
          weight: weight,
          reps: reps,
          duration: null,
          restTime: restTime,
          note: note.isNotEmpty ? note : null,
          restTimeUnitId: restTimeUnitId,
          durationTimeUnitId: null,
          weightUnitId: weightUnitId,
        );
      } else {
        // Validate duration format - must be a whole number
        bool hasDurationFormatError = _durationController.text.contains('.') ||
            _durationController.text.contains(':');

        // Validate rest time format - must be a whole number
        bool hasRestTimeFormatError = _restTimeController.text.isNotEmpty &&
            (_restTimeController.text.contains('.') ||
                _restTimeController.text.contains(':'));

        if (hasDurationFormatError || hasRestTimeFormatError) {
          CustomSnackbar.show(context, 'workouts.invalid_duration_format'.tr(),
              isError: true);
          setState(() {
            _isLoading = false;
            _hasDurationError = hasDurationFormatError;
            _hasRestTimeError = hasRestTimeFormatError;
          });
          return;
        }
        if (duration == null || duration <= 0) {
          CustomSnackbar.show(context, 'workouts.valid_duration_required'.tr(),
              isError: true);
          setState(() {
            _isLoading = false;
            _hasDurationError = true;
          });
          return;
        }
        // Clear errors on successful validation
        setState(() {
          _hasDurationError = false;
          _hasRestTimeError = false;
        });

        widget.onAdd(
          weight: weight,
          reps: null,
          duration: duration,
          restTime: restTime,
          note: note.isNotEmpty ? note : null,
          restTimeUnitId: restTimeUnitId,
          durationTimeUnitId: durationTimeUnitId,
          weightUnitId: weightUnitId,
        );
      }

      // Don't close the dialog automatically - let the logger callback handle it
      // The logger callback will close the dialog before navigating
      // If no logger callback is provided, close after a delay
      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        // Only close if we're still mounted (logger callback might have already closed it)
        Navigator.maybePop(context);
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        CustomSnackbar.show(context, 'workouts.failed_to_add_set'.tr(),
            isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access locale to trigger rebuild on language change
    context.locale;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.maxFinite,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1A1A1A)
              : Colors.white,
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
                    child: Icon(
                      Icons.add,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'workouts.add_set'.tr(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            // Loading indicator
            if (_isLoading)
              Container(
                height: 4,
                child: LinearProgressIndicator(
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1),
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
                      title: 'workouts.set_type'.tr(),
                      icon: Icons.tune,
                      child: _buildSetTypeToggle(),
                    ),
                    const SizedBox(height: 20),

                    // Weight Section
                    _buildSectionCard(
                      title: 'workouts.weight'.tr(),
                      icon: Icons.fitness_center,
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildModernTextField(
                              controller: _weightController,
                              hintText: 'workouts.weight_hint'.tr(),
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
                      title: _isRepsBased
                          ? 'workouts.repetitions'.tr()
                          : 'workouts.duration'.tr(),
                      icon: _isRepsBased ? Icons.repeat : Icons.timer_outlined,
                      child: _isRepsBased
                          ? _buildModernTextField(
                              controller: _repsController,
                              hintText: 'workouts.reps_hint'.tr(),
                              keyboardType: TextInputType.number,
                              prefixIcon: Icons.repeat,
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: _buildModernTextField(
                                    controller: _durationController,
                                    hintText: 'workouts.duration_hint'.tr(),
                                    keyboardType: TextInputType.number,
                                    prefixIcon: Icons.timer_outlined,
                                    hasError: _hasDurationError,
                                    onChanged: () {
                                      if (_hasDurationError) {
                                        setState(() {
                                          _hasDurationError = false;
                                        });
                                      }
                                    },
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
                      title: 'workouts.rest_time'.tr(),
                      icon: Icons.timer,
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildModernTextField(
                              controller: _restTimeController,
                              hintText: 'workouts.rest_time_hint'.tr(),
                              keyboardType: TextInputType.number,
                              prefixIcon: Icons.timer,
                              hasError: _hasRestTimeError,
                              onChanged: () {
                                if (_hasRestTimeError) {
                                  setState(() {
                                    _hasRestTimeError = false;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildModernToggle(
                            values: ['min', 'sec'],
                            selectedIndex: _isRestTimeInMinutes ? 0 : 1,
                            onChanged: (index) {
                              setState(() {
                                _isRestTimeInMinutes = index == 0;
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
                              foregroundColor: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white70
                                  : Colors.black87,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'workouts.cancel'.tr(),
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
                            onPressed: _isLoading ? null : _addSet,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isLoading
                                  ? AppColors.primary.withOpacity(0.6)
                                  : AppColors.primaryLight,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'workouts.adding_set'.tr(),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    'workouts.add_set_button'.tr(),
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
                      color: _isRepsBased ? Colors.white : AppColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'workouts.reps'.tr(),
                      style: TextStyle(
                        color: _isRepsBased
                            ? Colors.white
                            : Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
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
                      color: !_isRepsBased ? Colors.white : AppColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'workouts.duration'.tr(),
                      style: TextStyle(
                        color: !_isRepsBased
                            ? Colors.white
                            : Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
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
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withOpacity(0.03)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryLight, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
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
    bool hasError = false,
    VoidCallback? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      style: TextStyle(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
        fontSize: 16,
      ),
      onChanged: (_) => onChanged?.call(),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.5)
              : Colors.black.withOpacity(0.5),
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: hasError
              ? Colors.red.withOpacity(0.7)
              : AppColors.primary.withOpacity(0.7),
        ),
        filled: true,
        fillColor: hasError
            ? Colors.red.withOpacity(0.05)
            : Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: hasError
                ? Colors.red.withOpacity(0.5)
                : Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: hasError
                ? Colors.red.withOpacity(0.5)
                : Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: hasError ? Colors.red : AppColors.primaryLight,
            width: 2,
          ),
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
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
        ),
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
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.7)
                          : Colors.black.withOpacity(0.7),
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
