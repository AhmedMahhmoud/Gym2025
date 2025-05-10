import 'package:flutter/material.dart';
import 'package:gym/core/theme/app_colors.dart';

class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.backgroundSurface,
        ),
        child: Center(
          child: Icon(icon,
              size: 24, color: AppColors.textPrimary.withOpacity(0.7)),
        ),
      ),
    );
  }
}
