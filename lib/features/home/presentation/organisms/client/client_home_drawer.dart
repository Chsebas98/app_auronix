import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/app/core/bloc/dialog-cubit/dialog_cubit.dart';
import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/app/router/client/client_routes_path.dart';
import 'package:auronix_app/app/router/router.dart';
import 'package:auronix_app/features/home/presentation/bloc/client/home_client_bloc.dart';
import 'package:auronix_app/shared/templates/drawer/profile-drawer/profile_drawer.dart';
import 'package:auronix_app/shared/templates/drawer/profile-drawer/profile_drawer_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClientHomeDrawer extends StatelessWidget {
  const ClientHomeDrawer({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await context.read<DialogCubit>().showConfirm(
      title: 'Cerrar sesion?',
      message: 'Estas seguro que deseas cerrar sesion?',
      okText: 'Cerrar sesion',
      cancelText: 'Cancelar',
    );
    if (confirmed && context.mounted) {
      context.read<SessionBloc>().add(LoggoutUserEvent());
      AppRouter.go(Routes.auth);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeClientBloc, HomeClientState>(
      builder: (context, state) {
        final user = state.dataProfile;
        return ProfileDrawer(
          config: ProfileDrawerConfig(
            userName: user.username.isNotEmpty
                ? user.username
                : user.firstName.isNotEmpty
                ? user.firstName
                : 'Usuario',
            userEmail: user.email,
            userRole: 'Cliente',
            photoUrl: user.photoUrl.isNotEmpty ? user.photoUrl : null,
            roleColor: AppColors.third,
            onProfileTap: () => AppRouter.push(ClientRoutesPath.profile),
            onLogout: () => _handleLogout(context),
            items: [
              ProfileDrawerItem(
                title: 'Mi perfil',
                icon: Icons.person_outline,
                onTap: () => AppRouter.push(ClientRoutesPath.profile),
              ),
              ProfileDrawerItem(
                title: 'Mis viajes',
                icon: Icons.history,
                onTap: () => AppRouter.push(ClientRoutesPath.saveTrips),
              ),
              ProfileDrawerItem(
                title: 'Metodos de pago',
                icon: Icons.payment,
                onTap: () => debugPrint('Metodos de pago'),
              ),
              ProfileDrawerItem(
                title: 'Notificaciones',
                icon: Icons.notifications_outlined,
                trailing: _NotificationBadge(count: 3),
                onTap: () => debugPrint('Notificaciones'),
                showDivider: true,
              ),
              ProfileDrawerItem(
                title: 'Ayuda y soporte',
                icon: Icons.help_outline,
                onTap: () => debugPrint('Ayuda'),
              ),
              ProfileDrawerItem(
                title: 'Configuracion',
                icon: Icons.settings_outlined,
                onTap: () => debugPrint('Configuracion'),
              ),
              ProfileDrawerItem(
                title: 'Acerca de',
                icon: Icons.info_outline,
                onTap: () => AppRouter.push(Routes.about),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NotificationBadge extends StatelessWidget {
  const _NotificationBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.sevent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
