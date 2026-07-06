import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:beraca/responsive/responsive.dart';
import 'package:beraca/theme/app_theme.dart';


class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentIndex;
  final ValueChanged<int> onNavigate;
  final VoidCallback? onAbout;
  final VoidCallback? onAdmin;

  const ModernAppBar({
    super.key,
    required this.currentIndex,
    required this.onNavigate,
    this.onAbout,
    this.onAdmin,
  });

  @override
  Size get preferredSize => const Size.fromHeight(82);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final desktop = Responsive.isDesktop(context);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 20,
          sigmaY: 20,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: .82),
            border: Border(
              bottom: BorderSide(
                color: theme.dividerColor.withValues(alpha: .20),
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: ResponsiveContainer(
              child: SizedBox(
                height: 82,
                child: Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => onNavigate(0),
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "BERACA'S VALLEY",
                                style: theme.textTheme.titleLarge,
                              ),
                         ],
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (desktop && (onAbout != null || onAdmin != null))
                      const SizedBox(width: 8),
                    if (desktop && onAbout != null)
                      _HeaderIconButton(
                        icon: Icons.info_outline_rounded,
                        tooltip: "À propos",
                        onPressed: onAbout!,
                      ),
                    if (desktop && onAdmin != null)
                      _HeaderIconButton(
                        icon: Icons.admin_panel_settings_outlined,
                        tooltip: "Administration",
                        onPressed: onAdmin!,
                      ),
                    if (!desktop && (onAbout != null || onAdmin != null))
                      PopupMenuButton<String>(
                        tooltip: "Actions",
                        icon: const Icon(Icons.more_vert_rounded),
                        onSelected: (value) {
                          if (value == "about") {
                            onAbout?.call();
                          }
                          if (value == "admin") {
                            onAdmin?.call();
                          }
                        },
                        itemBuilder: (context) => [
                          if (onAbout != null)
                            const PopupMenuItem(
                              value: "about",
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline_rounded),
                                  SizedBox(width: 12),
                                  Text("À propos"),
                                ],
                              ),
                            ),
                          if (onAdmin != null)
                            const PopupMenuItem(
                              value: "admin",
                              child: Row(
                                children: [
                                  Icon(Icons.admin_panel_settings_outlined),
                                  SizedBox(width: 12),
                                  Text("Administration"),
                                ],
                              ),
                            ),
                        ],
                      ),
                    if (!desktop)
                      Builder(
                        builder: (context) {
                          return IconButton(
                            tooltip: "Menu",
                            icon: const Icon(
                              Icons.menu_rounded,
                              size: 30,
                            ),
                            onPressed: () {
                              Scaffold.of(context).openEndDrawer();
                            },
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        foregroundColor: AppTheme.primary,
        backgroundColor: AppTheme.primary.withValues(alpha: .08),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: widget.selected
              ? AppTheme.primary
              : hover
                  ? AppTheme.primary.withValues(alpha: .08)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 14,
            ),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  size: 18,
                  color: widget.selected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: widget.selected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
