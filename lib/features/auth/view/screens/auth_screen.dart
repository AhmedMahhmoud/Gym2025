import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:trackletics/core/theme/app_colors.dart';
import 'package:trackletics/features/auth/data/repositories/auth_repository.dart';
import 'package:trackletics/features/auth/view/cubit/auth_cubit.dart';
import 'package:trackletics/features/auth/view/widgets/auth_toggle_btns.dart';
import 'package:trackletics/features/auth/view/widgets/sign_in_view.dart';
import 'package:trackletics/features/auth/view/widgets/sign_up_view.dart';
import 'package:trackletics/features/onboarding/screens/onboarding_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trackletics/features/exercises/view/cubit/exercises_cubit.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AuthType _selectedType = AuthType.login;
  void _toggleSelectedType(AuthType type) {
    setState(() {
      _selectedType = type;
    });
  }

  Widget _buildLanguageSelector(BuildContext context) {
    final currentLocale = context.locale;
    final currentLanguageName =
        currentLocale.languageCode == 'ar' ? 'العربية' : 'English';
    final currentFlag = currentLocale.languageCode == 'ar' ? '🇪🇬' : '🇺🇸';

    return GestureDetector(
      onTap: () => _showLanguageDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentFlag,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 6),
            Text(
              currentLanguageName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white.withOpacity(0.7),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        FontAwesomeIcons.language,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'profile.select_language',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ).tr(),
                  ],
                ),
              ),
              const Divider(color: Colors.white24),
              // Language Options
              _buildLanguageOption(
                context: dialogContext,
                locale: const Locale('en'),
                languageName: 'English',
                languageNativeName: 'English',
                flagEmoji: '🇺🇸',
                isSelected: context.locale == const Locale('en'),
              ),
              _buildLanguageOption(
                context: dialogContext,
                locale: const Locale('ar'),
                languageName: 'Arabic',
                languageNativeName: 'العربية',
                flagEmoji: '🇪🇬',
                isSelected: context.locale == const Locale('ar'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required Locale locale,
    required String languageName,
    required String languageNativeName,
    required String flagEmoji,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () async {
        if (!isSelected) {
          await context.setLocale(locale);
          if (context.mounted) {
            Navigator.pop(context);
            // Refetch exercises with the new language if ExercisesCubit is available
            try {
              final exercisesCubit = context.read<ExercisesCubit>();
              exercisesCubit.loadExercises(context, true);
            } catch (e) {
              // ExercisesCubit might not be available on auth screen, ignore
            }
          }
        } else {
          Navigator.pop(context);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withOpacity(0.5)
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Text(
              flagEmoji,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    languageName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    languageNativeName,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Access locale to trigger rebuild on language change
    context.locale;

    return BlocProvider(
      create: (context) => AuthCubit(authRepository: AuthRepository()),
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            double screenHeight =
                constraints.maxHeight; // Get dynamic screen height

            return Stack(
              children: [
                SingleChildScrollView(
                  child: Form(
                    key: context.read<AuthCubit>().formKey,
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            ClipPath(
                              clipper: AngleClipper(),
                              child: Container(
                                height: screenHeight * 0.60,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: const AssetImage(
                                        'assets/images/gym4.jpg'),
                                    fit: BoxFit.cover,
                                    alignment: Alignment.topCenter,
                                    colorFilter: ColorFilter.mode(
                                      Colors.black.withOpacity(0.3),
                                      BlendMode.darken,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 20,
                              top: screenHeight * 0.1,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 240,
                                  child: FadeIn(
                                    key: ValueKey(_selectedType),
                                    child: Text(
                                      _selectedType == AuthType.login
                                          ? 'auth.welcome_login'.tr()
                                          : 'auth.welcome_signup'.tr(),
                                      style: const TextStyle(
                                        color: AppColors
                                            .textSecondary, // Light text color
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.w700,
                                        shadows: [
                                          Shadow(
                                            blurRadius: 14.0,
                                            color: Colors.black,
                                            offset: Offset(2.0, -2.0),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // ✅ Now Positioned is inside Stack, which is inside LayoutBuilder
                            Positioned(
                              right: 10,
                              top: screenHeight *
                                  0.50, // 🔹 Adjust this dynamically
                              child: Builder(
                                builder: (context) {
                                  return AuthToggleTabs(
                                    key: ValueKey(_selectedType),
                                    selectedType: _selectedType,
                                    onSelect: _toggleSelectedType,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        if (_selectedType == AuthType.login)
                          const SignInView()
                        else
                          const SignupView(),
                      ],
                    ),
                  ),
                ),
                // Language Selector - Top Right
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  right: 16,
                  child: _buildLanguageSelector(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
