import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gym/core/services/storage_service.dart';
import 'package:gym/routes/route_names.dart';

class SignOutBtn extends StatelessWidget {
  const SignOutBtn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        //clear the auth token
        final storaage = StorageService();
        await storaage.clearUserData();
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteNames.auth_screen_route,
          (route) => false,
        );
      },
      child: const Column(
        children: [
          Text(
            'SignOut',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const Icon(
            FontAwesomeIcons.rightFromBracket,
            size: 20,
          ),
        ],
      ),
    );
  }
}
