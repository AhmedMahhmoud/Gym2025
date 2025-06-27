import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AppAnimations {
  // Animation durations
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);

  // Curves
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.fastLinearToSlowEaseIn;

  // Page transitions
  static Route<T> slidePageRoute<T extends Object?>(
    Widget page, {
    Offset begin = const Offset(1.0, 0.0),
    Duration duration = normal,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: begin,
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: defaultCurve,
          )),
          child: child,
        );
      },
    );
  }

  static Route<T> fadePageRoute<T extends Object?>(
    Widget page, {
    Duration duration = normal,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  static Route<T> scalePageRoute<T extends Object?>(
    Widget page, {
    Duration duration = normal,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: bounceCurve,
          )),
          child: child,
        );
      },
    );
  }
}

// Enhanced animated widgets
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final VoidCallback? onTap;
  final double elevation;
  final Color? color;
  final BorderRadius? borderRadius;
  final EdgeInsets padding;
  final bool enableHoverEffect;

  const AnimatedCard({
    Key? key,
    required this.child,
    this.duration = AppAnimations.normal,
    this.onTap,
    this.elevation = 4,
    this.color,
    this.borderRadius,
    this.padding = const EdgeInsets.all(16),
    this.enableHoverEffect = true,
  }) : super(key: key);

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.defaultCurve,
    ));

    _elevationAnimation = Tween<double>(
      begin: widget.elevation,
      end: widget.elevation + 2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.defaultCurve,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enableHoverEffect) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.enableHoverEffect) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.enableHoverEffect) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Card(
              elevation: _elevationAnimation.value,
              color: widget.color,
              shape: RoundedRectangleBorder(
                borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
              ),
              child: Padding(
                padding: widget.padding,
                child: widget.child,
              ),
            ),
          );
        },
      ),
    );
  }
}

class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;

  const PulseAnimation({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
    this.minScale = 0.95,
    this.maxScale = 1.05,
  }) : super(key: key);

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}

class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration period;

  const ShimmerLoading({
    Key? key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.period = const Duration(milliseconds: 1500),
  }) : super(key: key);

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.period,
      vsync: this,
    );
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = widget.baseColor ?? Colors.grey[300]!;
    final highlightColor = widget.highlightColor ?? Colors.grey[100]!;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: const [
                0.0,
                0.5,
                1.0,
              ],
              transform: GradientRotation(_animation.value),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

// Staggered animation for lists
class StaggeredListAnimation extends StatelessWidget {
  final List<Widget> children;
  final Duration duration;
  final double offset;

  const StaggeredListAnimation({
    Key? key,
    required this.children,
    this.duration = AppAnimations.normal,
    this.offset = 0.1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        return child
            .animate(delay: Duration(milliseconds: (index * 100).round()))
            .slideX(
              begin: 0.2,
              end: 0,
              duration: duration,
              curve: AppAnimations.defaultCurve,
            )
            .fadeIn(
              duration: duration,
              curve: AppAnimations.defaultCurve,
            );
      }).toList(),
    );
  }
}

// Hero animation wrapper
class CustomHero extends StatelessWidget {
  final String tag;
  final Widget child;
  final Duration duration;

  const CustomHero({
    Key? key,
    required this.tag,
    required this.child,
    this.duration = AppAnimations.normal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      flightShuttleBuilder:
          (context, animation, direction, fromContext, toContext) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (animation.value * 0.1),
              child: child,
            );
          },
          child: child,
        );
      },
      child: child,
    );
  }
}
