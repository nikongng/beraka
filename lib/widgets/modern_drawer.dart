import 'package:flutter/material.dart';

import 'package:beraca/theme/app_theme.dart';

class ModernDrawer extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onNavigate;

  const ModernDrawer({
    super.key,
    required this.currentIndex,
    required this.onNavigate,
  });

  static const _menus = [
    ("Accueil", Icons.home_rounded),
    ("Menu", Icons.menu_rounded),
    ("Appartements", Icons.apartment_rounded),
    ("Mes réservations", Icons.history_rounded),
    ("Contact", Icons.call_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      elevation: 0,
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [

            //==========================
            // HEADER
            //==========================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [

                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.hotel_rounded,
                      color: AppTheme.primary,
                      size: 38,
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    "BERACA'S",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    "Hôtel • Restaurant",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _menus.length,
                itemBuilder: (context, index) {
                  final selected = currentIndex == index;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      leading: Icon(
                        _menus[index].$2,
                        color: selected
                            ? Colors.white
                            : AppTheme.primary,
                      ),
                      title: Text(
                        _menus[index].$1,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? Colors.white
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      tileColor: selected
                          ? AppTheme.primary
                          : Colors.transparent,
                      onTap: () {
                        Navigator.pop(context);
                        onNavigate(index);
                      },
                    ),
                  );
                },
              ),
            ),

            const Divider(),

            ListTile(
              leading: const Icon(
                Icons.phone_rounded,
                color: AppTheme.primary,
              ),
              title: const Text("+243 998 833 016"),
              subtitle: const Text("Réception"),
            ),

            ListTile(
              leading: const Icon(
                Icons.location_on_rounded,
                color: AppTheme.primary,
              ),
              title: const Text("Lubumbashi"),
              subtitle: const Text("RDC"),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Text(
                "Version 1.0.0",
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
