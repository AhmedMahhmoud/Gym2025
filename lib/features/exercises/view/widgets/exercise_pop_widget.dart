import 'package:flutter/material.dart';
import 'package:gym/Shared/ui/cached_network_img.dart';
import 'package:gym/core/theme/app_colors.dart';
import 'package:gym/features/exercises/data/models/exercises.dart';

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
            Positioned(
              bottom: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
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
