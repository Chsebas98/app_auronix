import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:auronix_app/features/home/domain/entities/fare_estimate.dart';
import 'package:auronix_app/features/home/domain/entities/route_info.dart';
import 'package:auronix_app/shared/atoms/buttons/app_button.dart';
import 'package:auronix_app/shared/atoms/skeleton/app_skeleton_box.dart';
import 'package:auronix_app/shared/atoms/spacing/app_spacing.dart';
import 'package:auronix_app/shared/atoms/text/app_text.dart';
import 'package:flutter/material.dart';

/// Tarjeta con el resumen de la ruta (T21): distancia, duracion estimada y
/// tarifa aproximada, con skeleton mientras se calcula, estado de error con
/// reintento y el boton de confirmacion principal.
class FareEstimateCard extends StatelessWidget {
  const FareEstimateCard({
    required this.onConfirm,
    this.routeInfo,
    this.fareEstimate,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
    super.key,
  });

  final RouteInfo? routeInfo;
  final FareEstimate? fareEstimate;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final VoidCallback onConfirm;

  bool get _isReady =>
      !isLoading &&
      errorMessage == null &&
      routeInfo != null &&
      fareEstimate != null;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.mapCardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (errorMessage != null)
            _ErrorState(message: errorMessage!, onRetry: onRetry)
          else if (isLoading)
            const _LoadingState()
          else
            _MetricsRow(routeInfo: routeInfo, fareEstimate: fareEstimate),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            key: const Key('fare_estimate_card_confirm_button'),
            label: 'Confirmar ruta',
            variant: AppButtonVariant.filled,
            expand: true,
            isDisabled: !_isReady,
            onPressed: _isReady ? onConfirm : null,
          ),
        ],
      ),
    );
  }
}

class _MetricsRow extends StatelessWidget {
  const _MetricsRow({required this.routeInfo, required this.fareEstimate});

  final RouteInfo? routeInfo;
  final FareEstimate? fareEstimate;

  @override
  Widget build(BuildContext context) {
    final distanceKm = (routeInfo?.distanceMeters ?? 0) / 1000;
    final durationMin = ((routeInfo?.durationSeconds ?? 0) / 60).round();
    final price = fareEstimate?.estimatedPrice;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _Metric(
          icon: Icons.straighten_rounded,
          value: '${distanceKm.toStringAsFixed(1)} km',
          label: 'Distancia',
        ),
        _Metric(
          icon: Icons.access_time_rounded,
          value: '$durationMin min',
          label: 'Tiempo est.',
        ),
        _Metric(
          icon: Icons.attach_money_rounded,
          value: price != null ? '\$${price.toStringAsFixed(2)}' : '--',
          label: 'Precio est.',
          highlight: true,
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.value,
    required this.label,
    this.highlight = false,
  });

  final IconData icon;
  final String value;
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final color = highlight ? colors.button : colors.text;

    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: AppSpacing.xs),
        AppText(
          value,
          variant: AppTextVariant.labelMedium,
          color: color,
          fontWeight: FontWeight.w700,
        ),
        AppText(
          label,
          variant: AppTextVariant.labelSmall,
          color: colors.textSecondary,
        ),
      ],
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        AppSkeletonBox(width: 56, height: 36),
        AppSkeletonBox(width: 56, height: 36),
        AppSkeletonBox(width: 56, height: 36),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.red),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: AppText(
                message,
                variant: AppTextVariant.bodySmall,
                color: colors.text,
              ),
            ),
          ],
        ),
        if (onRetry != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              key: const Key('fare_estimate_card_retry_button'),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const AppText(
                'Reintentar',
                variant: AppTextVariant.bodySmall,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
