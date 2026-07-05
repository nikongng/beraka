import 'models.dart';

class Pages {
  static const int hallCapacity = 300;

  static final List<Dish> menu = [
    Dish(
      id: 'dish-1',
      name: 'Carpaccio de bœuf',
      category: 'Entrées',
      description: 'Fines tranches de viande, huile d’olive et parmesan.',
      price: 14,
      imageUrl: 'https://via.placeholder.com/120x120?text=Entrée',
    ),
    Dish(
      id: 'dish-2',
      name: 'Soupe de poisson',
      category: 'Entrées',
      description: 'Bouillon parfumé aux herbes fraîches.',
      price: 11,
      imageUrl: 'https://via.placeholder.com/120x120?text=Entrée',
    ),
    Dish(
      id: 'dish-3',
      name: 'Filet de bœuf',
      category: 'Plats',
      description: 'Viande tendre, purée maison et sauce au poivre.',
      price: 28,
      imageUrl: 'https://via.placeholder.com/120x120?text=Plat',
    ),
    Dish(
      id: 'dish-4',
      name: 'Poisson grillé',
      category: 'Plats',
      description: 'Filet du jour grillé au beurre citronné.',
      price: 24,
      imageUrl: 'https://via.placeholder.com/120x120?text=Plat',
    ),
  ];

  static final List<Map<String, dynamic>> reviews = [
    {'author': 'Chloé', 'rating': 5, 'comment': 'Ambiance parfaite et personnel attentionné.'},
    {'author': 'Lucas', 'rating': 4, 'comment': 'Plats délicieux, je recommande la soupe de poisson.'},
  ];

  static final List<Map<String, String>> gallery = [
    {'label': 'Salle', 'image': 'https://via.placeholder.com/360x220?text=Salle'},
    {'label': 'Plats', 'image': 'https://via.placeholder.com/360x220?text=Plats'},
    {'label': 'Boissons', 'image': 'https://via.placeholder.com/360x220?text=Boissons'},
    {'label': 'Ambiance', 'image': 'https://via.placeholder.com/360x220?text=Ambiance'},
    {'label': 'Événement', 'image': 'https://via.placeholder.com/360x220?text=Événement'},
  ];
}
