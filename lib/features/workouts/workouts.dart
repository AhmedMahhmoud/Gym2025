import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym/core/network/dio_service.dart';
import 'package:gym/features/workouts/cubits/workouts_cubit.dart';
import 'package:gym/features/workouts/data/workouts_repository.dart';
import 'package:gym/features/workouts/views/screens/plans_screen.dart';

class WorkoutsFeature extends StatelessWidget {
  const WorkoutsFeature({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WorkoutsCubit(
        repository: WorkoutsRepository(
          dioService: DioService(),
          useStaticData: true, // Use static data
        ),
      ), // Load plans immediately
      child: const PlansScreen(),
    );
  }
}
