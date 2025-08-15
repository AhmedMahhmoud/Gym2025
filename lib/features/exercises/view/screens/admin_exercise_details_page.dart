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
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class AdminExerciseDetailsPage extends StatefulWidget {
  const AdminExerciseDetailsPage({
    required this.exercise,
    required this.videoThumbnail,
    super.key,
  });

  final Exercise exercise;
  final String videoThumbnail;

  @override
  State<AdminExerciseDetailsPage> createState() =>
      _AdminExerciseDetailsPageState();
}

class _AdminExerciseDetailsPageState extends State<AdminExerciseDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedGender = 'male'; // Default to male

  // Separate controllers for male and female videos
  YoutubePlayerController? _maleController;
  YoutubePlayerController? _femaleController;
  bool _hasMaleVideo = false;
  bool _hasFemaleVideo = false;

  // Track current URLs to re-init when exercise changes after edit
  String? _currentMaleUrl;
  String? _currentFemaleUrl;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize controllers for both videos
    _initializeControllers(
      maleUrl: widget.exercise.maleVideoUrl,
      femaleUrl: widget.exercise.femaleVideoUrl,
    );
  }

  void _initializeControllers(
      {required String maleUrl, required String femaleUrl}) {
    _currentMaleUrl = maleUrl;
    _currentFemaleUrl = femaleUrl;
    _initMaleController(maleUrl);
    _initFemaleController(femaleUrl);
  }

  void _initMaleController(String url) {
    // Dispose old controller if exists
    _maleController?.dispose();
    _maleController = null;
    _hasMaleVideo = false;

    final maleVideoId = YoutubePlayer.convertUrlToId(url);
    if (maleVideoId != null && maleVideoId.isNotEmpty) {
      _hasMaleVideo = true;
      _maleController = YoutubePlayerController(
        initialVideoId: maleVideoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          showLiveFullscreenButton: false,
          disableDragSeek: true,
        ),
      );
    }
  }

  void _initFemaleController(String url) {
    // Dispose old controller if exists
    _femaleController?.dispose();
    _femaleController = null;
    _hasFemaleVideo = false;

    final femaleVideoId = YoutubePlayer.convertUrlToId(url);
    if (femaleVideoId != null && femaleVideoId.isNotEmpty) {
      _hasFemaleVideo = true;
      _femaleController = YoutubePlayerController(
        initialVideoId: femaleVideoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          showLiveFullscreenButton: false,
          disableDragSeek: true,
        ),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _maleController?.dispose();
    _femaleController?.dispose();
    super.dispose();
  }

  /// Navigate to full-screen video player
  void _navigateToFullScreen(BuildContext context, String videoUrl) async {
    if (videoUrl.isEmpty) return;

    final isPlaying = _selectedGender == 'male'
        ? _maleController?.value.isPlaying ?? false
        : _femaleController?.value.isPlaying ?? false;

    // Pause the embedded player before navigating
    if (isPlaying) {
      if (_selectedGender == 'male') {
        _maleController?.pause();
      } else {
        _femaleController?.pause();
      }
    }

    final id = YoutubePlayer.convertUrlToId(videoUrl);
    if (id == null || id.isEmpty) return;

    // Navigate to the full-screen player (expects videoId)
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenVideoPlayer(
          videoId: id,
          autoPlay: isPlaying,
        ),
      ),
    );
  }

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
          style: const TextStyle(
            color: Colors.white,
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

    return (
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: formattedSteps,
      ),
      true, // Is steps
    );
  }

  /// Builds the Youtube player for the selected gender.
  /// Uses a ValueKey to force rebuild when switching tabs.
  Widget _buildPlayerFor({
    required String gender,
    required Exercise exercise,
  }) {
    final isMale = gender == 'male';
    final controller = isMale ? _maleController : _femaleController;
    final hasVideo = isMale ? _hasMaleVideo : _hasFemaleVideo;
    final videoUrl = isMale ? exercise.maleVideoUrl : exercise.femaleVideoUrl;

    if (!hasVideo || controller == null) {
      return Container(
        width: MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).height / 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(13),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.video_library,
                size: 48,
                color: Colors.grey,
              ),
              SizedBox(height: 8),
              Text(
                'No video available',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height / 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: YoutubePlayer(
          key: ValueKey(gender), // <-- forces rebuild when tab changes
          controller: controller,
          bottomActions: [
            CurrentPosition(),
            ProgressBar(isExpanded: true),
            IconButton(
              color: Colors.white,
              icon: const Icon(
                Icons.fullscreen,
                size: 25,
              ),
              onPressed: () => _navigateToFullScreen(context, videoUrl),
            ),
          ],
        ),
      ),
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
                    .where((e) => e.name == widget.exercise.name)
                    .firstOrNull ??
                widget.exercise;

            // If exercise URLs changed after editing, re-init controllers safely
            final newMaleUrl = updatedExercise.maleVideoUrl;
            final newFemaleUrl = updatedExercise.femaleVideoUrl;
            if (newMaleUrl != _currentMaleUrl ||
                newFemaleUrl != _currentFemaleUrl) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                setState(() {
                  _initializeControllers(
                      maleUrl: newMaleUrl, femaleUrl: newFemaleUrl);
                });
              });
            }

            return SafeArea(
              child: Scaffold(
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      alignment: Alignment.topLeft,
                      children: [
                        _buildPlayerFor(
                          gender: _selectedGender,
                          exercise: updatedExercise,
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CustomBackBtn(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Center(
                      child: Text(
                        updatedExercise.name,
                        style: const TextStyle(
                          fontSize: 20,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Divider(),

                    // Gender selection tabs (only show if exercise has both videos)
                    if (updatedExercise.hasBothVideos) ...[
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TabBar(
                          onTap: (value) {
                            setState(() {
                              _selectedGender = value == 0 ? 'male' : 'female';
                              // Do NOT re-init controllers here; keys will force rebuild
                            });
                          },
                          controller: _tabController,
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: AppColors.primary,
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.grey,
                          tabs: const [
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.male, size: 16),
                                  SizedBox(width: 4),
                                  Text('Male'),
                                ],
                              ),
                            ),
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.female, size: 16),
                                  SizedBox(width: 4),
                                  Text('Female'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

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
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Chip(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                label: Text(
                                  updatedExercise.primaryMuscle,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
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
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Chip(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  label: Text(
                                    updatedExercise.category,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
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
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 15),
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

                    // Video availability info for admin
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Video Availability',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.male,
                                color: updatedExercise.hasMaleVideo
                                    ? Colors.green
                                    : Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Male Video: ${updatedExercise.hasMaleVideo ? "Available" : "Not Available"}',
                                style: TextStyle(
                                  color: updatedExercise.hasMaleVideo
                                      ? Colors.green
                                      : Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.female,
                                color: updatedExercise.hasFemaleVideo
                                    ? Colors.green
                                    : Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Female Video: ${updatedExercise.hasFemaleVideo ? "Available" : "Not Available"}',
                                style: TextStyle(
                                  color: updatedExercise.hasFemaleVideo
                                      ? Colors.green
                                      : Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Admin Edit Floating Action Button
                floatingActionButton: FloatingActionButton(
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
                    if (result == true && mounted) {
                      // Reload list (will trigger rebuild)
                      context.read<ExercisesCubit>().loadExercises(context);
                      // Controllers will auto re-init on next build if URLs changed
                    }
                  },
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  child: const Icon(
                    Icons.edit,
                    size: 24,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
