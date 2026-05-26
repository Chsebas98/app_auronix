import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:auronix_app/app/router/client/client_routes_path.dart';
import 'package:auronix_app/features/trips/presentation/bloc/client-bloc/client_trip_bloc.dart';
import 'package:auronix_app/shared/atoms/buttons/app_button.dart';
import 'package:auronix_app/shared/atoms/text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ClientSelectDestinationTemplate extends StatefulWidget {
  const ClientSelectDestinationTemplate({super.key});

  @override
  State<ClientSelectDestinationTemplate> createState() =>
      _ClientSelectDestinationTemplateState();
}

class _ClientSelectDestinationTemplateState
    extends State<ClientSelectDestinationTemplate> {
  final _originController = TextEditingController(
    text: 'Mi ubicación actual',
  );
  final _destinationController = TextEditingController();

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  void _onConfirm() {
    final destination = _destinationController.text.trim();
    if (destination.isEmpty) return;

    // MVP: coordenadas de Bogotá como placeholder hasta GPS activo
    context.read<ClientTripBloc>().add(
          ClientTripSetRouteEvent(
            origenLatitud: 4.7110,
            origenLongitud: -74.0721,
            origenDireccion: _originController.text.trim(),
            destinoLatitud: 4.7200,
            destinoLongitud: -74.0650,
            destinoDireccion: destination,
            distanciaEstimadaKm: 2.5,
          ),
        );
    context.push(ClientRoutesPath.confirmTrip);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: context.appColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,
              color: context.appColors.icon, size: 20.r),
          onPressed: () => context.pop(),
        ),
        title: AppText(
          'Seleccionar destino',
          variant: AppTextVariant.titleMedium,
          color: context.appColors.text,
          fontWeight: FontWeight.w700,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Origen ────────────────────────────────────────────────
              _LocationField(
                controller: _originController,
                icon: Icons.trip_origin_rounded,
                iconColor: AppColors.fifth,
                label: 'Origen',
                readOnly: true,
              ),
              16.verticalSpace,

              // ── Destino ───────────────────────────────────────────────
              _LocationField(
                controller: _destinationController,
                icon: Icons.location_on_rounded,
                iconColor: AppColors.sevent,
                label: 'Destino',
                autofocus: true,
                onSubmitted: (_) => _onConfirm(),
              ),
              24.verticalSpace,

              // ── Sugerencias rápidas ───────────────────────────────────
              AppText(
                'Lugares frecuentes',
                variant: AppTextVariant.labelMedium,
                color: context.appColors.textSecondary,
              ),
              12.verticalSpace,
              _QuickPlace(
                icon: Icons.work_outline_rounded,
                label: 'Trabajo',
                onTap: () {
                  _destinationController.text = 'Trabajo';
                  setState(() {});
                },
              ),
              8.verticalSpace,
              _QuickPlace(
                icon: Icons.home_outlined,
                label: 'Casa',
                onTap: () {
                  _destinationController.text = 'Casa';
                  setState(() {});
                },
              ),

              const Spacer(),

              // ── Confirmar ─────────────────────────────────────────────
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _destinationController,
                builder: (_, value, __) => AppButton(
                  label: 'CONFIRMAR DESTINO',
                  variant: AppButtonVariant.filled,
                  expand: true,
                  isDisabled: value.text.trim().isEmpty,
                  onPressed: _onConfirm,
                ),
              ),
              16.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationField extends StatelessWidget {
  const _LocationField({
    required this.controller,
    required this.icon,
    required this.iconColor,
    required this.label,
    this.readOnly = false,
    this.autofocus = false,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final IconData icon;
  final Color iconColor;
  final String label;
  final bool readOnly;
  final bool autofocus;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: context.appColors.input,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.appColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 18.r),
          12.horizontalSpace,
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              autofocus: autofocus,
              textInputAction: TextInputAction.search,
              onSubmitted: onSubmitted,
              style: TextStyle(
                color: context.appColors.text,
                fontSize: 14.sp,
              ),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(
                  color: context.appColors.textSecondary,
                  fontSize: 12.sp,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10.h),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickPlace extends StatelessWidget {
  const _QuickPlace({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(
          children: [
            Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: context.appColors.card,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon,
                  color: context.appColors.textSecondary, size: 18.r),
            ),
            12.horizontalSpace,
            AppText(
              label,
              variant: AppTextVariant.bodyMedium,
              color: context.appColors.text,
            ),
          ],
        ),
      ),
    );
  }
}
