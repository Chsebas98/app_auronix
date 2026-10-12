import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/app/router/app_router.dart';
import 'package:auronix_app/app/router/client/client_routes_path.dart';
import 'package:auronix_app/features/trips/negotiation/domain/models/address_suggestion.dart';
import 'package:auronix_app/features/trips/negotiation/presentation/bloc/confirm_trip_cubit.dart';
import 'package:auronix_app/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// "Confirmar viaje y precio" (docs/design_patterns.md 3.2, docs/flow.md
/// sección 3): muestra origen/destino, distancia/duración/precio sugerido
/// (siempre calculados por backend) y permite editar el precio final antes
/// de publicar — validado contra el mínimo de `GET /config/public`, nunca
/// hardcodeado.
class ConfirmTripPage extends StatefulWidget {
  const ConfirmTripPage({required this.destination, super.key});

  final AddressSuggestion destination;

  @override
  State<ConfirmTripPage> createState() => _ConfirmTripPageState();
}

class _ConfirmTripPageState extends State<ConfirmTripPage> {
  late final ConfirmTripCubit _cubit;
  final _priceController = TextEditingController();
  String? _priceFieldError;

  @override
  void initState() {
    super.initState();
    _cubit = sl<ConfirmTripCubit>()..init(widget.destination);
  }

  @override
  void dispose() {
    _priceController.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppAppbar(
          hasBackButton: true,
          isCenter: true,
          content: AppText('Confirmar viaje', variant: AppTextVariant.titleMedium),
          goTo: () => Navigator.pop(context),
        ),
        body: BlocConsumer<ConfirmTripCubit, ConfirmTripState>(
          listenWhen: (prev, curr) =>
              (curr.errorMessage != null &&
                  curr.errorMessage != prev.errorMessage) ||
              curr.status == ConfirmTripStatus.published,
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
            }
            if (state.status == ConfirmTripStatus.published &&
                state.published != null) {
              AppRouter.go(
                ClientRoutesPath.searchingDriver,
                extra: state.published,
              );
            }
          },
          builder: (context, state) {
            if (state.status == ConfirmTripStatus.loadingOrigin ||
                (state.status == ConfirmTripStatus.estimating &&
                    state.estimate == null)) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == ConfirmTripStatus.error &&
                state.estimate == null) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppText(
                        state.errorMessage ?? 'No se pudo calcular el viaje',
                        variant: AppTextVariant.bodyMedium,
                        align: TextAlign.center,
                      ),
                      16.verticalSpace,
                      AppButton(
                        label: 'Reintentar',
                        onPressed: () => _cubit.init(widget.destination),
                      ),
                    ],
                  ),
                ),
              );
            }

            final estimate = state.estimate;
            if (estimate != null && _priceController.text.isEmpty) {
              _priceController.text = estimate.precioSugerido.toStringAsFixed(
                2,
              );
            }

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: ListView(
                children: [
                  _AddressRow(
                    icon: Icons.my_location,
                    label: state.origin?.label ?? '',
                  ),
                  12.verticalSpace,
                  _AddressRow(
                    icon: Icons.location_on,
                    label: state.destination?.label ?? widget.destination.label,
                  ),
                  24.verticalSpace,
                  if (estimate != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText(
                          '${estimate.distanciaKm.toStringAsFixed(1)} km',
                          variant: AppTextVariant.bodyMedium,
                        ),
                        AppText(
                          '${estimate.duracionEstimadaMin.round()} min',
                          variant: AppTextVariant.bodyMedium,
                        ),
                      ],
                    ),
                    16.verticalSpace,
                    AppText(
                      'Precio sugerido: '
                      '${estimate.precioSugerido.toStringAsFixed(2)} '
                      '${estimate.moneda}',
                      variant: AppTextVariant.bodyMedium,
                    ),
                    12.verticalSpace,
                    TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Precio a publicar (${estimate.moneda})',
                        border: const OutlineInputBorder(),
                        errorText: _priceFieldError,
                      ),
                      onChanged: (_) => setState(() => _priceFieldError = null),
                    ),
                    if (state.minPrice != null)
                      Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: AppText(
                          'Mínimo: ${state.minPrice!.toStringAsFixed(2)} '
                          '${estimate.moneda}',
                          variant: AppTextVariant.bodySmall,
                        ),
                      ),
                    24.verticalSpace,
                    AppButton(
                      label: 'Publicar solicitud',
                      expand: true,
                      isLoading:
                          state.status == ConfirmTripStatus.publishing,
                      onPressed: () => _onPublish(state),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _onPublish(ConfirmTripState state) {
    final rawPrice = _priceController.text.trim();
    final price = double.tryParse(rawPrice);

    if (price == null) {
      setState(() => _priceFieldError = 'Ingresa un precio válido');
      return;
    }

    if (state.minPrice != null && price < state.minPrice!) {
      setState(
        () => _priceFieldError =
            'El precio mínimo es ${state.minPrice!.toStringAsFixed(2)}',
      );
      return;
    }

    setState(() => _priceFieldError = null);
    _cubit.publish(precioPublicado: price);
  }
}

class _AddressRow extends StatelessWidget {
  const _AddressRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.third, size: 20),
        8.horizontalSpace,
        Expanded(
          child: AppText(
            label.isEmpty ? 'Sin definir' : label,
            variant: AppTextVariant.bodyMedium,
          ),
        ),
      ],
    );
  }
}
