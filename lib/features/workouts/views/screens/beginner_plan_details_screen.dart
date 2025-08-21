import 'package:flutter/material.dart';
import 'package:trackletics/features/workouts/data/general_beginner_data.dart';

class BeginnerPlanDetailsScreen extends StatelessWidget {
  final GeneralPlanSpec plan;

  const BeginnerPlanDetailsScreen({Key? key, required this.plan})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(plan.title),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: plan.exercises.length,
        itemBuilder: (context, idx) {
          final spec = plan.exercises[idx];
          return _buildExerciseCard(spec);
        },
      ),
    );
  }

  Widget _buildExerciseCard(GeneralExerciseSpec spec) {
    return Card(
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
                spec.exercise.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              subtitle: Text(
                spec.exercise.primaryMuscle.isNotEmpty
                    ? '${spec.exercise.primaryMuscle} • ${spec.exercise.description}'
                    : spec.exercise.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in spec.setScheme) _buildSetChip(s),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetChip(GeneralSetSpec s) {
    final String weightText =
        s.weightKg != null ? ' • ${s.weightKg!.toStringAsFixed(0)}kg' : '';
    final String restText =
        s.restSeconds != null ? ' • rest ${s.restSeconds!}s' : '';
    return Chip(
      label: Text('x${s.sets} × ${s.reps}$weightText$restText'),
    );
  }
}
