import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gym/core/services/storage_service.dart';
import 'package:gym/core/services/token_manager.dart';
import 'package:gym/features/profile/cubit/profile_cubit.dart';
import 'package:gym/routes/route_names.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class SignOutBtn extends StatelessWidget {
  const SignOutBtn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        try {
          // Clear TokenManager cache first
          final tokenManager = TokenManager();
          await tokenManager.clearToken();

          // Clear all storage types
          final storage = StorageService();
          await storage.clearAllData();

          // Reset ProfileCubit state and clear hydrated storage
          if (context.mounted) {
            await context.read<ProfileCubit>().clearAllData();
          }

          // Clear cached network images
          final cacheManager = DefaultCacheManager();
          await cacheManager.emptyCache();

          // Navigate to auth screen
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              RouteNames.auth_screen_route,
              (route) => false,
            );
          }
        } catch (e) {
          // If any error occurs, still try to navigate to auth screen
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              RouteNames.auth_screen_route,
              (route) => false,
            );
          }
        }
      },
      child: const Column(
        children: [
          Text(
            'SignOut',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          Icon(
            FontAwesomeIcons.rightFromBracket,
            size: 20,
          ),
        ],
      ),
    );
  }
}
