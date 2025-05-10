import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym/core/theme/app_colors.dart';
import 'package:gym/features/workouts/cubits/workouts_cubit.dart';
import 'package:gym/features/workouts/cubits/workouts_state.dart';
import 'package:gym/features/workouts/data/models/plan_model.dart';
import 'package:gym/features/workouts/views/screens/workouts_screen.dart';
import 'package:gym/features/workouts/views/widgets/error_message.dart';
import 'package:gym/features/workouts/views/widgets/loading_indicator.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({Key? key}) : super(key: key);

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  final _titleController = TextEditingController();
  bool _isAddingPlan = false;
  final Map<String, bool> _isDeleting = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _navigateToWorkouts(PlanModel plan) {
    context.read<WorkoutsCubit>().setCurrentPlan(plan);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => BlocProvider.value(
          value: context.read<WorkoutsCubit>(),
          child: const WorkoutsScreen(),
        ),
      ),
    );
  }

  void _createPlan() {
    if (_titleController.text.isNotEmpty) {
      context.read<WorkoutsCubit>().createPlan(_titleController.text);
      _titleController.clear();
      setState(() {
        _isAddingPlan = false;
      });
    }
  }

  void _showDeleteConfirmationDialog(PlanModel plan) {
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

  void _deletePlan(PlanModel plan) {
    setState(() {
      _isDeleting[plan.id] = true;
    });

    // Simulate local deletion after animation
    Future.delayed(const Duration(milliseconds: 500), () {
      final updatedPlans =
          List<PlanModel>.from(context.read<WorkoutsCubit>().state.plans)
            ..removeWhere((p) => p.id == plan.id);
      context.read<WorkoutsCubit>().emit(
            context.read<WorkoutsCubit>().state.copyWith(
                  plans: updatedPlans,
                  clearCurrentPlan:
                      context.read<WorkoutsCubit>().state.currentPlan?.id ==
                          plan.id,
                ),
          );
      setState(() {
        _isDeleting.remove(plan.id);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Plans'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        bottom: true,
        child: BlocConsumer<WorkoutsCubit, WorkoutsState>(
          listener: (context, state) {
            if (state.status == WorkoutsStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'An error occurred'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.status == WorkoutsStatus.loading && state.plans.isEmpty) {
              return const LoadingIndicator();
            }

            if (state.status == WorkoutsStatus.error && state.plans.isEmpty) {
              return ErrorMessage(
                message: state.errorMessage ?? 'Failed to load plans',
                onRetry: () => context.read<WorkoutsCubit>().loadPlans(),
              );
            }

            if (state.plans.isEmpty && !_isAddingPlan) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeIn(
                      duration: const Duration(milliseconds: 800),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          "No plans yet? Let's create your first plan, coach!",
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
                          backgroundColor:
                              MaterialStateProperty.all(Colors.transparent),
                          overlayColor: MaterialStateProperty.all(
                              Colors.white.withOpacity(0.1)),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.textSecondary,
                                AppColors.backgroundSurface.withOpacity(0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.buttonText.withOpacity(0.5),
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
              );
            }

            return Column(
              children: [
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
                                  color: Colors.white),
                              hintText: 'e.g., Push Pull Legs',
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.1),
                              labelStyle: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey),
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
                          const SizedBox(height: 20),
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
                                    Colors.transparent),
                                overlayColor: MaterialStateProperty.all(
                                    Colors.white.withOpacity(0.1)),
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
                                  'Confirm Plan',
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
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
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
                            // When adding, use FadeIn animation
                            return FadeIn(
                              duration: const Duration(milliseconds: 500),
                              child: child,
                            );
                          }
                          // When deleting, use SlideTransition
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
              ],
            );
          },
        ),
      ),
      floatingActionButton:
          context.read<WorkoutsCubit>().state.plans.isNotEmpty && !_isAddingPlan
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        _isAddingPlan = true;
                      });
                    },
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.5),
                            blurRadius: 10,
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
                )
              : null,
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
      backgroundColor: const Color(0xFF1A1A1A),
    );
  }

  Widget _buildPlanCard(PlanModel plan, int index) {
    return Card(
      key: ValueKey(plan.id), // Unique key for each plan card
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
          trailing: const Icon(
            Icons.chevron_right,
            color: Colors.white70,
          ),
          onTap: () => _navigateToWorkouts(plan),
          onLongPress: () => _showDeleteConfirmationDialog(plan),
        ),
      ),
    );
  }
}
