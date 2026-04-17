import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trackletics/Shared/ui/custom_back_btn.dart';
import 'package:trackletics/core/theme/app_colors.dart';
import 'package:trackletics/features/workouts/cubits/workouts_cubit.dart';
import 'package:trackletics/features/workouts/cubits/workouts_state.dart';
import 'package:trackletics/features/workouts/data/models/workout_model.dart';
import 'package:trackletics/features/workouts/views/screens/workout_details_screen.dart';
import 'package:trackletics/Shared/ui/sticky_add_button.dart';
import 'package:easy_localization/easy_localization.dart';
// import 'package:trackletics/core/debug/api_logger_model.dart';
// import 'package:trackletics/routes/route_names.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({Key? key}) : super(key: key);

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController(); // Add notes controller
  bool _isAddingWorkout = false;
  final Map<String, bool> _isDeleting = {};
  late WorkoutsCubit _workoutsCubit;

  @override
  void initState() {
    super.initState();
    _workoutsCubit = context.read<WorkoutsCubit>();
    if (_workoutsCubit.state.workouts.isEmpty) {
      // _workoutsCubit.loadWorkouts();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose(); // Dispose notes controller
    super.dispose();
  }

  void _navigateToExercises(WorkoutModel workout) {
    _workoutsCubit.setCurrentWorkout(workout);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => BlocProvider.value(
          value: _workoutsCubit,
          child: const WorkoutDetailsScreen(),
        ),
      ),
    );
  }

  void _createWorkout() {
    if (context.read<WorkoutsCubit>().state.isGuidedMode) return;

    if (_titleController.text.isNotEmpty) {
      setState(() {
        _isAddingWorkout = true;
      });

      // Logger navigation commented out
      // void navigateToLogger(ApiLoggerModel logData) {
      //   Navigator.pushNamed(
      //     context,
      //     RouteNames.api_logger_route,
      //     arguments: [logData],
      //   );
      // }

      _workoutsCubit
          .createWorkout(
        _titleController.text,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        // onLogCreated: navigateToLogger,
      )
          .then((newWorkout) {
        _titleController.clear();
        _notesController.clear();
        setState(() {
          _isAddingWorkout = false;
        });
      }).catchError((error) {
        setState(() {
          _isAddingWorkout = false;
        });
      });
    }
  }

  void _showEditWorkoutDialog(WorkoutModel workout) {
    final titleController = TextEditingController(text: workout.title);
    final notesController = TextEditingController(text: workout.notes);

    showDialog(
      context: context,
      builder: (context) => FadeInWidget(
        duration: const Duration(milliseconds: 300),
        child: AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF2A2A2A)
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'workouts.edit_workout'.tr(),
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
                  labelStyle: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey
                        : Colors.black54,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  hintText: 'workouts.notes_optional'.tr(),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
                  labelStyle: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey
                        : Colors.black54,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'workouts.cancel'.tr(),
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.black87,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _updateWorkout(
                  workout.id,
                  titleController.text,
                  notesController.text,
                );
                Navigator.pop(context);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'workouts.update'.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateWorkout(String workoutId, String title, String notes) {
    if (context.read<WorkoutsCubit>().state.isGuidedMode) return;

    _workoutsCubit.updateWorkout(
      workoutId,
      title: title,
      notes: notes,
    );
  }

  void _showDeleteConfirmationDialog(WorkoutModel workout) {
    showDialog(
      context: context,
      builder: (context) => FadeInWidget(
        duration: const Duration(milliseconds: 300),
        child: AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF2A2A2A)
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'workouts.delete_workout'.tr(),
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'workouts.delete_workout_confirmation'
                .tr(namedArgs: {'title': workout.title}),
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'workouts.cancel'.tr(),
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.black87,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteWorkout(workout);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.redAccent,
                      Colors.redAccent.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'workouts.delete'.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteWorkout(WorkoutModel workout) {
    if (context.read<WorkoutsCubit>().state.isGuidedMode) return;

    setState(() {
      _isDeleting[workout.id] = true;
    });

    _workoutsCubit.deleteWorkout(workout.id).then((_) {
      setState(() {
        _isDeleting.remove(workout.id);
      });
    }).catchError((error) {
      setState(() {
        _isDeleting.remove(workout.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('workouts.failed_to_delete_workout'
              .tr(namedArgs: {'error': error.toString()})),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Access locale to trigger rebuild on language change
    context.locale;

    return Scaffold(
      appBar: AppBar(
        leading: const CustomBackBtn(),
        title: Text(
          _workoutsCubit.state.currentPlan?.title ?? 'workouts.workouts'.tr(),
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        bottom: false,
        child: BlocConsumer<WorkoutsCubit, WorkoutsState>(
          listenWhen: (previous, current) =>
              (current.status == WorkoutsStatus.creatingWorkout &&
                  previous.status != WorkoutsStatus.creatingWorkout) ||
              (current.status == WorkoutsStatus.deletingWorkout &&
                  previous.status != WorkoutsStatus.deletingWorkout) ||
              (current.status == WorkoutsStatus.error &&
                  (previous.status == WorkoutsStatus.creatingWorkout ||
                      previous.status == WorkoutsStatus.deletingWorkout)),
          listener: (context, state) {
            if (state.status == WorkoutsStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      state.errorMessage ?? 'workouts.an_error_occurred'.tr()),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.status == WorkoutsStatus.loading ||
                state.status == WorkoutsStatus.loadingWorkouts) {
              return SizedBox(
                height: MediaQuery.sizeOf(context).height / 1.5,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (state.status == WorkoutsStatus.loading ||
                          state.status == WorkoutsStatus.loadingWorkouts)
                        Text(
                          'workouts.loading_workouts'.tr(),
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white70
                                    : Colors.black87,
                          ),
                        )
                      else
                        Text(
                          'workouts.loading_workouts'.tr(),
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white70
                                    : Colors.black87,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }

            if (state.status == WorkoutsStatus.error &&
                state.workouts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.errorMessage ??
                          'workouts.failed_to_load_workouts'.tr(),
                      style: const TextStyle(
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _workoutsCubit.loadWorkoutsForPlan(
                          _workoutsCubit.state.currentPlan!.id),
                      child: Text('workouts.retry'.tr()),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                if (state.status == WorkoutsStatus.updatingWorkout)
                  const LinearProgressIndicator(
                    backgroundColor: AppColors.primary,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                if (_isAddingWorkout && !state.isGuidedMode)
                  FadeIn(
                    duration: const Duration(milliseconds: 500),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              labelText: 'workouts.workout_title'.tr(),
                              floatingLabelStyle: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              hintText: 'workouts.workout_title_hint'.tr(),
                              filled: true,
                              fillColor: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.black.withOpacity(0.05),
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey
                                    : Colors.black54,
                              ),
                              hintStyle: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white38
                                    : Colors.black38,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                            ),
                            style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            onTapOutside: (event) =>
                                FocusScope.of(context).unfocus(),
                            autofocus: true,
                          ),
                          const SizedBox(height: 16),
                          // Add notes field
                          TextField(
                            controller: _notesController,
                            decoration: InputDecoration(
                              labelText: 'workouts.notes_optional'.tr(),
                              floatingLabelStyle: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              hintText: 'workouts.workout_notes_hint'.tr(),
                              filled: true,
                              fillColor: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.black.withOpacity(0.05),
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey
                                    : Colors.black54,
                              ),
                              hintStyle: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white38
                                    : Colors.black38,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                            ),
                            style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            onTapOutside: (event) =>
                                FocusScope.of(context).unfocus(),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Add cancel button
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isAddingWorkout = false;
                                    _titleController.clear();
                                    _notesController.clear();
                                  });
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white70
                                          : Colors.black87,
                                ),
                                child: Text('workouts.cancel'.tr()),
                              ),
                              const SizedBox(width: 8),
                              if (state.status == WorkoutsStatus.loading)
                                Container(
                                  width: double.infinity,
                                  height: 4,
                                  margin: const EdgeInsets.only(bottom: 20),
                                  child: const LinearProgressIndicator(
                                    backgroundColor: AppColors.primary,
                                  ),
                                )
                              else
                                Flexible(
                                  child: ElasticIn(
                                    duration: const Duration(milliseconds: 800),
                                    child: ElevatedButton(
                                      onPressed: _createWorkout,
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 15,
                                        ),
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                      ).copyWith(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                          Colors.transparent,
                                        ),
                                        overlayColor: MaterialStateProperty.all(
                                          Colors.white.withOpacity(0.1),
                                        ),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Theme.of(context).primaryColor,
                                              Theme.of(context)
                                                  .primaryColor
                                                  .withOpacity(0.7),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Theme.of(context)
                                                  .primaryColor
                                                  .withOpacity(0.5),
                                              blurRadius: 10,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 15,
                                        ),
                                        child: Text(
                                          'workouts.create_workout'.tr(),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                Expanded(
                  child: state.workouts.isEmpty && !_isAddingWorkout
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FadeIn(
                                duration: const Duration(milliseconds: 800),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30),
                                  child: Text(
                                    'workouts.add_new_workout'.tr(),
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white70
                                          : Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              if (!state.isGuidedMode)
                                SlideInUp(
                                  duration: const Duration(milliseconds: 1000),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _isAddingWorkout = true;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 40,
                                        vertical: 15,
                                      ),
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ).copyWith(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                        Colors.transparent,
                                      ),
                                      overlayColor: MaterialStateProperty.all(
                                        Colors.white.withOpacity(0.1),
                                      ),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.textSecondary,
                                            Theme.of(context)
                                                .colorScheme
                                                .surface
                                                .withOpacity(0.7),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.buttonText
                                                .withOpacity(0.5),
                                            blurRadius: 2,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      padding: const EdgeInsets.all(15),
                                      child: Icon(
                                        Icons.add,
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )
                      : (state.isGuidedMode
                          ? ListView.builder(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 16, 16, 100),
                              itemCount: state.workouts.length,
                              itemBuilder: (context, index) {
                                final workout = state.workouts[index];
                                return _buildWorkoutCard(workout, index);
                              },
                            )
                          : ReorderableListView.builder(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 16, 16, 100),
                              itemCount: state.workouts.length,
                              onReorder: (oldIndex, newIndex) async {
                                await _workoutsCubit.reorderWorkouts(
                                    oldIndex, newIndex);
                              },
                              itemBuilder: (context, index) {
                                final workout = state.workouts[index];
                                final isDeleting =
                                    _isDeleting[workout.id] ?? false;
                                return AnimatedSwitcher(
                                  key: ValueKey(workout.id),
                                  duration: const Duration(milliseconds: 300),
                                  switchOutCurve: Curves.easeOut,
                                  switchInCurve: Curves.easeIn,
                                  transitionBuilder: (Widget child,
                                      Animation<double> animation) {
                                    if (!isDeleting) {
                                      return FadeIn(
                                        duration:
                                            const Duration(milliseconds: 500),
                                        child: child,
                                      );
                                    }
                                    return FadeOut(
                                      curve: Curves.easeOut,
                                      child: child,
                                    );
                                  },
                                  child: isDeleting
                                      ? Container(
                                          key: ValueKey(
                                              '${workout.id}_deleting'))
                                      : _buildWorkoutCard(workout, index),
                                );
                              },
                            )),
                ),
                if (!state.isGuidedMode)
                  BlocBuilder<WorkoutsCubit, WorkoutsState>(
                    builder: (context, state) {
                      return StickyAddButton(
                        onPressed: () {
                          setState(() {
                            _isAddingWorkout = true;
                          });
                        },
                        text: 'workouts.add_workout'.tr(),
                        icon: Icons.add,
                        isVisible:
                            !_isAddingWorkout && state.workouts.isNotEmpty,
                      );
                    },
                  ),
              ],
            );
          },
        ),
        // Sticky Add Button
      ),
    );
  }

  Widget _buildWorkoutCard(WorkoutModel workout, int index) {
    return Card(
      key: ValueKey(workout.id),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          title: Text(
            workout.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          subtitle: workout.notes != null && workout.notes!.isNotEmpty
              ? Text(
                  workout.notes!,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black38,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!context.read<WorkoutsCubit>().state.isGuidedMode)
                IconButton(
                  icon: Icon(FontAwesomeIcons.edit,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : AppColors.textSecondary),
                  onPressed: () => _showEditWorkoutDialog(workout),
                ),
              if (!context.read<WorkoutsCubit>().state.isGuidedMode)
                IconButton(
                  icon: const Icon(FontAwesomeIcons.circleXmark,
                      color: Colors.redAccent),
                  onPressed: () => _showDeleteConfirmationDialog(workout),
                ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.black,
              ),
            ],
          ),
          onTap: () => _navigateToExercises(workout),
        ),
      ),
    );
  }
}

class FadeInWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const FadeInWidget({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
  }) : super(key: key);

  @override
  _FadeInWidgetState createState() => _FadeInWidgetState();
}

class _FadeInWidgetState extends State<FadeInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}
