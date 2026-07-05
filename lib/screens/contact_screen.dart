import 'package:flutter/material.dart';

import '../widgets/contact/contact_form.dart';
import '../widgets/contact/contact_info_card.dart';
import '../widgets/contact/google_map_card.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 1000;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 32,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1300,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Header
                /// Informations de contact
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: [
                    ContactInfoCard(
                      type: ContactType.phone,
                      icon: Icons.location_city_rounded,
                      color: theme.colorScheme.primary,
                      title: "Location d'espace",
                      subtitle:
                          "Réservez nos salles pour vos mariages, conférences, anniversaires et autres événements.",
                      value: "+243 998 833 016",
                    ),

                    ContactInfoCard(
                      type: ContactType.phone,
                      icon: Icons.chair_alt_rounded,
                      color: theme.colorScheme.secondary,
                      title: "Décoration",
                      subtitle:
                          "Une décoration élégante et personnalisée pour sublimer votre événement.",
                      value: "+243 898 344 713",
                    ),

                    ContactInfoCard(
                      type: ContactType.phone,
                      icon: Icons.restaurant_rounded,
                      color: theme.colorScheme.tertiary,
                      title: "Service traiteur",
                      subtitle:
                          "Des menus variés et un service professionnel pour toutes vos réceptions.",
                      value: "+243 810 360 156",
                    ),

                    ContactInfoCard(
                      type: ContactType.email,
                      icon: Icons.email_rounded,
                      color: theme.colorScheme.error,
                      title: "Adresse e-mail",
                      subtitle:
                          "Envoyez-nous votre demande ou vos questions à tout moment.",
                      value: "beracasvalley@gmail.com",
                    ),

                    ContactInfoCard(
                      type: ContactType.address,
                      icon: Icons.location_on_rounded,
                      color: theme.colorScheme.primaryContainer,
                      title: "Notre adresse",
                      subtitle:
                          "Retrouvez facilement Beraca's Valley à Lubumbashi.",
                      value:
                          "01, Avenue Géomètre Ponga\nPlateau Karavia\nRéférence : Cercle Hippique\nLubumbashi - RDC",
                    ),
                  ],
                ),

                const SizedBox(height: 60),

                /// Formulaire + Carte
                if (isDesktop)
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: ContactForm(),
                      ),
                      SizedBox(width: 30),
                      Expanded(
                        flex: 4,
                        child: GoogleMapCard(),
                      ),
                    ],
                  )
                else
                  const Column(
                    children: [
                      ContactForm(),
                      SizedBox(height: 32),
                      GoogleMapCard(),
                    ],
                  ),

                const SizedBox(height: 60),

                Center(
                  child: Text(
                    "Nous vous répondrons dans les meilleurs délais.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}