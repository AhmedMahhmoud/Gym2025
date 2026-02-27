import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:trackletics/core/theme/app_colors.dart';

class FloatingBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<FloatingNavBarItem> items;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final EdgeInsets margin;

  const FloatingBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  }) : super(key: key);

  @override
  State<FloatingBottomNavBar> createState() => _FloatingBottomNavBarState();
}

class _FloatingBottomNavBarState extends State<FloatingBottomNavBar>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      ),
    );

    _scaleAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOut),
      );
    }).toList();

    _fadeAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOut),
      );
    }).toList();

    // Animate initial selected item
    if (widget.currentIndex < _controllers.length) {
      _controllers[widget.currentIndex].forward();
    }
  }

  @override
  void didUpdateWidget(FloatingBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      // Animate out old selection
      if (oldWidget.currentIndex < _controllers.length) {
        _controllers[oldWidget.currentIndex].reverse();
      }
      // Animate in new selection
      if (widget.currentIndex < _controllers.length) {
        _controllers[widget.currentIndex].forward();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Determine colors based on theme
    final bgColor = widget.backgroundColor ??
        (isDark
            ? Colors.black.withOpacity(0.8)
            : Colors.white.withOpacity(0.9));
    final selectedColor = widget.selectedItemColor ?? AppColors.primary;
    final unselectedColor = widget.unselectedItemColor ??
        (isDark
            ? Colors.white.withOpacity(0.6)
            : Colors.black.withOpacity(0.6));

    return Container(
      margin: widget.margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.3)
                      : Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = constraints.maxWidth / widget.items.length;
                  return Stack(
                    children: [
                      // Animated background indicator (pill shape)
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        left: (widget.currentIndex * itemWidth) + 8,
                        top: 8,
                        bottom: 8,
                        width: itemWidth - 16,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                selectedColor.withOpacity(0.2),
                                selectedColor.withOpacity(0.15),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selectedColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      // Navigation items
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        textDirection: TextDirection.ltr,
                        children: List.generate(widget.items.length, (index) {
                          final item = widget.items[index];
                          final isSelected = widget.currentIndex == index;

                          return Expanded(
                            child: GestureDetector(
                              onTap: () => widget.onTap(index),
                              behavior: HitTestBehavior.opaque,
                              child: AnimatedBuilder(
                                animation: _controllers[index],
                                builder: (context, child) {
                                  return Opacity(
                                    opacity: _fadeAnimations[index].value,
                                    child: Transform.scale(
                                      scale: isSelected
                                          ? _scaleAnimations[index].value
                                          : 1.0,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Icon with animated container
                                          Container(
                                            child: Icon(
                                              item.icon,
                                              color: isSelected
                                                  ? selectedColor
                                                  : unselectedColor,
                                              size: isSelected ? 26 : 24,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          // Label
                                          AnimatedDefaultTextStyle(
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              style: TextStyle(
                                                color: isSelected
                                                    ? selectedColor
                                                    : unselectedColor,
                                                fontSize: isSelected ? 11 : 10,
                                                fontWeight: isSelected
                                                    ? FontWeight.w600
                                                    : FontWeight.w500,
                                                letterSpacing: 0.5,
                                              ),
                                              child: const SizedBox()),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
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
