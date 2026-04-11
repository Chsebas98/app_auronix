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
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RequestTripScreen extends StatelessWidget {
  const RequestTripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          RequestTripBloc(tripRepository: sl<TripRepository>()),
      child: _RequestTripView(),
    );
  }
}

class _RequestTripView extends StatefulWidget {
  const _RequestTripView();

  @override
  State<_RequestTripView> createState() => _RequestTripViewState();
}

class _RequestTripViewState extends State<_RequestTripView> {
  LatLng? _currentLocation;

  void _onConfirmTrip() {
    final state = context.read<RequestTripBloc>().state;

    if (state.selectedDestination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor selecciona un destino'),
          backgroundColor: AppColors.tenth,
        ),
      );
      return;
    }

    debugPrint('🚕 Confirmando viaje a: ${state.selectedDestination!.name}');
    // TODO: Navegar a confirmar viaje
    // AppRouter.push(ClientRoutesPath.confirmTrip, extra: {...});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryColor,
      body: BlocListener<RequestTripBloc, RequestTripState>(
        listenWhen: (previous, current) =>
            previous.selectedDestination != current.selectedDestination &&
            current.selectedDestination != null,
        listener: (context, state) {
          // ✅ Cuando se selecciona destino Y tenemos ubicación, calcular ruta
          if (_currentLocation != null) {
            context.read<RequestTripBloc>().add(
              CalculateRouteEvent(
                origin: _currentLocation!,
                destination: state.selectedDestination!,
              ),
            );
          }
        },
        child: BlocBuilder<RequestTripBloc, RequestTripState>(
          builder: (context, state) {
            return Stack(
              children: [
                // Mapa de fondo
                MapWidget(
                  destinationLat: state.selectedDestination?.lat,
                  destinationLng: state.selectedDestination?.lng,
                  polylinePoints: state.polylinePoints,
                  onLocationReady: (location) {
                    // ✅ Guardar ubicación cuando esté lista
                    setState(() {
                      _currentLocation = location;
                    });

                    // ✅ Si ya hay destino seleccionado, calcular ruta
                    if (state.selectedDestination != null &&
                        state.polylinePoints.isEmpty) {
                      context.read<RequestTripBloc>().add(
                        CalculateRouteEvent(
                          origin: location,
                          destination: state.selectedDestination!,
                        ),
                      );
                    }
                  },
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
                                    color: AppColorsExtension.iconColor(
                                      context,
                                    ),
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

                      // ✅ Loading mientras calcula ruta
                      if (state.isCalculatingRoute)
                        Container(
                          margin: EdgeInsets.only(bottom: 16.h),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.third.withAlpha(230),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16.w,
                                height: 16.h,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              12.horizontalSpace,
                              Text(
                                'Calculando ruta...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Botón confirmar viaje
                      if (state.selectedDestination != null)
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
                                      color: AppColors.third.withAlpha(51),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Destino',
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                color:
                                                    AppColorsExtension.textSecondaryColor(
                                                      context,
                                                    ),
                                              ),
                                        ),
                                        4.verticalSpace,
                                        Text(
                                          state.selectedDestination!.name,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
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

                              // ✅ Mostrar distancia y duración
                              if (state.distance != null &&
                                  state.duration != null) ...[
                                12.verticalSpace,
                                Container(
                                  padding: EdgeInsets.all(12.w),
                                  decoration: BoxDecoration(
                                    color: AppColors.third.withAlpha(26),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.straighten,
                                            color: AppColors.third,
                                            size: 18.r,
                                          ),
                                          8.horizontalSpace,
                                          Text(
                                            state.distance!,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.third,
                                                ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        width: 1,
                                        height: 20.h,
                                        color: AppColors.third.withAlpha(77),
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            color: AppColors.third,
                                            size: 18.r,
                                          ),
                                          8.horizontalSpace,
                                          Text(
                                            state.duration!,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.third,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              16.verticalSpace,

                              // Botón confirmar
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: _onConfirmTrip,
                                  style: FilledButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 16.h,
                                    ),
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
            );
          },
        ),
      ),
    );
  }
}
