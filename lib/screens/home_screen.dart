import 'package:flutter/material.dart';

import '../models.dart';
import '../services/supabase_service.dart';

import '../widgets/animated_section.dart';
import '../widgets/footer_section.dart';
import '../widgets/gallery_section.dart';
import '../widgets/hero_section.dart';
import '../widgets/calendar_panel.dart';
import '../widgets/info_panels.dart';

class HomeScreen extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onNavigate;
  final List<Reservation> reservations;

  const HomeScreen({
    super.key,
    required this.currentIndex,
    required this.onNavigate,
    this.reservations = const [],
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<GalleryPhoto> _galleryPhotos = [];
  bool _galleryLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGallery();
  }

  Future<void> _loadGallery() async {
    try {
      final photos = await SupabaseService.fetchGalleryPhotos();

      if (mounted) {
        setState(() {
          _galleryPhotos = photos;
        });
      }
    } catch (_) {
      debugPrint("Erreur chargement galerie");
    } finally {
      if (mounted) {
        setState(() {
          _galleryLoading = false;
        });
      }
    }
  }

  List<Map<String, String>> get galleryItems {
    if (_galleryPhotos.isEmpty) {
      return const [
        {
          "image": "assets/images/gallery1.jpg",
          "label": "Salle de réception",
        },
        {
          "image": "assets/images/gallery2.jpg",
          "label": "Restaurant",
        },
        {
          "image": "assets/images/gallery3.jpg",
          "label": "Mariage",
        },
      ];
    }

    return _galleryPhotos
        .map(
          (photo) => {
            "image": photo.imageUrl,
            "label": photo.label,
          },
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: HeroSection(
            onReservation: () => widget.onNavigate(2),
            onMenu: () => widget.onNavigate(1),
          ),
        ),
        SliverToBoxAdapter(
          child: AnimatedSection(
            delay: 80,
            child: CalendarPanel(reservations: widget.reservations),
          ),
        ),
        SliverToBoxAdapter(
          child: AnimatedSection(
            delay: 120,
            child: const InfoPanels(),
          ),
        ),
        SliverToBoxAdapter(
          child: AnimatedSection(
            delay: 300,
            child: _galleryLoading
                ? const Padding(
                    padding: EdgeInsets.all(80),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : GallerySection(
                    items: galleryItems,
                  ),
          ),
        ),
        const SliverToBoxAdapter(
          child: AnimatedSection(
            delay: 400,
            child: FooterSection(),
          ),
        ),
      ],
    );
  }
}
