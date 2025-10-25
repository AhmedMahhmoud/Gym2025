import 'package:easy_localization/easy_localization.dart';
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
  String? _tempSelectedMuscle; // For dual filtering
  String? _tempSelectedCategory; // For dual filtering

  @override
  void initState() {
    final state = context.read<ExercisesCubit>().state;
    _tempSelectedType = state.selectedFilterType;
    _tempSelectedChip = state.selectedChip;
    _tempSelectedMuscle = state.selectedMuscle;
    _tempSelectedCategory = state.selectedCategory;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Access locale to trigger rebuild on language change
    context.locale;

    final cubit = context.read<ExercisesCubit>();
    final state = context.watch<ExercisesCubit>().state;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header (fixed)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'workouts.filter_exercises'.tr(),
                      style: const TextStyle(
                        fontSize: 16,
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
                              _tempSelectedMuscle = null;
                              _tempSelectedCategory = null;
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
                const Divider(),
              ],
            ),
          ),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Show current filter selections if any
                  if (_tempSelectedType == FilterType.both &&
                      (_tempSelectedMuscle != null ||
                          _tempSelectedCategory != null))
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.filter_alt,
                              color: AppColors.primary, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _tempSelectedMuscle != null &&
                                      _tempSelectedCategory != null
                                  ? 'Dual Filter: $_tempSelectedMuscle + $_tempSelectedCategory'
                                  : _tempSelectedMuscle != null
                                      ? 'Muscle Selected: $_tempSelectedMuscle (select category for dual filter)'
                                      : 'Category Selected: $_tempSelectedCategory (select muscle for dual filter)',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Filter by muscle
                  Text('workouts.by_muscle'.tr(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17)),
                  const SizedBox(
                    height: 6,
                  ),
                  Wrap(
                    spacing: 8,
                    children: state.groupedByMuscle.keys.map((muscle) {
                      final isSelected =
                          (_tempSelectedType == FilterType.muscle &&
                                  _tempSelectedChip == muscle) ||
                              (_tempSelectedType == FilterType.both &&
                                  _tempSelectedMuscle == muscle);
                      return FilterChip(
                        label: Text(muscle),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            if (isSelected) {
                              // Deselect muscle
                              _tempSelectedMuscle = null;
                              // If no muscle and no category, clear dual mode
                              if (_tempSelectedCategory == null) {
                                _tempSelectedType = FilterType.none;
                              }
                            } else {
                              // Select muscle
                              _tempSelectedMuscle = muscle;
                              _tempSelectedType = FilterType.both;
                              // Clear single filter selections
                              _tempSelectedChip = null;
                            }
                          });
                        },
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color:
                              isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                        backgroundColor: AppColors.background,
                      );
                    }).toList(),
                  ),

                  const Divider(),

                  // Filter by category
                  Text('workouts.by_category'.tr(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17)),
                  Wrap(
                    spacing: 8,
                    children: state.groupedByCategory.keys.map((category) {
                      final isSelected =
                          (_tempSelectedType == FilterType.category &&
                                  _tempSelectedChip == category) ||
                              (_tempSelectedType == FilterType.both &&
                                  _tempSelectedCategory == category);
                      return FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            if (isSelected) {
                              // Deselect category
                              _tempSelectedCategory = null;
                              // If no muscle and no category, clear dual mode
                              if (_tempSelectedMuscle == null) {
                                _tempSelectedType = FilterType.none;
                              }
                            } else {
                              // Select category
                              _tempSelectedCategory = category;
                              _tempSelectedType = FilterType.both;
                              // Clear single filter selections
                              _tempSelectedChip = null;
                            }
                          });
                        },
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color:
                              isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                        backgroundColor: AppColors.background,
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Fixed bottom button
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
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
                  if (_tempSelectedType == FilterType.both &&
                      _tempSelectedMuscle != null &&
                      _tempSelectedCategory != null) {
                    // Apply dual filter (both muscle and category)
                    cubit.setDualFilter(
                      muscle: _tempSelectedMuscle!,
                      category: _tempSelectedCategory!,
                    );
                  } else if (_tempSelectedType == FilterType.both &&
                      _tempSelectedMuscle != null &&
                      _tempSelectedCategory == null) {
                    // Apply single muscle filter
                    cubit.setFilter(
                      type: FilterType.muscle,
                      chipValue: _tempSelectedMuscle!,
                    );
                  } else if (_tempSelectedType == FilterType.both &&
                      _tempSelectedMuscle == null &&
                      _tempSelectedCategory != null) {
                    // Apply single category filter
                    cubit.setFilter(
                      type: FilterType.category,
                      chipValue: _tempSelectedCategory!,
                    );
                  } else if (_tempSelectedType != null &&
                      _tempSelectedChip != null) {
                    // Apply single filter (legacy)
                    cubit.setFilter(
                      type: _tempSelectedType!,
                      chipValue: _tempSelectedChip!,
                    );
                  }
                  Navigator.pop(context);
                },
                child: Text(
                  'exercises.Apply Filter'.tr(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
