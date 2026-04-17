import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackletics/core/theme/app_colors.dart';
import 'package:trackletics/features/coaches/data/models/coach_model.dart';
import 'package:trackletics/features/coaches/view/cubit/coaches_list_cubit.dart';
import 'package:trackletics/routes/route_names.dart';

class CoachesScreen extends StatelessWidget {
  const CoachesScreen({Key? key}) : super(key: key);

  Future<void> _onApplyTap(BuildContext context) async {
    final result = await Navigator.pushNamed(
      context,
      RouteNames.apply_to_become_coach_route,
    );
    if (result == true && context.mounted) {
      context.read<CoachesListCubit>().loadCoaches();
    }
  }

  @override
  Widget build(BuildContext context) {
    context.locale;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textPrimary =
        isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'coaches.title'.tr(),
          style: TextStyle(
            color: isDark ? AppColors.textPrimary : Colors.white,
          ),
        ),
        backgroundColor: isDark ? AppColors.surface : theme.colorScheme.primary,
        elevation: 0,
      ),
      body: Container(
        color: isDark ? AppColors.background : AppColors.backgroundLight,
        child: BlocBuilder<CoachesListCubit, CoachesListState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ApplyCoachCard(
                    isDark: isDark,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    applyTitle: 'coaches.apply_to_become_coach'.tr(),
                    applySubtitle: 'coaches.apply_subtitle'.tr(),
                    onTap: () => _onApplyTap(context),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'coaches.available_coaches'.tr(),
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _CoachesListContent(
                    state: state,
                    isDark: isDark,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CoachesListContent extends StatelessWidget {
  const _CoachesListContent({
    required this.state,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
  });

  final CoachesListState state;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    if (state.status == CoachesListStatus.loading && state.coaches.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 32,
                width: 32,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(height: 16),
              Text(
                'loading'.tr(),
                style: TextStyle(color: textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    if (state.status == CoachesListStatus.error && state.coaches.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: 12),
              Text(
                state.errorMessage ?? 'error'.tr(),
                style: TextStyle(color: textSecondary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => context.read<CoachesListCubit>().loadCoaches(),
                icon: const Icon(Icons.refresh_rounded),
                label: Text('retry'.tr()),
              ),
            ],
          ),
        ),
      );
    }

    if (state.coaches.isEmpty) {
      return _PlaceholderCoachesList(
        isDark: isDark,
        textPrimary: textPrimary,
        textSecondary: textSecondary,
        noCoachesTitle: 'coaches.no_coaches_yet'.tr(),
        noCoachesMessage: 'coaches.no_coaches_message'.tr(),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.coaches.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _CoachCard(
          coach: state.coaches[index],
          isDark: isDark,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        );
      },
    );
  }
}

class _CoachCard extends StatelessWidget {
  const _CoachCard({
    required this.coach,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
  });

  final CoachModel coach;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.divider
              : AppColors.dividerLight.withOpacity(0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
            backgroundImage: coach.profilePictureUrl != null &&
                    coach.profilePictureUrl!.isNotEmpty
                ? NetworkImage(coach.profilePictureUrl!)
                : null,
            child: coach.profilePictureUrl == null ||
                    coach.profilePictureUrl!.isEmpty
                ? Icon(
                    Icons.person_rounded,
                    size: 28,
                    color: theme.colorScheme.primary,
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coach.name ?? 'Coach',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (coach.bio != null && coach.bio!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    coach.bio!,
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ApplyCoachCard extends StatelessWidget {
  const _ApplyCoachCard({
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.applyTitle,
    required this.applySubtitle,
    required this.onTap,
  });

  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final String applyTitle;
  final String applySubtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      theme.colorScheme.primary.withOpacity(0.25),
                      theme.colorScheme.primary.withOpacity(0.12),
                    ]
                  : [
                      theme.colorScheme.primary.withOpacity(0.18),
                      theme.colorScheme.primary.withOpacity(0.08),
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.how_to_reg_rounded,
                  size: 32,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      applyTitle,
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      applySubtitle,
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceholderCoachesList extends StatelessWidget {
  const _PlaceholderCoachesList({
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.noCoachesTitle,
    required this.noCoachesMessage,
  });

  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final String noCoachesTitle;
  final String noCoachesMessage;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(
              Icons.school_rounded,
              size: 64,
              color: isDark
                  ? AppColors.textSecondary.withOpacity(0.5)
                  : AppColors.textSecondaryLight.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              noCoachesTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              noCoachesMessage,
              style: TextStyle(
                fontSize: 14,
                color: textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
