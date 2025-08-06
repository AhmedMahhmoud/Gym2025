import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:trackletics/core/theme/app_colors.dart';

class FloatingBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<FloatingNavBarItem> items;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final double elevation;
  final double borderRadius;
  final EdgeInsets margin;

  const FloatingBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.elevation = 8.0,
    this.borderRadius = 12.0,
    this.margin = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
  }) : super(key: key);

  @override
  _FloatingBottomNavBarState createState() => _FloatingBottomNavBarState();
}

class _FloatingBottomNavBarState extends State<FloatingBottomNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.2, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? AppColors.primary;
    final selectedColor = widget.selectedItemColor ?? Colors.white;
    final unselectedColor = widget.unselectedItemColor ?? Colors.white70;

    return Padding(
      padding: widget.margin,
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: bgColor, // Solid background color
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.buttonText
                        .withOpacity(_glowAnimation.value * 0.3),
                    blurRadius: 1,
                    spreadRadius: 1.5,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(widget.items.length, (index) {
                  final item = widget.items[index];
                  final isSelected = widget.currentIndex == index;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => widget.onTap(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TweenAnimationBuilder<double>(
                              tween: Tween(
                                  begin: 1.0, end: isSelected ? 1.4 : 1.0),
                              duration: const Duration(milliseconds: 300),
                              builder: (context, scale, child) {
                                return Transform.scale(
                                  scale: scale - 0.1,
                                  child: child,
                                );
                              },
                              child: Icon(
                                item.icon,
                                color: isSelected
                                    ? selectedColor
                                    : unselectedColor,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 4),
                            isSelected
                                ? const SizedBox()
                                : Text(
                                    item.label,
                                    style: TextStyle(
                                      color: isSelected
                                          ? selectedColor
                                          : unselectedColor,
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          );
        },
      ),
    );
  }
}

class FloatingNavBarItem {
  const FloatingNavBarItem({
    required this.icon,
    required this.label,
  });
  
  final IconData icon;
  final String label;
}
