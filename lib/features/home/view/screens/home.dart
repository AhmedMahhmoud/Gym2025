import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gym/features/exercises/view/screens/exercises_display_page.dart';
import 'package:gym/features/home/view/widgets/signout.dart';
import 'package:gym/features/profile/cubit/profile_cubit.dart';
import 'package:gym/features/profile/cubit/profile_state.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Hello',
                      style: TextStyle(fontSize: 27),
                    ),
                    const SizedBox(
                      width: 7,
                    ),
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.70,
                      child: BlocBuilder<ProfileCubit, ProfileState>(
                        builder: (context, state) {
                          return Text(
                            state.displayName ?? '',
                            maxLines: 1,
                            style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis,
                                color: Colors.white),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            const Expanded(child: ExercisesScreen())
          ],
        ),
      ),
    ));
  }
}
