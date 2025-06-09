import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gym/Shared/ui/custom_snackbar.dart';
import 'package:gym/core/theme/app_colors.dart';
import 'package:gym/core/widgets/dialogs/input_dialog_container.dart';
import 'package:gym/features/workouts/data/units_service.dart';

class AddSetDialog extends StatefulWidget {
  final Function({
    required double weight,
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

  void _addSet() {
    final weight = double.tryParse(_weightController.text);
    final reps = int.tryParse(_repsController.text);
    final duration = int.tryParse(_durationController.text);
    final restTime = int.tryParse(_restTimeController.text);
    final note = _noteController.text.trim();

    if (weight == null || weight <= 0) {
      CustomSnackbar.show(context, 'Please enter a valid weight',
          isError: true);
      return;
    }

    // 5. Finally, let's update the `AddSetDialog` to not convert units
    // Get unit IDs based on selection without conversion
    final weightUnitId = _isWeightInKg
        ? _unitsService.getDefaultWeightUnit()?.id
        : _unitsService.weightUnits
            .where((unit) => unit.title == 'Lbs')
            .firstOrNull
            ?.id;

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
        return;
      }
      widget.onAdd(
        weight: weight, // Use weight as is without conversion
        reps: reps,
        duration: null,
        restTime: restTime, // Use restTime as is without conversion
        note: note.isNotEmpty ? note : null,
        timeUnitId: timeUnitId,
        weightUnitId: weightUnitId,
      );
    } else {
      if (duration == null || duration <= 0) {
        CustomSnackbar.show(context, 'Please enter a valid duration',
            isError: true);
        return;
      }
      widget.onAdd(
        weight: weight, // Use weight as is without conversion
        reps: null,
        duration: duration, // Use duration as is without conversion
        restTime: restTime, // Use restTime as is without conversion
        note: note.isNotEmpty ? note : null,
        timeUnitId: timeUnitId,
        weightUnitId: weightUnitId,
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return InputDialogContainer(
      width: MediaQuery.of(context).size.width * 0.9,
      content: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add Set',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Reps',
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 8),
                Switch(
                  activeColor: AppColors.primary,
                  value: _isRepsBased,
                  onChanged: (value) {
                    setState(() {
                      _isRepsBased = value;
                    });
                  },
                ),
                const Text(
                  'Duration',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Weight',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white30),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    onTapOutside: (event) => FocusScope.of(context).unfocus(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ToggleButtons(
                    isSelected: [_isWeightInKg, !_isWeightInKg],
                    onPressed: (index) {
                      setState(() {
                        _isWeightInKg = index == 0;
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
            if (_isRepsBased)
              TextField(
                controller: _repsController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Reps',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Duration',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white30),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ToggleButtons(
                      isSelected: [_isDurationInMinutes, !_isDurationInMinutes],
                      onPressed: (index) {
                        setState(() {
                          _isDurationInMinutes = index == 0;
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _restTimeController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Rest Time',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white30),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ToggleButtons(
                    isSelected: [_isDurationInMinutes, !_isDurationInMinutes],
                    onPressed: (index) {
                      setState(() {
                        _isDurationInMinutes = index == 0;
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
              keyboardType: TextInputType.text,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addSet,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
