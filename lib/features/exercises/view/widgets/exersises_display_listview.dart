import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackletics/core/utils/shared_utils.dart';
import 'package:trackletics/features/exercises/data/models/exercises.dart';
import 'package:trackletics/features/exercises/view/widgets/exercise_pop_widget.dart';
import 'package:trackletics/features/exercises/view/cubit/exercises_cubit.dart';
import 'package:trackletics/features/exercises/view/widgets/update_custom_exercise_form.dart';
import 'package:trackletics/routes/route_names.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:trackletics/core/theme/app_colors.dart';

class ExerciseListView extends StatelessWidget {
  final List<Exercise> exercises;
  final bool isLoading;
  final bool isCustomTab;

  const ExerciseListView({
    super.key,
    required this.exercises,
    this.isLoading = false,
    this.isCustomTab = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExercisesCubit, ExercisesState>(
      builder: (context, state) {
        return Column(
          children: [
            // Loading indicator for delete operations
            if (state.status == ExerciseStatus.loading && isCustomTab)
              const LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            Expanded(
              child: Skeletonizer(
                enabled: isLoading,
                child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: isLoading ? 6 : exercises.length,
                    itemBuilder: (context, index) {
                      final exercise =
                          isLoading ? Exercise.fake() : exercises[index];
                      final imageUrl =
                          SharedUtils.extractThumbnail(exercise.videoUrl);

                      return PopAnimatedCard(
                        exercise: exercise,
                        imageUrl: imageUrl,
                        onTap: () {
                          Navigator.pushNamed(
                              context, RouteNames.exercise_details_route,
                              arguments: [exercise, imageUrl]);
                        },
                        showDelete: isCustomTab,
                        onDelete: isCustomTab
                            ? () => _showDeleteConfirmation(context, exercise)
                            : null,
                        isDeleteLoading: state.status == ExerciseStatus.loading,
                        showEdit: isCustomTab,
                        onEdit: isCustomTab
                            ? () => _editCustomExercise(context, exercise)
                            : null,
                      );
                    }),
              ),
            ),
          ],
        );
      },
    );
  }

  // Navigate to update custom exercise form and handle the result
  Future<void> _editCustomExercise(BuildContext context, Exercise exercise) async {
    // Navigate to update custom exercise form and wait for result
    final Exercise? updatedExercise = await Navigator.push<Exercise>(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateCustomExerciseForm(exercise: exercise),
      ),
    );

    // If an exercise was updated, refresh the custom exercises list
    if (updatedExercise != null) {
      // Refresh the custom exercises to get the updated data
      await context.read<ExercisesCubit>().loadCustomExercises();
    }
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context, Exercise exercise) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Delete Exercise',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${exercise.name}"? This action cannot be undone.',
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
              Navigator.pop(context);
              context.read<ExercisesCubit>().deleteCustomExercise(exercise.id);
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
