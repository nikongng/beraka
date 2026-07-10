import 'dart:convert';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models.dart';

const _supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://ztcswyewwotyycvbcyhs.supabase.co',
);

const _supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'sb_publishable_HckyHQCOwDc6WAjM48KmUA_XvmPmOk8',
);

void _validateSupabaseConfig() {
  if (_supabaseUrl.isEmpty || _supabaseAnonKey.isEmpty) {
    throw StateError(
      'Supabase configuration is missing. ' 
      'Run Flutter with --dart-define=SUPABASE_URL=... ' 
      '--dart-define=SUPABASE_ANON_KEY=... or set the values in your environment.',
    );
  }

  if (_supabaseUrl.contains('YOUR_SUPABASE_URL') || _supabaseAnonKey.contains('YOUR_SUPABASE_ANON_KEY')) {
    throw StateError(
      'Supabase URL or anon key is still using placeholder values. '
      'Replace them with your real Supabase credentials.',
    );
  }
}

Future<void> initSupabase() async {
  _validateSupabaseConfig();
  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey: _supabaseAnonKey,
  );
}

SupabaseClient get supabase => Supabase.instance.client;

const String _galleryBucket = 'gallery';

List<String> _configuredAdminEmails() {
  const raw = String.fromEnvironment(
    'ADMIN_EMAILS',
    defaultValue: 'admin@beraca.com,beracasvalley@gmail.com',
  );

  return raw
      .split(',')
      .map((email) => email.trim().toLowerCase())
      .where((email) => email.isNotEmpty)
      .toSet()
      .toList();
}

bool currentUserIsAdmin() {
  final user = supabase.auth.currentUser;
  if (user == null) return false;

  final configuredEmails = _configuredAdminEmails();
  final email = user.email?.toLowerCase();
  final metadataEmail = user.userMetadata?['email']?.toString().toLowerCase();
  final metadataRole = user.userMetadata?['role']?.toString().toLowerCase();
  final appMetadataRole = user.appMetadata['role']?.toString().toLowerCase();
  final isAdminFlag = user.userMetadata?['is_admin'] ?? user.appMetadata['is_admin'];

  if (email != null && configuredEmails.contains(email)) return true;
  if (metadataEmail != null && configuredEmails.contains(metadataEmail)) return true;
  if (metadataRole != null && ['admin', 'superadmin', 'administrator', 'owner'].contains(metadataRole)) return true;
  if (appMetadataRole != null && ['admin', 'superadmin', 'administrator', 'owner'].contains(appMetadataRole)) return true;
  if (isAdminFlag is bool && isAdminFlag) return true;

  return false;
}

Future<bool> signInWithEmail(String email, String password) async {
  final response = await supabase.auth.signInWithPassword(
    email: email,
    password: password,
  );

  if (response.session == null && response.user == null) {
    throw 'Impossible de se connecter. Vérifiez l’email et le mot de passe.';
  }

  return response.user != null || response.session != null;
}

Future<void> signOut() async {
  await supabase.auth.signOut();
}

User? currentSupabaseUser() {
  return supabase.auth.currentUser;
}

class SupabaseService {
  static Future<List<Reservation>> fetchReservations() async {
    try {
      final result = await supabase
          .from('reservations')
          .select('*')
          .order('date', ascending: true)
          .execute();

      final data = result.data as List<dynamic>?;
      return (data ?? [])
          .cast<Map<String, dynamic>>()
          .map(Reservation.fromMap)
          .toList();
    } on PostgrestException catch (error) {
      throw error.message;
    }
  }

  static Future<Reservation> createReservation(Reservation reservation) async {
    try {
      final result = await supabase
          .from('reservations')
          .insert(reservation.toMap())
          .select()
          .single()
          .execute();

      final data = result.data;
      if (data == null || data is! Map<String, dynamic>) {
        throw 'Réponse inattendue du serveur.';
      }

      return Reservation.fromMap(data);
    } on PostgrestException catch (error) {
      throw error.message;
    }
  }

  static Future<Reservation> updateReservationStatus(String id, String status) async {
    try {
      final result = await supabase
          .from('reservations')
          .update({'status': status})
          .eq('id', id)
          .select()
          .single()
          .execute();

      final data = result.data;
      if (data == null || data is! Map<String, dynamic>) {
        throw 'Réponse inattendue du serveur.';
      }

      return Reservation.fromMap(data);
    } on PostgrestException catch (error) {
      throw error.message;
    }
  }

  static Future<void> cancelReservation(String id) async {
    try {
      await supabase
          .from('reservations')
          .delete()
          .eq('id', id)
          .execute();
    } on PostgrestException catch (error) {
      throw error.message;
    }
  }

