import 'package:flutter/material.dart';
import 'package:trackletics/Shared/ui/cached_network_img.dart';
import 'package:trackletics/Shared/ui/custom_back_btn.dart';
import 'package:trackletics/Shared/ui/youtube_player.dart';
import 'package:trackletics/core/theme/app_colors.dart';
import 'package:trackletics/features/exercises/data/models/exercises.dart';
import 'package:trackletics/features/exercises/view/screens/admin_exercise_edit_screen.dart';
import 'package:trackletics/features/profile/cubit/profile_cubit.dart';
import 'package:trackletics/features/profile/cubit/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackletics/features/exercises/view/cubit/exercises_cubit.dart';

class ExerciseDetailsPage extends StatelessWidget {
  const ExerciseDetailsPage(
      {required this.exercise, required this.videoThumbnail, super.key});
  final Exercise exercise;
  final String videoThumbnail;

  /// Parses description text and formats numbered instructions
  Widget _buildFormattedDescription(String description) {
    // Check if description contains numbered instructions (e.g., "1.", "2.", etc.)
    final hasNumberedInstructions = RegExp(r'\d+\.').hasMatch(description);

    if (!hasNumberedInstructions) {
      // Regular description - display as single paragraph
      return Text(
        description,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
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
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
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
                    style: const TextStyle(
                      color: Colors.white,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: formattedSteps,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, profileState) {
        return BlocBuilder<ExercisesCubit, ExercisesState>(
          builder: (context, exercisesState) {
            // Get the updated exercise data from the cubit
            final updatedExercise = exercisesState.allExercises
                    .where((e) => e.name == exercise.name)
                    .firstOrNull ??
                exercise;

            return SafeArea(
              child: Scaffold(
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      alignment: Alignment.topLeft,
                      children: [
                        if (updatedExercise.videoUrl.isNotEmpty)
                          YoutubeIframeWidget(
                              videoId: updatedExercise.videoUrl),
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
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600),
                    )),
                    Divider(),
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
                              const Text(
                                'Primary Muscle',
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              Chip(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  label: Text(
                                    updatedExercise.primaryMuscle,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  )),
                            ],
                          ),
                          if (updatedExercise.category.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Equipment',
                                  style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Chip(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    label: Text(
                                      updatedExercise.category,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    )),
                              ],
                            ),
                        ],
                      ),
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Description",
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          _buildFormattedDescription(
                              updatedExercise.description),
                        ],
                      ),
                    )
                  ],
                ),
                // Admin Edit Floating Action Button
                floatingActionButton: profileState.isAdmin
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
                            context.read<ExercisesCubit>().loadExercises();
                          }
                        },
                        backgroundColor: AppColors.primary,
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
}
