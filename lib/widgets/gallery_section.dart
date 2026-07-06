import 'package:flutter/material.dart';

import 'package:beraca/responsive/responsive.dart';
import 'package:beraca/theme/app_theme.dart';
import 'package:beraca/widgets/section_title.dart';

class GallerySection extends StatelessWidget {
  final List<Map<String, String>> items;

  const GallerySection({
    super.key,
    required this.items,
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
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: Responsive.gridColumns(context),
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              childAspectRatio: 1.25,
            ),
            itemBuilder: (context, index) {
              final image = items[index]["image"]!;
              final label = items[index]["label"]!;

              return _GalleryCard(
                image: image,
                label: label,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _GalleryCard extends StatefulWidget {
  final String image;
  final String label;

  const _GalleryCard({
    required this.image,
    required this.label,
  });

  @override
  State<_GalleryCard> createState() => _GalleryCardState();
}

class _GalleryCardState extends State<_GalleryCard> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    final imageWidget = widget.image.startsWith("http")
        ? Image.network(
            widget.image,
            fit: BoxFit.cover,
          )
        : Image.asset(
            widget.image,
            fit: BoxFit.cover,
          );

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
                    tag: "gallery_${widget.label}",
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
                          Colors.black.withValues(alpha: hover ? .65 : .45),
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
                        child: Text(
                          widget.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => _GalleryPreviewPage(
                                image: widget.image,
                                tag: 'gallery_${widget.label}',
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

class _GalleryPreviewPage extends StatelessWidget {
  final String image;
  final String tag;

  const _GalleryPreviewPage({required this.image, required this.tag});

  @override
  Widget build(BuildContext context) {
    final imageWidget = image.startsWith('http')
        ? Image.network(image, fit: BoxFit.contain)
        : Image.asset(image, fit: BoxFit.contain);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Hero(
          tag: tag,
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 0.5,
            maxScale: 4.0,
            child: imageWidget,
          ),
        ),
      ),
    );
  }
}
