// File: exercise_search_field.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym/core/theme/app_colors.dart';
import 'package:gym/features/exercises/view/cubit/exercises_cubit.dart';
import 'package:gym/features/exercises/view/widgets/exercises_filter_bottomsheet.dart';

class ExerciseSearchField extends StatelessWidget {
  const ExerciseSearchField({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExercisesCubit>();

    return Row(
      children: [
        Expanded(
          child: TextField(
            onTapOutside: (event) => FocusScope.of(context).unfocus(),
            onChanged: cubit.setSearchQuery,
            decoration: InputDecoration(
              hintText: 'Search for an exercise',
              filled: true,
              fillColor: AppColors.surface,
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              hintStyle: const TextStyle(color: Colors.white54),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: () => showAnimatedFilterBottomSheet(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.filter_list, color: Colors.white),
          ),
        )
      ],
    );
  }

  Future<void> showAnimatedFilterBottomSheet(BuildContext context) {
    final cubit = context.read<ExercisesCubit>();

    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Filter",
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: Colors.transparent,
            child: BlocProvider.value(
              value: cubit,
              child: const ExerciseFilterBottomSheet(),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOut)),
          child: FadeTransition(
            opacity: anim1,
            child: child,
          ),
        );
      },
    );
  }
}
