import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PrimaryRoundedButton extends StatelessWidget {
  const PrimaryRoundedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.width = 135,
    this.height = 50,
    this.borderRadius = 30,
    this.isDisabled = false,
    this.isLoading = false,
  });

  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final double width;
  final double height;
  final double borderRadius;
  final bool isDisabled;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled || isLoading
          ? null
          : onPressed, // Prevent taps when loading
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
        width: isLoading ? height : width, // 🔹 Shrinks horizontally
        height: height,
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey : AppColors.primary,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: 8),
                    Icon(icon, size: 16, color: Colors.white),
                  ],
                ],
              ),
      ),
    );
  }
}
