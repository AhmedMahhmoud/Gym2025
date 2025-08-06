import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackletics/core/network/dio_service.dart';
import 'package:trackletics/features/workouts/cubits/workouts_cubit.dart';
import 'package:trackletics/features/workouts/data/workouts_repository.dart';
import 'package:trackletics/features/workouts/views/screens/plans_screen.dart';

class WorkoutsFeature extends StatelessWidget {
  const WorkoutsFeature({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WorkoutsCubit(
        repository: WorkoutsRepository(
          dioService: DioService(),
        ),
      ), // Load plans immediately
      child: const PlansScreen(),
    );
  }
}
