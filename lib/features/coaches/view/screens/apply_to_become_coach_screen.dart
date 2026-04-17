import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackletics/core/theme/app_colors.dart';
import 'package:trackletics/features/coaches/view/cubit/apply_to_become_coach_cubit.dart';
import 'package:trackletics/features/coaches/view/widgets/coach_id_document_picker.dart';

class ApplyToBecomeCoachScreen extends StatefulWidget {
  const ApplyToBecomeCoachScreen({Key? key}) : super(key: key);

  @override
  State<ApplyToBecomeCoachScreen> createState() =>
      _ApplyToBecomeCoachScreenState();
}

class _ApplyToBecomeCoachScreenState extends State<ApplyToBecomeCoachScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idDocumentFieldKey = GlobalKey<FormFieldState<String?>>();
  final _bioController = TextEditingController();
  final _experienceController = TextEditingController();

  @override
  void dispose() {
    _bioController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final idPath = _idDocumentFieldKey.currentState?.value;
    if (idPath == null || idPath.isEmpty) {
      return;
    }

    context.read<ApplyToBecomeCoachCubit>().submitApplication(
          bio: _bioController.text,
          experience: _experienceController.text,
          idDocumentPath: idPath,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final surfaceColor = isDark ? AppColors.surface : AppColors.surfaceLight;
    final textPrimary =
        isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;
    final borderColor =
        isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.15);
    final focusedBorderColor = theme.colorScheme.primary;

    return BlocConsumer<ApplyToBecomeCoachCubit, ApplyToBecomeCoachState>(
      listener: (context, state) {
          if (state is ApplyToBecomeCoachSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('coaches.application_success'.tr()),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.of(context).pop(true);
          } else if (state is ApplyToBecomeCoachError) {
            final message = state.message.contains('Failed to submit')
                ? 'coaches.failed_to_submit'.tr()
                : state.message;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      builder: (context, state) {
        final isLoading = state is ApplyToBecomeCoachLoading;

        return Scaffold(
            appBar: AppBar(
              title: Text(
                'coaches.apply_screen_title'.tr(),
                style: TextStyle(
                  color: isDark ? AppColors.textPrimary : Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor:
                  isDark ? AppColors.surface : theme.colorScheme.primary,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: isDark ? AppColors.textPrimary : Colors.white,
                  size: 20,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: Container(
              color: isDark ? AppColors.background : AppColors.backgroundLight,
              child: SafeArea(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(theme, isDark, textPrimary, textSecondary),
                        const SizedBox(height: 28),
                        _buildSectionLabel(
                            'coaches.bio'.tr(), isDark, textPrimary),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _bioController,
                          maxLines: 5,
                          minLines: 3,
                          style: TextStyle(color: textPrimary, fontSize: 16),
                          decoration: InputDecoration(
                            hintText: 'coaches.bio_hint'.tr(),
                            hintStyle:
                                TextStyle(color: textSecondary, fontSize: 14),
                            filled: true,
                            fillColor: surfaceColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                  color: focusedBorderColor, width: 2),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide:
                                  const BorderSide(color: AppColors.error),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'coaches.bio_required'.tr();
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        _buildSectionLabel(
                            'coaches.experience'.tr(), isDark, textPrimary),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _experienceController,
                          maxLines: 5,
                          minLines: 3,
                          style: TextStyle(color: textPrimary, fontSize: 16),
                          decoration: InputDecoration(
                            hintText: 'coaches.experience_hint'.tr(),
                            hintStyle:
                                TextStyle(color: textSecondary, fontSize: 14),
                            filled: true,
                            fillColor: surfaceColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                  color: focusedBorderColor, width: 2),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide:
                                  const BorderSide(color: AppColors.error),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'coaches.experience_required'.tr();
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),
                        FormField<String?>(
                          key: _idDocumentFieldKey,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'coaches.id_document_required'.tr();
                            }
                            return null;
                          },
                          builder: (field) {
                            return CoachIdDocumentPicker(
                              imagePath: field.value,
                              onChanged: (p) => field.didChange(p),
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              surfaceColor: surfaceColor,
                              theme: theme,
                              errorText:
                                  field.hasError ? field.errorText : null,
                            );
                          },
                        ),
                        const SizedBox(height: 32),
                        _buildSubmitButton(context, theme, isLoading),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
      },
    );
  }

  Widget _buildHeader(
      ThemeData theme, bool isDark, Color textPrimary, Color textSecondary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (isDark ? AppColors.primary : theme.colorScheme.primary)
                .withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                Icons.sports_martial_arts_rounded,
                size: 40,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'coaches.join_as_coach'.tr(),
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'coaches.join_subtitle'.tr(),
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label, bool isDark, Color textPrimary) {
    return Text(
      label,
      style: TextStyle(
        color: textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSubmitButton(
      BuildContext context, ThemeData theme, bool isLoading) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : () => _submit(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: theme.colorScheme.primary.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'coaches.submit_application'.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
