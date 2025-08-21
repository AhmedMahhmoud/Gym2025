import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackletics/core/theme/app_colors.dart';
import 'package:trackletics/features/exercises/data/models/exercises.dart';
import 'package:trackletics/features/exercises/view/cubit/exercises_cubit.dart';
import 'package:trackletics/features/profile/cubit/profile_cubit.dart';
import 'package:trackletics/features/profile/cubit/profile_state.dart';
import 'package:trackletics/routes/route_names.dart';

class AdminMissingVideosScreen extends StatelessWidget {
  const AdminMissingVideosScreen({Key? key}) : super(key: key);

  List<Exercise> _getExercisesMissingAnyVideo(List<Exercise> all) {
    return all.where((e) {
      final hasMale = (e.maleVideoUrl).isNotEmpty;
      final hasFemale = (e.femaleVideoUrl).isNotEmpty;
      return !(hasMale && hasFemale);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, profileState) {
        if (!profileState.isAdmin) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Access Denied'),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: const Center(
              child: Text(
                'Admin access required',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        return BlocBuilder<ExercisesCubit, ExercisesState>(
          builder: (context, state) {
            final exercises = state.allExercises;

            if (state.status == ExerciseStatus.initial) {
              context.read<ExercisesCubit>().loadExercises(context, true, true);
            }

            final missing = _getExercisesMissingAnyVideo(exercises);

            return Scaffold(
              appBar: AppBar(
                title: const Text('Exercises Missing Videos'),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              body: state.status == ExerciseStatus.loading && exercises.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    )
                  : missing.isEmpty
                      ? const Center(
                          child: Text(
                            'All exercises have both videos. Great job! 🟢',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: missing.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final exercise = missing[index];
                            final hasMale = exercise.maleVideoUrl.isNotEmpty;
                            final hasFemale =
                                exercise.femaleVideoUrl.isNotEmpty;

                            return InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  RouteNames.admin_exercise_edit_route,
                                  arguments: [exercise],
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color:
                                            AppColors.primary.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: AppColors.primary
                                                .withOpacity(0.3)),
                                      ),
                                      child: const Icon(
                                        Icons.videocam_off,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            exercise.name,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              _buildChip(
                                                label: 'Male',
                                                ok: hasMale,
                                              ),
                                              const SizedBox(width: 8),
                                              _buildChip(
                                                label: 'Female',
                                                ok: hasFemale,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: Colors.white70,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            );
          },
        );
      },
    );
  }

  Widget _buildChip({required String label, required bool ok}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (ok ? Colors.green : Colors.red).withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: (ok ? Colors.green : Colors.red).withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            ok ? Icons.check_circle : Icons.error_outline,
            color: ok ? Colors.green : Colors.red,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: ok ? Colors.green : Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
