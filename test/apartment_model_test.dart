import 'package:flutter_test/flutter_test.dart';
import 'package:beraka_hotel_restaurant/models.dart';

void main() {
  test('creates an apartment from a map with a display price', () {
    final apartment = Apartment.fromMap({
      'id': 'apt-1',
      'title': 'Appartement Deluxe',
      'description': 'Vue sur la ville',
      'price': 250000,
      'image_url': 'https://example.com/apt.jpg',
    });

    expect(apartment.title, 'Appartement Deluxe');
    expect(apartment.description, 'Vue sur la ville');
    expect(apartment.price, 250000);
    expect(apartment.displayPrice, '250 000 \$');
    expect(apartment.imageUrls, ['https://example.com/apt.jpg']);
  });

  test('creates an apartment from a map with multiple image urls', () {
    final jsonArray = '["https://example.com/apt1.jpg", "https://example.com/apt2.jpg"]';
    final apartment = Apartment.fromMap({
      'id': 'apt-2',
      'title': 'Appartement Premium',
      'description': 'Vue sur la mer',
      'price': 300000,
      'image_url': jsonArray,
    });

    expect(apartment.imageUrls, [
      'https://example.com/apt1.jpg',
      'https://example.com/apt2.jpg',
    ]);
    expect(apartment.imageUrl, 'https://example.com/apt1.jpg');
  });
}
