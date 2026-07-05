import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:beraka_hotel_restaurant/responsive/responsive.dart';
import 'package:beraka_hotel_restaurant/theme/app_theme.dart';
import 'primary_button.dart';

class HeroSection extends StatelessWidget {
  final VoidCallback onReservation;
  final VoidCallback onMenu;

  const HeroSection({
    super.key,
    required this.onReservation,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final desktop = Responsive.isDesktop(context);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 650),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/background.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.onBackground.withOpacity(.70),
              theme.colorScheme.onBackground.withOpacity(.45),
              theme.colorScheme.onBackground.withOpacity(.20),
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        child: SafeArea(
          child: ResponsiveContainer(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: desktop
                  ? Row(
                      children: [
                        Expanded(child: _left(theme)), // Passage du thème en paramètre
                        const SizedBox(width: 40),
                        Expanded(child: _right()),
                      ],
                    )
                  : Column(
                      children: [
                        _left(theme), // Passage du thème en paramètre
                        const SizedBox(height: 40),
                        _right(),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _left(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Animate(
          child: const Text(
            "BERACA'S VALLEY",
            style: TextStyle(
              color: AppTheme.secondary,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ).fade().moveX(begin: -40),
        const SizedBox(height: 20),
        Animate(
          child: Text(
            "L'excellence pour vos événements.",
            style: TextStyle(
              color: Colors.white,
              fontSize: 54,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
        ).fade(delay: const Duration(milliseconds: 200)).moveY(begin: 30),
        const SizedBox(height: 25),
        Animate(
          child: Text(
            "decouvrez BERACA'S VALLEY, la salle de reception prestigieuse concu pour sublimer vos moments innoubliables. Mariages, conférences, anniversaires.",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              height: 1.8,
            ),
          ),
        ).fade(delay: const Duration(milliseconds: 400)),
        const SizedBox(height: 40),
        Animate(
          child: Wrap(
            spacing: 18,
            runSpacing: 18,
            children: [
              PrimaryButton(
                text: "Réserver",
                icon: Icons.calendar_month,
                onPressed: onReservation,
              ),
              OutlinedButton.icon(
                onPressed: onMenu,
                icon: const Icon(Icons.restaurant_menu),
                label: const Text("Voir le menu"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: theme.colorScheme.onBackground),
                ),
              ),
            ],
          ),
        ).fade(delay: const Duration(milliseconds: 600)),
      ],
    );
  }

  static Widget _right() {
    return const Wrap(
      spacing: 20,
      runSpacing: 20,
      children: [
        _InfoCard(
          icon: Icons.people,
          value: "300+",
          title: "Invités",
        ),
        _InfoCard(
          icon: Icons.star,
          value: "4.9",
          title: "Note",
        ),
        _InfoCard(
          icon: Icons.local_parking,
          value: "Parking",
          title: "Sécurisé",
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String title;

  const _InfoCard({
    required this.icon,
    required this.value,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    // Récupération du thème pour ce widget indépendant
    final theme = Theme.of(context);

    return Container(
      width: 170,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.onSurface.withOpacity(.24),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 34,
          ),
          const SizedBox(height: 18),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
            ),
          )
        ],
      ),
    );
  }
}