import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trackletics/core/services/storage_service.dart';
import 'package:trackletics/core/services/token_manager.dart';
import 'package:trackletics/features/profile/cubit/profile_cubit.dart';
import 'package:trackletics/features/exercises/view/cubit/exercises_cubit.dart';
import 'package:trackletics/routes/route_names.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:trackletics/core/theme/app_colors.dart';
import 'package:trackletics/core/network/dio_service.dart';

class SignOutBtn extends StatelessWidget {
  const SignOutBtn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Sign Out Button
        GestureDetector(
          onTap: () => _showSignOutConfirmation(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.orange.withOpacity(0.2),
                  Colors.orange.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.orange.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    FontAwesomeIcons.rightFromBracket,
                    color: Colors.orange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sign Out',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Log out of your account',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.orange.withOpacity(0.6),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Delete User Button
        GestureDetector(
          onTap: () => _showDeleteUserConfirmation(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.red.withOpacity(0.2),
                  Colors.red.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.red.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    FontAwesomeIcons.userXmark,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Delete Account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Permanently delete your account',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.red.withOpacity(0.6),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showSignOutConfirmation(BuildContext context) {
    _showModernConfirmationDialog(
      context: context,
      title: 'Sign Out',
      message:
          'Are you sure you want to sign out? You will need to log in again.',
      icon: FontAwesomeIcons.rightFromBracket,
      iconColor: Colors.orange,
      confirmText: 'Sign Out',
      confirmColor: Colors.orange,
      onConfirm: () async {
        Navigator.pop(context);
        await _performSignOut(context);
      },
    );
  }

  void _showDeleteUserConfirmation(BuildContext context) {
    _showModernConfirmationDialog(
      context: context,
      title: 'Delete Account',
      message:
          'This action cannot be undone. All your data will be permanently deleted.',
      icon: FontAwesomeIcons.userXmark,
      iconColor: Colors.red,
      confirmText: 'Delete Account',
      confirmColor: Colors.red,
      onConfirm: () async {
        Navigator.pop(context);
        await _performDeleteUser(context);
      },
    );
  }

  void _showModernConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
    required String confirmText,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              confirmText,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performSignOut(BuildContext context) async {
    try {
      print('🔐 Starting signout process...');

      // Clear TokenManager cache first
      final tokenManager = TokenManager();
      await tokenManager.clearToken();
      print('✅ TokenManager cache cleared');

      // Force refresh cache to ensure no stale data persists
      await tokenManager.forceRefreshCache();
      print('✅ TokenManager cache force refreshed');

      // Clear only user data, preserve app settings like onboarding status
      final storage = StorageService();
      await storage.clearUserDataOnly();
      print('✅ Storage user data cleared');

      // Reset ProfileCubit state and clear hydrated storage
      if (context.mounted) {
        await context.read<ProfileCubit>().clearAllData();
        print('✅ ProfileCubit data cleared');
      }

      // Reset ExercisesCubit static data to ensure fresh data on next login
      ExercisesCubit.resetStaticData();
      print('✅ ExercisesCubit static data reset');

      // Clear any potential gender-related cached data
      // Force clear any remaining cached data that might persist
      await storage.delete(key: 'auth_token', type: StorageType.secure);
      await storage.delete(key: 'user_id', type: StorageType.secure);
      await storage.delete(key: 'user_email', type: StorageType.secure);
      await storage.delete(key: 'user_name', type: StorageType.secure);
      print('✅ Additional secure storage keys cleared');

      // Clear cached network images
      final cacheManager = DefaultCacheManager();
      await cacheManager.emptyCache();
      print('✅ Network image cache cleared');

      print('🔐 Signout process completed successfully');

      // Navigate to auth screen
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteNames.auth_screen_route,
          (route) => false,
        );
        print('✅ Navigated to auth screen');
      }
    } catch (e) {
      print('❌ Error during signout: $e');
      // If any error occurs, still try to navigate to auth screen
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteNames.auth_screen_route,
          (route) => false,
        );
      }
    }
  }

  Future<void> _performDeleteUser(BuildContext context) async {
    try {
      // Get current user email from ProfileCubit
      final profileState = context.read<ProfileCubit>().state;
      final userEmail = profileState.email;

      if (userEmail == null || userEmail.isEmpty) {
        throw Exception('User email not found');
      }

      // Call delete user API
      final dioService = DioService();
      final response = await dioService.delete(
        '/api/Auth/DeleteUser',
        data: {
          'email': userEmail,
        },
      );

      if (response.statusCode == 200) {
        // Success - clear all data and navigate to auth
        await _performSignOut(context);
      } else {
        throw Exception('Failed to delete user account');
      }
    } catch (e) {
      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete account: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
