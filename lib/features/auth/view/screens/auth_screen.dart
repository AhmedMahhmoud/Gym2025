import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:trackletics/core/theme/app_colors.dart';
import 'package:trackletics/features/auth/data/repositories/auth_repository.dart';
import 'package:trackletics/features/auth/view/cubit/auth_cubit.dart';
import 'package:trackletics/features/auth/view/widgets/auth_toggle_btns.dart';
import 'package:trackletics/features/auth/view/widgets/sign_in_view.dart';
import 'package:trackletics/features/auth/view/widgets/sign_up_view.dart';
import 'package:trackletics/features/onboarding/screens/onboarding_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(authRepository: AuthRepository()),
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            double screenHeight =
                constraints.maxHeight; // Get dynamic screen height

            return SingleChildScrollView(
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
                                image:
                                    const AssetImage('assets/images/gym4.jpg'),
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
                                      ? 'Welcome !\nAlready have an account ? Login now!'
                                      : 'Enter your information below or login with another account',
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
                          top:
                              screenHeight * 0.50, // 🔹 Adjust this dynamically
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
            );
          },
        ),
      ),
    );
  }
}
