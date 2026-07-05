import 'package:flutter/material.dart';

import 'package:beraka_hotel_restaurant/responsive/responsive.dart';
import 'package:beraka_hotel_restaurant/theme/app_theme.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mobile = Responsive.isMobile(context);

    return Container(
      margin: const EdgeInsets.only(top: 80),
      width: double.infinity,
      color: AppTheme.darkBackground,
      child: ResponsiveContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 60,
          ),
          child: Column(
            children: [
              Wrap(
                spacing: 60,
                runSpacing: 40,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 320,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "BERACA'S VALLEY",
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 26,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          "Une salle de réception moderne destinée à accueillir vos mariages, conférences, anniversaires et événements privés dans un cadre prestigieux.",
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const _FooterColumn(
                    title: "Navigation",
                    items: [
                      "Accueil",
                      "Menu",
                      "Réserver",
                      "Mes réservations",
                      "Contact",
                    ],
                  ),
                  const _FooterColumn(
                    title: "Informations",
                    items: [
                      "Parking sécurisé",
                      "Service sur mesure",
                      "Salle climatisée",
                      "Restaurant",
                    ],
                  ),
                  SizedBox(
                    width: 260,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Contact",
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _contact(Icons.phone, "+243 998 833 016"),
                        _contact(Icons.email, "beracasvalley@gmail.com"),
                        _contact(Icons.location_on, "Lubumbashi, RDC"),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              Divider(
                color: theme.colorScheme.onPrimary.withValues(alpha: .08),
              ),
              const SizedBox(height: 25),
              mobile
                  ? Column(
                      children: [
                        Text(
                          "© 2026 BERACA'S VALLEY",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _Social(Icons.facebook),
                            SizedBox(width: 12),
                            _Social(Icons.camera_alt),
                            SizedBox(width: 12),
                            _Social(Icons.chat),
                          ],
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Text(
                          "© 2026 BERACA'S VALLEY",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const Spacer(),
                        const _Social(Icons.facebook),
                        const SizedBox(width: 12),
                        const _Social(Icons.camera_alt),
                        const SizedBox(width: 12),
                        const _Social(Icons.chat),
                      ],
                    )
            ],
          ),
        ),
      ),
    );
  }

  Widget _contact(
    IconData icon,
    String text,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.secondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey.shade400,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _FooterColumn extends StatelessWidget {
  final String title;
  final List<String> items;

  const _FooterColumn({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    // Récupération du thème
    final theme = Theme.of(context);

    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 20),
          ...items.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                e,
                style: TextStyle(
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _Social extends StatelessWidget {
  final IconData icon;

  const _Social(this.icon);

  @override
  Widget build(BuildContext context) {
    // Récupération du thème
    final theme = Theme.of(context);

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: theme.colorScheme.onPrimary.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Icon(
        icon,
        color: theme.colorScheme.onPrimary,
      ),
    );
  }
}