import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:trackletics/Shared/ui/custom_back_btn.dart';
import 'package:trackletics/Shared/ui/youtube_player.dart';
import 'package:trackletics/core/theme/app_colors.dart';
import 'package:trackletics/features/exercises/data/models/exercises.dart';
import 'package:trackletics/features/exercises/view/screens/admin_exercise_edit_screen.dart';
import 'package:trackletics/features/exercises/view/screens/admin_exercise_details_page.dart';
import 'package:trackletics/features/profile/cubit/profile_cubit.dart';
import 'package:trackletics/features/profile/cubit/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackletics/features/exercises/view/cubit/exercises_cubit.dart';
import 'package:trackletics/features/exercises/view/widgets/update_custom_exercise_form.dart';
import 'package:trackletics/main.dart';

class ExerciseDetailsPage extends StatelessWidget {
  const ExerciseDetailsPage(
      {required this.exercise, required this.videoThumbnail, super.key});
  final Exercise exercise;
  final String videoThumbnail;

  /// Parses description text and formats numbered instructions
  /// Returns a tuple of (formatted widget, isSteps)
  (Widget, bool) _buildFormattedDescription(String description) {
    // Check if description contains numbered instructions (e.g., "1.", "2.", etc.)
    final hasNumberedInstructions = RegExp(r'\d+\.').hasMatch(description);

    if (!hasNumberedInstructions) {
      // Regular description - display as single paragraph
      return (
        Text(
          description,
          style: TextStyle(
            color: Theme.of(navKey.currentState!.context).brightness ==
                    Brightness.dark
                ? Colors.white
                : Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        false, // Not steps
      );
    }

    // Find all numbered steps using regex
    final regex = RegExp(r'(\d+)\.\s*([^.]+)');
    final matches = regex.allMatches(description);
    final formattedSteps = <Widget>[];

    for (final match in matches) {
      final stepNumber = match.group(1)!;
      final stepText = match.group(2)!.trim();

      if (stepText.isNotEmpty) {
        formattedSteps.add(
          Padding(
            padding: const EdgeInsets.only(
              bottom: 14.0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Theme.of(navKey.currentState!.context)
                        .colorScheme
                        .primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      stepNumber,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    stepText,
                    style: TextStyle(
                      color:
                          Theme.of(navKey.currentState!.context).brightness ==
                                  Brightness.dark
                              ? Colors.white
                              : Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    return (
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: formattedSteps,
      ),
      true, // Is steps
    );
  }

  // Check if exercise is a custom exercise
  bool _isCustomExercise(BuildContext context) {
    final exercisesState = context.read<ExercisesCubit>().state;
    return exercisesState.customExercises.any((e) => e.id == exercise.id);
  }

  @override
  Widget build(BuildContext context) {
    // Access locale to trigger rebuild on language change
    context.locale;

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, profileState) {
        return BlocBuilder<ExercisesCubit, ExercisesState>(
          builder: (context, exercisesState) {
            // Get the updated exercise data from the cubit
            final updatedExercise = exercisesState.allExercises
                    .where((e) => e.name == exercise.name)
                    .firstOrNull ??
                exercise;

            final isCustomExercise = _isCustomExercise(context);

            // Redirect admin users to admin exercise details page for better video management
            if (profileState.isAdmin && !isCustomExercise) {
              return AdminExerciseDetailsPage(
                exercise: updatedExercise,
                videoThumbnail: videoThumbnail,
              );
            }

            return SafeArea(
              child: Scaffold(
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      alignment: Alignment.topLeft,
                      children: [
                        if (updatedExercise.videoUrl.isNotEmpty ||
                            updatedExercise.maleVideoUrl.isNotEmpty)
                          YoutubeIframeWidget(
                              videoId: updatedExercise.videoUrl.isEmpty
                                  ? updatedExercise.maleVideoUrl
                                  : updatedExercise.videoUrl),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CustomBackBtn(),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Center(
                        child: Text(
                      updatedExercise.name,
                      style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          fontWeight: FontWeight.w600),
                    )),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: updatedExercise.category.isEmpty
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Primary Muscle',
                                style: TextStyle(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              Chip(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  label: Text(
                                    updatedExercise.primaryMuscle,
                                    style: TextStyle(
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14),
                                  )),
                            ],
                          ),
                          if (updatedExercise.category.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Equipment',
                                  style: TextStyle(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? AppColors.textSecondary
                                          : Colors.black87,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Chip(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    label: Text(
                                      updatedExercise.category,
                                      style: TextStyle(
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    )),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Builder(
                            builder: (context) {
                              final formattedResult =
                                  _buildFormattedDescription(
                                      updatedExercise.description);
                              return Text(
                                formattedResult.$2 ? 'Steps' : 'Description',
                                style: TextStyle(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700),
                              );
                            },
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Builder(
                            builder: (context) {
                              final formattedResult =
                                  _buildFormattedDescription(
                                      updatedExercise.description);
                              return formattedResult.$1;
                            },
                          ),
                        ],
                      ),
                    ),
                    // Action buttons for custom exercises
                    if (isCustomExercise) ...[
                      const Divider(),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Text(
                            //   'Custom Exercise Actions',
                            //   style: TextStyle(
                            //     color: Colors.grey[400],
                            //     fontSize: 14,
                            //     fontWeight: FontWeight.w600,
                            //   ),
                            // ),
                            // const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildActionButton(
                                    context: context,
                                    icon: Icons.edit_outlined,
                                    label: 'exercises.edit_exercise'.tr(),
                                    color: Colors.orange,
                                    onTap: () => _editCustomExercise(
                                        context, updatedExercise),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildActionButton(
                                    context: context,
                                    icon: Icons.delete_outline,
                                    label: 'workouts.delete_exercise'.tr(),
                                    color: Colors.red,
                                    onTap: () => _showDeleteConfirmation(
                                        context, updatedExercise),
                                    isLoading: exercisesState.status ==
                                        ExerciseStatus.loading,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                // Admin Edit Floating Action Button (only for non-custom exercises)
                floatingActionButton: profileState.isAdmin && !isCustomExercise
                    ? FloatingActionButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminExerciseEditScreen(
                                exercise: updatedExercise,
                              ),
                            ),
                          );
                          // Refresh exercises data after edit
                          if (result == true) {
                            context
                                .read<ExercisesCubit>()
                                .loadExercises(context);
                          }
                        },
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 8,
                        child: const Icon(
                          Icons.edit,
                          size: 24,
                        ),
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.2),
              color.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              )
            else
              Icon(
                icon,
                color: color,
                size: 18,
              ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Navigate to update custom exercise form and handle the result
  Future<void> _editCustomExercise(
      BuildContext context, Exercise exercise) async {
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'workouts.delete_exercise'.tr(),
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'workouts.delete_exercise_confirmation'
                  .tr(namedArgs: {'name': exercise.name}),
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'workouts.delete_exercise_confirmation_desc'.tr(),
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.black87,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'common.cancel'.tr(),
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ExercisesCubit>().deleteCustomExercise(exercise.id);
              Navigator.pop(context); // Go back to exercises list
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red, Colors.red.shade700],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'workouts.delete'.tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
