import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym/Shared/ui/custom_snackbar.dart';
import 'package:gym/features/exercises/data/repo/exercises_repo.dart';
import 'package:gym/features/exercises/view/widgets/exersises_display_listview.dart';
import 'package:gym/features/exercises/view/widgets/exersises_search_field.dart';

import 'package:skeletonizer/skeletonizer.dart';

import '../cubit/exercises_cubit.dart';

class ExercisesScreen extends StatelessWidget {
  const ExercisesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ExercisesCubit(exerciseRepository: ExercisesRepository())
        ..loadExercises(),
      child: BlocConsumer<ExercisesCubit, ExercisesState>(
        listener: (context, state) {
          if (state.status == ExerciseStatus.error) {
            CustomSnackbar.show(context, state.errorMessage.toString(),
                isError: true);
          }
        },
        builder: (context, state) {
          context.read<ExercisesCubit>();

          return Scaffold(
              body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: const ExerciseSearchField(),
              ),
              const SizedBox(height: 20),
              ExerciseListView(
                exercises: state.filteredExercises,
                isLoading: state.status == ExerciseStatus.loading,
              )
            ],
          ));
        },
      ),
    );
  }
}
