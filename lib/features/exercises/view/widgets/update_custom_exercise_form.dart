import 'package:flutter/material.dart';
import 'package:trackletics/core/theme/app_colors.dart';
import 'package:trackletics/Shared/ui/custom_snackbar.dart';
import 'package:trackletics/features/exercises/view/cubit/exercises_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:trackletics/features/exercises/data/models/exercises.dart';

class UpdateCustomExerciseForm extends StatefulWidget {
  final Exercise exercise;

  const UpdateCustomExerciseForm({
    super.key,
    required this.exercise,
  });

  @override
  State<UpdateCustomExerciseForm> createState() =>
      _UpdateCustomExerciseFormState();
}

class _UpdateCustomExerciseFormState extends State<UpdateCustomExerciseForm>
    with SingleTickerProviderStateMixin {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _videoUrlController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  late AnimationController _animationController;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    // Pre-fill the form with existing exercise data
    _titleController.text = widget.exercise.name;
    _descriptionController.text = widget.exercise.description ?? '';
    _videoUrlController.text = widget.exercise.videoUrl ?? '';
    _categoryController.text = widget.exercise.primaryMuscle ?? '';

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Create staggered animations for each form element
    _animations = List.generate(
      5, // Number of elements to animate (Lottie + 4 text fields)
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.15, // Start time
            (index * 0.15) + 0.3, // End time (reduced from 0.5 to 0.3)
            curve: Curves.easeOut,
          ),
        ),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _videoUrlController.dispose();
    _categoryController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedFormField({
    required Widget child,
    required int index,
  }) {
    return AnimatedBuilder(
      animation: _animations[index],
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _animations[index].value)),
          child: Opacity(
            opacity: _animations[index].value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Future<void> _handleSubmit() async {
    if (_titleController.text.isEmpty || _categoryController.text.isEmpty) {
      CustomSnackbar.show(
        context,
        'Please fill in all required fields',
        isError: true,
      );
      return;
    }

    final exercisesCubit = context.read<ExercisesCubit>();
    await exercisesCubit.updateCustomExercise(
      exerciseId: widget.exercise.id,
      title: _titleController.text,
      description: _descriptionController.text,
      primaryMuscle: _categoryController.text,
      videoUrl:
          _videoUrlController.text.isNotEmpty ? _videoUrlController.text : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExercisesCubit, ExercisesState>(
      listener: (context, state) {
        if (state.status == ExerciseStatus.error) {
          CustomSnackbar.show(
            context,
            state.errorMessage ?? 'Failed to update custom exercise',
            isError: true,
          );
        } else if (state.status == ExerciseStatus.success) {
          // First show the success message
          CustomSnackbar.show(
            context,
            'Custom exercise updated successfully',
            isError: false,
          );
          // Return the updated exercise
          final updatedExercise = state.customExercises.firstWhere(
            (e) => e.id == widget.exercise.id,
            orElse: () => widget.exercise,
          );
          Navigator.pop(context, updatedExercise);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Update Custom Exercise'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: BlocBuilder<ExercisesCubit, ExercisesState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Animated Lottie
                  _buildAnimatedFormField(
                    index: 0,
                    child: Center(
                      child: Lottie.asset(
                        'assets/images/gymLottie.json',
                        height: 300,
                      ),
                    ),
                  ),

                  // Loading Indicator
                  if (state.status == ExerciseStatus.loading)
                    const LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  const SizedBox(height: 5),

                  // Title Field
                  _buildAnimatedFormField(
                    index: 1,
                    child: TextField(
                      controller: _titleController,
                      onTapOutside: (event) => FocusScope.of(context).unfocus(),
                      decoration: InputDecoration(
                        hintText: 'Exercise Name',
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.primary),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Description Field
                  _buildAnimatedFormField(
                    index: 2,
                    child: TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      onTapOutside: (event) => FocusScope.of(context).unfocus(),
                      decoration: InputDecoration(
                        hintText: 'Description',
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.primary),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Video URL Field
                  _buildAnimatedFormField(
                    index: 3,
                    child: TextField(
                      controller: _videoUrlController,
                      onTapOutside: (event) => FocusScope.of(context).unfocus(),
                      decoration: InputDecoration(
                        hintText: 'YouTube Video URL (Optional)',
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.primary),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Category Field
                  _buildAnimatedFormField(
                    index: 4,
                    child: TextField(
                      controller: _categoryController,
                      onTapOutside: (event) => FocusScope.of(context).unfocus(),
                      decoration: InputDecoration(
                        hintText: 'Muscle Group (e.g., Chest)',
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.primary),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  _buildAnimatedFormField(
                    index: 4,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state.status == ExerciseStatus.loading
                            ? null
                            : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          state.status == ExerciseStatus.loading
                              ? 'Updating Exercise...'
                              : 'Update Custom Exercise',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
