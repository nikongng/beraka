import 'package:flutter_test/flutter_test.dart';
import 'package:beraka_hotel_restaurant/widgets/visitor_assistant.dart';

void main() {
  test('builds a capacity reply with a cost estimate for a guest count', () {
    final reply = buildCapacityReply(
      request: 'Pour 80 personnes, combien ça coûte ?',
      maxCapacity: 300,
      perGuestBasePrice: 15.0,
      packageFlatPriceNumeric: {
        'Pack Basique': 2500.0,
        'Pack VIP': 3500.0,
      },
      asksPrice: true,
    );

    expect(reply, isNotNull);
    expect(reply, contains('80'));
    expect(reply, contains('300'));
    expect(reply, contains('1 200\$'));
    expect(reply, contains('Pack Basique'));
  });

  test('understands a hundred guests phrase', () {
    final reply = buildCapacityReply(
      request: 'Pour une centaine de personnes, quel est le prix ?',
      maxCapacity: 300,
      perGuestBasePrice: 15.0,
      packageFlatPriceNumeric: {
        'Pack Basique': 2500.0,
      },
      asksPrice: true,
    );

    expect(reply, isNotNull);
    expect(reply, contains('100'));
    expect(reply, contains('1 500\$'));
  });
}
