import 'dart:async';

import 'package:auronix_app/app/router/app_router.dart';
import 'package:auronix_app/app/router/client/client_routes_path.dart';
import 'package:auronix_app/features/trips/negotiation/domain/models/published_trip_request.dart';
import 'package:auronix_app/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Estado de espera tras publicar una solicitud (docs/flow.md sección 3):
/// visible para conductores cercanos hasta `expiraEn` (5 min fijos). Aún no
/// muestra ofertas entrantes en vivo — eso depende de `RealtimeClient`
/// (T5.1, bloqueado) y es el alcance de T6.2-T6.5, todavía pendientes. Por
/// ahora solo confirma la publicación y cuenta la expiración.
class SearchingDriverPage extends StatefulWidget {
  const SearchingDriverPage({required this.request, super.key});

  final PublishedTripRequest request;

  @override
  State<SearchingDriverPage> createState() => _SearchingDriverPageState();
}

class _SearchingDriverPageState extends State<SearchingDriverPage> {
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.request.expiraEn.difference(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = widget.request.expiraEn.difference(DateTime.now());
      if (remaining.isNegative) {
        _timer?.cancel();
        setState(() => _remaining = Duration.zero);
        return;
      }
      setState(() => _remaining = remaining);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _remaining.inMinutes;
    final seconds = _remaining.inSeconds % 60;
    final expired = _remaining == Duration.zero;

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppAppbar(
          hasBackButton: false,
          isCenter: true,
          content: AppText('Buscando conductor', variant: AppTextVariant.titleMedium),
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!expired) const CircularProgressIndicator(),
                24.verticalSpace,
                AppText(
                  expired
                      ? 'Tu solicitud expiró sin ofertas'
                      : 'Solicitud publicada. Esperando ofertas de '
                            'conductores cercanos...',
                  variant: AppTextVariant.bodyMedium,
                  align: TextAlign.center,
                ),
                12.verticalSpace,
                AppText(
                  'Precio publicado: '
                  '${widget.request.precioPublicado.toStringAsFixed(2)} '
                  '${widget.request.moneda}',
                  variant: AppTextVariant.bodyMedium,
                ),
                if (!expired) ...[
                  8.verticalSpace,
                  AppText(
                    'Expira en ${minutes.toString().padLeft(2, '0')}:'
                    '${seconds.toString().padLeft(2, '0')}',
                    variant: AppTextVariant.bodySmall,
                  ),
                ],
                32.verticalSpace,
                // No hay endpoint de cancelación de solicitud PUBLICADA
                // documentado (docs/requerimientos_backend.md sección 4.1
                // solo cubre retirar ofertas y cancelar un `viaje` ya
                // asignado) — este botón solo navega, no cancela nada en
                // backend.
                AppButton(
                  label: 'Volver al inicio',
                  expand: true,
                  onPressed: () => AppRouter.go(ClientRoutesPath.home),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
