import 'package:auronix_app/features/client/home/presentation/widgets/home_client_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CooperativasSectionWidget extends StatelessWidget {
  const CooperativasSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // todo: Obtener cooperativas desde el backend
    final cooperativas = [
      {
        'name': 'Taxi 24h',
        'logo': 'https://via.placeholder.com/100',
        'available': true,
        'carsCount': 15,
        'rating': 4.8,
        'eta': '3 min',
      },
      {
        'name': 'Uber Executive',
        'logo': 'https://via.placeholder.com/100',
        'available': true,
        'carsCount': 8,
        'rating': 4.9,
        'eta': '5 min',
      },
      {
        'name': 'Rapido City',
        'logo': 'https://via.placeholder.com/100',
        'available': true,
        'carsCount': 23,
        'rating': 4.7,
        'eta': '2 min',
      },
      {
        'name': 'Taxi Express',
        'logo': 'https://via.placeholder.com/100',
        'available': false,
        'carsCount': 0,
        'rating': 4.6,
        'eta': '---',
      },
    ];

    return Column(
      children: [
        SectionHeader(
          title: 'Cooperativas Disponibles',
          subtitle:
              '${cooperativas.where((c) => c['available'] == true).length} cooperativas activas',
          icon: Icons.business,
          onSeeAll: () {
            debugPrint('🏢 Ver todas las cooperativas');
          },
        ),
        12.verticalSpace,
        SizedBox(
          height: 160.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: cooperativas.length,
            itemBuilder: (context, index) {
              final coop = cooperativas[index];
              return CooperativaCard(
                name: coop['name'] as String,
                logoUrl: coop['logo'] as String,
                isAvailable: coop['available'] as bool,
                carsCount: coop['carsCount'] as int,
                rating: coop['rating'] as double,
                eta: coop['eta'] as String,
                onTap: () {
                  debugPrint('🏢 ${coop['name']} seleccionado');
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
