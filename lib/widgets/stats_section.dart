import 'package:flutter/material.dart';

import 'package:beraka_hotel_restaurant/responsive/responsive.dart';
import 'package:beraka_hotel_restaurant/theme/app_theme.dart';
import 'package:beraka_hotel_restaurant/widgets/section_title.dart';

class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  static const List<_StatItem> _stats = [
    _StatItem(
      icon: Icons.people_alt_rounded,
      value: "500+",
      title: "Invités",
      subtitle: "Capacité maximale",
    ),
    _StatItem(
      icon: Icons.celebration_rounded,
      value: "350+",
      title: "Événements",
      subtitle: "Organisés avec succès",
    ),
    _StatItem(
      icon: Icons.star_rounded,
      value: "4.9",
      title: "Note",
      subtitle: "Satisfaction client",
    ),
    _StatItem(
      icon: Icons.support_agent_rounded,
      value: "24/7",
      title: "Support",
      subtitle: "Toujours disponible",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ResponsiveContainer(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: Responsive.sectionSpacing(context),
        ),
        child: Column(
          children: [
            const SectionTitle(
              badge: "Chiffres clés",
              title: "Pourquoi nos clients nous font confiance",
              subtitle:
                  "Chaque événement est préparé avec le plus grand soin afin d'offrir une expérience exceptionnelle.",
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = Responsive.gridColumns(context);

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _stats.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                    childAspectRatio: 1.2,
                  ),
                  itemBuilder: (_, index) {
                    return _StatCard(stat: _stats[index]);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem {
  final IconData icon;
  final String value;
  final String title;
  final String subtitle;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.title,
    required this.subtitle,
  });
}

class _StatCard extends StatefulWidget {
  final _StatItem stat;

  const _StatCard({
    required this.stat,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
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
                ? AppTheme.primary.withValues(alpha: .30)
                : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: hover ? .12 : .05,
              ),
              blurRadius: hover ? 30 : 12,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: AppTheme.primary.withValues(alpha: .08),
              child: Icon(
                widget.stat.icon,
                color: AppTheme.primary,
                size: 34,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              widget.stat.value,
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.stat.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                widget.stat.subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
                softWrap: true,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
