import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class GoogleMapCard extends StatelessWidget {
  const GoogleMapCard({super.key});

  /// Coordonnées exactes de Beraca's Valley
  static const LatLng _location = LatLng(
    -11.663987426444498,
    27.434273788134824,
  );

  static const String _address = '''
01, Avenue Géomètre Ponga
Plateau Karavia
Référence : Cercle Hippique
Lubumbashi - RDC
''';

  Future<void> _openGoogleMaps() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${_location.latitude},${_location.longitude}',
    );

    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception("Impossible d'ouvrir Google Maps.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 8,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// ===============================
          /// HEADER
          /// ===============================
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primaryContainer,
                ],
              ),
            ),
            child: Row(
              children: [

                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .18),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 30,
                  ),
                ),

                const SizedBox(width: 18),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Text(
                        "Notre localisation",
                        style: theme.textTheme.titleLarge
                            ?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        "Retrouvez facilement Beraca's Valley",
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// ===============================
          /// MAP
          /// ===============================
          SizedBox(
            height: 360,
            child: FlutterMap(
              options: const MapOptions(
                initialCenter: _location,
                initialZoom: 17.5,
                minZoom: 5,
                maxZoom: 19,
              ),

              children: [

                TileLayer(
                  urlTemplate:
                      "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png",

                  subdomains: const [
                    'a',
                    'b',
                    'c',
                    'd'
                  ],

                  userAgentPackageName:
                      "com.beracasvalley.app",
                ),

                MarkerLayer(
                  markers: [                    Marker(
                      point: _location,
                      width: 170,
                      height: 90,
                      alignment: Alignment.topCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: .20),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Text(
                              "Beraca's Valley",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 42,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Beraca's Valley",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.place_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _address,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Ouvert tous les jours • 09h00 à 23h00",
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: _openGoogleMaps,
                      icon: const Icon(Icons.directions),
                      label: const Text("Itinéraire"),
                    ),
                    OutlinedButton.icon(
                      onPressed: _openGoogleMaps,
                      icon: const Icon(Icons.map_outlined),
                      label: const Text("Google Maps"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}