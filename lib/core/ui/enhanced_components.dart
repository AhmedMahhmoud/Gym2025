import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gym/core/animations/app_animations.dart';
import 'package:gym/core/theme/app_colors.dart';

class EnhancedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isDisabled;
  final Color? backgroundColor;
  final Color? textColor;
  final double borderRadius;
  final EdgeInsets padding;
  final double elevation;
  final bool enableHapticFeedback;

  const EnhancedButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    this.elevation = 2,
    this.enableHapticFeedback = true,
  }) : super(key: key);

  @override
  State<EnhancedButton> createState() => _EnhancedButtonState();
}

class _EnhancedButtonState extends State<EnhancedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.defaultCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isDisabled && !widget.isLoading) {
      _controller.forward();
      if (widget.enableHapticFeedback) {
        HapticFeedback.lightImpact();
      }
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = widget.isDisabled || widget.isLoading;
    final backgroundColor = widget.backgroundColor ?? AppColors.primary;
    final textColor = widget.textColor ?? Colors.white;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: isDisabled ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: AppAnimations.normal,
              padding: widget.padding,
              decoration: BoxDecoration(
                color: isDisabled
                    ? backgroundColor.withOpacity(0.5)
                    : backgroundColor,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: backgroundColor.withOpacity(0.3),
                    blurRadius: widget.elevation * 2,
                    offset: Offset(0, widget.elevation),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isLoading)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(textColor),
                      ),
                    )
                  else if (widget.icon != null)
                    Icon(
                      widget.icon,
                      color: textColor,
                      size: 20,
                    ),
                  if ((widget.isLoading || widget.icon != null) &&
                      widget.text.isNotEmpty)
                    const SizedBox(width: 8),
                  if (widget.text.isNotEmpty)
                    Text(
                      widget.text,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class EnhancedTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enableFloatingLabel;
  final Color? fillColor;
  final int maxLines;

  const EnhancedTextField({
    Key? key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.enableFloatingLabel = true,
    this.fillColor,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  State<EnhancedTextField> createState() => _EnhancedTextFieldState();
}

class _EnhancedTextFieldState extends State<EnhancedTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _borderAnimation;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.normal,
      vsync: this,
    );
    _borderAnimation = Tween<double>(begin: 1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.defaultCurve),
    );
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    if (_isFocused) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _borderAnimation,
      builder: (context, child) {
        return TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          onChanged: widget.onChanged,
          maxLines: widget.maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: Colors.white70)
                : null,
            suffixIcon: widget.suffixIcon != null
                ? GestureDetector(
                    onTap: widget.onSuffixTap,
                    child: Icon(widget.suffixIcon, color: Colors.white70),
                  )
                : null,
            filled: true,
            fillColor: widget.fillColor ?? Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primary.withOpacity(0.3),
                width: _borderAnimation.value,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: _borderAnimation.value,
              ),
            ),
            labelStyle: TextStyle(
              color: _isFocused ? AppColors.primary : Colors.white70,
              fontWeight: _isFocused ? FontWeight.w600 : FontWeight.normal,
            ),
            hintStyle: const TextStyle(color: Colors.white38),
          ),
        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0);
      },
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? loadingText;
  final Color? backgroundColor;

  const LoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
    this.loadingText,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: backgroundColor ?? Colors.black.withOpacity(0.5),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: AppColors.primary),
                  if (loadingText != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      loadingText!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ).animate().fadeIn().scale(),
            ),
          ),
      ],
    );
  }
}

class ExpandableCard extends StatefulWidget {
  final Widget header;
  final Widget expandedContent;
  final bool initiallyExpanded;
  final Duration duration;
  final Color? backgroundColor;
  final double borderRadius;

  const ExpandableCard({
    Key? key,
    required this.header,
    required this.expandedContent,
    this.initiallyExpanded = false,
    this.duration = AppAnimations.normal,
    this.backgroundColor,
    this.borderRadius = 12,
  }) : super(key: key);

  @override
  State<ExpandableCard> createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotationAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.defaultCurve,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.defaultCurve),
    );

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    if (_isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCard(
      color: widget.backgroundColor,
      borderRadius: BorderRadius.circular(widget.borderRadius),
      onTap: _toggle,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: widget.header),
              AnimatedBuilder(
                animation: _rotationAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationAnimation.value * 3.14159,
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ],
          ),
          SizeTransition(
            sizeFactor: _expandAnimation,
            axisAlignment: -1,
            child: Column(
              children: [
                const SizedBox(height: 16),
                widget.expandedContent,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomSnackbar {
  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
    IconData? icon,
  }) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            icon ?? (isError ? Icons.error : Icons.check_circle),
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: isError ? Colors.red[600] : AppColors.primary,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

class PullToRefreshWrapper extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;

  const PullToRefreshWrapper({
    Key? key,
    required this.child,
    required this.onRefresh,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? AppColors.primary,
      backgroundColor: Colors.white,
      child: child,
    );
  }
}
