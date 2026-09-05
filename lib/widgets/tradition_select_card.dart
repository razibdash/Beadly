import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/tradition.dart';

/// A selectable card for one tradition on the onboarding / settings screens.
class TraditionSelectCard extends StatelessWidget {
  final Tradition tradition;
  final bool selected;
  final VoidCallback onTap;

  const TraditionSelectCard({
    super.key,
    required this.tradition,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? BeadlyColors.accentRose
                : theme.dividerColor,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: selected ? BeadlyColors.accentGradient : null,
                color: selected ? null : theme.colorScheme.onSurface.withValues(alpha: 0.06),
              ),
              child: Icon(
                tradition.icon,
                color: selected ? Colors.white : theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tradition.label,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    tradition.subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: BeadlyColors.accentRose),
          ],
        ),
      ),
    );
  }
}
