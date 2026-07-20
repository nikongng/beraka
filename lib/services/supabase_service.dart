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
      final data = await supabase
          .from('reservations')
          .select('*')
          .order('date', ascending: true);

      return (data as List<dynamic>)
          .map((e) => Reservation.fromMap(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (error) {
      throw error.message;
    }
  }

  static Future<Reservation> createReservation(Reservation reservation) async {
    try {
      final data = await supabase
          .from('reservations')
          .insert(reservation.toMap())
          .select()
          .single();

      return Reservation.fromMap(data as Map<String, dynamic>);
    } on PostgrestException catch (error) {
      throw error.message;
    }
  }

  static Future<Reservation> updateReservationStatus(String id, String status) async {
    try {
      final data = await supabase
          .from('reservations')
          .update({'status': status})
          .eq('id', id)
          .select()
          .single();

      return Reservation.fromMap(data as Map<String, dynamic>);
    } on PostgrestException catch (error) {
      throw error.message;
    }
  }

  static Future<void> cancelReservation(String id) async {
    try {
      await supabase.from('reservations').delete().eq('id', id);
    } on PostgrestException catch (error) {
      throw error.message;
    }
  }

  static Future<List<GalleryPhoto>> fetchGalleryPhotos() async {
    try {
      final data = await supabase
          .from('gallery')
          .select('*')
          .order('created_at', ascending: false);

      return (data as List<dynamic>)
          .map((e) => GalleryPhoto.fromMap(e as Map<String, dynamic>))
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
      await supabase.from('gallery').delete().eq('id', photo.id);
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
      final data = await supabase
          .from('gallery')
          .insert({
            'label': label,
            'image_url': publicUrl,
          })
          .select()
          .single();
      return GalleryPhoto.fromMap(data as Map<String, dynamic>);
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

  static Future<String> uploadMenuImage(Uint8List bytes, String filename) async {
    try {
      final safeName = filename.replaceAll(RegExp(r'[^A-Za-z0-9_.-]'), '_');
      final filePath = 'menu_packs/${DateTime.now().millisecondsSinceEpoch}_$safeName';
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

  static Future<List<Dish>> fetchMenu() async {
    final seen = <String>{};

    try {
      final data = await supabase
          .from('menu_packs')
          .select('*')
          .order('title');

      return _mapMenuRows(data as List<dynamic>, seen);
    } on PostgrestException catch (error) {
      print('Erreur Supabase lors du chargement du menu: ${error.message}');
      throw error.message;
    } catch (e) {
      print('Erreur inattendue fetchMenu: $e');
      return []; 
    }
  }

  // Paged fetch for admin screens
  static Future<List<Dish>> fetchMenuPaged({int from = 0, int limit = 20}) async {
    final seen = <String>{};
    try {
      final data = await supabase
          .from('menu_packs')
          .select('*')
          .order('title')
          .range(from, from + limit - 1);

      return _mapMenuRows(data as List<dynamic>, seen);
    } on PostgrestException catch (error) {
      print('Erreur Supabase lors du chargement du menu (paged): ${error.message}');
      throw error.message;
    } catch (e) {
      print('Erreur inattendue fetchMenuPaged: $e');
      return [];
    }
  }

  static List<Dish> _mapMenuRows(List<dynamic> data, Set<String> seen) {
    return data
        .cast<Map<String, dynamic>>()
        .map((m) {
          final rawCategory = (m['default_event_type'] ?? m['category_id'] ?? '').toString();
          final category = _normalizeCategory(rawCategory);
          final priceText = _normalizePriceText(m['price_text']?.toString() ?? '');
          final priceValue = m['price'] is int
              ? m['price'] as int
              : int.tryParse(m['price']?.toString() ?? '0') ?? 0;
            final saturdayPrice = m['saturday_price'] is int
              ? m['saturday_price'] as int
              : int.tryParse(m['saturday_price']?.toString() ?? '0') ?? 0;
            final friSunPrice = m['fri_sun_price'] is int
              ? m['fri_sun_price'] as int
              : int.tryParse(m['fri_sun_price']?.toString() ?? '0') ?? 0;
          final includes = _parseIncludes(m['includes']);
          return Dish(
            id: m['id']?.toString() ?? '',
            name: m['title']?.toString() ?? m['name']?.toString() ?? '',
            category: category,
            categoryId: m['category_id']?.toString() ?? '',
            defaultEventType: m['default_event_type']?.toString() ?? '',
            tag: m['tag']?.toString() ?? '',
            priceNote: m['price_note']?.toString() ?? '',
            defaultMenuPack: m['default_menu_pack']?.toString() ?? '',
            premium: m['premium'] is bool
                ? m['premium'] as bool
                : m['premium'] is int
                    ? m['premium'] != 0
                    : m['premium']?.toString().toLowerCase() == 'true',
            description: m['description']?.toString() ?? '',
            price: priceValue,
            saturdayPrice: saturdayPrice,
            friSunPrice: friSunPrice,
            priceVarious: m['price_various'] is bool
                ? m['price_various'] as bool
                : (m['price_various'] is int ? (m['price_various'] as int) != 0 : (m['price_various']?.toString().toLowerCase() == 'true')),
            priceText: priceText,
            includes: includes,
            imageUrl: m['image_url']?.toString() ?? '',
          );
        })
        .where((dish) {
          final key = '${dish.category.toLowerCase()}|${dish.name.toLowerCase()}|${dish.price}|${_normalizePriceText(dish.priceText).toLowerCase()}';
          if (seen.contains(key)) return false;
          seen.add(key);
          return true;
        })
        .toList();
  }

  static String _normalizeCategory(String category) {
    final lower = category.toLowerCase().trim();
    if (lower.contains('mariage')) return 'Mariage';
    if (lower.contains('traiteur')) return 'Services traiteurs'; // <-- AJOUTER
    if (lower.contains('autres') || lower.contains('cérémonies') || lower.contains('ceremonies')) return 'Autres cérémonies';
    if (lower.contains('cocktail') || lower.contains('cocktails')) return 'Cocktail';
    if (lower.contains('extérieur') || lower.contains('exterieur')) return 'Espace extérieur';
    return category.trim();
  }

  static String _normalizePriceText(String priceText) {
    var normalized = priceText.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) return normalized;
    normalized = normalized.replaceAll(RegExp(r'\$'), 'USD');
    normalized = normalized.replaceAll(RegExp(r'usd', caseSensitive: false), 'USD');
    normalized = normalized.replaceAll(RegExp(r'\s+USD'), ' USD');
    normalized = normalized.replaceAll(RegExp(r'USD\s+USD'), 'USD');
    return normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
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
      case 'jpg': case 'jpeg': return 'image/jpeg';
      case 'png': return 'image/png';
      case 'gif': return 'image/gif';
      case 'webp': return 'image/webp';
      default: return 'application/octet-stream';
    }
  }

  static Future<List<Apartment>> fetchApartments() async {
    try {
      final data = await supabase
          .from('apartments')
          .select('*')
          .order('price', ascending: true);
      return (data as List<dynamic>)
          .map((e) => Apartment.fromMap(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (error) {
      throw error.message;
    }
  }

  static Future<List<Apartment>> fetchApartmentsPaged({int from = 0, int limit = 20}) async {
    try {
      final data = await supabase
          .from('apartments')
          .select('*')
          .order('price', ascending: true)
          .range(from, from + limit - 1);
      return (data as List<dynamic>)
          .map((e) => Apartment.fromMap(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (error) {
      throw error.message;
    }
  }

  static Future<List<GalleryPhoto>> fetchGalleryPhotosPaged({int from = 0, int limit = 30}) async {
    try {
      final data = await supabase
          .from('gallery')
          .select('*')
          .order('created_at', ascending: false)
          .range(from, from + limit - 1);

      return (data as List<dynamic>)
          .map((e) => GalleryPhoto.fromMap(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (error) {
      throw error.message;
    }
  }

  static Future<List<Reservation>> fetchReservationsPaged({int from = 0, int limit = 20}) async {
    try {
      final data = await supabase
          .from('reservations')
          .select('*')
          .order('date', ascending: true)
          .range(from, from + limit - 1);

      return (data as List<dynamic>)
          .map((e) => Reservation.fromMap(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (error) {
      throw error.message;
    }
  }

  static Future<Apartment> addApartment(Apartment apartment) async {
    try {
      final data = await supabase
          .from('apartments')
          .insert(apartment.toMap())
          .select()
          .single();
      return Apartment.fromMap(data as Map<String, dynamic>);
    } on PostgrestException catch (error) {
      throw error.message;
    }
  }

  static Future<Apartment> updateApartmentImages(String apartmentId, List<String> imageUrls) async {
    try {
      final data = await supabase
          .from('apartments')
          .update({'image_url': jsonEncode(imageUrls)})
          .eq('id', apartmentId)
          .select()
          .single();
      return Apartment.fromMap(data as Map<String, dynamic>);
    } on PostgrestException catch (error) {
      throw error.message;
    }
  }

  static Future<Apartment> updateApartment(Apartment apartment) async {
    try {
      final data = await supabase
          .from('apartments')
          .update(apartment.toMap())
          .eq('id', apartment.id)
          .select()
          .single();
      return Apartment.fromMap(data as Map<String, dynamic>);
    } on PostgrestException catch (error) {
      throw error.message;
    }
  }

  static Future<void> removeApartment(String apartmentId) async {
    try {
      await supabase.from('apartments').delete().eq('id', apartmentId);
    } on PostgrestException catch (error) {
      throw error.message;
    }
  }

  static Future<Dish> addMenuItem(Dish dish) async {
    try {
      final data = await supabase
          .from('menu_packs')
          .insert(dish.toMap())
          .select()
          .single();
      return Dish.fromMap(data as Map<String, dynamic>);
    } on PostgrestException catch (error) {
      throw error.message;
    }
  }

  static Future<Dish> updateMenuItem(Dish dish) async {
    try {
      final data = await supabase
          .from('menu_packs')
          .update(dish.toMap())
          .eq('id', dish.id)
          .select()
          .single();
      return Dish.fromMap(data as Map<String, dynamic>);
    } on PostgrestException catch (error) {
      throw error.message;
    }
  }

  static Future<void> removeMenuItem(String dishId) async {
    try {
      await supabase.from('menu_packs').delete().eq('id', dishId);
    } on PostgrestException catch (error) {
      throw error.message;
    }
  }
}