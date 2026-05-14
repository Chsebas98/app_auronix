import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:auronix_app/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeLocationRow extends StatelessWidget {
  const HomeLocationRow({
    required this.address,
    required this.isLoading,
    required this.onRefresh,
    super.key,
  });

  final String address;
  final bool isLoading;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        isLoading
            ? SizedBox(
                width: 18.r,
                height: 18.r,
                child: const CircularProgressIndicator.adaptive(strokeWidth: 2),
              )
            : Icon(
                Icons.location_on,
                size: 18.r,
                color: context
                    .appColors
                    .button, // third en light, twelveth en dark
              ),
        const SizedBox(width: 6),
        Expanded(
          child: AppText(
            address.isEmpty ? 'Obteniendo ubicacion...' : address,
            variant: AppTextVariant.bodySmall,
            color: context.appColors.textSecondary, // fourth → semantico
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TextButton(
          onPressed: isLoading ? null : onRefresh,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
          ),
          child: AppText(
            'Actualizar',
            variant: AppTextVariant.labelSmall,
            color: context.appColors.button,
          ),
        ),
      ],
    );
  }
}
