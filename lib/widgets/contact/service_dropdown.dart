import 'package:flutter/material.dart';

class ServiceDropdown extends StatefulWidget {
  const ServiceDropdown({
    super.key,
    required this.services,
    required this.onChanged,
    this.value,
  });

  final List<String> services;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  State<ServiceDropdown> createState() => _ServiceDropdownState();
}

class _ServiceDropdownState extends State<ServiceDropdown> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Focus(
      onFocusChange: (value) {
        setState(() {
          _focused = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _focused
                ? theme.colorScheme.primary
                : Colors.grey.shade300,
            width: _focused ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _focused
                  ? theme.colorScheme.primary.withValues(alpha: .12)
                  : Colors.black.withValues(alpha: .03),
              blurRadius: _focused ? 18 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: DropdownButtonFormField<String>(
            initialValue: (widget.value != null && widget.services.contains(widget.value)) ? widget.value : null,
            decoration: InputDecoration(
            border: InputBorder.none,
            labelText: "Service souhaité",
            prefixIcon: Icon(
              Icons.room_service_outlined,
              color: _focused
                  ? theme.colorScheme.primary
                  : Colors.grey,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
          ),
          borderRadius: BorderRadius.circular(18),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          isExpanded: true,
          items: widget.services.map((service) {
            return DropdownMenuItem(
              value: service,
              child: Text(service),
            );
          }).toList(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Veuillez sélectionner un service";
            }
            return null;
          },
          onChanged: widget.onChanged,
          ),
        ),
      ),
    );
  }
}