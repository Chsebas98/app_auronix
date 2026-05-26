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

class ClientSearchingDriverTemplate extends StatelessWidget {
  const ClientSearchingDriverTemplate({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ClientTripBloc, ClientTripState>(
          listenWhen: (prev, curr) =>
              curr.status == ClientTripStatus.accepted &&
              prev.status != ClientTripStatus.accepted,
          listener: (_, __) =>
              context.pushReplacement(ClientRoutesPath.tripInProgress),
        ),
        BlocListener<ClientTripBloc, ClientTripState>(
          listenWhen: (prev, curr) =>
              curr.status == ClientTripStatus.cancelled &&
              prev.status != ClientTripStatus.cancelled,
          listener: (_, __) => context.go(ClientRoutesPath.trips),
        ),
      ],
      child: BlocBuilder<ClientTripBloc, ClientTripState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: context.appColors.background,
            body: SafeArea(
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),

                    // ── Animación de búsqueda ─────────────────────────
                    SizedBox(
                      width: 160.r,
                      height: 160.r,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _PulseRing(size: 160.r, delay: 0),
                          _PulseRing(size: 120.r, delay: 400),
                          Container(
                            width: 72.r,
                            height: 72.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.third,
                            ),
                            child: Icon(
                              Icons.directions_car_rounded,
                              color: AppColors.secondary,
                              size: 36.r,
                            ),
                          ),
                        ],
                      ),
                    ),
                    32.verticalSpace,

                    AppText(
                      'Buscando conductor...',
                      variant: AppTextVariant.titleMedium,
                      color: context.appColors.text,
                      fontWeight: FontWeight.w700,
                      align: TextAlign.center,
                    ),
                    12.verticalSpace,
                    AppText(
                      'Estamos buscando el conductor más cercano para ti.',
                      variant: AppTextVariant.bodyMedium,
                      color: context.appColors.textSecondary,
                      align: TextAlign.center,
                    ),

                    if (state.destinoDireccion != null) ...[
                      24.verticalSpace,
                      Container(
                        padding: EdgeInsets.all(14.r),
                        decoration: BoxDecoration(
                          color: context.appColors.card,
                          borderRadius: BorderRadius.circular(12.r),
                          border:
                              Border.all(color: context.appColors.border),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.location_on_rounded,
                                color: AppColors.sevent, size: 18.r),
                            10.horizontalSpace,
                            Expanded(
                              child: AppText(
                                state.destinoDireccion!,
                                variant: AppTextVariant.bodySmall,
                                color: context.appColors.text,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const Spacer(),

                    // ── Cancelar ──────────────────────────────────────
                    AppButton(
                      label: 'CANCELAR BÚSQUEDA',
                      variant: AppButtonVariant.outlined,
                      expand: true,
                      onPressed: () =>
                          context.read<ClientTripBloc>().add(
                                ClientTripCancelEvent(
                                  userId: 0,
                                  tripId: state.activeTrip?.id ?? 0,
                                  motivo: 'Cancelado por el usuario',
                                ),
                              ),
                    ),
                    16.verticalSpace,
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PulseRing extends StatefulWidget {
  const _PulseRing({required this.size, required this.delay});
  final double size;
  final int delay;

  @override
  State<_PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<_PulseRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _scale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _opacity = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Opacity(
        opacity: _opacity.value,
        child: Container(
          width: widget.size * _scale.value,
          height: widget.size * _scale.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.third,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
