import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.onSaved,
    this.prefixIcon,
    this.suffixIcon,
    this.textInputAction,
    this.autovalidateMode,
    this.onChanged,
    this.validator,
  });
  final String hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool isPassword;
  final TextInputAction? textInputAction;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final String? Function(String?)? onSaved;
  final AutovalidateMode? autovalidateMode;
  final String? Function(String?)? onChanged;
  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return TextFormField(
      controller: widget.controller,
      onChanged: (value) =>
          widget.onChanged == null ? null : widget.onChanged!(value),
      keyboardType: widget.keyboardType,
      obscureText: _obscureText,
      style: TextStyle(
        color: isDark ? AppColors.textPrimary : Colors.black,
      ),
      validator: (value) {
        // Default Validation: Check if field is empty
        if (value == null || value.trim().isEmpty) {
          return 'validation.required'.tr();
        }
        // Apply custom validation if provided
        if (widget.validator != null) {
          return widget.validator!(value);
        }
        return null;
      },
      autovalidateMode:
          widget.autovalidateMode ?? AutovalidateMode.onUserInteraction,
      onSaved: (s) => widget.onSaved == null ? null : widget.onSaved!(s),
      onTapOutside: (event) => FocusScope.of(context).unfocus(),
      textInputAction: widget.textInputAction ?? TextInputAction.next,
      decoration: InputDecoration(
        suffixIconColor: isDark ? AppColors.textSecondary : Colors.black54,
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: isDark ? AppColors.textSecondary : Colors.black54,
        ),
        filled: false,
        errorStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.redAccent,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: isDark ? AppColors.textSecondary : Colors.black54,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : widget.suffixIcon,
      ),
    );
  }
}
