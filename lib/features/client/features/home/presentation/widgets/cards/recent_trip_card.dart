import 'package:auronix_app/app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecentTripCard extends StatelessWidget {
  final String origin;
  final String destination;
  final String address;
  final double price;
  final String duration;
  final String date;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const RecentTripCard({
    super.key,
    required this.origin,
    required this.destination,
    required this.address,
    required this.price,
    required this.duration,
    required this.date,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12.r),
      shadowColor: AppShadowColors.blackSoft,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            // ✅ Colores específicos
            color: AppColorsExtension.cardColor(context),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: theme.brightness == Brightness.light
                  ? AppColors.lightBorder
                  : AppColors.darkBorder,
              width: 1.w,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Iconos de origen y destino
                  Column(
                    children: [
                      Container(
                        width: 12.r,
                        height: 12.r,
                        decoration: BoxDecoration(
                          color: AppColors.eleventh,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.white,
                            width: 2.w,
                          ),
                        ),
                      ),
                      Container(
                        width: 2.w,
                        height: 24.h,
                        color: AppColors.fourth,
                      ),
                      Container(
                        width: 12.r,
                        height: 12.r,
                        decoration: BoxDecoration(
                          color: AppColors.sevent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.white,
                            width: 2.w,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(width: 12.w),

                  // Info del viaje
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (isFavorite) ...[
                              Icon(
                                Icons.star,
                                size: 16.r,
                                color: AppColors.twelveth,
                              ),
                              SizedBox(width: 4.w),
                            ],
                            Expanded(
                              child: Text(
                                origin,
                                style: theme.textTheme.titleSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          address,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.fourth,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          destination,
                          style: theme.textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Favorito button
                  IconButton(
                    onPressed: onFavoriteToggle,
                    icon: Icon(
                      isFavorite ? Icons.star : Icons.star_border,
                      color: isFavorite ? AppColors.twelveth : AppColors.fourth,
                      size: 24.r,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // Footer con precio y acción
              Row(
                children: [
                  // Precio
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.third.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      '\$${price.toStringAsFixed(2)}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.brightness == Brightness.light
                            ? AppColors.secondary
                            : AppColors.third,
                      ),
                    ),
                  ),

                  SizedBox(width: 8.w),

                  // Duration y fecha
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(duration, style: theme.textTheme.bodySmall),
                        Text(
                          date,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.fourth,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Botón repetir
                  FilledButton.icon(
                    onPressed: onTap,
                    icon: Icon(Icons.replay, size: 18.r),
                    label: const Text('Repetir'),
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      minimumSize: Size.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
