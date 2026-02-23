import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trackletics/core/theme/app_theme.dart';
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
    return DropdownButtonFormField<T>(
      value: widget.value,
      items: widget.items,
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
        color: AppColors.textPrimary,
        fontSize: 16,
        fontFamily: context.locale.languageCode == 'ar' ? 'Cairo' : 'Quicksand',
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
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
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        prefixIcon: widget.prefixIcon,
        suffixIcon: const Icon(
          FontAwesomeIcons.chevronDown,
          color: AppColors.textSecondary,
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
