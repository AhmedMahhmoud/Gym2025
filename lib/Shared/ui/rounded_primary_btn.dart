import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PrimaryRoundedButton extends StatefulWidget {
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
  State<PrimaryRoundedButton> createState() => _PrimaryRoundedButtonState();
}

class _PrimaryRoundedButtonState extends State<PrimaryRoundedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (!widget.isDisabled && !widget.isLoading) {
          setState(() => _isPressed = true);
          _animationController.forward();
        }
      },
      onTapUp: (_) {
        if (!widget.isDisabled && !widget.isLoading) {
          setState(() => _isPressed = false);
          _animationController.reverse();
        }
      },
      onTapCancel: () {
        if (!widget.isDisabled && !widget.isLoading) {
          setState(() => _isPressed = false);
          _animationController.reverse();
        }
      },
      onTap: widget.isDisabled || widget.isLoading ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: widget.isLoading ? widget.height : widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                gradient: widget.isDisabled
                    ? const LinearGradient(
                        colors: [Colors.grey, Colors.grey],
                      )
                    : LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: widget.isDisabled
                        ? Colors.transparent
                        : AppColors.primary.withOpacity(0.3),
                    blurRadius: _isPressed ? 8 : 12,
                    offset: Offset(0, _isPressed ? 2 : 4),
                    spreadRadius: _isPressed ? 0 : 1,
                  ),
                ],
                border: Border.all(
                  color: widget.isDisabled
                      ? Colors.grey.withOpacity(0.3)
                      : AppColors.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: widget.isLoading
                  ? const SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.text,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        if (widget.icon != null) ...[
                          const SizedBox(width: 10),
                          Icon(
                            widget.icon,
                            size: 18,
                            color: Colors.white,
                          ),
                        ],
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}
