import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:auronix_app/app/router/client/client_routes_path.dart';
import 'package:auronix_app/core/utils/helpers/jwt_helpers.dart';
import 'package:auronix_app/features/trips/presentation/bloc/client-bloc/client_trip_bloc.dart';
import 'package:auronix_app/shared/atoms/buttons/app_button.dart';
import 'package:auronix_app/shared/atoms/text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ClientRateTripTemplate extends StatefulWidget {
  const ClientRateTripTemplate({super.key});

  @override
  State<ClientRateTripTemplate> createState() =>
      _ClientRateTripTemplateState();
}

class _ClientRateTripTemplateState extends State<ClientRateTripTemplate> {
  int _selectedStars = 0;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ClientTripBloc, ClientTripState>(
      listenWhen: (prev, curr) =>
          curr.status == ClientTripStatus.rated &&
          prev.status != ClientTripStatus.rated,
      listener: (_, __) =>
          context.pushReplacement(ClientRoutesPath.tripCompleted),
      child: BlocBuilder<ClientTripBloc, ClientTripState>(
        builder: (context, state) {
          final isRating = state.status == ClientTripStatus.rating;

          return Scaffold(
            backgroundColor: context.appColors.background,
            appBar: AppBar(
              backgroundColor: context.appColors.background,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: AppText(
                'Calificar conductor',
                variant: AppTextVariant.titleMedium,
                color: context.appColors.text,
                fontWeight: FontWeight.w700,
              ),
              centerTitle: true,
            ),
            body: SafeArea(
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    56.verticalSpace,

                    // ── Avatar conductor ──────────────────────────────
                    Container(
                      width: 80.r,
                      height: 80.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.appColors.card,
                        border: Border.all(
                            color: context.appColors.border, width: 2),
                      ),
                      child: Icon(Icons.person_rounded,
                          size: 44.r,
                          color: context.appColors.textSecondary),
                    ),
                    16.verticalSpace,

                    AppText(
                      '¿Cómo fue tu conductor?',
                      variant: AppTextVariant.titleSmall,
                      color: context.appColors.text,
                      fontWeight: FontWeight.w600,
                      align: TextAlign.center,
                    ),
                    8.verticalSpace,
                    AppText(
                      'Tu opinión ayuda a mejorar el servicio.',
                      variant: AppTextVariant.bodySmall,
                      color: context.appColors.textSecondary,
                      align: TextAlign.center,
                    ),
                    40.verticalSpace,

                    // ── Estrellas ─────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        final filled = i < _selectedStars;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedStars = i + 1),
                          child: Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: 6.w),
                            child: Icon(
                              filled
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: filled
                                  ? AppColors.third
                                  : context.appColors.border,
                              size: 48.r,
                            ),
                          ),
                        );
                      }),
                    ),
                    32.verticalSpace,

                    // ── Comentario ────────────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: context.appColors.input,
                        borderRadius: BorderRadius.circular(12.r),
                        border:
                            Border.all(color: context.appColors.border),
                      ),
                      child: TextField(
                        controller: _commentController,
                        maxLines: 3,
                        style: TextStyle(
                          color: context.appColors.text,
                          fontSize: 14.sp,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Comentario (opcional)',
                          hintStyle: TextStyle(
                            color: context.appColors.textSecondary,
                            fontSize: 14.sp,
                          ),
                          contentPadding: EdgeInsets.all(14.r),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // ── Enviar ────────────────────────────────────────
                    AppButton(
                      label: 'ENVIAR CALIFICACIÓN',
                      variant: AppButtonVariant.filled,
                      expand: true,
                      isLoading: isRating,
                      isDisabled: _selectedStars == 0,
                      onPressed: _selectedStars == 0
                          ? null
                          : () {
                              final session =
                                  context.read<SessionBloc>().state;
                              final userId = session is SessionAuthenticated
                                  ? JwtHelpers.getUserId(
                                          session.dataUser.tokenAccess) ??
                                      0
                                  : 0;
                              context.read<ClientTripBloc>().add(
                                    ClientTripRateDriverEvent(
                                      userId: userId,
                                      tripId: state.activeTrip?.id ?? 0,
                                      calificacion: _selectedStars,
                                      comentario:
                                          _commentController.text.isEmpty
                                              ? null
                                              : _commentController.text,
                                    ),
                                  );
                            },
                    ),
                    12.verticalSpace,
                    TextButton(
                      onPressed: isRating
                          ? null
                          : () => context.pushReplacement(
                              ClientRoutesPath.tripCompleted),
                      child: AppText(
                        'Omitir',
                        variant: AppTextVariant.bodyMedium,
                        color: context.appColors.textSecondary,
                      ),
                    ),
                    8.verticalSpace,
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
