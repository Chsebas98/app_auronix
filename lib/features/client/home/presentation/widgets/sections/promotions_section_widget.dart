import 'package:auronix_app/features/client/home/presentation/widgets/home_client_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PromotionsSectionWidget extends StatelessWidget {
  const PromotionsSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // todo: Obtener promociones desde el backend
    final promotions = [
      {
        'title': '50% OFF',
        'description': 'En tu primer viaje',
        'code': 'BIENVENIDO',
        'color': Color(0xFFFF6B6B),
        'icon': Icons.local_offer,
      },
      {
        'title': '3x2',
        'description': 'En viajes este fin de semana',
        'code': 'FINDE3X2',
        'color': Color(0xFF4ECDC4),
        'icon': Icons.celebration,
      },
      {
        'title': 'Gratis',
        'description': 'Invita amigos y gana viajes',
        'code': 'REFERIDO',
        'color': Color(0xFFFFBE0B),
        'icon': Icons.card_giftcard,
      },
    ];

    if (promotions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const SectionHeader(
          title: 'Ofertas Especiales',
          subtitle: 'Aprovecha estas promociones',
          icon: Icons.local_offer,
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 160.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: promotions.length,
            itemBuilder: (context, index) {
              final promo = promotions[index];
              return PromotionCard(
                title: promo['title'] as String,
                description: promo['description'] as String,
                code: promo['code'] as String,
                color: promo['color'] as Color,
                icon: promo['icon'] as IconData,
                onTap: () {
                  debugPrint('🎁 Promoción: ${promo['code']}');
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
