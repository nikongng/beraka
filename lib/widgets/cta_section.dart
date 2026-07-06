import 'package:flutter/material.dart';

import 'package:beraca/responsive/responsive.dart';
import 'package:beraca/theme/app_theme.dart';

class CTASection extends StatelessWidget {
  const CTASection({
    super.key,
    this.onReservation,
    this.onContact,
  });

  final VoidCallback? onReservation;
  final VoidCallback? onContact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final desktop = Responsive.isDesktop(context);

    return ResponsiveContainer(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: Responsive.sectionSpacing(context),
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: desktop ? 60 : 28,
            vertical: desktop ? 60 : 36,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36),
            gradient: LinearGradient(
              colors: [
                AppTheme.primary,
                AppTheme.primary.withValues(alpha: 0.9),
                AppTheme.primary.withValues(alpha: 0.75),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: .15),
                blurRadius: 35,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: desktop
              ? Row(
                  children: [
                    Expanded(child: _text(context, theme)),
                    const SizedBox(width: 40),
                    _buttons(theme),
                  ],
                )
              : Column(
                  children: [
                    _text(context, theme),
                    const SizedBox(height: 30),
                    _buttons(theme),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _text(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.onPrimary.withValues(alpha: .15),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            "Votre événement commence ici",
            style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: 22),

        Text(
          "Organisons ensemble\nun événement inoubliable.",
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontSize: 34,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),

        const SizedBox(height: 20),

        Text(
          "Mariages • Conférences • Banquets • Anniversaires • Réceptions privées",
          style: TextStyle(
            color: theme.colorScheme.onPrimary.withValues(alpha: .7),
            fontSize: 17,
            height: 1.8,
          ),
        ),
      ],
    );
  }

  Widget _buttons(ThemeData theme) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: onReservation,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.secondary,
            foregroundColor: theme.colorScheme.onSecondary,
            minimumSize: const Size(180, 58),
          ),
          icon: const Icon(Icons.calendar_month),
          label: const Text("Réserver"),
        ),
        OutlinedButton.icon(
          onPressed: onContact,
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.onPrimary,
            side: BorderSide(color: theme.colorScheme.onPrimary),
            minimumSize: const Size(180, 58),
          ),
          icon: const Icon(Icons.phone),
          label: const Text("Nous contacter"),
        ),
      ],
    );
  }
}