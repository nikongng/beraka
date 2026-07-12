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
        _buildBullet('La décoration de la salle.'),
        const SizedBox(height: 8),
        _buildBullet('Le matériel de sonorisation, les services d\'un DJ.'),
        const SizedBox(height: 8),
        _buildBullet('5 protocoles offerts.'),
        const SizedBox(height: 8),
        _buildBullet('Deux agents d\'entretien dédiés au nettoyage des toilettes.'),
      ],
    );

    final servicesColumn2 = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBullet('Un parking intérieur, sécurisé et surveillé.'),
        const SizedBox(height: 8),
        _buildBullet('L\'accès à un espace extérieur pour l\'organisation d\'une cérémonie civile, religieuse ou d\'un cocktail.'),
        const SizedBox(height: 8),
        _buildBullet('L\'entrée de la boisson est gratuite.'),
        const SizedBox(height: 8),
        _buildBullet('Accès au congélateur gratuit.'),
        const SizedBox(height: 8),
        _buildBullet('Droit de bouchon offert.'),
        const SizedBox(height: 8),
        _buildBullet('Générateur inclus.'),
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
                    const Text('Conditions de réservation', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 18),
                    Column(
                      children: [
                        _buildBullet('Exigez une facture après tout paiement.'),
                        const SizedBox(height: 8),
                        _buildBullet('Contresignez le package sélectionné après vérification en y joignant vos numéros de contact.'),
                        const SizedBox(height: 8),
                        _buildBullet('Un dépôt de 50% du montant global du package non remboursable même en cas de désistement est obligatoire afin de garantir votre réservation.'),
                        const SizedBox(height: 8),
                        _buildBullet('Vous êtes tenu de solder la totalité du montant 2 semaines avant l’événement.'),
                        const SizedBox(height: 8),
                        _buildBullet('Un délai butoir unique d’un mois avant la manifestation vous est accordé pour changement des dates.'),
                        const SizedBox(height: 8),
                        _buildBullet('Une caution remboursable de 200 \$ est exigée, garantissant la couverture en cas de perte ou casses.'),
                        const SizedBox(height: 8),
                        _buildBullet('50\$ de frais de mairie.'),
                        const SizedBox(height: 8),
                        _buildBullet('Le prix de base inclut le nombre de vos invités. L’ajout d’une table (10 pers.) se fait moyennant 100\$ /table.'),
                        const SizedBox(height: 8),
                        _buildBullet('La capacité d’accueil pour le mariage civil est de 60 personnes.'),
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