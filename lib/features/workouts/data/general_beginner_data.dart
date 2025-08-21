import 'package:trackletics/features/exercises/data/models/exercises.dart';

class GeneralSetSpec {
  final int sets;
  final int reps;
  final double? weightKg;
  final int? restSeconds;

  const GeneralSetSpec({
    required this.sets,
    required this.reps,
    this.weightKg,
    this.restSeconds,
  });
}

class GeneralExerciseSpec {
  final Exercise exercise;
  final List<GeneralSetSpec> setScheme;

  const GeneralExerciseSpec({
    required this.exercise,
    required this.setScheme,
  });
}

class GeneralPlanSpec {
  final String id;
  final String title;
  final String description;
  final List<GeneralExerciseSpec> exercises;

  const GeneralPlanSpec({
    required this.id,
    required this.title,
    required this.description,
    required this.exercises,
  });
}

// BEGINNER GENERAL PLANS (adjust freely)
// You can edit exercises, reps, sets, and optional weights/rests below.
// Use empty strings for fields you don't need (e.g., imageUrl, videoUrl).

final List<GeneralPlanSpec> generalBeginnerPlans = [
  GeneralPlanSpec(
    id: 'general_1',
    title: 'General 1',
    description: 'Full body introduction (Day 1)',
    exercises: [
      GeneralExerciseSpec(
        exercise: Exercise(
          id: 'g1_squat',
          name: 'Bodyweight Squat',
          description: 'Keep chest up, sit back, and go as low as comfortable.',
          videoUrl: '',
          primaryMuscle: 'Quads',
          primaryMuscleId: 'quads',
          category: 'Lower Body',
          categoryId: 'lower_body',
          imageUrl: '',
        ),
        setScheme: [
          GeneralSetSpec(sets: 3, reps: 12, weightKg: null, restSeconds: 60),
        ],
      ),
      GeneralExerciseSpec(
        exercise: Exercise(
          id: 'g1_pushup',
          name: 'Incline Push-up',
          description: 'Hands on bench/wall, keep core tight.',
          videoUrl: '',
          primaryMuscle: 'Chest',
          primaryMuscleId: 'chest',
          category: 'Upper Body',
          categoryId: 'upper_body',
          imageUrl: '',
        ),
        setScheme: [
          GeneralSetSpec(sets: 3, reps: 10, weightKg: null, restSeconds: 60),
        ],
      ),
      GeneralExerciseSpec(
        exercise: Exercise(
          id: 'g1_row',
          name: 'Seated Cable Row (Light)',
          description: 'Neutral spine, squeeze shoulder blades together.',
          videoUrl: '',
          primaryMuscle: 'Back',
          primaryMuscleId: 'back',
          category: 'Upper Body',
          categoryId: 'upper_body',
          imageUrl: '',
        ),
        setScheme: [
          GeneralSetSpec(sets: 3, reps: 12, weightKg: 15, restSeconds: 60),
        ],
      ),
    ],
  ),
  GeneralPlanSpec(
    id: 'general_2',
    title: 'General 2',
    description: 'Full body introduction (Day 2)',
    exercises: [
      GeneralExerciseSpec(
        exercise: Exercise(
          id: 'g2_dl',
          name: 'Dumbbell Romanian Deadlift',
          description: 'Hip hinge, slight knee bend, feel the hamstrings.',
          videoUrl: '',
          primaryMuscle: 'Hamstrings',
          primaryMuscleId: 'hamstrings',
          category: 'Lower Body',
          categoryId: 'lower_body',
          imageUrl: '',
        ),
        setScheme: [
          GeneralSetSpec(sets: 3, reps: 10, weightKg: 10, restSeconds: 75),
        ],
      ),
      GeneralExerciseSpec(
        exercise: Exercise(
          id: 'g2_shoulder',
          name: 'Dumbbell Shoulder Press (Seated)',
          description: 'Control the weight; avoid shrugging.',
          videoUrl: '',
          primaryMuscle: 'Shoulders',
          primaryMuscleId: 'delts',
          category: 'Upper Body',
          categoryId: 'upper_body',
          imageUrl: '',
        ),
        setScheme: [
          GeneralSetSpec(sets: 3, reps: 10, weightKg: 6, restSeconds: 75),
        ],
      ),
      GeneralExerciseSpec(
        exercise: Exercise(
          id: 'g2_lat',
          name: 'Lat Pulldown (Light)',
          description: 'Pull elbows down to sides; avoid using momentum.',
          videoUrl: '',
          primaryMuscle: 'Lats',
          primaryMuscleId: 'lats',
          category: 'Upper Body',
          categoryId: 'upper_body',
          imageUrl: '',
        ),
        setScheme: [
          GeneralSetSpec(sets: 3, reps: 12, weightKg: 20, restSeconds: 75),
        ],
      ),
    ],
  ),
  GeneralPlanSpec(
    id: 'general_3',
    title: 'General 3',
    description: 'Full body introduction (Day 3)',
    exercises: [
      GeneralExerciseSpec(
        exercise: Exercise(
          id: 'g3_lunge',
          name: 'Bodyweight Lunge (Alternating)',
          description: 'Short, controlled steps; keep torso upright.',
          videoUrl: '',
          primaryMuscle: 'Quads/Glutes',
          primaryMuscleId: 'quads_glutes',
          category: 'Lower Body',
          categoryId: 'lower_body',
          imageUrl: '',
        ),
        setScheme: [
          GeneralSetSpec(sets: 3, reps: 10, weightKg: null, restSeconds: 60),
        ],
      ),
      GeneralExerciseSpec(
        exercise: Exercise(
          id: 'g3_chest',
          name: 'Machine Chest Press (Light)',
          description: 'Elbows at ~45°, control on the way down.',
          videoUrl: '',
          primaryMuscle: 'Chest',
          primaryMuscleId: 'chest',
          category: 'Upper Body',
          categoryId: 'upper_body',
          imageUrl: '',
        ),
        setScheme: [
          GeneralSetSpec(sets: 3, reps: 12, weightKg: 15, restSeconds: 60),
        ],
      ),
      GeneralExerciseSpec(
        exercise: Exercise(
          id: 'g3_row',
          name: 'Dumbbell Row (Supported)',
          description: 'Flat back, pull dumbbell towards hip.',
          videoUrl: '',
          primaryMuscle: 'Back',
          primaryMuscleId: 'back',
          category: 'Upper Body',
          categoryId: 'upper_body',
          imageUrl: '',
        ),
        setScheme: [
          GeneralSetSpec(sets: 3, reps: 12, weightKg: 8, restSeconds: 60),
        ],
      ),
    ],
  ),
];
