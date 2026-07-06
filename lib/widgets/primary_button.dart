import 'package:flutter/material.dart';

import 'package:beraca/theme/app_theme.dart';

class PrimaryButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool expanded;
  final double height;

  const PrimaryButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.expanded = false,
    this.height = 58,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    Widget button = MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: AnimatedScale(
        scale: hover ? 1.03 : 1,
        duration: const Duration(milliseconds: 180),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: hover
                  ? [
                      AppTheme.primary,
                      AppTheme.primary.withValues(alpha: 0.9),
                    ]
                  : [
                      AppTheme.primary,
                      AppTheme.primary.withValues(alpha: 0.8),
                    ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: hover ? .40 : .25),
                blurRadius: hover ? 24 : 14,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: widget.onPressed,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                ),
                child: Row(
                  mainAxisSize: widget.expanded
                      ? MainAxisSize.max
                      : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                    ],
                    Text(
                      widget.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.expanded) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}