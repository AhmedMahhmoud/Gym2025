import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:gym/core/theme/app_colors.dart';

class CustomSnackbar {
  static void show(BuildContext context, String message,
      {bool isError = false}) {
    final snackbar = AnimatedSnackBar(
      duration: const Duration(seconds: 5),
      animationDuration: const Duration(seconds: 1),
      mobilePositionSettings: const MobilePositionSettings(
        topOnAppearance: 100,
        // bottomOnAppearance: 100,
        // left: 20,
        // right: 70,
      ),
      animationCurve: Curves.fastOutSlowIn,
      snackBarStrategy: RemoveSnackBarStrategy(),
      builder: ((context) {
        return Container(
          width: 300,
          padding: const EdgeInsets.all(8),
          height: 60,
          decoration: BoxDecoration(
            color: isError ? Colors.redAccent : Colors.green,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: AppColors.buttonText),
            ),
          ),
        );
      }),
    );
    snackbar.show(context);
  }
}
