import 'package:flutter/material.dart';
import 'package:trackletics/Shared/ui/cached_network_img.dart';
import 'package:trackletics/core/theme/app_colors.dart';
import 'package:trackletics/features/exercises/data/models/exercises.dart';

class PopAnimatedCard extends StatefulWidget {
  final Exercise exercise;
  final String imageUrl;
  final VoidCallback onTap;

  const PopAnimatedCard({
    super.key,
    required this.exercise,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  State<PopAnimatedCard> createState() => _PopAnimatedCardState();
}

class _PopAnimatedCardState extends State<PopAnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      lowerBound: 1.0,
      upperBound: 1.1,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() async {
    await _controller.forward();
    await _controller.reverse();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _controller,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Thumbnail section (50% width)
              Container(
                width: (MediaQuery.of(context).size.width - 48) * 0.55,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(16),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(
                    Radius.circular(16),
                  ),
                  child: CachedImage(
                    imageUrl: widget.imageUrl,
                    borderRadius: 0,
                    width: double.infinity,
                    height: 120,
                    fit: BoxFit
                        .cover, // This will crop the image to fill the container
                  ),
                ),
              ),
              // Exercise info section (60% width)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Exercise name
                      Text(
                        widget.exercise.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Muscle group and category with modern UI
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Muscle group
                          if (widget.exercise.primaryMuscle.isNotEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.primary.withOpacity(0.3),
                                    AppColors.primary.withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.4),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.fitness_center,
                                    color: AppColors.primary,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      widget.exercise.primaryMuscle,
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // Spacing between chips
                          if (widget.exercise.primaryMuscle.isNotEmpty &&
                              widget.exercise.category.isNotEmpty)
                            const SizedBox(height: 6),
                          // Category (if available)
                          if (widget.exercise.category.isNotEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.grey.withOpacity(0.3),
                                    Colors.grey.withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.4),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.category,
                                    color: Colors.grey,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      widget.exercise.category,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
