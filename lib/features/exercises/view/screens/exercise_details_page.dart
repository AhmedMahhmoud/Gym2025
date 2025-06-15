import 'package:flutter/material.dart';
import 'package:gym/Shared/ui/cached_network_img.dart';
import 'package:gym/Shared/ui/custom_back_btn.dart';
import 'package:gym/Shared/ui/youtube_player.dart';
import 'package:gym/core/theme/app_colors.dart';
import 'package:gym/features/exercises/data/models/exercises.dart';

class ExerciseDetailsPage extends StatelessWidget {
  const ExerciseDetailsPage(
      {required this.exercise, required this.videoThumbnail, super.key});
  final Exercise exercise;
  final String videoThumbnail;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.topLeft,
              children: [
                if (exercise.videoUrl.isNotEmpty)
                  YoutubeIframeWidget(videoId: exercise.videoUrl),
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
              exercise.name,
              style: TextStyle(
                  fontSize: 20,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600),
            )),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: exercise.category.isEmpty
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
                            exercise.primaryMuscle,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          )),
                    ],
                  ),
                  if (exercise.category.isNotEmpty)
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
                              exercise.category,
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
                  Text(exercise.description,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w400)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
