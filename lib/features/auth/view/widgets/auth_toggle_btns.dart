import 'package:flutter/material.dart';
import 'package:trackletics/core/theme/app_colors.dart';

enum AuthType { login, signup }

class AuthToggleTabs extends StatelessWidget {
  const AuthToggleTabs({
    super.key,
    required this.selectedType,
    required this.onSelect,
  });
  final AuthType selectedType;
  final ValueChanged<AuthType> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: AuthType.values.map((type) {
        return Padding(
          padding: const EdgeInsets.only(right: 20),
          child: AuthTabButton(
            label: type == AuthType.login ? 'Login' : 'Sign up',
            isSelected: selectedType == type,
            onTap: () => onSelect(type),
          ),
        );
      }).toList(),
    );
  }
}

class AuthTabButton extends StatelessWidget {
  const AuthTabButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 19),
          ),
          const SizedBox(height: 5),
          AnimatedContainer(
            duration: const Duration(seconds: 450),
            curve: Curves.fastOutSlowIn,
            width: isSelected ? 40 : 0,
            height: 3,
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
        ],
      ),
    );
  }
}
