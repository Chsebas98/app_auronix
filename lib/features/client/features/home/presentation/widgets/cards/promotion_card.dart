import 'package:auronix_app/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PromotionCard extends StatelessWidget {
  final String title;
  final String description;
  final String code;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const PromotionCard({
    super.key,
    required this.title,
    required this.description,
    required this.code,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(right: 12.w),
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(16.r),
        shadowColor: color.withValues(alpha: 0.3),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            width: 280.w,
            height: 160.h, // ✅ ALTURA FIJA
            padding: EdgeInsets.all(14.r), // ✅ REDUCIDO de 16.r a 14.r
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // ✅ IMPORTANTE
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con icono y badge
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6.r), // ✅ REDUCIDO de 8.r a 6.r
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        icon,
                        color: AppColors.white,
                        size: 20.r, // ✅ REDUCIDO de 24.r a 20.r
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w, // ✅ REDUCIDO de 8.w a 6.w
                        vertical: 3.h, // ✅ REDUCIDO de 4.h a 3.h
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'ACTIVO',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 9.sp, // ✅ AGREGAR tamaño fijo
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10.h), // ✅ REDUCIDO de 12.h a 10.h
                // Título
                Text(
                  title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                    height: 1.0, // ✅ AGREGAR para reducir altura de línea
                  ),
                  maxLines: 1, // ✅ AGREGAR
                  overflow: TextOverflow.ellipsis, // ✅ AGREGAR
                ),

                SizedBox(height: 4.h),

                // Descripción
                Flexible(
                  // ✅ CAMBIAR de Text a Flexible + Text
                  child: Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      // ✅ CAMBIAR de bodyMedium a bodySmall
                      color: AppColors.white.withValues(alpha: 0.9),
                      height: 1.2, // ✅ AGREGAR
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const Spacer(), // ✅ MANTENER
                // Código de promoción
                InkWell(
                  onTap: () => _copyCode(context),
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w, // ✅ REDUCIDO de 12.w a 10.w
                      vertical: 6.h, // ✅ REDUCIDO
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: color, width: 2.w),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          code,
                          style: theme.textTheme.labelMedium?.copyWith(
                            // ✅ CAMBIAR de labelLarge a labelMedium
                            color: color,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Icon(
                          Icons.copy,
                          size: 14.r, // ✅ REDUCIDO de 16.r a 14.r
                          color: color,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _copyCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Código $code copiado ✅'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
