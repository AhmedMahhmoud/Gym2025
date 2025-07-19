import 'package:flutter/material.dart';
import 'package:gym/core/theme/app_colors.dart';
import 'package:gym/Shared/ui/custom_snackbar.dart';
import 'package:gym/features/exercises/data/models/exercises.dart';
import 'package:gym/features/profile/cubit/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym/features/profile/cubit/profile_cubit.dart';
import 'package:gym/features/exercises/view/cubit/exercises_cubit.dart';

class AdminExerciseEditScreen extends StatefulWidget {
  final Exercise exercise;

  const AdminExerciseEditScreen({
    Key? key,
    required this.exercise,
  }) : super(key: key);

  @override
  State<AdminExerciseEditScreen> createState() =>
      _AdminExerciseEditScreenState();
}

class _AdminExerciseEditScreenState extends State<AdminExerciseEditScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _primaryMuscleController = TextEditingController();
  final _categoryController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current exercise data
    _nameController.text = widget.exercise.name;
    _descriptionController.text = widget.exercise.description;
    _videoUrlController.text = widget.exercise.videoUrl;
    _primaryMuscleController.text = widget.exercise.primaryMuscle;
    _categoryController.text = widget.exercise.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _videoUrlController.dispose();
    _primaryMuscleController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_nameController.text.trim().isEmpty) {
      CustomSnackbar.show(
        context,
        'Exercise name is required',
        isError: true,
      );
      return;
    }

    final exercisesCubit = context.read<ExercisesCubit>();
    await exercisesCubit.updateExercise(
      exerciseName: widget.exercise.name, // Use original name for API call
      title: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      videoUrl: _videoUrlController.text.trim().isNotEmpty
          ? _videoUrlController.text.trim()
          : null,
      primaryMuscleId: null, // We don't have ID mapping yet
      categoryId: null, // We don't have ID mapping yet
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, profileState) {
        // Check if user is admin
        if (!profileState.isAdmin) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Access Denied'),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock,
                    size: 64,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Access Denied',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'You need admin privileges to edit exercises',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return BlocListener<ExercisesCubit, ExercisesState>(
          listener: (context, state) {
            if (state.status == ExerciseStatus.error) {
              CustomSnackbar.show(
                context,
                state.errorMessage ?? 'Failed to update exercise',
                isError: true,
              );
              setState(() {
                _isLoading = false;
              });
            } else if (state.status == ExerciseStatus.success) {
              CustomSnackbar.show(
                context,
                'Exercise updated successfully',
                isError: false,
              );
              setState(() {
                _isLoading = false;
              });
              Navigator.pop(context, true);
            }
          },
          child: BlocBuilder<ExercisesCubit, ExercisesState>(
            builder: (context, exercisesState) {
              // Update local loading state based on cubit state
              if (exercisesState.status == ExerciseStatus.loading) {
                _isLoading = true;
              } else if (exercisesState.status == ExerciseStatus.success ||
                  exercisesState.status == ExerciseStatus.error) {
                _isLoading = false;
              }

              return Scaffold(
                appBar: AppBar(
                  title: const Text('Edit Exercise'),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  actions: [
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Loading Indicator
                      if (_isLoading)
                        const Column(
                          children: [
                            LinearProgressIndicator(
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary),
                            ),
                            SizedBox(height: 16),
                          ],
                        ),

                      // Admin Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.admin_panel_settings,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Admin Mode',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Exercise Name
                      _buildTextField(
                        controller: _nameController,
                        label: 'Exercise Name',
                        hint: 'Enter exercise name',
                        icon: Icons.fitness_center,
                      ),
                      const SizedBox(height: 16),

                      // Description
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        hint: 'Enter exercise description',
                        icon: Icons.description,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // Primary Muscle
                      _buildTextField(
                        controller: _primaryMuscleController,
                        label: 'Primary Muscle (Read Only)',
                        hint: 'e.g., Chest, Back, Legs',
                        icon: Icons.fitness_center,
                        enabled: false,
                      ),
                      const SizedBox(height: 16),

                      // Category
                      _buildTextField(
                        controller: _categoryController,
                        label: 'Category (Read Only)',
                        hint: 'e.g., Strength, Cardio',
                        icon: Icons.category,
                        enabled: false,
                      ),
                      const SizedBox(height: 8),

                      // Note about read-only fields
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.3),
                          ),
                        ),
                        child: const Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Colors.orange,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Primary Muscle and Category are read-only. These require ID mappings that are not currently available.',
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Video URL
                      _buildTextField(
                        controller: _videoUrlController,
                        label: 'Video URL (Optional)',
                        hint: 'Enter YouTube video URL',
                        icon: Icons.video_library,
                      ),
                      const SizedBox(height: 32),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _isLoading ? 'Saving...' : 'Save Changes',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: enabled ? Colors.white : Colors.white.withOpacity(0.6),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          enabled: enabled,
          onTapOutside: (event) => FocusScope.of(context).unfocus(),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: enabled
                  ? Colors.white.withOpacity(0.5)
                  : Colors.white.withOpacity(0.3),
            ),
            prefixIcon: Icon(
              icon,
              color: enabled
                  ? AppColors.primary.withOpacity(0.7)
                  : AppColors.primary.withOpacity(0.3),
            ),
            filled: true,
            fillColor: enabled
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.02),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: enabled
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.05),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: enabled
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.05),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: enabled
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}
