import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:auronix_app/features/trips/domain/models/request/trip_request.dart';
import 'package:auronix_app/features/trips/presentation/molecules/driver/trip_request_info.dart';
import 'package:auronix_app/shared/atoms/buttons/app_button.dart';
import 'package:auronix_app/shared/atoms/text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TripRequestBottomCard extends StatelessWidget {
  const TripRequestBottomCard({
    required this.request,
    required this.onAccept,
    required this.onReject,
    this.isLoading = false,
    super.key,
  });

  final TripRequest request;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final cardBg = context.appColors.mapCardBg;
    final textColor = context.appColors.text;
    final mutedColor = context.appColors.textSecondary;

    return Container(
      margin: EdgeInsets.all(12.r),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ────────────────────────────────────────────────────
          Row(
            children: [
              AppText(
                request.clientName,
                variant: AppTextVariant.titleSmall,
                color: textColor,
                fontWeight: FontWeight.w700,
              ),
              8.horizontalSpace,
              Icon(Icons.star_rounded, color: AppColors.third, size: 16.r),
              4.horizontalSpace,
              AppText(
                request.clientRating.toStringAsFixed(1),
                variant: AppTextVariant.bodySmall,
                color: textColor,
              ),
              const Spacer(),
              AppText(
                '${request.distanceKm} km',
                variant: AppTextVariant.bodySmall,
                color: mutedColor,
              ),
            ],
          ),
          12.verticalSpace,

          // ── Origen / Destino ──────────────────────────────────────────
          TripRequestInfoRow(
            label: 'Origen:',
            address: request.originAddress,
            eta: request.originEta,
          ),
          6.verticalSpace,
          TripRequestInfoRow(
            label: 'Destino:',
            address: request.destinationAddress,
            eta: request.destinationEta,
          ),
          8.verticalSpace,

          // ── Tarifa ───────────────────────────────────────────────────
          Row(
            children: [
              AppText(
                'Tarifa Est.: ',
                variant: AppTextVariant.bodySmall,
                color: mutedColor,
              ),
              AppText(
                '\$${request.estimatedFare.toStringAsFixed(2)}',
                variant: AppTextVariant.bodyMedium,
                color: AppColors.third,
                fontWeight: FontWeight.w700,
              ),
            ],
          ),
          16.verticalSpace,

          // ── Botones ──────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'RECHAZAR',
                  variant: AppButtonVariant.outlined,
                  isDisabled: isLoading,
                  onPressed: onReject,
                  expand: true,
                ),
              ),
              12.horizontalSpace,
              Expanded(
                child: AppButton(
                  label: 'ACEPTAR',
                  variant: AppButtonVariant.filled,
                  isLoading: isLoading,
                  onPressed: onAccept,
                  expand: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
