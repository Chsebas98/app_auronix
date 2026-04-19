import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:auronix_app/shared/atoms/spacing/app_spacing.dart';
import 'package:auronix_app/shared/atoms/text/app_text.dart';
import 'package:flutter/material.dart';

enum AppButtonVariant { filled, outlined }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.filled,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.expand = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final Widget? icon;
  final bool isLoading;
  final bool isDisabled;

  /// true → ocupa todo el ancho disponible
  final bool expand;

  bool get _isInteractive => !isDisabled && !isLoading;

  @override
  Widget build(BuildContext context) {
    final child = _buildChild(context);

    final button = switch (variant) {
      AppButtonVariant.filled => _buildFilled(child),
      AppButtonVariant.outlined => _buildOutlined(context, child),
    };

    if (expand) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }

  // ── Filled ─────────────────────────────────────────────────────────────────

  Widget _buildFilled(Widget child) {
    return FilledButton(
      onPressed: _isInteractive ? onPressed : null,
      child: child,
    );
  }

  // ── Outlined ───────────────────────────────────────────────────────────────

  Widget _buildOutlined(BuildContext context, Widget child) {
    return OutlinedButton(
      onPressed: _isInteractive ? onPressed : null,
      child: child,
    );
  }

  // ── Child (label + icon + loading) ─────────────────────────────────────────

  Widget _buildChild(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator.adaptive(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(context.appColors.text),
        ),
      );
    }

    if (icon == null) {
      return AppText(label, variant: AppTextVariant.labelLarge);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon!,
        SizedBox(width: AppSpacing.x2),
        AppText(label, variant: AppTextVariant.labelLarge),
      ],
    );
  }
}
