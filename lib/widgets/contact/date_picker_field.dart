import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerField extends StatefulWidget {
  const DatePickerField({
    super.key,
    required this.controller,
    this.firstDate,
    this.lastDate,
    this.label = "Date de l'événement",
  });

  final TextEditingController controller;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String label;

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  late final FocusNode _focusNode;
  bool _focused = false;

  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode();

    _focusNode.addListener(() {
      if (mounted) {
        setState(() {
          _focused = _focusNode.hasFocus;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: widget.firstDate ?? now,
      lastDate: widget.lastDate ?? DateTime(now.year + 5),
      helpText: "Choisissez une date",
    );

    if (date != null) {
      widget.controller.text = DateFormat("dd/MM/yyyy").format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
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
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        readOnly: true,
        onTap: _pickDate,
        decoration: InputDecoration(
          labelText: widget.label,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          prefixIcon: Icon(
            Icons.calendar_month_outlined,
            color: _focused
                ? theme.colorScheme.primary
                : Colors.grey,
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.event),
            onPressed: _pickDate,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Veuillez sélectionner une date";
          }
          return null;
        },
      ),
    );
  }
}