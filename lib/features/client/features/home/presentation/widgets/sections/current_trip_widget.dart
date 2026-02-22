import 'package:auronix_app/app/theme/theme.dart';
import 'package:auronix_app/features/client/features/home/domain/models/interfaces/current_trip_model.dart';
import 'package:auronix_app/features/client/features/home/domain/models/interfaces/current_trip_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CurrentTripWidget extends StatelessWidget {
  final TripModel? currentTrip;
  final VoidCallback? onCancel;
  final VoidCallback? onContactDriver;
  final VoidCallback? onViewDetails;

  const CurrentTripWidget({
    super.key,
    this.currentTrip,
    this.onCancel,
    this.onContactDriver,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    if (currentTrip == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: _buildTripCard(context),
    );
  }

  Widget _buildTripCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColorsExtension.cardColor(context),
        borderRadius: BorderRadius.circular(16.r),

        boxShadow: [
          BoxShadow(
            color: AppColorsExtension.surfaceColor(
              context,
            ).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColorsExtension.borderColor(context),
          width: 1.w,
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          _buildContent(context),
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final statusConfig = _getStatusConfig(currentTrip!.status);

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColorsExtension.cardColor(context),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      child: Row(
        children: [
          // Icono
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColorsExtension.surfaceColor(context),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              statusConfig['icon'] as IconData,
              color: _getStatusColor(currentTrip!.status),
              size: 24.r,
            ),
          ),

          12.horizontalSpace,

          // Estado
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusConfig['title'] as String,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColorsExtension.textColor(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  statusConfig['subtitle'] as String,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColorsExtension.textSecondaryColor(context),
                  ),
                ),
              ],
            ),
          ),

          // Loading indicator
          if (currentTrip!.status == TripStatus.searchingDriver)
            SizedBox(
              width: 20.r,
              height: 20.r,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(
                  AppColorsExtension.textSecondaryColor(context),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (currentTrip!.status) {
      case TripStatus.searchingDriver:
        return _buildSearchingContent(context);
      case TripStatus.driverAssigned:
      case TripStatus.inProgress:
        return _buildDriverAssignedContent(context);
      case TripStatus.completed:
        return _buildCompletedContent(context);
      case TripStatus.cancelled:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSearchingContent(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Column(
        children: [
          _buildRouteInfo(context),
          16.verticalSpace,
          Text(
            'Estamos buscando el mejor conductor para ti',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColorsExtension.textColor(context),
            ),
          ),
          8.verticalSpace,
          if (currentTrip!.estimatedPrice != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColorsExtension.cardColor(
                  context,
                ).withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'Precio estimado: \$${currentTrip!.estimatedPrice!.toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColorsExtension.textColor(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDriverAssignedContent(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Column(
        children: [
          // Conductor info
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppColorsExtension.cardColor(context),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                // Foto
                CircleAvatar(
                  radius: 30.r,
                  backgroundColor: AppColorsExtension.surfaceColor(context),
                  backgroundImage: currentTrip!.driverPhotoUrl != null
                      ? NetworkImage(currentTrip!.driverPhotoUrl!)
                      : null,
                  child: currentTrip!.driverPhotoUrl == null
                      ? Icon(
                          Icons.person,
                          size: 30.r,
                          color: AppColorsExtension.textSecondaryColor(context),
                        )
                      : null,
                ),

                12.horizontalSpace,

                // Datos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentTrip!.driverName ?? 'Conductor',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColorsExtension.textColor(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      4.verticalSpace,
                      Row(
                        children: [
                          Icon(Icons.star, color: AppColors.third, size: 16.r),
                          4.horizontalSpace,
                          Text(
                            currentTrip!.driverRating?.toStringAsFixed(1) ??
                                'N/A',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColorsExtension.textColor(context),
                            ),
                          ),
                          12.horizontalSpace,
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColorsExtension.surfaceColor(context),
                              borderRadius: BorderRadius.circular(4.r),
                              border: Border.all(
                                color: AppColorsExtension.borderColor(context),
                                width: 1.w,
                              ),
                            ),
                            child: Text(
                              currentTrip!.driverPlate ?? '',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColorsExtension.textColor(context),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Botón llamar
                IconButton(
                  onPressed: onContactDriver,
                  icon: Icon(
                    Icons.phone,
                    color: AppColors.fifth, // 🔥 Teal para destacar
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColorsExtension.surfaceColor(context),
                  ),
                ),
              ],
            ),
          ),

          12.verticalSpace,

          // ETA
          if (currentTrip!.estimatedArrivalMinutes != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColorsExtension.cardColor(context),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.third, width: 1.5.w),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.access_time, color: AppColors.third, size: 18.r),
                  8.horizontalSpace,
                  Text(
                    'Llega en ${currentTrip!.estimatedArrivalMinutes} min',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColorsExtension.textColor(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          12.verticalSpace,

          // Ruta
          _buildRouteInfo(context),
        ],
      ),
    );
  }

  Widget _buildCompletedContent(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Column(
        children: [
          Icon(Icons.check_circle, color: AppColors.eleventh, size: 48.r),
          12.verticalSpace,
          Text(
            '¡Viaje completado!',
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColorsExtension.textColor(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          8.verticalSpace,
          if (currentTrip!.finalPrice != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColorsExtension.cardColor(context),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'Total: \$${currentTrip!.finalPrice!.toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.third,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRouteInfo(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColorsExtension.cardColor(context),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          // Iconos de ruta
          Column(
            children: [
              Icon(Icons.circle, color: AppColors.eleventh, size: 12.r),
              Container(width: 2.w, height: 30.h, color: AppColors.gray400),
              Icon(Icons.location_on, color: AppColors.sevent, size: 16.r),
            ],
          ),

          12.horizontalSpace,

          // Direcciones
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentTrip!.originAddress ?? 'Origen',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColorsExtension.textSecondaryColor(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                8.verticalSpace,
                Text(
                  currentTrip!.destinationAddress ?? 'Destino',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColorsExtension.textColor(context),
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Row(
        children: [
          // Ver detalles
          Expanded(
            child: OutlinedButton(
              onPressed: onViewDetails,
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColorsExtension.tripActionButton(context),
                foregroundColor: context.isLight
                    ? AppColors.secondary
                    : AppColors.darkText,
                side: BorderSide(
                  color: AppColorsExtension.borderColor(context),
                  width: 1.5.w,
                ),
                minimumSize: Size(0, 44.h),
              ),
              child: const Text('Ver detalles'),
            ),
          ),

          12.horizontalSpace,

          // Cancelar
          if (currentTrip!.status == TripStatus.searchingDriver ||
              currentTrip!.status == TripStatus.driverAssigned)
            Expanded(
              child: ElevatedButton(
                onPressed: onCancel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkDivider,
                  foregroundColor: AppColors.white,
                  minimumSize: Size(0, 44.h),
                  textStyle: TextStyle(fontWeight: FontWeight.w600),
                ),
                child: const Text('Cancelar'),
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(TripStatus status) {
    switch (status) {
      case TripStatus.searchingDriver:
        return AppColors.third;
      case TripStatus.driverAssigned:
        return AppColors.fifth;
      case TripStatus.inProgress:
        return AppColors.eleventh;
      case TripStatus.completed:
        return AppColors.eleventh;
      case TripStatus.cancelled:
        return AppColors.sevent;
    }
  }

  Map<String, dynamic> _getStatusConfig(TripStatus status) {
    switch (status) {
      case TripStatus.searchingDriver:
        return {
          'icon': Icons.search,
          'title': 'Buscando conductor',
          'subtitle': 'Esto tomará solo unos segundos',
        };
      case TripStatus.driverAssigned:
        return {
          'icon': Icons.local_taxi,
          'title': 'Conductor asignado',
          'subtitle': 'Tu conductor está en camino',
        };
      case TripStatus.inProgress:
        return {
          'icon': Icons.navigation,
          'title': 'En viaje',
          'subtitle': 'Disfruta tu viaje',
        };
      case TripStatus.completed:
        return {
          'icon': Icons.check_circle,
          'title': 'Viaje completado',
          'subtitle': 'Gracias por viajar con nosotros',
        };
      case TripStatus.cancelled:
        return {
          'icon': Icons.cancel,
          'title': 'Viaje cancelado',
          'subtitle': '',
        };
    }
  }
}
