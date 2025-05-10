import 'package:flutter/material.dart';
import 'package:gym/features/workouts/data/models/set_model.dart';

class SetCard extends StatelessWidget {
  final SetModel set;

  const SetCard({
    Key? key,
    required this.set,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reps: ${set.reps}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Weight: ${set.weight} kg',
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (set.restTime != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Rest: ${set.restTime} seconds',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${set.reps}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}