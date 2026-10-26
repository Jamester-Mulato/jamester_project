import 'package:flutter/material.dart';

enum StatusPanelTone { success, error, empty, info }

/// Reusable response panel for Success, Empty, Error, and informational states.
///
/// The report screen uses it for all non-loading outcomes, which keeps the
/// icon, heading, message, and action layout consistent.
class StatusPanel extends StatelessWidget {
  const StatusPanel({
    super.key,
    required this.tone,
    required this.icon,
    required this.title,
    required this.message,
    this.eyebrow,
    this.child,
    this.primaryAction,
    this.secondaryAction,
  });

  final StatusPanelTone tone;
  final IconData icon;
  final String title;
  final String message;
  final String? eyebrow;
  final Widget? child;
  final Widget? primaryAction;
  final Widget? secondaryAction;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    final (Color accent, Color tint) = switch (tone) {
      StatusPanelTone.success => (
        const Color(0xFF15803D),
        const Color(0xFFECFDF3),
      ),
      StatusPanelTone.error => (
        colors.error,
        colors.errorContainer.withValues(alpha: 0.55),
      ),
      StatusPanelTone.empty => (
        const Color(0xFFB45309),
        const Color(0xFFFFFBEB),
      ),
      StatusPanelTone.info => (
        colors.primary,
        colors.primaryContainer.withValues(alpha: 0.45),
      ),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: accent.withValues(alpha: 0.22)),
              ),
              child: Icon(icon, color: accent, size: 30),
            ),
            const SizedBox(height: 20),
            if (eyebrow != null)
              Text(
                eyebrow!.toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
            if (eyebrow != null) const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.55,
              ),
            ),
            if (child != null) ...<Widget>[const SizedBox(height: 22), child!],
            if (primaryAction != null || secondaryAction != null) ...<Widget>[
              const SizedBox(height: 26),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[?primaryAction, ?secondaryAction],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
