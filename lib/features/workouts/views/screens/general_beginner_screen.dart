import 'package:flutter/material.dart';
import 'package:trackletics/features/workouts/data/general_beginner_data.dart';
import 'package:trackletics/features/exercises/data/models/exercises.dart';

class GeneralBeginnerScreen extends StatelessWidget {
  const GeneralBeginnerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: generalBeginnerPlans.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Beginner Plans'),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              for (final plan in generalBeginnerPlans) Tab(text: plan.title),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            for (final plan in generalBeginnerPlans)
              _PlanExercisesView(plan: plan),
          ],
        ),
      ),
    );
  }
}

class _PlanExercisesView extends StatelessWidget {
  final GeneralPlanSpec plan;

  const _PlanExercisesView({required this.plan});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: plan.exercises.length,
      itemBuilder: (context, index) {
        final spec = plan.exercises[index];
        return _ExerciseTile(exercise: spec.exercise, setSpecs: spec.setScheme);
      },
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  final Exercise exercise;
  final List<GeneralSetSpec> setSpecs;

  const _ExerciseTile({
    required this.exercise,
    required this.setSpecs,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (exercise.primaryMuscle.isNotEmpty)
                        Text(
                          exercise.primaryMuscle,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (exercise.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                exercise.description,
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in setSpecs)
                  _SetChip(
                      sets: s.sets,
                      reps: s.reps,
                      weightKg: s.weightKg,
                      restSeconds: s.restSeconds),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SetChip extends StatelessWidget {
  final int sets;
  final int reps;
  final double? weightKg;
  final int? restSeconds;

  const _SetChip({
    required this.sets,
    required this.reps,
    this.weightKg,
    this.restSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final String weightText =
        weightKg != null ? ' • ${weightKg!.toStringAsFixed(0)}kg' : '';
    final String restText =
        restSeconds != null ? ' • rest ${restSeconds!}s' : '';
    return Chip(
      label: Text('x$sets × $reps$weightText$restText'),
    );
  }
}
