import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/app_colors.dart';

class AppDropdown<T> extends StatefulWidget {
  const AppDropdown({
    super.key,
    required this.hintText,
    required this.items,
    required this.onChanged,
    this.value,
    this.validator,
    this.onSaved,
    this.prefixIcon,
    this.isRequired = true,
  });

  final String hintText;
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final void Function(T?)? onSaved;
  final Widget? prefixIcon;
  final bool isRequired;

  @override
  State<AppDropdown<T>> createState() => _AppDropdownState<T>();
}

class _AppDropdownState<T> extends State<AppDropdown<T>> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return DropdownButtonFormField<T>(
      value: widget.value,
      items: widget.items.map((item) {
        return DropdownMenuItem<T>(
          value: item.value,
          child: DefaultTextStyle(
            style: TextStyle(
              color: isDark ? AppColors.textPrimary : Colors.black,
              fontSize: 16,
              fontFamily: context.locale.languageCode == 'ar' ? 'Cairo' : 'Quicksand',
              fontWeight: FontWeight.w500,
            ),
            child: item.child,
          ),
        );
      }).toList(),
      onChanged: widget.onChanged,
      onSaved: widget.onSaved,
      validator: (value) {
        if (widget.isRequired && (value == null)) {
          return 'validation.required'.tr();
        }
        if (widget.validator != null) {
          return widget.validator!(value);
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: TextStyle(
        color: isDark ? AppColors.textPrimary : Colors.black,
        fontSize: 16,
        fontFamily: context.locale.languageCode == 'ar' ? 'Cairo' : 'Quicksand',
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
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
        suffixIcon: Icon(
          FontAwesomeIcons.chevronDown,
          color: isDark ? AppColors.textSecondary : Colors.black54,
          size: 16,
        ),
      ),
      dropdownColor: Theme.of(context).colorScheme.surface,
      icon: const SizedBox.shrink(),
      isExpanded: true,
      menuMaxHeight: 200,
      borderRadius: BorderRadius.circular(12),
    );
  }
}
