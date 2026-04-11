import 'package:auronix_app/app/core/bloc/dialog-cubit/dialog_cubit.dart';
import 'package:auronix_app/app/core/bloc/session-bloc/session_bloc.dart';
import 'package:auronix_app/app/router/router.dart';
import 'package:auronix_app/app/theme/theme.dart';
import 'package:auronix_app/core/utils/helpers/responsive_helper.dart';
import 'package:auronix_app/features/client/client.dart';
import 'package:auronix_app/features/shared/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeClientPage extends StatelessWidget {
  const HomeClientPage({super.key});

  @override
  Widget build(BuildContext context) {
    Future<void> _handleLogout(BuildContext context) async {
      final confirmed = await context.read<DialogCubit>().showConfirm(
        title: '¿Cerrar sesión?',
        message: '¿Estás seguro que deseas cerrar sesión?',
        okText: 'Cerrar sesión',
        cancelText: 'Cancelar',
      );

      if (confirmed) {
        if (context.mounted) {
          context.read<SessionBloc>().add(LoggoutUserEvent());
          AppRouter.go(Routes.auth);
        }
      }
    }

    return BlocBuilder<HomeClientBloc, HomeClientState>(
      builder: (context, state) {
        final user = state.dataProfile;
        return Scaffold(
          drawer: ProfileDrawer(
            config: ProfileDrawerConfig(
              userName: user.username.isNotEmpty
                  ? user.username
                  : state.dataProfile.firstName.isNotEmpty
                  ? state.dataProfile.firstName
                  : 'Usuario',
              userEmail: user.email,
              userRole: 'Cliente',
              photoUrl: user.photoUrl.isNotEmpty ? user.photoUrl : null,
              roleColor: AppColors.third,
              onProfileTap: () {
                AppRouter.push(ClientRoutesPath.profile);
              },
              items: [
                ProfileDrawerItem(
                  title: 'Mi perfil',
                  icon: Icons.person_outline,
                  onTap: () {
                    AppRouter.push(ClientRoutesPath.profile);
                  },
                ),
                ProfileDrawerItem(
                  title: 'Mis viajes',
                  icon: Icons.history,
                  onTap: () {
                    AppRouter.push(ClientRoutesPath.saveTrips);
                  },
                ),
                ProfileDrawerItem(
                  title: 'Métodos de pago',
                  icon: Icons.payment,
                  onTap: () {
                    debugPrint('💳 Métodos de pago');
                  },
                ),
                ProfileDrawerItem(
                  title: 'Notificaciones',
                  icon: Icons.notifications_outlined,
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.sevent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '3',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  onTap: () {
                    debugPrint('🔔 Ver notificaciones');
                  },
                  showDivider: true, // ✅ Divider después de este item
                ),
                ProfileDrawerItem(
                  title: 'Ayuda y soporte',
                  icon: Icons.help_outline,
                  onTap: () {
                    debugPrint('❓ Ayuda');
                  },
                ),
                ProfileDrawerItem(
                  title: 'Configuración',
                  icon: Icons.settings_outlined,
                  onTap: () {
                    debugPrint('⚙️ Configuración');
                  },
                ),
                ProfileDrawerItem(
                  title: 'Acerca de',
                  icon: Icons.info_outline,
                  onTap: () {
                    AppRouter.push(Routes.about);
                  },
                ),
              ],
              onLogout: () => _handleLogout(context),
            ),
          ),
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
                                              context
                                                  .read<HomeClientBloc>()
                                                  .add(
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
      },
    );
  }
}
