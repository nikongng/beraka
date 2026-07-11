import 'dart:convert';

import 'package:flutter/material.dart';

class Dish {
  final String id;
  final String category;
  final String name;
  final String categoryId;
  final String defaultEventType;
  final String tag;
  final String priceNote;
  final String defaultMenuPack;
  final bool premium;
  final String description;
  final int price;
  final String priceText;
  final List<String> includes;
  final String imageUrl;

  Dish({
    required this.id,
    required this.category,
    required this.name,
    this.categoryId = '',
    this.defaultEventType = '',
    this.tag = '',
    this.priceNote = '',
    this.defaultMenuPack = '',
    this.premium = false,
    required this.description,
    required this.price,
    this.priceText = '',
    this.includes = const [],
    required this.imageUrl,
  });

  factory Dish.fromMap(Map<String, dynamic> map) {
    final rawIncludes = map['includes'];
    final includes = <String>[];
    if (rawIncludes is String && rawIncludes.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawIncludes);
        if (decoded is List) {
          includes.addAll(decoded.cast<String>());
        }
      } catch (_) {
        includes.add(rawIncludes);
      }
    } else if (rawIncludes is List) {
      includes.addAll(rawIncludes.cast<String>());
    }

    final rawCategory = (map['default_event_type'] ?? map['category_id'] ?? map['category'] ?? '').toString();
    return Dish(
      id: map['id']?.toString() ?? '',
      category: _normalizeCategory(rawCategory),
      name: map['title']?.toString() ?? map['name']?.toString() ?? '',
      categoryId: map['category_id']?.toString() ?? '',
      defaultEventType: map['default_event_type']?.toString() ?? '',
      tag: map['tag']?.toString() ?? '',
      priceNote: map['price_note']?.toString() ?? '',
      defaultMenuPack: map['default_menu_pack']?.toString() ?? '',
      premium: map['premium'] is bool
          ? map['premium'] as bool
          : map['premium'] is int
              ? map['premium'] != 0
              : map['premium']?.toString().toLowerCase() == 'true',
      description: map['description']?.toString() ?? '',
      price: map['price'] is int
          ? map['price'] as int
          : int.tryParse(map['price']?.toString() ?? '0') ?? 0,
      priceText: map['price_text']?.toString() ?? '',
      includes: includes,
      imageUrl: map['image_url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    final data = {
      if (id.isNotEmpty) 'id': id,
      'title': name,
      'description': description,
      'price': price,
      'price_text': priceText,
      'includes': includes,
      'image_url': imageUrl,
      if (categoryId.isNotEmpty) 'category_id': categoryId,
      if (tag.isNotEmpty) 'tag': tag,
      if (priceNote.isNotEmpty) 'price_note': priceNote,
      'premium': premium,
      if (defaultMenuPack.isNotEmpty) 'default_menu_pack': defaultMenuPack,
      if (defaultEventType.isNotEmpty) 'default_event_type': defaultEventType,
    };
    return data;
  }

  static String _normalizeCategory(String category) {
    final lower = category.toLowerCase().trim();
    if (lower.contains('mariage')) return 'Mariage';
    if (lower.contains('traiteur') || lower.contains('traiteurs')) return 'Services traiteurs';
    if (lower.contains('cocktail') || lower.contains('cocktails')) return 'Cocktail';
    if (lower.contains('autres') || lower.contains('cérémonies') || lower.contains('ceremonies')) return 'Autres cérémonies';
    if (lower.contains('extérieur') || lower.contains('exterieur')) return 'Espace extérieur';
    return category.trim();
  }
}

class Reservation {
  final String id;
  final String guestName;
  final String phone;
  final String email;
  final DateTime date;
  final TimeOfDay time;
  final int guests;
  final String eventType;
  final String menuPack;
  final String note;
  final String status;

  bool get isConfirmed => status.toLowerCase().contains('confirm');
  bool get isPending => status.toLowerCase().contains('attent');
  bool get isCancelled => status.toLowerCase().contains('annul') || status.toLowerCase().contains('refus');

  Reservation({
    required this.id,
    required this.guestName,
    required this.phone,
    required this.email,
    required this.date,
    required this.time,
    required this.guests,
    this.eventType = '',
    this.menuPack = '',
    required this.note,
    required this.status,
  });

