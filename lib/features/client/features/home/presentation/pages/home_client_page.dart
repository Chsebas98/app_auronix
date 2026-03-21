import 'package:auronix_app/core/utils/helpers/responsive_helper.dart';
import 'package:auronix_app/features/client/features/home/home-client-bloc/home_client_bloc.dart';
import 'package:auronix_app/features/client/features/home/presentation/widgets/home_client_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeClientPage extends StatelessWidget {
  const HomeClientPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ResponsiveHelper.maxContentWidth(context),
              ),
              child: CustomScrollView(
                slivers: [
                  // AppBar fijo (solo iconos/avatar)
                  const HomeAppBar(),

                  // Hero Section
                  const SliverToBoxAdapter(child: HeroSectionWidget()),

                  // Viaje Actual
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: BlocBuilder<HomeClientBloc, HomeClientState>(
                        builder: (context, state) {
                          return CurrentTripWidget(
                            currentTrip: state.currentTrip,
                            onCancel: () {
                              // Cancelar viaje
                              if (state.currentTrip != null) {
                                showDialog(
                                  context: context,
                                  builder: (dialogContext) => AlertDialog(
                                    title: const Text('Cancelar viaje'),
                                    content: const Text(
                                      '¿Estás seguro que deseas cancelar el viaje?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(dialogContext),
                                        child: const Text('No'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(dialogContext);
                                          context.read<HomeClientBloc>().add(
                                            CancelTripEvent(
                                              state.currentTrip!.id,
                                            ),
                                          );
                                        },
                                        child: const Text('Sí, cancelar'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            onContactDriver: () {
                              // Llamar al conductor
                              if (state.currentTrip?.driverPhone != null) {
                                debugPrint(
                                  '📞 Llamando a: ${state.currentTrip!.driverPhone}',
                                );
                                // TODO: Abrir app de teléfono
                                // url_launcher: tel:${state.currentTrip!.driverPhone}
                              }
                            },
                            onViewDetails: () {
                              // Ver detalles del viaje
                              debugPrint(
                                '👀 Ver detalles del viaje: ${state.currentTrip?.id}',
                              );
                              // TODO: Navegar a pantalla de detalles
                              // AppRouter.go(Routes.tripDetails, extra: state.currentTrip);
                            },
                          );
                        },
                      ),
                    ),
                  ),

                  // Quick Actions
                  // SliverToBoxAdapter(
                  //   child: Padding(
                  //     padding: EdgeInsets.symmetric(vertical: 16.h),
                  //     child: const QuickActionsWidget(),
                  //   ),
                  // ),

                  // Cooperativas
                  // SliverToBoxAdapter(
                  //   child: Padding(
                  //     padding: EdgeInsets.symmetric(vertical: 16.h),
                  //     child: const CooperativasSectionWidget(),
                  //   ),
                  // ),

                  // Viajes Recientes
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: const RecentTripsSectionWidget(),
                    ),
                  ),

                  // Promociones
                  // SliverToBoxAdapter(
                  //   child: Padding(
                  //     padding: EdgeInsets.symmetric(vertical: 16.h),
                  //     child: const PromotionsSectionWidget(),
                  //   ),
                  // ),

                  // Stats / Credibilidad
                  // SliverToBoxAdapter(
                  //   child: Padding(
                  //     padding: EdgeInsets.symmetric(vertical: 16.h),
                  //     child: const StatsSectionWidget(),
                  //   ),
                  // ),

                  // Cómo Funciona
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: const HowItWorksSectionWidget(),
                    ),
                  ),

                  // Métodos de Pago
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: const PaymentMethodsSectionWidget(),
                    ),
                  ),

                  // Espacio extra para el FAB
                  SliverPadding(padding: EdgeInsets.only(bottom: 100.h)),
                ],
              ),
            ),
          ),

          // FAB Flotante (siempre visible)
          const Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: FloatingActionTaxiButton(),
          ),
        ],
      ),
    );
  }
}
