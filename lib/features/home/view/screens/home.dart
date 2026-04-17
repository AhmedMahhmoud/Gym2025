import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackletics/features/exercises/view/screens/exercises_display_page.dart';
import 'package:trackletics/features/profile/cubit/profile_cubit.dart';
import 'package:trackletics/features/profile/cubit/profile_state.dart';
import 'package:trackletics/features/recommendation/view/draggable_plan_chat_bubble.dart';

class Home extends StatelessWidget {
  const Home({
    super.key,
    required this.onOpenWorkoutsTab,
  });

  /// Switches bottom navigation to the Workouts tab (for AI plan flow / “View my plan”).
  final VoidCallback onOpenWorkoutsTab;

  @override
  Widget build(BuildContext context) {
    context.locale;

    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          SafeArea(
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
                          Text(
                            'home.hello'.tr(),
                            style: TextStyle(
                              fontSize: 27,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 7),
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.70,
                            child: BlocBuilder<ProfileCubit, ProfileState>(
                              builder: (context, state) {
                                final theme = Theme.of(context);
                                return Text(
                                  state.displayName ?? '',
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    overflow: TextOverflow.ellipsis,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  const Expanded(child: ExercisesScreen()),
                ],
              ),
            ),
          ),
          DraggablePlanChatBubble(onOpenWorkoutsTab: onOpenWorkoutsTab),
        ],
      ),
    );
  }
}
