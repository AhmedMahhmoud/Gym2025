import 'package:flutter/material.dart';
import 'package:trackletics/core/theme/app_colors.dart';
import 'package:trackletics/Shared/ui/custom_snackbar.dart';
import 'package:trackletics/features/exercises/data/models/exercises.dart';
import 'package:trackletics/features/profile/cubit/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackletics/features/profile/cubit/profile_cubit.dart';
import 'package:trackletics/features/exercises/view/cubit/exercises_cubit.dart';

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
  final _maleVideoUrlController = TextEditingController();
  final _femaleVideoUrlController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current exercise data
    _nameController.text = widget.exercise.name;
    _descriptionController.text = widget.exercise.description;
    _maleVideoUrlController.text = widget.exercise.maleVideoUrl;
    _femaleVideoUrlController.text = widget.exercise.femaleVideoUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _maleVideoUrlController.dispose();
    _femaleVideoUrlController.dispose();
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
      exerciseId: widget.exercise.id, // Use exercise ID for API call
      title: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      maleVideoUrl: _maleVideoUrlController.text.trim().isNotEmpty
          ? _maleVideoUrlController.text.trim()
          : null,
      femaleVideoUrl: _femaleVideoUrlController.text.trim().isNotEmpty
          ? _femaleVideoUrlController.text.trim()
          : null,
      primaryMuscleId:
          widget.exercise.primaryMuscleId, // We don't have ID mapping yet
      categoryId: widget.exercise.categoryId, // We don't have ID mapping yet
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
              Navigator.pop(context);
              Navigator.pop(context);
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
                        controller: TextEditingController(
                            text: widget.exercise.primaryMuscle),
                        label: 'Primary Muscle (Read Only)',
                        hint: 'e.g., Chest, Back, Legs',
                        icon: Icons.fitness_center,
                        enabled: false,
                      ),
                      const SizedBox(height: 16),

                      // Category
                      _buildTextField(
                        controller: TextEditingController(
                            text: widget.exercise.category),
                        label: 'Category (Read Only)',
                        hint: 'e.g., Strength, Cardio',
                        icon: Icons.category,
                        enabled: false,
                      ),
                      const SizedBox(height: 16),

                      // Male Video URL
                      _buildTextField(
                        controller: _maleVideoUrlController,
                        label: 'Male Video URL (Optional)',
                        hint: 'Enter YouTube video URL for male demonstration',
                        icon: Icons.male,
                      ),
                      const SizedBox(height: 16),

                      // Female Video URL
                      _buildTextField(
                        controller: _femaleVideoUrlController,
                        label: 'Female Video URL (Optional)',
                        hint:
                            'Enter YouTube video URL for female demonstration',
                        icon: Icons.female,
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
