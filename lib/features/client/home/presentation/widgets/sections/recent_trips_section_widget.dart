import 'package:auronix_app/features/client/home/presentation/widgets/home_client_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecentTripsSectionWidget extends StatelessWidget {
  const RecentTripsSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // todo: Obtener viajes desde el backend
    final recentTrips = [
      {
        'origin': 'Casa',
        'destination': 'Oficina',
        'address': 'Av. Principal 123',
        'price': 7.50,
        'duration': '15 min',
        'date': 'Hace 2 días',
        'isFavorite': true,
      },
      {
        'origin': 'Centro Comercial',
        'destination': 'Casa',
        'address': 'Mall del Sol',
        'price': 12.00,
        'duration': '25 min',
        'date': 'Hace 5 días',
        'isFavorite': true,
      },
      {
        'origin': 'Aeropuerto',
        'destination': 'Hotel',
        'address': 'Aeropuerto Internacional',
        'price': 25.00,
        'duration': '35 min',
        'date': 'Hace 1 semana',
        'isFavorite': false,
      },
    ];

    if (recentTrips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SectionHeader(
          title: 'Tus Viajes Recientes',
          subtitle: 'Repite tus viajes frecuentes',
          icon: Icons.history,
          onSeeAll: () {
            debugPrint('🕐 Ver historial completo');
          },
        ),
        SizedBox(height: 8.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          itemCount: recentTrips.length > 3 ? 3 : recentTrips.length,
          itemBuilder: (context, index) {
            final trip = recentTrips[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: RecentTripCard(
                origin: trip['origin'] as String,
                destination: trip['destination'] as String,
                address: trip['address'] as String,
                price: trip['price'] as double,
                duration: trip['duration'] as String,
                date: trip['date'] as String,
                isFavorite: trip['isFavorite'] as bool,
                onTap: () {
                  debugPrint(
                    '🔁 Repetir viaje: ${trip['origin']} → ${trip['destination']}',
                  );
                },
                onFavoriteToggle: () {
                  debugPrint('⭐ Toggle favorito');
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
