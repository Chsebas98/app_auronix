import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/shared/atoms/buttons/app_icon_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DriverCarMarker extends StatelessWidget {
  const DriverCarMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56.r,
      height: 56.r,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Sombra circular
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: AppColors.third,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.third.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          // Opcion A: asset image (recomendado)
          Image.asset(
            'assets/images/gif/car_maker.gif',
            width: 32.r,
            height: 32.r,
            // Si el asset es oscuro y el fondo es amarillo ya se ve bien
            // Si es blanco/claro usa colorBlendMode:
            // color: AppColors.secondary,
            // colorBlendMode: BlendMode.srcIn,
            errorBuilder: (_, __, ___) => _fallbackIcon(),
          ),
        ],
      ),
    );
  }

  // Opcion B: fallback si no hay asset
  Widget _fallbackIcon() {
    return AppIconButton(
      onPressed: () {},
      isDisabled: true,
      iconAndroid: Icons.local_taxi_rounded,
      iconIOS: CupertinoIcons.car_fill,
      color: AppColors.secondary,
      size: 28.r,
    );
  }
}
