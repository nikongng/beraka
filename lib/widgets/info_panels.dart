import 'package:flutter/material.dart';

class InfoPanels extends StatelessWidget {
  const InfoPanels({super.key});

  Widget _buildBullet(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 4, right: 8),
          child: Icon(Icons.check, size: 16, color: Color(0xFFB78C1E)),
        ),
        Expanded(child: Text(text)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Détection de la taille de l'écran (mobile si < 800px)
    final isMobile = MediaQuery.of(context).size.width < 800;

    // On extrait les deux listes de services pour rendre le code plus propre
    final servicesColumn1 = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBullet('Un appartement mis à disposition pour une nuit, exclusivement pour les mariés.'),
        const SizedBox(height: 8),
        _buildBullet('Le matériel de sonorisation, les services d\'un DJ.'),
        const SizedBox(height: 8),
        _buildBullet('Deux agents d\'entretien dédiés au nettoyage des toilettes.'),
        const SizedBox(height: 8),
        _buildBullet('L\'accès à un espace extérieur pour une cérémonie civile ou cocktail.'),
      ],
    );

    final servicesColumn2 = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBullet('La décoration de la salle.'),
        const SizedBox(height: 8),
        _buildBullet('Les serveurs pour le service de la boisson.'),
        const SizedBox(height: 8),
        _buildBullet('Un parking intérieur, sécurisé et surveillé.'),
        const SizedBox(height: 8),
        _buildBullet('Droit de bouchon offert.'),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        children: [
          // Carte 1 : Services Inclus
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Container(
                // Sur mobile, on réduit un peu le padding pour gagner de la place
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 28, vertical: 28),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 12, offset: const Offset(0, 6)),
                  ],
                ),
                child: Column(
                  children: [
                    const Text('Services Inclus ou Offerts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 18),
                    // CONDITION RESPONSIVE ICI
                    isMobile
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              servicesColumn1,
                              const SizedBox(height: 8), // Espacement entre les deux listes sur mobile
                              servicesColumn2,
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: servicesColumn1),
                              const SizedBox(width: 20),
                              Expanded(child: servicesColumn2),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Carte 2 : Conditions de Réservation
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 28, vertical: 28),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 12, offset: const Offset(0, 6)),
                  ],
                ),
                child: Column(
                  children: [
                    const Text('Conditions de Réservation', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 18),
                    Column(
                      children: [
                        _buildBullet('Un acompte de 1.000 \$ est requis pour bloquer la réservation.'),
                        const SizedBox(height: 8),
                        _buildBullet('Versement d\'une caution de 50\$ remboursable en cas de perte ou casse.'),
                        const SizedBox(height: 8),
                        _buildBullet('50\$ de frais de mairie.'),
                        const SizedBox(height: 8),
                        _buildBullet('Le prix de base inclut de 1 à 300 personnes. Tables supplémentaires facturées.'),
                        const SizedBox(height: 8),
                        _buildBullet('La capacité maximale est de 300 personnes.'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}