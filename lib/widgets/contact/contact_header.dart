import 'package:flutter/material.dart';

class ContactHeader extends StatelessWidget {
  const ContactHeader({
    super.key,
    this.height = 340,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: height,
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          /// Image de fond
          Image.asset(
            'assets/images/contact_header.jpg',
            fit: BoxFit.cover,
          ),

          /// Overlay sombre
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: .20),
                  Colors.black.withValues(alpha: .55),
                  Colors.black.withValues(alpha: .82),
                ],
              ),
            ),
          ),

          /// Contenu
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .18),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Text(
                    "Nous sommes à votre écoute",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  "Contactez\nBeraca's Valley",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),

                const SizedBox(height: 14),

                const SizedBox(
                  width: 520,
                  child: Text(
                    "Notre équipe est disponible pour répondre à toutes vos questions, préparer votre réservation et vous accompagner dans l'organisation de votre événement.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                FilledButton.icon(
                  onPressed: () {
                    // Scroll vers le formulaire
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text("Demander un devis"),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}