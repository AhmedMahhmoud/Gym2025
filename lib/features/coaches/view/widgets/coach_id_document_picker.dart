import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trackletics/core/theme/app_colors.dart';

/// National ID front photo picker with a card-shaped frame overlay (visual guide only).
/// Does not verify document authenticity — that is left to backend review.
class CoachIdDocumentPicker extends StatelessWidget {
  const CoachIdDocumentPicker({
    super.key,
    required this.imagePath,
    required this.onChanged,
    required this.textPrimary,
    required this.textSecondary,
    required this.surfaceColor,
    required this.theme,
    this.errorText,
  });

  final String? imagePath;
  final ValueChanged<String?> onChanged;
  final Color textPrimary;
  final Color textSecondary;
  final Color surfaceColor;
  final ThemeData theme;
  final String? errorText;

  static const double _cardAspect = 1.586;

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(
      source: source,
      maxWidth: 2048,
      imageQuality: 85,
    );
    if (xfile != null) {
      onChanged(xfile.path);
    }
  }

  void _showSourceSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'coaches.id_document_pick_source'.tr(),
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _SourceTile(
                    icon: Icons.camera_alt_rounded,
                    label: 'common.camera'.tr(),
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickImage(context, ImageSource.camera);
                    },
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppColors.background
                        : AppColors.textPrimaryDark,
                  ),
                  _SourceTile(
                    icon: Icons.photo_library_rounded,
                    label: 'common.gallery'.tr(),
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickImage(context, ImageSource.gallery);
                    },
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppColors.background
                        : AppColors.textPrimaryDark,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && imagePath!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'coaches.id_document_title'.tr(),
          style: TextStyle(
            color: textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'coaches.id_document_subtitle'.tr(),
          style: TextStyle(
            color: textSecondary,
            fontSize: 12,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'coaches.id_document_frame_hint'.tr(),
          style: TextStyle(
            color: textSecondary.withOpacity(0.9),
            fontSize: 11,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 12),
        AspectRatio(
          aspectRatio: _cardAspect,
          child: GestureDetector(
            onTap: () => _showSourceSheet(context),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    color: surfaceColor,
                    child: hasImage
                        ? Image.file(
                            File(imagePath!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                ),
                CustomPaint(
                  painter: _IdCardFramePainter(
                    color: theme.colorScheme.primary.withOpacity(0.85),
                    dashed: !hasImage,
                  ),
                ),
                if (!hasImage)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.badge_outlined,
                          size: 44,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? AppColors.divider
                                  : AppColors.textPrimaryDark,
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'coaches.id_document_tap_to_add'.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (hasImage) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => _showSourceSheet(context),
                icon: Icon(Icons.edit_outlined,
                    size: 18, color: theme.colorScheme.primary),
                label: Text(
                  'coaches.id_document_replace'.tr(),
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              ),
              TextButton.icon(
                onPressed: () => onChanged(null),
                icon: const Icon(Icons.delete_outline_rounded,
                    size: 18, color: AppColors.error),
                label: Text(
                  'coaches.id_document_remove'.tr(),
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 8),
        Text(
          'coaches.id_document_privacy_note'.tr(),
          style: TextStyle(
            color: textSecondary.withOpacity(0.85),
            fontSize: 11,
          ),
        ),
        if (errorText != null && errorText!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            errorText!,
            style: const TextStyle(
              color: AppColors.error,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rounded rect + corner brackets; dashed when empty to suggest “place card here”.
class _IdCardFramePainter extends CustomPainter {
  _IdCardFramePainter({required this.color, required this.dashed});

  final Color color;
  final bool dashed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = dashed ? 2 : 2.5
      ..style = PaintingStyle.stroke;

    const radius = 16.0;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
      const Radius.circular(radius),
    );

    if (dashed) {
      _drawDashedPath(canvas, Path()..addRRect(rect), paint);
    } else {
      canvas.drawRRect(rect, paint);
    }

    const len = 22.0;
    const pad = 10.0;
    // Corner brackets (stronger visual cue for ID alignment)
    _corner(canvas, const Offset(pad, pad), len, len, paint);
    _corner(canvas, Offset(size.width - pad, pad), -len, len, paint);
    _corner(canvas, Offset(pad, size.height - pad), len, -len, paint);
    _corner(
        canvas, Offset(size.width - pad, size.height - pad), -len, -len, paint);
  }

  void _corner(Canvas canvas, Offset o, double dx, double dy, Paint paint) {
    canvas.drawLine(o, o + Offset(dx, 0), paint);
    canvas.drawLine(o, o + Offset(0, dy), paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      const dash = 8.0;
      const gap = 5.0;
      while (d < metric.length) {
        final next = (d + dash).clamp(0.0, metric.length);
        canvas.drawPath(
          metric.extractPath(d, next),
          paint,
        );
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _IdCardFramePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.dashed != dashed;
  }
}
