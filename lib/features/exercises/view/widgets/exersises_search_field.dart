// File: exercise_search_field.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackletics/core/theme/app_colors.dart';
import 'package:trackletics/features/exercises/view/cubit/exercises_cubit.dart';
import 'package:trackletics/features/exercises/view/widgets/exercises_filter_bottomsheet.dart';

class ExerciseSearchField extends StatelessWidget {
  const ExerciseSearchField({super.key});

  @override
  Widget build(BuildContext context) {
    // Access locale to trigger rebuild on language change
    context.locale;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<ExercisesCubit, ExercisesState>(
      builder: (context, state) {
        return TextField(
          onChanged: (value) {
            context.read<ExercisesCubit>().setSearchQuery(value);
          },
          decoration: InputDecoration(
            hintText: 'exercises.search_exercises'.tr(),
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            filled: true,
            fillColor: colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        );
      },
    );
  }
}
