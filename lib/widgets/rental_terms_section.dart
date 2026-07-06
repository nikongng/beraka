import 'package:flutter/material.dart';

import 'package:beraca/responsive/responsive.dart';
import 'package:beraca/theme/app_theme.dart';

class RentalTermsSection extends StatelessWidget {
  const RentalTermsSection({super.key});

  static const List<String> _includedServices = [
    "Appartement mis gratuitement à la disposition des mariés pour une nuit.",
    "Sonorisation complète et prestation DJ incluses.",
    "Deux agents d'entretien dédiés au nettoyage permanent des sanitaires.",
    "Espace extérieur disponible pour une cérémonie civile, religieuse ou un cocktail.",
    "Décoration standard de la salle incluse.",
    "Serveurs pour le service des boissons.",
    "Parking intérieur sécurisé et surveillé pouvant accueillir jusqu'à 150 véhicules.",
    "Accès gratuit au congélateur.",
    "Groupe électrogène disponible en permanence.",
    "Boissons apportées par le client autorisées, sans frais d'entrée.",
    "Droit de bouchon offert.",
  ];

  static const List<String> _bookingConditions = [
    "Un acompte de 1 000 \$ est exigé pour confirmer la réservation.",
    "Une caution remboursable de 50 \$ est demandée pour couvrir les éventuelles pertes ou dégradations.",
    "Des frais administratifs de 50 \$ sont applicables.",
    "Le tarif de base comprend un accueil de 1 à 300 personnes.",
    "Toute table supplémentaire de 10 personnes est facturée 100 \$ par table.",
    "La capacité d'accueil pour une cérémonie civile est de 100 personnes.",
    "La capacité maximale de la salle est de 300 personnes.",
  ];

  @override
  Widget build(BuildContext context) {
    final desktop = Responsive.isDesktop(context);

    return ResponsiveContainer(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: Responsive.sectionSpacing(context),
        ),
        child: desktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Expanded(
                    child: _TermsPanel(
                      icon: Icons.verified_rounded,
                      title: "Services inclus offerts",
                      subtitle: "Services inclus avec la location",
                      accentColor: AppTheme.success,
                      items: _includedServices,
                    ),
                  ),
                  SizedBox(width: 24),
                  Expanded(
                    child: _TermsPanel(
                      icon: Icons.assignment_turned_in_rounded,
                      title: "Conditions de réservation",
                      subtitle: "Modalités pour confirmer votre date",
                      accentColor: AppTheme.primary,
                      items: _bookingConditions,
                    ),
                  ),
                ],
              )
            : Column(
                children: const [
                  _TermsPanel(
                    icon: Icons.verified_rounded,
                    title: "Services inclus offerts",
                    subtitle: "Services inclus avec la location",
                    accentColor: AppTheme.success,
                    items: _includedServices,
                  ),
                  SizedBox(height: 24),
                  _TermsPanel(
                    icon: Icons.assignment_turned_in_rounded,
                    title: "Conditions de réservation",
                    subtitle: "Modalités pour confirmer votre date",
                    accentColor: AppTheme.primary,
                    items: _bookingConditions,
                  ),
                ],
              ),
      ),
    );
  }
}

class _TermsPanel extends StatelessWidget {
  const _TermsPanel({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.items,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: accentColor.withValues(alpha: .18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...items.map(
            (item) => _TermItem(
              text: item,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _TermItem extends StatelessWidget {
  const _TermItem({
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 15,
                height: 1.55,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
