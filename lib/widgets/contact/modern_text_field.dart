import 'package:flutter/material.dart';

class ModernTextField extends StatefulWidget {
  const ModernTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.suffix,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffix;

  @override
  State<ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<ModernTextField> {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
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
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        validator: widget.validator,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        maxLines: widget.maxLines,
        readOnly: widget.readOnly,
        onTap: widget.onTap,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,

          prefixIcon: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            child: Icon(
              widget.icon,
              color: _focused
                  ? theme.colorScheme.primary
                  : Colors.grey,
            ),
          ),

          suffixIcon: widget.suffix,

          floatingLabelStyle: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),

          border: InputBorder.none,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
        ),
      ),
    );
  }
}