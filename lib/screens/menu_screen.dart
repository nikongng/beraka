import 'package:flutter/material.dart';

import 'package:beraca/responsive/responsive.dart';
import 'package:beraca/theme/app_theme.dart';
import '../models.dart';
import '../services/supabase_service.dart';
import 'reservation_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  bool _isLoading = true;
  List<Dish> _menuItems = [];
  List<String> _categories = ['Tous'];
  String _selectedCategory = 'Tous';

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
  }

  Future<void> _loadMenuItems() async {
    try {
      final items = await SupabaseService.fetchMenu();
      setState(() {
        _menuItems = items;
        _categories = const ['Tous', 'Mariage', 'Autres cérémonies', 'Espace extérieur', 'Services traiteurs', 'Cocktail'];
        _selectedCategory = _categories.first;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Dish> get _visiblePackages {
    if (_selectedCategory == 'Tous') {
      return _menuItems;
    }
    return _menuItems.where((item) => item.category == _selectedCategory).toList();
  }

  void _showPackageDialog(Dish menuItem) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          elevation: 24,
          shadowColor: Colors.black.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: SizedBox(
            width: Responsive.isDesktop(context) ? 900 : double.infinity,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Responsive.isDesktop(context)
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: AspectRatio(
                                aspectRatio: 4 / 3,
                                child: _buildPackageImage(menuItem),
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 2,
                            child: _PackageDialogContent(
                              menuItem: menuItem,
                              dialogContext: dialogContext,
                              onReserve: () => _navigateToReservation(menuItem, dialogContext),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: SizedBox(
                              width: double.infinity,
                              height: 220,
                              child: _buildPackageImage(menuItem),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _PackageDialogContent(
                            menuItem: menuItem,
                            dialogContext: dialogContext,
                            onReserve: () => _navigateToReservation(menuItem, dialogContext),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPackageImage(Dish menuItem) {
    final imageUrl = menuItem.imageUrl.trim();
    if (imageUrl.isEmpty) {
      return Container(color: AppTheme.lightBackground);
    }

    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(color: AppTheme.lightBackground),
      );
    }

    return Image.asset(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(color: AppTheme.lightBackground),
    );
  }

  void _navigateToReservation(Dish menuItem, BuildContext dialogContext) {
    Navigator.of(dialogContext).pop();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ReservationScreen(
        onSubmit: (reservation) async {
          await SupabaseService.createReservation(reservation);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Réservation créée.')),
            );
          }
        },
        initialMenuPack: menuItem.name,
        initialEventType: menuItem.category,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: false,
              backgroundColor: Theme.of(context).colorScheme.surface,
              elevation: 0.5,
              centerTitle: true,
              title: Text(
                'Nos Menus',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
              ),
              iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CategorySelector(
                      categories: _categories,
                      selectedCategory: _selectedCategory,
                      onChanged: (value) => setState(() => _selectedCategory = value),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: _isLoading
                  ? const SliverToBoxAdapter(
                      child: SizedBox(
                        height: 240,
                        child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
                      ),
                    )
                  : _menuItems.isEmpty
                      ? SliverToBoxAdapter(
                          child: SizedBox(
                            height: 240,
                            child: Center(
                              child: Text(
                                'Aucun menu disponible pour le moment.',
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                              ),
                            ),
                          ),
                        )
                      : _ModernPackageGrid(
                          packages: _visiblePackages,
                          onView: _showPackageDialog,
                        ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 40),
            ),
          ],
        ),
      ),
    );
  }
}

class _PackageDialogContent extends StatelessWidget {
  const _PackageDialogContent({
    required this.menuItem,
    required this.dialogContext,
    required this.onReserve,
  });

  final Dish menuItem;
  final BuildContext dialogContext;
  final VoidCallback onReserve;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                menuItem.name,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.secondary.withValues(alpha: .16),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                menuItem.category.isEmpty ? 'Menu' : menuItem.category,
                style: const TextStyle(
                  color: AppTheme.secondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          menuItem.priceText.isNotEmpty
              ? menuItem.priceText
              : '${menuItem.price.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ' ')} USD',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.primary),
        ),
        const SizedBox(height: 14),
        Text(
          menuItem.description,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        if (menuItem.includes.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            'Services inclus :',
            style: TextStyle(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 10),
          ...menuItem.includes.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Fermer'),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              onPressed: onReserve,
              child: const Text('Réserver', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ],
    );
  }
}

class _ModernPackageGrid extends StatelessWidget {
  const _ModernPackageGrid({
    required this.packages,
    required this.onView,
  });

  final List<Dish> packages;
  final ValueChanged<Dish> onView;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cross = width > 1200 ? 3 : (width > 800 ? 2 : 1);
    final aspect = width > 1200 ? 3.2 : (width > 800 ? 3.0 : 2.5);

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cross,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: aspect,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return _PackageCard(package: packages[index], onView: onView);
        },
        childCount: packages.length,
      ),
    );
  }
}

class _PackageCard extends StatefulWidget {
  const _PackageCard({
    required this.package,
    required this.onView,
  });

  final Dish package;
  final ValueChanged<Dish> onView;

  @override
  State<_PackageCard> createState() => _PackageCardState();
}

class _PackageCardState extends State<_PackageCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final package = widget.package;
    const accent = AppTheme.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..translate(0.0, _hover ? -6.0 : 0.0, 0.0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _hover ? accent.withValues(alpha: .55) : Theme.of(context).colorScheme.outline,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _hover ? .08 : .03),
              blurRadius: _hover ? 20 : 10,
              offset: Offset(0, _hover ? 10 : 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    package.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    package.category,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  package.priceText.isNotEmpty
                      ? package.priceText
                      : '${package.price.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ' ')} USD',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: accent),
                ),
                const SizedBox(height: 6),
                IconButton(
                  onPressed: () => widget.onView(package),
                  icon: const Icon(Icons.remove_red_eye_rounded),
                  tooltip: 'Voir',
                  color: accent.withValues(alpha: 0.8),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({
    required this.categories,
    required this.selectedCategory,
    required this.onChanged,
  });

  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: categories.map((category) {
        final selected = selectedCategory == category;
        return ChoiceChip(
          label: Text(category),
          selected: selected,
          selectedColor: AppTheme.primary,
          backgroundColor: Colors.white,
          side: BorderSide(
            color: selected ? AppTheme.primary : AppTheme.primary.withValues(alpha: .16),
          ),
          labelStyle: TextStyle(
            color: selected ? Colors.white : AppTheme.lightText,
            fontWeight: FontWeight.w700,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          onSelected: (_) => onChanged(category),
        );
      }).toList(),
    );
  }
}
