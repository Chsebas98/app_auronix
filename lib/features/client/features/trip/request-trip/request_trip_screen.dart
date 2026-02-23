// request_trip_screen.dart

import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/app/router/app_router.dart';
import 'package:auronix_app/app/theme/app_colors.dart';
import 'package:auronix_app/app/theme/theme_extensions.dart';
import 'package:auronix_app/features/client/client.dart';
import 'package:auronix_app/features/client/features/trip/domain/repository/trip_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RequestTripScreen extends StatelessWidget {
  const RequestTripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          RequestTripBloc(tripRepository: sl<TripRepository>()),
      child: _RequestTripController(),
    );
  }
}

class _RequestTripController extends StatefulWidget {
  const _RequestTripController();

  @override
  State<_RequestTripController> createState() => _RequestTripControllerState();
}

class _RequestTripControllerState extends State<_RequestTripController> {
  String? _selectedDestination;
  double? _destinationLat;
  double? _destinationLng;

  void _onConfirmTrip() {
    if (_selectedDestination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor selecciona un destino'),
          backgroundColor: AppColors.tenth,
        ),
      );
      return;
    }

    debugPrint('🚕 Confirmando viaje a: $_selectedDestination');
    // TODO: Navegar a confirmar viaje
    // AppRouter.push(ClientRoutesPath.confirmTrip, extra: {...});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryColor,
      body: Stack(
        children: [
          // Mapa de fondo
          MapWidget(
            destinationLat: _destinationLat,
            destinationLng: _destinationLng,
          ),

          // Overlay superior con búsqueda
          SafeArea(
            child: Column(
              children: [
                // Header con botón atrás y búsqueda
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    boxShadow: [
                      BoxShadow(
                        color: context.isLight
                            ? AppShadowColors.blackSoft
                            : AppShadowColors.darkSoft,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Botón atrás
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => AppRouter.pop(),
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: AppColorsExtension.iconColor(context),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Solicitar taxi',
                              style: theme.textTheme.titleLarge,
                            ),
                          ),
                        ],
                      ),

                      8.verticalSpace,

                      // Buscador de destino
                      DestinationSearch(),
                    ],
                  ),
                ),

                Spacer(),

                // Botón confirmar viaje
                if (_selectedDestination != null)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20.r),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: context.isLight
                              ? AppShadowColors.blackSoft
                              : AppShadowColors.darkSoft,
                          blurRadius: 12,
                          offset: Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Destino seleccionado
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: AppColors.third.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(
                                Icons.location_on,
                                color: AppColors.third,
                                size: 20.r,
                              ),
                            ),
                            12.horizontalSpace,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Destino',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color:
                                          AppColorsExtension.textSecondaryColor(
                                            context,
                                          ),
                                    ),
                                  ),
                                  4.verticalSpace,
                                  Text(
                                    _selectedDestination!,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        16.verticalSpace,

                        // Botón confirmar
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _onConfirmTrip,
                            style: FilledButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                            ),
                            child: Text(
                              'Confirmar viaje',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
