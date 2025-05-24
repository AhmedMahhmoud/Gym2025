import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gym/core/theme/app_colors.dart';

class InputDialogContainer extends StatelessWidget {
  final Widget content;
  final double? width;
  final double? height;

  const InputDialogContainer({
    required this.content,
    this.width,
    this.height,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.divider,
      shadowColor: AppColors.primary,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Animate(
        effects: [
          FadeEffect(
            duration: 200.ms,
            curve: Curves.easeIn,
          ),
        ],
        child: Container(
          width: width,
          height: height,
          padding: const EdgeInsets.all(24),
          child: content,
        ),
      ),
    );
  }
}

Future<T?> showAnimatedDialog<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: builder,
  );
}
