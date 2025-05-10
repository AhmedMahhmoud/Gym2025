import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gym/core/theme/app_colors.dart';

class CustomBackBtn extends StatelessWidget {
  const CustomBackBtn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      child: Container(
          padding: const EdgeInsets.all(7),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.backgroundSurface,
          ),
          child: const Icon(
            FontAwesomeIcons.arrowLeft,
            color: Colors.white,
            size: 20,
          )),
    );
  }
}
