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
  List<GalleryAlbum> _galleryAlbums = [];
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
          _galleryAlbums = GalleryAlbum.groupByTitle(photos);
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

  List<GalleryAlbum> get galleryItems {
    if (_galleryAlbums.isEmpty) {
      return [
        GalleryAlbum(
          title: 'Salle de réception',
          photos: [
            GalleryPhoto(
              id: 'fallback_1',
              label: 'Salle de réception',
              imageUrl: 'assets/images/gallery1.jpg',
              createdAt: DateTime.now(),
            ),
          ],
        ),
        GalleryAlbum(
          title: 'Restaurant',
          photos: [
            GalleryPhoto(
              id: 'fallback_2',
              label: 'Restaurant',
              imageUrl: 'assets/images/gallery2.jpg',
              createdAt: DateTime.now(),
            ),
          ],
        ),
        GalleryAlbum(
          title: 'Mariage',
          photos: [
            GalleryPhoto(
              id: 'fallback_3',
              label: 'Mariage',
              imageUrl: 'assets/images/gallery3.jpg',
              createdAt: DateTime.now(),
            ),
          ],
        ),
      ];
    }

    return _galleryAlbums;
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
        const SliverToBoxAdapter(
          child: AnimatedSection(
            delay: 120,
            child: InfoPanels(),
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
                    albums: galleryItems,
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
