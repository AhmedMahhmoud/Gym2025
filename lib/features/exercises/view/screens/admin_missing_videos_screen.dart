import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackletics/Shared/ui/custom_back_btn.dart';
import 'package:trackletics/core/theme/app_colors.dart';
import 'package:trackletics/features/exercises/data/models/exercises.dart';
import 'package:trackletics/features/exercises/data/models/missing_video_exercise.dart';
import 'package:trackletics/features/exercises/view/cubit/exercises_cubit.dart';
import 'package:trackletics/features/profile/cubit/profile_cubit.dart';
import 'package:trackletics/features/profile/cubit/profile_state.dart';
import 'package:trackletics/routes/route_names.dart';

class AdminMissingVideosScreen extends StatefulWidget {
  const AdminMissingVideosScreen({Key? key}) : super(key: key);

  @override
  State<AdminMissingVideosScreen> createState() =>
      _AdminMissingVideosScreenState();
}

class _AdminMissingVideosScreenState extends State<AdminMissingVideosScreen> {
  @override
  void initState() {
    super.initState();
    // Always refresh missing videos on enter
    final cubit = context.read<ExercisesCubit>();
    cubit.loadMissingVideos();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, profileState) {
        if (!profileState.isAdmin) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Access Denied',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: CustomBackBtn(),
            ),
            body: Center(
              child: Text(
                'Admin access required',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
          );
        }

        return BlocBuilder<ExercisesCubit, ExercisesState>(
          builder: (context, state) {
            final exercises = state.allExercises;
            final bool isLoadingMissing =
                state.missingVideosStatus == ExerciseStatus.loading;

            // Ensure full exercises are loaded for navigation/editing
            if (state.status == ExerciseStatus.initial) {
              context.read<ExercisesCubit>().loadExercises(context, true, true);
            }
            final List<MissingVideoExercise> missing = state.missingVideos;

            return Scaffold(
              appBar: AppBar(
                leading: CustomBackBtn(),
                title: Text(
                  'profile.admin_missing_videos'.tr(),
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                actions: [
                  if (isLoadingMissing)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              body: (isLoadingMissing && missing.isEmpty)
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    )
                  : missing.isEmpty
                      ? Center(
                          child: Text(
                            'All exercises have both videos. Great job! 🟢',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white70
                                  : Colors.black87,
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            if (isLoadingMissing)
                              const Column(
                                children: [
                                  LinearProgressIndicator(
                                    backgroundColor: Colors.transparent,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.primary),
                                  ),
                                  SizedBox(height: 8),
                                ],
                              ),
                            Expanded(
                              child: ListView.separated(
                                padding: const EdgeInsets.all(16),
                                itemCount: missing.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final item = missing[index];
                                  // Try to find full exercise details for editing
                                  final matches = exercises
                                      .where((e) => e.id == item.id)
                                      .toList();
                                  final Exercise? fullExercise =
                                      matches.isNotEmpty ? matches.first : null;

                                  return InkWell(
                                    onTap: () {
                                      if (fullExercise != null) {
                                        Navigator.pushNamed(
                                          context,
                                          RouteNames.admin_exercise_edit_route,
                                          arguments: [fullExercise],
                                        );
                                      } else {
                                        // Fallback by title match if ids differ
                                        final byTitle = exercises
                                            .where((e) => e.name == item.title)
                                            .toList();
                                        if (byTitle.isNotEmpty) {
                                          Navigator.pushNamed(
                                            context,
                                            RouteNames
                                                .admin_exercise_edit_route,
                                            arguments: [byTitle.first],
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Exercise details not available yet. Try again after list loads.',
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.primary
                                              .withOpacity(0.3),
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: AppColors.primary
                                                  .withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: AppColors.primary
                                                      .withOpacity(0.3)),
                                            ),
                                            child: Icon(Icons.videocam_off,
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : AppColors.primaryLight),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.title,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                                .brightness ==
                                                            Brightness.dark
                                                        ? Colors.white
                                                        : Colors.black,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  'Missing at least one video',
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                                .brightness ==
                                                            Brightness.dark
                                                        ? Colors.white70
                                                        : Colors.black87,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.chevron_right,
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? Colors.white70
                                                    : Colors.black87,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
            );
          },
        );
      },
    );
  }
}
