import 'package:flutter/material.dart';

import 'package:beraka_hotel_restaurant/responsive/responsive.dart';
import 'package:beraka_hotel_restaurant/theme/app_theme.dart';

class SectionTitle extends StatelessWidget {
  final String badge;
  final String title;
  final String subtitle;
  final TextAlign textAlign;

  const SectionTitle({
    super.key,
    required this.badge,
    required this.title,
    required this.subtitle,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: textAlign == TextAlign.center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppTheme.primary.withValues(alpha: .15),
            ),
          ),
          child: Text(
            badge.toUpperCase(),
            style: const TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              fontSize: 12,
            ),
          ),
        ),

        const SizedBox(height: 22),

        Text(
          title,
          textAlign: textAlign,
          style: TextStyle(
              fontSize: Responsive.isDesktop(context) ? 42 : 30,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.displayMedium?.color ?? AppTheme.lightText,
              height: 1.2,
            ),
        ),
        const SizedBox(height: 18),

        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 700,
          ),
          child: Text(
            subtitle,
            textAlign: textAlign,
            style: TextStyle(
              fontSize: 17,
              color: Colors.grey.shade700,
              height: 1.7,
            ),
          ),
        ),

        const SizedBox(height: 50),
      ],
    );
  }
}