  factory Reservation.fromMap(Map<String, dynamic> map) {
    final dateValue = map['date'];
    final timeValue = map['time']?.toString() ?? '19:00';
    final parsedTime = timeValue.split(':');
    return Reservation(
      id: map['id']?.toString() ?? '',
      guestName: map['guest_name']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      date: dateValue is String
          ? DateTime.tryParse(dateValue) ?? DateTime.now()
          : dateValue is DateTime
              ? dateValue
              : DateTime.now(),
      time: TimeOfDay(
        hour: parsedTime.isNotEmpty ? int.tryParse(parsedTime[0]) ?? 19 : 19,
        minute: parsedTime.length > 1 ? int.tryParse(parsedTime[1]) ?? 0 : 0,
      ),
      guests: map['guests'] is int
          ? map['guests'] as int
          : int.tryParse(map['guests']?.toString() ?? '1') ?? 1,
      eventType: map['event_type']?.toString() ?? '',
      menuPack: map['menu_pack']?.toString() ?? '',
      note: map['note']?.toString() ?? '',
      status: map['status']?.toString() ?? 'Confirmée',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'guest_name': guestName,
      'phone': phone,
      'email': email,
      'date': date.toIso8601String(),
      'time': '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      'guests': guests,
      if (eventType.isNotEmpty) 'event_type': eventType,
      if (menuPack.isNotEmpty) 'menu_pack': menuPack,
      'note': note,
      'status': status,
    };
  }
}
class Apartment {
  final String id;
  final String title;
  final String description;
  final int price;
  final List<String> imageUrls;

  Apartment({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrls,
  });

  String get imageUrl => imageUrls.isNotEmpty ? imageUrls.first : '';

  String get displayPrice => '${price.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ' ')} \$';

  factory Apartment.fromMap(Map<String, dynamic> map) {
    final rawImage = map['image_url'];
    final imageUrls = <String>[];

    if (rawImage is String && rawImage.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawImage);
        if (decoded is List) {
          imageUrls.addAll(decoded.cast<String>());
        } else if (decoded is String) {
          imageUrls.add(decoded);
        }
      } catch (_) {
        imageUrls.add(rawImage);
      }
    } else if (rawImage is List) {
      imageUrls.addAll(rawImage.cast<String>());
    }

    return Apartment(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      price: map['price'] is int
          ? map['price'] as int
          : int.tryParse(map['price']?.toString() ?? '0') ?? 0,
      imageUrls: imageUrls,
    );
  }

  Map<String, dynamic> toMap() {
    final data = {
      'title': title,
      'description': description,
      'price': price,
      'image_url': jsonEncode(imageUrls),
    };

    if (id.isNotEmpty) {
      data['id'] = id;
    }

    return data;
  }
}

class GalleryPhoto {
  final String id;
  final String label;
  final String imageUrl;
  final DateTime createdAt;

  GalleryPhoto({
    required this.id,
    required this.label,
    required this.imageUrl,
    required this.createdAt,
  });

  factory GalleryPhoto.fromMap(Map<String, dynamic> map) {
    final createdAtValue = map['created_at'];
    return GalleryPhoto(
      id: map['id']?.toString() ?? '',
      label: map['label']?.toString() ?? '',
      imageUrl: map['image_url']?.toString() ?? '',
      createdAt: createdAtValue is String
          ? DateTime.tryParse(createdAtValue) ?? DateTime.now()
          : createdAtValue is DateTime
              ? createdAtValue
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'image_url': imageUrl,
    };
  }
}

class GalleryAlbum {
  final String title;
  final List<GalleryPhoto> photos;

  GalleryAlbum({
    required this.title,
    required this.photos,
  });

  String get coverImageUrl => photos.first.imageUrl;
  int get photoCount => photos.length;

  static List<GalleryAlbum> groupByTitle(List<GalleryPhoto> photos) {
    final grouped = <String, List<GalleryPhoto>>{};

    for (final photo in photos) {
      final title = photo.label.trim().isEmpty ? 'Sans titre' : photo.label.trim();
      grouped.putIfAbsent(title, () => []).add(photo);
    }

    final albums = grouped.entries.map((entry) {
      final groupedPhotos = List<GalleryPhoto>.from(entry.value);
      groupedPhotos.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return GalleryAlbum(title: entry.key, photos: groupedPhotos);
    }).toList();

    albums.sort((a, b) => b.photos.first.createdAt.compareTo(a.photos.first.createdAt));
    return albums;
  }
}

