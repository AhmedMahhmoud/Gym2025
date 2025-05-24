import 'package:flutter/material.dart';
import 'package:gym/features/exercises/data/models/exercises.dart';

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onTap;

  const ExerciseCard({
    Key? key,
    required this.exercise,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      exercise.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              if (exercise.primaryMuscle.isNotEmpty) ...[  // Changed from muscleGroup to primaryMuscle
                const SizedBox(height: 8),
                Text(
                  'Muscle Group: ${exercise.primaryMuscle}',  // Changed from muscleGroup to primaryMuscle
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
              if (exercise.description.isNotEmpty) ...[  // Changed from description != null
                const SizedBox(height: 8),
                Text(
                  exercise.description,  // Changed from description!
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
              if (exercise.imageUrl != null && exercise.imageUrl!.isNotEmpty) ...[  // Added check for empty string
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    exercise.imageUrl!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}