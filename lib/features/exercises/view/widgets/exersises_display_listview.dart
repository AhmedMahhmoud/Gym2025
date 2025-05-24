import 'package:flutter/material.dart';
import 'package:gym/core/utils/shared_utils.dart';
import 'package:gym/features/exercises/data/models/exercises.dart';
import 'package:gym/features/exercises/view/widgets/exercise_pop_widget.dart';
import 'package:gym/routes/route_names.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:gym/core/theme/app_colors.dart';

class ExerciseListView extends StatelessWidget {
  final List<Exercise> exercises;
  final bool isLoading;

  const ExerciseListView({
    super.key,
    required this.exercises,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Skeletonizer(
        enabled: isLoading,
        child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: isLoading ? 6 : exercises.length,
            itemBuilder: (context, index) {
              final exercise = isLoading ? Exercise.fake() : exercises[index];
              final imageUrl = SharedUtils.extractThumbnail(exercise.videoUrl);

              return PopAnimatedCard(
                exercise: exercise,
                imageUrl: imageUrl,
                onTap: () {
                  Navigator.pushNamed(
                      context, RouteNames.exercise_details_route,
                      arguments: [exercise, imageUrl]);
                },
              );
            }),
      ),
    );
  }
}
