import 'package:flutter/material.dart';
import 'package:trackletics/core/theme/app_theme.dart';
import 'package:trackletics/routes/route_names.dart';
import '../models/onboarding_item.dart';
import '../../../core/theme/app_colors.dart';
import 'package:trackletics/core/services/storage_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _pages = [
    OnboardingItem(
      title: 'Meet your coach,\nstart your journey',
      subtitle: '',
      imagePath: 'assets/images/gym1.jpg',
    ),
    OnboardingItem(
      title: 'Create a workout plan\nto stay fit',
      subtitle: '',
      imagePath: 'assets/images/gym2.jpeg',
    ),
    OnboardingItem(
      title: 'Action is the\nkey to all success',
      subtitle: '',
      imagePath: 'assets/images/gym3.jpg',
      hasButton: true,
      buttonText: 'Start Now',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Persisted Background Image with Clipper
          Positioned(
            child: ClipPath(
              clipper: AngleClipper(),
              child: AnimatedSwitcher(
                switchInCurve: Curves.easeInCubic,
                duration: const Duration(milliseconds: 400),
                switchOutCurve: Curves.easeOut,
                child: Container(
                  height: 600,
                  key: ValueKey<int>(_currentPage),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(_pages[_currentPage].imagePath),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.2),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Full-screen PageView for content
          PageView.builder(
            physics: const BouncingScrollPhysics(),
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return OnboardingPage(item: _pages[index]);
            },
          ),

          // Page Indicator
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: (_currentPage == index) ? 35 : 18,
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: (_currentPage == index)
                        ? AppColors.primary
                        : AppColors.textSecondary.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key, required this.item});
  final OnboardingItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.only(bottom: 110, left: 24, right: 24, top: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              color: AppColors.textPrimary,
              shadows: [
                Shadow(
                  blurRadius: 14.0,
                  color: AppColors.primary.withOpacity(0.5),
                  offset: const Offset(2.0, -1.0),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (item.hasButton)
            SizedBox(
              width: 160,
              child: ElevatedButton(
                onPressed: () async {
                  final storage = StorageService();
                  await storage.setHasSeenOnboarding(true);

                  if (context.mounted) {
                    Navigator.pushReplacementNamed(
                        context, RouteNames.auth_screen_route);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(item.buttonText ?? 'Start Now'),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AngleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.90);
    path.lineTo(size.width, size.height * 0.70);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