  static Future<List<GalleryPhoto>> fetchGalleryPhotos() async {
    try {
      final result = await supabase
          .from('gallery')
          .select('*')
          .order('created_at', ascending: false)
          .execute();

      final data = result.data as List<dynamic>?;
      return (data ?? [])
          .cast<Map<String, dynamic>>()
          .map(GalleryPhoto.fromMap)
          .toList();
    } on PostgrestException catch (error) {
      throw error.message;
    }
  }

  static Future<void> removeGalleryPhoto(GalleryPhoto photo) async {
    try {
      final imageUrl = photo.imageUrl;
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      final fileName = pathSegments.isNotEmpty ? pathSegments.last : '';
      final storagePath = fileName.isEmpty ? '' : 'uploads/$fileName';

      if (storagePath.isNotEmpty) {
        await supabase.storage.from(_galleryBucket).remove([storagePath]);
      }
      await supabase.from('gallery').delete().eq('id', photo.id).execute();
    } on PostgrestException catch (error) {
      throw error.message;
    }
  }

  static Future<GalleryPhoto> uploadGalleryPhoto(String label, Uint8List bytes, String filename) async {
    try {
      final safeName = filename.replaceAll(RegExp(r'[^A-Za-z0-9_.-]'), '_');
      final filePath = 'uploads/${DateTime.now().millisecondsSinceEpoch}_$safeName';
      final contentType = _guessMimeType(filename);

      await supabase.storage.from(_galleryBucket).uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(contentType: contentType, upsert: true),
          );

      final publicUrl = '$_supabaseUrl/storage/v1/object/public/$_galleryBucket/$filePath';
      final result = await supabase
          .from('gallery')
          .insert({
            'label': label,
            'image_url': publicUrl,
          })
          .select()
          .single()
          .execute();
      return GalleryPhoto.fromMap(result.data as Map<String, dynamic>);
    } on PostgrestException catch (error) {
      throw error.message;
    }
  }

  static Future<String> uploadApartmentImage(Uint8List bytes, String filename) async {
    try {
      final safeName = filename.replaceAll(RegExp(r'[^A-Za-z0-9_.-]'), '_');
      final filePath = 'apartments/${DateTime.now().millisecondsSinceEpoch}_$safeName';
      final contentType = _guessMimeType(filename);

      await supabase.storage.from(_galleryBucket).uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(contentType: contentType, upsert: true),
          );

      return '$_supabaseUrl/storage/v1/object/public/$_galleryBucket/$filePath';
    } on PostgrestException catch (error) {
      throw error.message;
    }
  }

  static String _normalizeCategory(String category) {
    final lower = category.toLowerCase().trim();
    if (lower.contains('mariage')) return 'Mariage';
    if (lower.contains('autres') || lower.contains('cérémonies') || lower.contains('ceremonies')) return 'Autres cérémonies';
    if (lower.contains('extérieur') || lower.contains('exterieur')) return 'Espace extérieur';
    return category.trim();
  }

  static String _normalizePriceText(String priceText) {
    var normalized = priceText.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) return normalized;
    normalized = normalized.replaceAll(RegExp(r'\$'), 'USD');
    normalized = normalized.replaceAll(RegExp(r'(?i)usd'), 'USD');
    normalized = normalized.replaceAll(RegExp(r'\s+USD'), ' USD');
    normalized = normalized.replaceAll(RegExp(r'USD\s+USD'), 'USD');
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
    return normalized;
  }

  static List<String> _parseIncludes(dynamic rawIncludes) {
    final includes = <String>[];
    if (rawIncludes is String && rawIncludes.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawIncludes);
        if (decoded is List) {
          includes.addAll(decoded.cast<String>());
        } else {
          includes.add(rawIncludes);
        }
      } catch (_) {
        includes.add(rawIncludes);
      }
    } else if (rawIncludes is List) {
      includes.addAll(rawIncludes.cast<String>());
    }
    return includes;
  }

  static String _guessMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }

  static Future<List<Dish>> fetchMenu() async {
    final allowed = <String>{'mariage', 'autres_ceremonies', 'exterieur', 'Mariage', 'Autres cérémonies', 'Espace extérieur'};
    final seen = <String>{};

    try {
      final result = await supabase
          .from('menu_packs')
          .select('*')
          .order('title')
          .execute();

      final data = result.data as List<dynamic>?;
      final menuPacks = _mapMenuRows(data, allowed, seen);
      if (menuPacks.isNotEmpty) {
        return menuPacks;
      }
    } catch (_) {
      // ignore and attempt fallback
    }

    try {
      final fallbackResult = await supabase
          .from('menu')
          .select('*')
          .order('name')
          .execute();
      final fallbackData = fallbackResult.data as List<dynamic>?;
      final legacyMenu = _mapMenuRows(fallbackData, allowed, seen);
      if (legacyMenu.isNotEmpty) {
        print('SupabaseService.fetchMenu: loaded fallback legacy menu with ${legacyMenu.length} items');
        return legacyMenu;
      }
    } catch (_) {
      // ignore and use local default fallback
    }

    return _defaultMenuPacks();
  }

  static List<Dish> _mapMenuRows(List<dynamic>? data, Set<String> allowed, Set<String> seen) {
    return (data ?? [])
        .cast<Map<String, dynamic>>()
        .where((m) {
          final rawCategory = (m['default_event_type'] ?? m['category'] ?? m['category_id'] ?? '').toString();
          final category = _normalizeCategory(rawCategory);
          return allowed.contains(category);
        })
        .map((m) {
          final rawCategory = (m['default_event_type'] ?? m['category'] ?? m['category_id'] ?? '').toString();
          final category = _normalizeCategory(rawCategory);
          final priceText = _normalizePriceText(m['price_text']?.toString() ?? '');
          final priceValue = m['price'] is int
              ? m['price'] as int
              : int.tryParse(m['price']?.toString() ?? '0') ?? 0;
          final includes = _parseIncludes(m['includes']);
          return Dish(
            id: m['id']?.toString() ?? '',
            name: m['title']?.toString() ?? m['name']?.toString() ?? '',
            category: category,
            description: m['description']?.toString() ?? '',
            price: priceValue,
            priceText: priceText,
            includes: includes,
            imageUrl: m['image_url']?.toString() ?? '',
          );
        })
        .where((dish) {
          final key = '${dish.category.toLowerCase()}|${dish.name.toLowerCase()}|${dish.price}|${_normalizePriceText(dish.priceText).toLowerCase()}';
          if (seen.contains(key)) {
            return false;
          }
          seen.add(key);
          return true;
        })
        .toList();
  }

  static List<Dish> _defaultMenuPacks() {
    return [
      Dish(
        id: 'mariage_1',
        name: 'Décoration Basique',
        category: 'Mariage',
        description: 'Décoration basique pour mariage avec mise en place standard et ambiance élégante.',
        price: 2500,
        priceText: '2 500 USD',
        includes: [
          'Nappes et housses de chaises assorties',
          'Centres de table simples',
          'Éclairage d’ambiance doux',
          'Décoration de la table d’honneur',
        ],
        imageUrl: 'assets/images/decosimple.jpg',
      ),
      Dish(
        id: 'mariage_2',
        name: 'Décoration Moyenne',
        category: 'Mariage',
        description: 'Décoration moyenne pour mariage avec éléments floraux et mobilier décoratif.',
        price: 3000,
        priceText: '3 000 USD',
        includes: [
          'Tout le pack Basique',
          'Arches florales ou structure de cérémonie',
          'Chemins de table et décorations supplémentaires',
          'Décoration de chaises et signalétique',
        ],
        imageUrl: 'assets/images/decomoyenne.png',
      ),
      Dish(
        id: 'mariage_3',
        name: 'Décoration VIP',
        category: 'Mariage',
        description: 'Décoration VIP pour mariage avec touches luxueuses et mise en scène complète.',
        price: 3500,
        priceText: '3 500 USD',
        includes: [
          'Tout le pack Moyenne',
          'Décoration florale premium',
          'Mobilier lounge et coin photo',
          'Installation personnalisée haut de gamme',
        ],
        imageUrl: 'assets/images/decoluxe.jpg',
      ),
      Dish(
        id: 'autres_1',
        name: 'Réunion, conférence, formation',
        category: 'Autres cérémonies',
        description: 'Pack événementiel pour réunion, conférence ou formation avec matériel de base.',
        price: 250,
        priceText: '250 USD',
        includes: [
          'Tables et chaises pour participants',
          'Matériel de présentation (projecteur, écran)',
          'Sonorisation légère',
          'Aménagement de l’espace et accueil',
        ],
        imageUrl: 'assets/images/conference.jpg',
      ),
      Dish(
        id: 'autres_2',
        name: 'Mariage coutumier (option A)',
        category: 'Autres cérémonies',
        description: 'Formule mariage coutumier pour samedi avec décor traditionnel et espace cérémonial.',
        price: 170,
        priceText: '170 USD',
        includes: [
          'Décoration adaptée aux traditions',
          'Installation de la scène cérémoniale',
          'Coin d’accueil et mobilier décoratif',
          'Éclairage chaleureux',
        ],
        imageUrl: 'assets/images/mariagecoutumier.jpg',
      ),
      Dish(
        id: 'autres_3',
        name: 'Mariage coutumier (option B)',
        category: 'Autres cérémonies',
        description: 'Formule mariage coutumier pour vendredi et dimanche avec décoration simplifiée.',
        price: 150,
        priceText: '150 USD',
        includes: [
          'Décoration traditionnelle légère',
          'Coin cérémonie et tables de réception',
          'Éléments de décoration culturelle',
          'Accueil et signalétique',
        ],
        imageUrl: 'assets/images/mariagecoutumier.jfif',
      ),
      Dish(
        id: 'exterieur_1',
        name: 'Décoration Basique',
        category: 'Espace extérieur',
        description: 'Décoration basique pour espace extérieur avec ambiance naturelle.',
        price: 500,
        priceText: '500 USD',
        includes: [
          'Guirlandes lumineuses et lampions',
          'Mobilier de jardin simple',
          'Décoration de tables et chemins extérieurs',
          'Aménagement d’un espace cocktail',
        ],
        imageUrl: 'assets/images/decoexternebasique.jfif',
      ),
      Dish(
        id: 'exterieur_2',
        name: 'Décoration VIP',
        category: 'Espace extérieur',
        description: 'Décoration VIP pour espace extérieur avec touches festives et élégantes.',
        price: 850,
        priceText: '850 USD',
        includes: [
          'Tout le pack Basique',
          'Décorations fleuries et luminaires premium',
          'Espace lounge extérieur',
          'Aménagement de piste et accueil VIP',
        ],
        imageUrl: 'assets/images/decoexterneluxe.jfif',
      ),
    ];
  }

  static Future<List<Apartment>> fetchApartments() async {
    try {
      final result = await supabase
          .from('apartments')
          .select('*')
          .order('price', ascending: true)
          .execute();
      final data = result.data as List<dynamic>?;
      return (data ?? [])
          .cast<Map<String, dynamic>>()
          .map(Apartment.fromMap)
          .toList();
    } on PostgrestException catch (error) {
      throw error.message;
    }
  }

  static Future<Apartment> addApartment(Apartment apartment) async {
    try {
      final result = await supabase
          .from('apartments')
          .insert(apartment.toMap())
          .select()
          .single()
          .execute();
      return Apartment.fromMap(result.data as Map<String, dynamic>);
    } on PostgrestException catch (error) {
      throw error.message;
    }
  }

  static Future<Apartment> updateApartmentImages(String apartmentId, List<String> imageUrls) async {
    try {
      final result = await supabase
          .from('apartments')
          .update({'image_url': jsonEncode(imageUrls)})
          .eq('id', apartmentId)
          .select()
          .single()
          .execute();
      return Apartment.fromMap(result.data as Map<String, dynamic>);
    } on PostgrestException catch (error) {
      throw error.message;
    }
  }

  static Future<void> removeApartment(String apartmentId) async {
    try {
      await supabase.from('apartments').delete().eq('id', apartmentId).execute();
    } on PostgrestException catch (error) {
      throw error.message;
    }
  }

  static Future<Dish> addMenuItem(Dish dish) async {
    try {
      final result = await supabase
          .from('menu_packs')
          .insert(dish.toMap())
          .select()
          .single()
          .execute();
      return Dish.fromMap(result.data as Map<String, dynamic>);
    } on PostgrestException {
      // Fallback to legacy menu table if menu_packs is unavailable.
    }

    try {
      final result = await supabase
          .from('menu')
          .insert(dish.toMap())
          .select()
          .single()
          .execute();
      return Dish.fromMap(result.data as Map<String, dynamic>);
    } on PostgrestException catch (error) {
      throw error.message;
    }
  }

  static Future<Dish> updateMenuItem(Dish dish) async {
    try {
      final result = await supabase
          .from('menu_packs')
          .update(dish.toMap())
          .eq('id', dish.id)
          .select()
          .single()
          .execute();
      return Dish.fromMap(result.data as Map<String, dynamic>);
    } on PostgrestException {
      // Fallback to legacy menu table if updating menu_packs fails.
    }

    try {
      final result = await supabase
          .from('menu')
          .update(dish.toMap())
          .eq('id', dish.id)
          .select()
          .single()
          .execute();
      return Dish.fromMap(result.data as Map<String, dynamic>);
    } on PostgrestException catch (error) {
      throw error.message;
    }
  }

  static Future<void> removeMenuItem(String dishId) async {
    try {
      final result = await supabase.from('menu_packs').delete().eq('id', dishId).execute();
      final deleted = result.data;
      if (deleted != null && (deleted is List ? deleted.isNotEmpty : true)) {
        return;
      }
    } on PostgrestException {
      // Fallback to legacy menu table if deleting from menu_packs fails.
    }

    try {
      await supabase.from('menu').delete().eq('id', dishId).execute();
    } on PostgrestException catch (error) {
      throw error.message;
    }
  }
}
