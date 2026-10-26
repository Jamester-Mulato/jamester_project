import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, ghost }

/// Shared action button used by the Login, Home, and Report screens.
///
/// A single component keeps spacing, height, loading feedback, and disabled
/// behavior consistent across the app.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.loadingLabel,
    this.expand = true,
    this.variant = AppButtonVariant.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final String? loadingLabel;
  final bool expand;
  final AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color spinnerColor = variant == AppButtonVariant.primary
        ? colors.onPrimary
        : colors.primary;

    final Widget content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (isLoading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: spinnerColor,
            ),
          )
        else if (icon != null)
          Icon(icon, size: 18),
        if (isLoading || icon != null) const SizedBox(width: 10),
        Flexible(
          child: Text(
            isLoading ? (loadingLabel ?? label) : label,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    final VoidCallback? effectiveOnPressed = isLoading ? null : onPressed;
    const EdgeInsets padding = EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 16,
    );
    final Size minimumSize = Size(expand ? double.infinity : 0, 52);
    final RoundedRectangleBorder shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    );

    switch (variant) {
      case AppButtonVariant.primary:
        return FilledButton(
          onPressed: effectiveOnPressed,
          style: FilledButton.styleFrom(
            minimumSize: minimumSize,
            padding: padding,
            shape: shape,
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
          child: content,
        );
      case AppButtonVariant.secondary:
        return OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: minimumSize,
            padding: padding,
            shape: shape,
            side: BorderSide(color: colors.outline),
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
          child: content,
        );
      case AppButtonVariant.ghost:
        return TextButton(
          onPressed: effectiveOnPressed,
          style: TextButton.styleFrom(
            minimumSize: minimumSize,
            padding: padding,
            shape: shape,
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
          child: content,
        );
    }
  }
}
