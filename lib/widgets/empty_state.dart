import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback? onActionPressed;
  final String? actionLabel;

  const EmptyState({
    super.key,
    required this.message,
    required this.icon,
    this.onActionPressed,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ).animate()
              .fadeIn(duration: const Duration(milliseconds: 600))
              .scale(delay: const Duration(milliseconds: 200)),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ).animate()
              .fadeIn(delay: const Duration(milliseconds: 300), duration: const Duration(milliseconds: 600)),
            if (onActionPressed != null && actionLabel != null) ...[
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onActionPressed,
                child: Text(actionLabel!),
              ).animate()
                .fadeIn(delay: const Duration(milliseconds: 600), duration: const Duration(milliseconds: 600))
                .slideY(begin: 0.2, end: 0),
            ],
          ],
        ),
      ),
    );
  }
}