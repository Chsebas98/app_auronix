import 'package:auronix_app/app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CooperativaCard extends StatelessWidget {
  final String name;
  final String logoUrl;
  final bool isAvailable;
  final int carsCount;
  final double rating;
  final String eta;
  final VoidCallback onTap;

  const CooperativaCard({
    super.key,
    required this.name,
    required this.logoUrl,
    required this.isAvailable,
    required this.carsCount,
    required this.rating,
    required this.eta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(right: 12.w),
      child: Opacity(
        opacity: isAvailable ? 1.0 : 0.5,
        child: Material(
          elevation: 3,
          borderRadius: BorderRadius.circular(16.r),
          shadowColor: AppShadowColors.blackSoft,
          child: InkWell(
            onTap: isAvailable ? onTap : null,
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              width: 140.w,
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: AppColorsExtension.cardColor(context),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isAvailable
                      ? AppColors.eleventh.withValues(alpha: 0.3)
                      : (AppColorsExtension.borderColor(context)),
                  width: 1.w,
                ),
              ),
              child: Column(
                children: [
                  // Logo y status
                  Stack(
                    children: [
                      Container(
                        width: 60.r,
                        height: 60.r,
                        decoration: BoxDecoration(
                          color: AppColors.third.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child:
                              logoUrl.isNotEmpty && logoUrl.startsWith('http')
                              ? Image.network(
                                  logoUrl,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value:
                                                loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                : null,
                                            strokeWidth: 2.w,
                                            color: AppColors.third,
                                          ),
                                        );
                                      },
                                  errorBuilder: (context, error, stackTrace) {
                                    // ✅ Fallback cuando falla la imagen
                                    return Center(
                                      child: Icon(
                                        Icons.local_taxi_rounded,
                                        size: 32.r,
                                        color: AppColors.third,
                                      ),
                                    );
                                  },
                                )
                              : Center(
                                  child: Icon(
                                    Icons.local_taxi_rounded,
                                    size: 32.r,
                                    color: AppColors.third,
                                  ),
                                ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 12.r,
                          height: 12.r,
                          decoration: BoxDecoration(
                            color: isAvailable
                                ? AppColors.eleventh
                                : AppColors.sevent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.primaryColor,
                              width: 2.w,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  // Nombre
                  Text(
                    name,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const Spacer(),

                  // Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Rating
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 14.r,
                            color: AppColors.twelveth,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            rating.toString(),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),

                      // Cars disponibles
                      Row(
                        children: [
                          Icon(
                            Icons.local_taxi,
                            size: 14.r,
                            color: AppColors.fourth,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            carsCount.toString(),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 4.h),

                  // ETA
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: isAvailable
                          ? AppColors.eleventh.withValues(alpha: 0.2)
                          : AppColors.fourth.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      isAvailable ? 'Llega en $eta' : 'No disponible',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isAvailable
                            ? AppColors.eleventh
                            : AppColors.fourth,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
