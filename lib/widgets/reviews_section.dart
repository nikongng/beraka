import 'package:flutter/material.dart';

import 'package:beraka_hotel_restaurant/responsive/responsive.dart';
import 'package:beraka_hotel_restaurant/theme/app_theme.dart';
import 'package:beraka_hotel_restaurant/widgets/section_title.dart';

class ReviewsSection extends StatelessWidget {
  const ReviewsSection({super.key});

  static const List<_Review> _reviews = [
    _Review(
      name: "Jean M.",
      role: "Mariage",
      rating: 5,
      comment:
          "Une salle magnifique, un personnel accueillant et une organisation parfaite. Je recommande vivement.",
    ),
    _Review(
      name: "Sarah K.",
      role: "Anniversaire",
      rating: 5,
      comment:
          "Le service est exceptionnel, la nourriture délicieuse et le cadre très élégant.",
    ),
    _Review(
      name: "Patrick L.",
      role: "Conférence",
      rating: 5,
      comment:
          "Excellent accueil, matériel de qualité et salle parfaitement adaptée à nos besoins.",
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
              badge: "Témoignages",
              title: "Ce que disent nos clients",
              subtitle:
                  "La satisfaction de nos clients est notre plus grande récompense.",
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _reviews.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: Responsive.gridColumns(context),
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: 1.05,
              ),
              itemBuilder: (_, index) {
                return _ReviewCard(review: _reviews[index]);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Review {
  final String name;
  final String role;
  final int rating;
  final String comment;

  const _Review({
    required this.name,
    required this.role,
    required this.rating,
    required this.comment,
  });
}

class _ReviewCard extends StatefulWidget {
  final _Review review;

  const _ReviewCard({
    required this.review,
  });

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard> {
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
          boxShadow: [
            BoxShadow(
              blurRadius: hover ? 30 : 12,
              color: Colors.black.withValues(alpha: .08),
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(
                widget.review.rating,
                (_) => const Icon(
                  Icons.star_rounded,
                  color: Colors.amber,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Text(
                '"${widget.review.comment}"',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const Divider(height: 32),
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.primary,
                  child: Text(
                    widget.review.name[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.review.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.review.role,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
