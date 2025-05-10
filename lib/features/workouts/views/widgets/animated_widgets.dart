import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

class FadeInWidget extends StatelessWidget {
  const FadeInWidget({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
  }) : super(key: key);
  final Widget child;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      duration: duration,
      child: child,
    );
  }
}

class SlideInUpWidget extends StatelessWidget {
  const SlideInUpWidget({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
  }) : super(key: key);
  final Widget child;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return SlideInUp(
      duration: duration,
      child: child,
    );
  }
}

class ElasticInWidget extends StatelessWidget {
  const ElasticInWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
  });
  final Widget child;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return ElasticIn(
      duration: duration,
      child: child,
    );
  }
}
