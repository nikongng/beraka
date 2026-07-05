import 'dart:ui';

import 'package:flutter/material.dart';

class GlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool hoverEffect;
  final double borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.onTap,
    this.hoverEffect = true,
    this.borderRadius = 28,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (widget.hoverEffect) {
          setState(() => hover = true);
        }
      },
      onExit: (_) {
        if (widget.hoverEffect) {
          setState(() => hover = false);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..translateByDouble(0.0, hover ? -8.0 : 0.0, 0.0, 1.0)
          ..scaleByDouble(
            hover ? 1.02 : 1.0,
            hover ? 1.02 : 1.0,
            1.0,
            1.0,
          ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 10,
              sigmaY: 10,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: widget.padding,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      widget.borderRadius,
                    ),
                    color: Theme.of(context).colorScheme.surface.withValues(alpha: hover ? .90 : .82),
                    border: Border.all(
                      color: hover
                          ? Theme.of(context).colorScheme.primary.withValues(alpha: .25)
                          : Theme.of(context).colorScheme.outlineVariant.withValues(alpha: .40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withValues(alpha: hover ? .15 : .08),
                        blurRadius: hover ? 28 : 14,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
