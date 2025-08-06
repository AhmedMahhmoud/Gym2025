import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trackletics/core/theme/app_colors.dart';
import 'package:trackletics/features/exercises/view/cubit/exercises_cubit.dart';

class ExerciseFilterBottomSheet extends StatefulWidget {
  const ExerciseFilterBottomSheet({super.key});

  @override
  State<ExerciseFilterBottomSheet> createState() =>
      _ExerciseFilterBottomSheetState();
}

class _ExerciseFilterBottomSheetState extends State<ExerciseFilterBottomSheet> {
  FilterType? _tempSelectedType;
  String? _tempSelectedChip;

  @override
  void initState() {
    final state = context.read<ExercisesCubit>().state;
    _tempSelectedType = state.selectedFilterType;
    _tempSelectedChip = state.selectedChip;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExercisesCubit>();
    final state = context.watch<ExercisesCubit>().state;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter Exercises',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _tempSelectedType = FilterType.none;
                        _tempSelectedChip = null;
                      });
                      cubit.clearFilter();
                    },
                    child: const Icon(FontAwesomeIcons.refresh),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(FontAwesomeIcons.circleXmark),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          const Divider(),
          // Filter by muscle
          const Text('By Muscle',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17)),
          const SizedBox(
            height: 6,
          ),
          Wrap(
            spacing: 8,
            children: state.groupedByMuscle.keys.map((muscle) {
              final isSelected = _tempSelectedType == FilterType.muscle &&
                  _tempSelectedChip == muscle;
              return FilterChip(
                label: Text(muscle),
                selected: isSelected,
                onSelected: (_) {
                  setState(() {
                    _tempSelectedType = FilterType.muscle;
                    _tempSelectedChip = muscle;
                  });
                },
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
                backgroundColor: AppColors.background,
              );
            }).toList(),
          ),

          const Divider(),
          // Filter by category
          const Text('By Category',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: state.groupedByCategory.keys.map((category) {
              final isSelected = _tempSelectedType == FilterType.category &&
                  _tempSelectedChip == category;
              return FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (_) {
                  setState(() {
                    _tempSelectedType = FilterType.category;
                    _tempSelectedChip = category;
                  });
                },
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
                backgroundColor: AppColors.background,
              );
            }).toList(),
          ),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                if (_tempSelectedType != null && _tempSelectedChip != null) {
                  cubit.setFilter(
                    type: _tempSelectedType!,
                    chipValue: _tempSelectedChip!,
                  );
                }
                Navigator.pop(context);
              },
              child: const Text(
                'Apply Filter',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          )
        ],
      ),
    );
  }
}
