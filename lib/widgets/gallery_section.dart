import 'package:flutter/material.dart';

import 'package:beraca/responsive/responsive.dart';
import 'package:beraca/theme/app_theme.dart';
import 'package:beraca/widgets/section_title.dart';

import '../models.dart';

class GallerySection extends StatelessWidget {
  final List<GalleryAlbum> albums;

  const GallerySection({
    super.key,
    required this.albums,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            badge: "Galerie",
            title: "Notre galerie",
            subtitle:
                "Découvrez quelques images de notre salle, de nos événements et de nos prestations.",
            textAlign: TextAlign.start,
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: albums.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: Responsive.gridColumns(context),
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              childAspectRatio: 1.25,
            ),
            itemBuilder: (context, index) {
              final album = albums[index];
              return _GalleryCard(album: album);
            },
          ),
        ],
      ),
    );
  }
}

class _GalleryCard extends StatefulWidget {
  final GalleryAlbum album;

  const _GalleryCard({
    required this.album,
  });

  @override
  State<_GalleryCard> createState() => _GalleryCardState();
}

class _GalleryCardState extends State<_GalleryCard> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    final coverUrl = widget.album.coverImageUrl;
    final imageWidget = coverUrl.startsWith("http")
        ? Image.network(
            coverUrl,
            fit: BoxFit.cover,
          )
        : Image.asset(
            coverUrl,
            fit: BoxFit.cover,
          );

    final photoCount = widget.album.photoCount;

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          hover = true;
        });
      },
      onExit: (_) {
        setState(() {
          hover = false;
        });
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 250),
        scale: hover ? 1.03 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                blurRadius: hover ? 28 : 12,
                color: Colors.black12,
                offset: const Offset(0, 12),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Hero(
                    tag: 'gallery_${widget.album.title}_${coverUrl}',
                    child: imageWidget,
                  ),
                ),
                Positioned.fill(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(hover ? .65 : .45),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 20,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.album.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$photoCount photo(s)',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => _GalleryPreviewPage(
                                album: widget.album,
                                tag: 'gallery_${widget.album.title}_${coverUrl}',
                              ),
                              fullscreenDialog: true,
                            ),
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          decoration: BoxDecoration(
                            color: hover ? AppTheme.secondary : Colors.white,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                            color: hover ? Colors.white : AppTheme.primary,
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GalleryPreviewPage extends StatefulWidget {
  final GalleryAlbum album;
  final String tag;

  const _GalleryPreviewPage({required this.album, required this.tag});

  @override
  State<_GalleryPreviewPage> createState() => _GalleryPreviewPageState();
}

class _GalleryPreviewPageState extends State<_GalleryPreviewPage> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.album.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.album.photos.length,
              itemBuilder: (context, index) {
                final photo = widget.album.photos[index];
                final imageWidget = photo.imageUrl.startsWith('http')
                    ? Image.network(photo.imageUrl, fit: BoxFit.contain)
                    : Image.asset(photo.imageUrl, fit: BoxFit.contain);

                return Center(
                  child: index == 0
                      ? Hero(
                          tag: widget.tag,
                          child: InteractiveViewer(
                            panEnabled: true,
                            minScale: 0.5,
                            maxScale: 4.0,
                            child: imageWidget,
                          ),
                        )
                      : InteractiveViewer(
                          panEnabled: true,
                          minScale: 0.5,
                          maxScale: 4.0,
                          child: imageWidget,
                        ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Photo ${_pageController.hasClients ? (_pageController.page?.round() ?? 0) + 1 : 1} sur ${widget.album.photoCount}',
                  style: const TextStyle(color: Colors.white70),
                ),
                TextButton(
                  onPressed: () {
                    final nextPage = (_pageController.page?.round() ?? 0) + 1;
                    if (nextPage < widget.album.photoCount) {
                      _pageController.animateToPage(
                        nextPage,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: const Text('Suivant', style: TextStyle(color: Colors.white)),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
