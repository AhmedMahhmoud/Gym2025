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
import 'package:trackletics/features/profile/cubit/profile_cubit.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({Key? key}) : super(key: key);

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen>
    with TickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _staticTitleController = TextEditingController();
  final _staticNotesController = TextEditingController();
  bool _isAddingPlan = false;
  bool _isAddingStaticPlan = false;
  final Map<String, bool> _isDeleting = {};
  late WorkoutsCubit _workoutsCubit;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _workoutsCubit = context.read<WorkoutsCubit>();
    _tabController = TabController(length: 2, vsync: this);
    log('WORKOUT SCREEN LOAD');
    _workoutsCubit.loadPlans();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _staticTitleController.dispose();
    _staticNotesController.dispose();
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
      _workoutsCubit
          .createPlan(
        _titleController.text,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
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

  void _createStaticPlan() {
    if (_staticTitleController.text.isNotEmpty) {
      setState(() {
        _isAddingStaticPlan = true;
      });
      _workoutsCubit
          .createStaticPlan(
        _staticTitleController.text,
        notes: _staticNotesController.text.isNotEmpty
            ? _staticNotesController.text
            : null,
      )
          .then((_) {
        _staticTitleController.clear();
        _staticNotesController.clear();
        setState(() {
          _isAddingStaticPlan = false;
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

    showDialog(
      context: context,
      builder: (context) => FadeIn(
        duration: const Duration(milliseconds: 300),
        child: AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Edit Plan',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  labelStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: 'Notes (Optional)',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  labelStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
              ),
            ],
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
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Update',
                  style: TextStyle(
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Plans'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: 'My Plans'),
              Tab(text: 'Static Plans'),
            ],
            onTap: (index) {
              if (index == 0) {
                _workoutsCubit.switchToUserPlans();
              } else {
                _workoutsCubit.switchToStaticPlans();
              }
            },
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildUserPlansTab(),
            _buildStaticPlansTab(),
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
          (current.status == WorkoutsStatus.creatingStaticPlan &&
              previous.status != WorkoutsStatus.creatingStaticPlan) ||
          (current.status == WorkoutsStatus.deletingPlan &&
              previous.status != WorkoutsStatus.deletingPlan) ||
          (current.status == WorkoutsStatus.updatingPlan &&
              previous.status != WorkoutsStatus.updatingPlan) ||
          (current.status == WorkoutsStatus.error &&
              (previous.status == WorkoutsStatus.creatingPlan ||
                  previous.status == WorkoutsStatus.creatingStaticPlan ||
                  previous.status == WorkoutsStatus.deletingPlan ||
                  previous.status == WorkoutsStatus.updatingPlan)),
      listener: (context, state) {
        if (state.status == WorkoutsStatus.error) {
          _showErrorSnackBar(state.errorMessage ?? 'An error occurred');
        }
      },
      builder: (context, state) {
        log(state.status.toString(), name: 'test');
        if (state.status == WorkoutsStatus.error && state.plans.isEmpty) {
          return ErrorMessage(
            message: state.errorMessage ?? 'Failed to load plans',
            onRetry: () => _workoutsCubit.loadPlans(),
          );
        }

        return Column(
          children: [
            if (state.status == WorkoutsStatus.loadingPlans)
              SizedBox(
                height: MediaQuery.sizeOf(context).height / 2,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Loading plans...',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            if (_isAddingPlan)
              FadeIn(
                duration: const Duration(milliseconds: 500),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Plan Title',
                          floatingLabelStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                          hintText: 'e.g., Push Pull Legs',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                          hintStyle: const TextStyle(color: Colors.white38),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        onTapOutside: (event) =>
                            FocusScope.of(context).unfocus(),
                        autofocus: true,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          labelText: 'Notes (Optional)',
                          floatingLabelStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                          hintText: 'e.g., Push Pull Leg split',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                          hintStyle: const TextStyle(color: Colors.white38),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
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
                              foregroundColor: Colors.white70,
                            ),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 16),
                          if (state.status == WorkoutsStatus.loading)
                            Container(
                              width: double.infinity,
                              height: 4,
                              margin: const EdgeInsets.only(bottom: 20),
                              child: const LinearProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                                backgroundColor: AppColors.primary,
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
                                  child: const Text(
                                    'Create Plan',
                                    style: TextStyle(
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
              ),
            if (state.status == WorkoutsStatus.creatingPlan)
              Container(
                width: double.infinity,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: const LinearProgressIndicator(
                  backgroundColor: AppColors.primary,
                ),
              ),
            if (state.status == WorkoutsStatus.creatingStaticPlan)
              Container(
                width: double.infinity,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: const LinearProgressIndicator(
                  backgroundColor: AppColors.primary,
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
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 30),
                              child: Text(
                                "Add New Plan",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
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
                                      AppColors.backgroundSurface
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
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
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
                  text: 'Add Plan',
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

  Widget _buildStaticPlansTab() {
    return BlocBuilder<WorkoutsCubit, WorkoutsState>(
      builder: (context, state) {
        if (state.status == WorkoutsStatus.loadingPlans) {
          return SizedBox(
            height: MediaQuery.sizeOf(context).height / 2,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading plans...',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          );
        }

        if (state.status == WorkoutsStatus.error && state.staticPlans.isEmpty) {
          return ErrorMessage(
            message: state.errorMessage ?? 'Failed to load static plans',
            onRetry: () => _workoutsCubit.loadPlans(),
          );
        }

        return Column(
          children: [
            if (state.status == WorkoutsStatus.creatingStaticPlan)
              Container(
                width: double.infinity,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: const LinearProgressIndicator(
                  backgroundColor: AppColors.primary,
                ),
              ),
            if (_isAddingStaticPlan &&
                context.read<ProfileCubit>().state.isAdmin)
              FadeIn(
                duration: const Duration(milliseconds: 500),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _staticTitleController,
                        decoration: InputDecoration(
                          labelText: 'Static Plan Title',
                          floatingLabelStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                          hintText: 'e.g., General Plan',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                          hintStyle: const TextStyle(color: Colors.white38),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        onTapOutside: (event) =>
                            FocusScope.of(context).unfocus(),
                        autofocus: true,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _staticNotesController,
                        decoration: InputDecoration(
                          labelText: 'Notes (Optional)',
                          floatingLabelStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                          hintText: 'e.g., General Plan Example 1',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                          hintStyle: const TextStyle(color: Colors.white38),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
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
                                _isAddingStaticPlan = false;
                                _staticTitleController.clear();
                                _staticNotesController.clear();
                              });
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white70,
                            ),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 16),
                          if (state.status == WorkoutsStatus.creatingStaticPlan)
                            Container(
                              width: double.infinity,
                              height: 4,
                              margin: const EdgeInsets.only(bottom: 20),
                              child: const LinearProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                                backgroundColor: AppColors.primary,
                              ),
                            )
                          else
                            ElevatedButton(
                              onPressed: _createStaticPlan,
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
                                child: const Text(
                                  'Create Static Plan',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
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
              child: state.staticPlans.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.fitness_center,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            context.read<ProfileCubit>().state.isAdmin
                                ? 'No static plans available'
                                : 'No static plans available',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.read<ProfileCubit>().state.isAdmin
                                ? 'Create your first static plan'
                                : 'Check back later for new plans',
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          if (context.read<ProfileCubit>().state.isAdmin) ...[
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _isAddingStaticPlan = true;
                                });
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Create Static Plan'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      itemCount: state.staticPlans.length,
                      itemBuilder: (context, index) {
                        final plan = state.staticPlans[index];
                        return _buildStaticPlanCard(plan, index);
                      },
                    ),
            ),
            if (context.read<ProfileCubit>().state.isAdmin)
              BlocBuilder<WorkoutsCubit, WorkoutsState>(
                builder: (context, state) {
                  return StickyAddButton(
                    onPressed: () {
                      setState(() {
                        _isAddingStaticPlan = true;
                      });
                    },
                    text: 'Add Static Plan',
                    icon: Icons.add,
                    isVisible:
                        !_isAddingStaticPlan && state.staticPlans.isNotEmpty,
                  );
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildPlanCard(PlanResponse plan, int index) {
    final isDeleting = _isDeleting[plan.id] ?? false;
    return Card(
      key: ValueKey(plan.id),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            ListTile(
              title: Text(
                plan.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              subtitle: plan.notes != null && plan.notes!.isNotEmpty
                  ? Text(
                      plan.notes!,
                      style: const TextStyle(
                        color: Colors.white70,
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
                    icon: const Icon(FontAwesomeIcons.edit,
                        color: Colors.white70),
                    onPressed: () => _showEditPlanDialog(plan),
                  ),
                  IconButton(
                    icon: const Icon(FontAwesomeIcons.circleXmark,
                        color: Colors.redAccent),
                    onPressed: () => _showDeleteConfirmationDialog(plan),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.white70,
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
                child: const LinearProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  backgroundColor: AppColors.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaticPlanCard(PlanResponse plan, int index) {
    return Card(
      key: ValueKey(plan.id),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          title: Text(
            plan.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          subtitle: plan.notes != null && plan.notes!.isNotEmpty
              ? Text(
                  plan.notes!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          trailing: const Icon(
            Icons.chevron_right,
            color: Colors.white70,
          ),
          onTap: () => _navigateToWorkouts(plan),
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
          backgroundColor: const Color(0xFF2A2A2A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Delete Plan',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${plan.title}"?',
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
                child: const Text(
                  'Delete',
                  style: TextStyle(
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
      _showErrorSnackBar('Failed to delete plan: $error');
    });
  }
}
