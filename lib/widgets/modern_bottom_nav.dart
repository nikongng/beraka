import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ModernBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const ModernBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    {'icon': Icons.home_rounded, 'label': 'Accueil'},
    {'icon': Icons.menu_rounded, 'label': 'Menu'},
    {'icon': Icons.calendar_month_rounded, 'label': 'Je réserve'},
    {'icon': Icons.apartment_rounded, 'label': 'Apparts'},
    {'icon': Icons.support_agent_rounded, 'label': 'Contact'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final desktop = screenWidth >= 1024;
    final isSmallScreen = screenWidth < 380;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: desktop ? 80 : (isSmallScreen ? 10 : 24),
          vertical: 16,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              height: 76,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(35),
                border: Border.all(
                  color: theme.colorScheme.surface.withValues(alpha: 0.6),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(_items.length, (index) {
                  final item = _items[index];
                  final selected = currentIndex == index;

                  if (index == 2) {
                    // Le paramètre "theme" est maintenant passé ici
                    return _buildCenterButton(theme, item, selected, () => onTap(index), isSmallScreen);
                  }

                  // Le paramètre "theme" est maintenant passé ici
                  return _buildStandardItem(theme, item, selected, () => onTap(index), isSmallScreen);
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Ajout de "ThemeData theme" dans les paramètres
  Widget _buildStandardItem(ThemeData theme, Map<String, Object> item, bool selected, VoidCallback onTap, bool isSmallScreen) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutBack,
            padding: EdgeInsets.symmetric(
              horizontal: selected ? (isSmallScreen ? 8 : 12) : 4,
              vertical: selected ? 10 : 8,
            ),
            decoration: BoxDecoration(
              color: selected 
                  ? AppTheme.primary.withValues(alpha: 0.12) 
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: selected ? 1.15 : 1.0,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutBack,
                  child: Icon(
                    item['icon'] as IconData,
                    size: isSmallScreen ? 22 : 24,
                    color: selected
                        ? AppTheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  style: TextStyle(
                    fontSize: selected ? (isSmallScreen ? 11 : 12) : (isSmallScreen ? 10 : 11),
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? AppTheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                    fontFamily: 'Inter',
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      item['label'] as String,
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Ajout de "ThemeData theme" dans les paramètres
  Widget _buildCenterButton(ThemeData theme, Map<String, Object> item, bool selected, VoidCallback onTap, bool isSmallScreen) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 0.0 : 4.0),
        child: AnimatedScale(
          scale: selected ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutBack,
                width: isSmallScreen ? 46 : 52, 
                height: isSmallScreen ? 46 : 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primary.withValues(alpha: 0.8),
                      AppTheme.primary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: theme.colorScheme.onPrimary,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.35),
                      blurRadius: selected ? 10 : 15,
                      offset: Offset(0, selected ? 2 : 5),
                      spreadRadius: selected ? 0 : 2,
                    ),
                  ],
                ),
                child: Icon(
                  item['icon'] as IconData,
                  color: theme.colorScheme.onPrimary,
                  size: isSmallScreen ? 20 : 24,
                ),
              ),
              const SizedBox(height: 2), 
              SizedBox(
                width: isSmallScreen ? 56 : 64,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    item['label'] as String,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 10 : 11,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      color: selected ? AppTheme.primary : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}