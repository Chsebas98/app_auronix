import 'package:auronix_app/app/theme/app_colors.dart';
import 'package:auronix_app/features/client/features/home/presentation/widgets/home_client_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SectionHeader(
          title: 'Servicios Disponibles',
          subtitle: 'Elige el tipo de servicio que necesitas',
          icon: Icons.local_taxi_rounded,
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 140.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            children: [
              ServiceTypeCard(
                icon: Icons.local_taxi_rounded,
                label: 'Taxi',
                priceRange: '\$5 - \$8',
                color: AppColors.third,
                onTap: () {
                  debugPrint('🚕 Taxi seleccionado');
                },
              ),
              ServiceTypeCard(
                icon: Icons.diamond_outlined,
                label: 'Premium',
                priceRange: '\$12 - \$15',
                color: AppColors.tenth,
                badge: 'VIP',
                onTap: () {
                  debugPrint('💎 Premium seleccionado');
                },
              ),
              ServiceTypeCard(
                icon: Icons.people_outline,
                label: 'Compartido',
                priceRange: '\$3 - \$5',
                color: AppColors.eleventh,
                badge: '-40%',
                onTap: () {
                  debugPrint('👥 Compartido seleccionado');
                },
              ),
              ServiceTypeCard(
                icon: Icons.two_wheeler_outlined,
                label: 'Moto',
                priceRange: '\$2 - \$4',
                color: AppColors.sixth,
                onTap: () {
                  debugPrint('🏍️ Moto seleccionado');
                },
              ),
              ServiceTypeCard(
                icon: Icons.airport_shuttle_rounded,
                label: 'Van',
                priceRange: '\$15 - \$20',
                color: AppColors.nineth,
                onTap: () {
                  debugPrint('🚐 Van seleccionado');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
