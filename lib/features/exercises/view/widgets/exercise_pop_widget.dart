import 'package:flutter/material.dart';
import 'package:gym/Shared/ui/cached_network_img.dart';
import 'package:gym/core/theme/app_colors.dart';
import 'package:gym/features/exercises/data/models/exercises.dart';

class PopAnimatedCard extends StatefulWidget {
  final Exercise exercise;
  final String imageUrl;
  final VoidCallback onTap;
  final bool showDelete;
  final VoidCallback? onDelete;
  final bool isDeleteLoading;

  const PopAnimatedCard({
    super.key,
    required this.exercise,
    required this.imageUrl,
    required this.onTap,
    this.showDelete = false,
    this.onDelete,
    this.isDeleteLoading = false,
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
    if (!widget.isDeleteLoading) {
      await _controller.forward();
      await _controller.reverse();
      widget.onTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _controller,
        child: Stack(
          children: [
            CachedImage(
              imageUrl: widget.imageUrl,
              borderRadius: 20,
              width: double.infinity,
              height: 160,
            ),
            Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.2,
                ),
              ),
              alignment: Alignment.center,
            ),
            // Delete button for custom exercises
            if (widget.showDelete && widget.onDelete != null)
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: widget.isDeleteLoading ? null : widget.onDelete,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.7),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.8),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      color: widget.isDeleteLoading ? Colors.grey : Colors.red,
                      size: 18,
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 0,
              child: Container(
                width: MediaQuery.of(context).size.width - 48,
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20))),
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                  ),
                  child: Text(
                    widget.exercise.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      shadows: [
                        Shadow(
                          blurRadius: 18,
                          color: Colors.black,
                          offset: Offset(1, 1),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
