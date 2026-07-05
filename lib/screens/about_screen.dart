import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'À propos',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1, // Léger effet d'ombre au scroll
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800), // Empêche l'étirement sur PC/Tablette
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIntroSection(context),
                const SizedBox(height: 40),
                
                _buildSectionTitle(context, 'Notre mission', Icons.track_changes_rounded),
                const SizedBox(height: 16),
                _buildMissionCard(context),
                
                const SizedBox(height: 40),
                
                _buildSectionTitle(context, 'Nos valeurs', Icons.diamond_rounded),
                const SizedBox(height: 16),
                _buildValuesSection(context),

                const SizedBox(height: 40),

                _buildSectionTitle(context, 'Contact & Réservations', Icons.headset_mic_rounded),
                const SizedBox(height: 16),
                _buildContactCard(context),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntroSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Bienvenue chez\nBeraca's Valley",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            height: 1.2,
            letterSpacing: -0.5,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Beraca\'s Hôtel Restaurant est un établissement chaleureux dédié à la gastronomie locale et internationale. ' 
          'Nous offrons une expérience culinaire de qualité, un service attentionné et un cadre élégant pour toutes vos occasions.',
          style: TextStyle(
            fontSize: 16, 
            height: 1.6,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 28),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildMissionCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: .03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        // Remplacement du gris en dur par outlineVariant
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.wb_sunny_rounded, color: theme.colorScheme.secondary, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              'Offrir un service restaurant et hôtelier authentique, respectueux des traditions locales et des besoins modernes. ' 
              'Créer un lieu où les clients se sentent chez eux, que ce soit pour un dîner romantique, un événement de groupe ou une pause gourmande.',
              style: TextStyle(
                fontSize: 16, 
                height: 1.6,
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValuesSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        _valueItem(
          theme: theme,
          title: 'Qualité', 
          description: 'Des produits frais sélectionnés avec soin et une cuisine maison.',
          icon: Icons.restaurant_menu_rounded,
          color: theme.colorScheme.error,
        ),
        const SizedBox(height: 16),
        _valueItem(
          theme: theme,
          title: 'Hospitalité', 
          description: 'Un accueil chaleureux et un service personnalisé pour chaque client.',
          icon: Icons.volunteer_activism_rounded,
          color: theme.colorScheme.secondary,
        ),
        const SizedBox(height: 16),
        _valueItem(
          theme: theme,
          title: 'Convivialité', 
          description: 'Un cadre confortable pour partager un bon repas en famille ou entre amis.',
          icon: Icons.groups_rounded,
          color: theme.colorScheme.tertiary,
        ),
      ],
    );
  }

  Widget _valueItem({
    required ThemeData theme, 
    required String title, 
    required String description, 
    required IconData icon, 
    required Color color
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        // Remplacement de Colors.grey.shade100 par outlineVariant
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 6),
                Text(
                  description, 
                  // Remplacement de Colors.grey.shade600 par theme.colorScheme.onSurfaceVariant
                  style: TextStyle(fontSize: 15, height: 1.5, color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: .8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: .3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _contactRow(context, Icons.phone_rounded, 'Téléphone', '+243 998 833 016'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: theme.colorScheme.onPrimary.withValues(alpha: .24), height: 1),
          ),
          _contactRow(context, Icons.email_rounded, 'Email', 'beracasvalley@gmail.com'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: theme.colorScheme.onPrimary.withValues(alpha: .24), height: 1),
          ),
          _contactRow(context, Icons.location_on_rounded, 'Adresse', '01, Av. Géomètre Ponga\nPlateau Karavia, Lubumbashi - RDC'),
        ],
      ),
    );
  }

  Widget _contactRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.colorScheme.onPrimary, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: theme.colorScheme.onPrimary.withValues(alpha: .7), fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}