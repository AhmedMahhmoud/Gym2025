import 'dart:developer';
import 'package:trackletics/Shared/ui/custom_snackbar.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trackletics/core/theme/app_colors.dart';
import 'package:trackletics/features/workouts/cubits/workouts_cubit.dart';
import 'package:trackletics/features/workouts/cubits/workouts_state.dart';
import 'package:trackletics/features/workouts/data/models/plan_response.dart';
import 'package:trackletics/features/workouts/views/screens/workouts_screen.dart';
import 'package:trackletics/features/workouts/views/widgets/error_message.dart';
import 'package:trackletics/Shared/ui/sticky_add_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:trackletics/features/recommendation/cubit/plan_recommendation_chat_cubit.dart';
import 'package:trackletics/features/recommendation/cubit/plan_recommendation_chat_state.dart';
import 'package:trackletics/features/recommendation/view/draggable_plan_chat_bubble.dart';
// import 'package:trackletics/core/debug/api_logger_model.dart';
// import 'package:trackletics/routes/route_names.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({Key? key}) : super(key: key);

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen>
    with TickerProviderStateMixin {
  static const int _kAiPlansTabIndex = 1;

  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isAddingPlan = false;
  final Map<String, bool> _isDeleting = {};
  late WorkoutsCubit _workoutsCubit;
  late TabController _tabController;

  void _onPlansTabControllerChanged() {
    if (_tabController.indexIsChanging) return;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _workoutsCubit = context.read<WorkoutsCubit>();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onPlansTabControllerChanged);
    log('WORKOUT SCREEN LOAD');
    _workoutsCubit.loadPlans();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _consumePendingAiPlansTab());
  }

  void _consumePendingAiPlansTab() {
    if (!mounted) return;
    final cubit = context.read<PlanRecommendationChatCubit>();
    if (!cubit.state.pendingOpenAiPlansTab) return;
    if (_tabController.index != _kAiPlansTabIndex) {
      _tabController.animateTo(_kAiPlansTabIndex);
    }
    cubit.clearPendingOpenAiPlansTab();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onPlansTabControllerChanged);
    _titleController.dispose();
    _notesController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToWorkouts(PlanResponse plan) {
    _workoutsCubit.setCurrentPlan(plan);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => BlocProvider.value(
          value: _workoutsCubit,
          child: const WorkoutsScreen(),
        ),
      ),
    );
  }

  void _createPlan() {
    if (_titleController.text.isNotEmpty) {
      setState(() {
        _isAddingPlan = true;
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
          .createPlan(
        _titleController.text,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        // onLogCreated: navigateToLogger,
      )
          .then((_) {
        _titleController.clear();
        _notesController.clear();
        setState(() {
          _isAddingPlan = false;
        });
      });
    }
  }

  void _showErrorSnackBar(String message) {
    CustomSnackbar.show(context, message, isError: true);
  }

  void _showEditPlanDialog(PlanResponse plan) {
    final titleController = TextEditingController(text: plan.title);
    final notesController = TextEditingController(text: plan.notes);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) => FadeIn(
        duration: const Duration(milliseconds: 300),
        child: AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'plans.edit_plan'.tr(),
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'plans.title'.tr(),
                  filled: true,
                  fillColor: colorScheme.surface,
                  labelStyle:
                      TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(color: colorScheme.onSurface),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: 'plans.notes_optional'.tr(),
                  filled: true,
                  fillColor: colorScheme.surface,
                  labelStyle:
                      TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(color: colorScheme.onSurface),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'plans.cancel'.tr(),
                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
              ),
            ),
            TextButton(
              onPressed: () {
                _updatePlan(
                  plan.id,
                  titleController.text,
                  notesController.text,
                );
                Navigator.pop(context);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'plans.update'.tr(),
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

  void _updatePlan(String planId, String title, String notes) {
    _workoutsCubit.updatePlan(
      planId,
      title: title,
      notes: notes,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Access locale to trigger rebuild on language change
    context.locale;

    return BlocListener<PlanRecommendationChatCubit,
        PlanRecommendationChatState>(
      listenWhen: (previous, current) =>
          current.pendingOpenAiPlansTab && !previous.pendingOpenAiPlansTab,
      listener: (context, state) {
        _consumePendingAiPlansTab();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'plans.workout_plans'.tr(),
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Builder(
              builder: (context) {
                final theme = Theme.of(context);
                final colorScheme = theme.colorScheme;
                return TabBar(
                  dividerColor: Colors.transparent,
                  controller: _tabController,
                  indicatorColor: colorScheme.primary,
                  labelColor: colorScheme.onSurface,
                  unselectedLabelColor: colorScheme.onSurface.withOpacity(0.7),
                  tabs: [
                    Tab(text: 'plans.my_plans'.tr()),
                    Tab(text: 'plans.ai_plans'.tr()),
                  ],
                );
              },
            ),
          ),
        ),
        body: Stack(
          clipBehavior: Clip.none,
          children: [
            SafeArea(
              bottom: false,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildUserPlansTab(),
                  _buildRecommendedPlansTab(),
                ],
              ),
            ),
            if (_tabController.index == _kAiPlansTabIndex)
              DraggablePlanChatBubble(
                onOpenWorkoutsTab: () {},
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserPlansTab() {
    return BlocConsumer<WorkoutsCubit, WorkoutsState>(
      listenWhen: (previous, current) =>
          (current.status == WorkoutsStatus.creatingPlan &&
              previous.status != WorkoutsStatus.creatingPlan) ||
          (current.status == WorkoutsStatus.generatingRecommendation &&
              previous.status != WorkoutsStatus.generatingRecommendation) ||
          (current.status == WorkoutsStatus.deletingPlan &&
              previous.status != WorkoutsStatus.deletingPlan) ||
          (current.status == WorkoutsStatus.updatingPlan &&
              previous.status != WorkoutsStatus.updatingPlan) ||
          (current.status == WorkoutsStatus.error &&
              (previous.status == WorkoutsStatus.creatingPlan ||
                  previous.status == WorkoutsStatus.generatingRecommendation ||
                  previous.status == WorkoutsStatus.deletingPlan ||
                  previous.status == WorkoutsStatus.updatingPlan)),
      listener: (context, state) {
        if (state.status == WorkoutsStatus.error) {
          _showErrorSnackBar(
              state.errorMessage ?? 'plans.an_error_occurred'.tr());
        }
      },
      builder: (context, state) {
        log(state.status.toString(), name: 'test');
        if (state.status == WorkoutsStatus.error && state.plans.isEmpty) {
          return ErrorMessage(
            message: state.errorMessage ?? 'plans.failed_to_load_plans'.tr(),
            onRetry: () => _workoutsCubit.loadPlans(),
          );
        }

        return Column(
          children: [
            if (state.status == WorkoutsStatus.loadingPlans)
              Builder(
                builder: (context) {
                  final theme = Theme.of(context);
                  final colorScheme = theme.colorScheme;
                  return SizedBox(
                    height: MediaQuery.sizeOf(context).height / 2,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.primary),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'plans.loading_plans'.tr(),
                            style: TextStyle(
                                color: colorScheme.onSurface.withOpacity(0.7)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            if (_isAddingPlan)
              Builder(
                builder: (context) {
                  final theme = Theme.of(context);
                  final colorScheme = theme.colorScheme;
                  final isDark = theme.brightness == Brightness.dark;
                  return FadeIn(
                    duration: const Duration(milliseconds: 500),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              labelText: 'plans.plan_title'.tr(),
                              floatingLabelStyle: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                                color: colorScheme.primary,
                              ),
                              hintText: 'plans.plan_title_hint'.tr(),
                              filled: true,
                              fillColor: isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : colorScheme.surface,
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface.withOpacity(0.7),
                              ),
                              hintStyle: TextStyle(
                                  color:
                                      colorScheme.onSurface.withOpacity(0.5)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                            ),
                            style: TextStyle(color: colorScheme.onSurface),
                            onTapOutside: (event) =>
                                FocusScope.of(context).unfocus(),
                            autofocus: true,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _notesController,
                            decoration: InputDecoration(
                              labelText: 'plans.notes_optional'.tr(),
                              floatingLabelStyle: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                                color: colorScheme.primary,
                              ),
                              hintText: 'plans.notes_hint'.tr(),
                              filled: true,
                              fillColor: isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : colorScheme.surface,
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface.withOpacity(0.7),
                              ),
                              hintStyle: TextStyle(
                                  color:
                                      colorScheme.onSurface.withOpacity(0.5)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                            ),
                            style: TextStyle(color: colorScheme.onSurface),
                            onTapOutside: (event) =>
                                FocusScope.of(context).unfocus(),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isAddingPlan = false;
                                    _titleController.clear();
                                    _notesController.clear();
                                  });
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      colorScheme.onSurface.withOpacity(0.7),
                                ),
                                child: Text('plans.cancel'.tr()),
                              ),
                              const SizedBox(width: 16),
                              if (state.status == WorkoutsStatus.loading)
                                Container(
                                  width: double.infinity,
                                  height: 4,
                                  margin: const EdgeInsets.only(bottom: 20),
                                  child: LinearProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        colorScheme.primary),
                                    backgroundColor:
                                        colorScheme.primary.withOpacity(0.2),
                                  ),
                                )
                              else
                                ElasticIn(
                                  duration: const Duration(milliseconds: 800),
                                  child: ElevatedButton(
                                    onPressed: _createPlan,
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
                                            Theme.of(context).primaryColor,
                                            Theme.of(context)
                                                .primaryColor
                                                .withOpacity(0.7),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(30),
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
                                        horizontal: 30,
                                        vertical: 15,
                                      ),
                                      child: Text(
                                        'plans.create_plan'.tr(),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
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
                  );
                },
              ),
            if (state.status == WorkoutsStatus.creatingPlan)
              Container(
                width: double.infinity,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: LinearProgressIndicator(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            Expanded(
              child: state.plans.isEmpty &&
                      !_isAddingPlan &&
                      state.status != WorkoutsStatus.loadingPlans
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FadeIn(
                            duration: const Duration(milliseconds: 800),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 30),
                              child: Text(
                                'plans.add_new_plan'.tr(),
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
                          SlideInUp(
                            duration: const Duration(milliseconds: 1000),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isAddingPlan = true;
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
                                backgroundColor: MaterialStateProperty.all(
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
                                      color:
                                          AppColors.buttonText.withOpacity(0.5),
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
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      itemCount: state.plans.length,
                      itemBuilder: (context, index) {
                        final plan = state.plans[index];
                        final isDeleting = _isDeleting[plan.id] ?? false;
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          switchOutCurve: Curves.easeOut,
                          switchInCurve: Curves.easeIn,
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            if (!isDeleting) {
                              return FadeIn(
                                duration: const Duration(milliseconds: 500),
                                child: child,
                              );
                            }
                            return FadeOut(
                              curve: Curves.easeOut,
                              child: child,
                            );
                          },
                          child: isDeleting
                              ? Container(key: ValueKey('${plan.id}_deleting'))
                              : _buildPlanCard(plan, index),
                        );
                      },
                    ),
            ),
            BlocBuilder<WorkoutsCubit, WorkoutsState>(
              builder: (context, state) {
                return StickyAddButton(
                  onPressed: () {
                    setState(() {
                      _isAddingPlan = true;
                    });
                  },
                  text: 'plans.add_plan'.tr(),
                  icon: Icons.add,
                  isVisible: !_isAddingPlan && state.plans.isNotEmpty,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecommendedPlansTab() {
    return BlocBuilder<WorkoutsCubit, WorkoutsState>(
      builder: (context, state) {
        if (state.status == WorkoutsStatus.loadingPlans) {
          return SizedBox(
            height: MediaQuery.sizeOf(context).height / 2,
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
                  Text(
                    'plans.loading_plans'.tr(),
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
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
            state.recommendedPlans.isEmpty) {
          return ErrorMessage(
            message: state.errorMessage ?? 'plans.failed_to_load_plans'.tr(),
            onRetry: () => _workoutsCubit.loadPlans(),
          );
        }

        return Column(
          children: [
            if (state.status == WorkoutsStatus.generatingRecommendation)
              Container(
                width: double.infinity,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: LinearProgressIndicator(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            Expanded(
              child: state.recommendedPlans.isEmpty &&
                      state.status != WorkoutsStatus.loadingPlans
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 56,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'plans.no_ai_plans_yet'.tr(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            // const SizedBox(height: 10),
                            // Text(
                            //   'plans.use_home_chat_hint'.tr(),
                            //   style: TextStyle(
                            //     color: Theme.of(context)
                            //         .colorScheme
                            //         .onSurface
                            //         .withOpacity(0.7),
                            //   ),
                            //   textAlign: TextAlign.center,
                            // ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      itemCount: state.recommendedPlans.length,
                      itemBuilder: (context, index) {
                        final plan = state.recommendedPlans[index];
                        return _buildPlanCard(plan, index);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlanCard(PlanResponse plan, int index) {
    final isDeleting = _isDeleting[plan.id] ?? false;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      key: ValueKey(plan.id),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            ListTile(
              title: Text(
                plan.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: colorScheme.onSurface,
                ),
              ),
              subtitle: plan.notes != null && plan.notes!.isNotEmpty
                  ? Text(
                      plan.notes!,
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(FontAwesomeIcons.edit,
                        color: colorScheme.onSurface.withOpacity(0.7)),
                    onPressed: () => _showEditPlanDialog(plan),
                  ),
                  IconButton(
                    icon: const Icon(FontAwesomeIcons.circleXmark,
                        color: Colors.redAccent),
                    onPressed: () => _showDeleteConfirmationDialog(plan),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ],
              ),
              onTap: () => _navigateToWorkouts(plan),
            ),
            if (isDeleting)
              Container(
                width: double.infinity,
                height: 4,
                margin: const EdgeInsets.only(bottom: 8),
                child: LinearProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(colorScheme.primary),
                  backgroundColor: colorScheme.primary.withOpacity(0.2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(PlanResponse plan) {
    showDialog(
      context: context,
      builder: (context) => FadeIn(
        duration: const Duration(milliseconds: 300),
        child: AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF2A2A2A)
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'plans.delete_plan'.tr(),
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'plans.delete_plan_confirmation'
                .tr(namedArgs: {'title': plan.title}),
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
                'plans.cancel'.tr(),
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
                _deletePlan(plan);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
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
                  'plans.delete'.tr(),
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

  void _deletePlan(PlanResponse plan) {
    setState(() {
      _isDeleting[plan.id] = true;
    });

    // Call the cubit to delete the plan
    _workoutsCubit.deletePlan(plan.id).then((_) {
      setState(() {
        _isDeleting.remove(plan.id);
      });
    }).catchError((error) {
      setState(() {
        _isDeleting.remove(plan.id);
      });
      _showErrorSnackBar('plans.failed_to_delete_plan'
          .tr(namedArgs: {'error': error.toString()}));
    });
  }
}
