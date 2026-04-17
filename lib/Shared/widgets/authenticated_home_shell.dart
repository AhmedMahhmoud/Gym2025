import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackletics/core/network/dio_service.dart';
import 'package:trackletics/features/recommendation/cubit/plan_recommendation_chat_cubit.dart';
import 'package:trackletics/features/workouts/cubits/workouts_cubit.dart';
import 'package:trackletics/features/workouts/data/workouts_repository.dart';
import 'package:trackletics/shared/widgets/main_scaffold.dart';

/// Provides [WorkoutsCubit] and [PlanRecommendationChatCubit] above [MainScaffold].
/// Used by [MaterialApp] `home` when the session is already authenticated and by
/// [RouteNames.home_route] after login — both must match or the workouts tab crashes.
class AuthenticatedHomeShell extends StatelessWidget {
  const AuthenticatedHomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WorkoutsCubit(
        repository: WorkoutsRepository(
          dioService: DioService(),
        ),
      ),
      child: BlocProvider(
        create: (context) => PlanRecommendationChatCubit(
          context.read<WorkoutsCubit>(),
        ),
        child: const MainScaffold(),
      ),
    );
  }
}
