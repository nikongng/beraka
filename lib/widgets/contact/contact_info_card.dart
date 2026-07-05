import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

enum ContactType {
  phone,
  email,
  address,
}

class ContactInfoCard extends StatefulWidget {
  const ContactInfoCard({
    super.key,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
    required this.color,
    this.onPrimaryAction,
    this.onSecondaryAction,
  });

  final ContactType type;

  final String title;
  final String subtitle;

  /// numéro, email ou adresse
  final String value;

  final IconData icon;
  final Color color;

  final VoidCallback? onPrimaryAction;
  final VoidCallback? onSecondaryAction;

  @override
  State<ContactInfoCard> createState() => _ContactInfoCardState();
}

class _ContactInfoCardState extends State<ContactInfoCard> {
  bool _hover = false;

  String get _primaryButtonText {
    switch (widget.type) {
      case ContactType.phone:
        return "Appeler";

      case ContactType.email:
        return "Envoyer";

      case ContactType.address:
        return "Itinéraire";
    }
  }

  IconData get _primaryIcon {
    switch (widget.type) {
      case ContactType.phone:
        return Icons.call;

      case ContactType.email:
        return Icons.email_outlined;

      case ContactType.address:
        return Icons.navigation;
    }
  }

  String get _secondaryButtonText {
    switch (widget.type) {
      case ContactType.phone:
        return "WhatsApp";

      case ContactType.email:
        return "Copier";

      case ContactType.address:
        return "Carte";
    }
  }

  IconData get _secondaryIcon {
    switch (widget.type) {
      case ContactType.phone:
        return Icons.chat;

      case ContactType.email:
        return Icons.copy;

      case ContactType.address:
        return Icons.map_outlined;
    }
  }

  IconData get _valueIcon {
    switch (widget.type) {
      case ContactType.phone:
        return Icons.phone;

      case ContactType.email:
        return Icons.email;

      case ContactType.address:
        return Icons.place;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Future<void> _defaultPrimaryAction() async {
      late final Uri uri;
      switch (widget.type) {
        case ContactType.phone:
          uri = Uri.parse('tel:${widget.value}');
          break;
        case ContactType.email:
          uri = Uri.parse('mailto:${widget.value}');
          break;
        case ContactType.address:
          uri = Uri.parse(
              'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(widget.value)}');
          break;
      }
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Impossible d’ouvrir l’action de contact.')),
        );
      }
    }

    Future<void> _defaultSecondaryAction() async {
      switch (widget.type) {
        case ContactType.phone:
          final uri = Uri.parse(
              'https://wa.me/${widget.value.replaceAll(RegExp(r'[^0-9]'), '')}');
          if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Impossible d’ouvrir WhatsApp.')),
            );
          }
          break;
        case ContactType.email:
          await Clipboard.setData(ClipboardData(text: widget.value));
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Adresse email copiée.')),
          );
          break;
        case ContactType.address:
          final uri = Uri.parse(
              'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(widget.value)}');
          if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Impossible d’ouvrir la carte.')),
            );
          }
          break;
      }
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..translate(
            0.0,
            _hover ? -6.0 : 0.0,
          ),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _hover
                ? widget.color.withValues(alpha: .35)
                : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _hover ? .12 : .05),
              blurRadius: _hover ? 22 : 10,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.color,
                      size: 30,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.verified,
                    color: Colors.green.shade600,
                    size: 22,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                widget.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _valueIcon,
                      color: widget.color,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.value,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed:
                          widget.onPrimaryAction ?? _defaultPrimaryAction,
                      icon: Icon(_primaryIcon),
                      label: Text(_primaryButtonText),
                      style: FilledButton.styleFrom(
                        backgroundColor: widget.color,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          widget.onSecondaryAction ?? _defaultSecondaryAction,
                      icon: Icon(_secondaryIcon),
                      label: Text(_secondaryButtonText),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: widget.color,
                        side: BorderSide(color: widget.color),
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
