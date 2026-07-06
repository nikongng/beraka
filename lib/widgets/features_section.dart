import 'package:flutter/material.dart';

import 'package:beraca/responsive/responsive.dart';
import 'package:beraca/theme/app_theme.dart';
import 'package:beraca/widgets/section_title.dart';

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  static const List<_Feature> _features = [
    _Feature(
      Icons.people_alt_rounded,
      "500 invités",
      "Grande capacité pour mariages, conférences et événements.",
    ),
    _Feature(
      Icons.local_parking_rounded,
      "Parking sécurisé",
      "Parking spacieux et surveillé pour vos invités.",
    ),
    _Feature(
      Icons.ac_unit_rounded,
      "Climatisation",
      "Salle entièrement climatisée pour un confort optimal.",
    ),
    _Feature(
      Icons.restaurant_rounded,
      "Restaurant",
      "Cuisine raffinée préparée par notre équipe.",
    ),
    _Feature(
      Icons.wifi_rounded,
      "Wi-Fi",
      "Connexion Internet haut débit gratuite.",
    ),
    _Feature(
      Icons.security_rounded,
      "Sécurité",
      "Personnel qualifié présent durant tous les événements.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ResponsiveContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            badge: "Nos atouts",
            title: "Pourquoi choisir Beraca's Valley ?",
            subtitle:
                "Nous mettons à votre disposition un espace moderne, confortable et parfaitement équipé pour faire de chaque événement un succès.",
            textAlign: TextAlign.start,
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _features.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: Responsive.gridColumns(context),
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, index) {
              return _FeatureCard(feature: _features[index]);
            },
          ),
        ],
      ),
    );
  }
}

class _Feature {
  final IconData icon;
  final String title;
  final String description;

  const _Feature(this.icon, this.title, this.description);
}

class _FeatureCard extends StatefulWidget {
  final _Feature feature;

  const _FeatureCard({required this.feature});

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..translateByDouble(0.0, hover ? -8.0 : 0.0, 0.0, 1.0),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: hover
                ? AppTheme.secondary.withValues(alpha: .6)
                : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: hover ? 24 : 10,
              offset: const Offset(0, 10),
              color: Colors.black.withValues(alpha: .08),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppTheme.primary.withValues(alpha: .08),
              child: Icon(
                widget.feature.icon,
                color: AppTheme.primary,
                size: 30,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.feature.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Text(
                widget.feature.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
