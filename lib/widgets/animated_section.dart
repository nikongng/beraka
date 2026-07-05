import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedSection extends StatelessWidget {
  final Widget child;

  final int delay;

  final Duration duration;

  final double offsetY;

  final bool enableScale;

  const AnimatedSection({
    super.key,
    required this.child,
    this.delay = 0,
    this.duration = const Duration(milliseconds: 700),
    this.offsetY = 40,
    this.enableScale = true,
  });

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    if (reduceMotion) {
      return child;
    }

    final animation = Animate(
      child: child,
      delay: Duration(milliseconds: delay),
    ).fade(
      duration: duration,
      curve: Curves.easeOut,
    ).moveY(
      begin: offsetY,
      end: 0,
      duration: duration,
      curve: Curves.easeOutCubic,
    );

    if (enableScale) {
      return animation.scale(
        begin: const Offset(.97, .97),
        end: const Offset(1, 1),
        duration: duration,
        curve: Curves.easeOut,
      );
    }

    return animation;
  }
}