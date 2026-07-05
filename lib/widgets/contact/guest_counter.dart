import 'package:flutter/material.dart';

class GuestCounter extends StatelessWidget {
  const GuestCounter({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 1000,
  });

  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.groups_outlined,
            color: theme.colorScheme.primary,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Nombre d'invités",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "Indiquez une estimation",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          _CounterButton(
            icon: Icons.remove,
            enabled: value > min,
            onPressed: () {
              if (value > min) {
                onChanged(value - 1);
              }
            },
          ),

          Container(
            width: 70,
            alignment: Alignment.center,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: Text(
                "$value",
                key: ValueKey(value),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          _CounterButton(
            icon: Icons.add,
            enabled: value < max,
            onPressed: () {
              if (value < max) {
                onChanged(value + 1);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  const _CounterButton({
    required this.icon,
    required this.onPressed,
    required this.enabled,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled
          ? Theme.of(context).colorScheme.primary
          : Colors.grey.shade300,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: enabled ? onPressed : null,
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(
            icon,
            color: enabled ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }
}