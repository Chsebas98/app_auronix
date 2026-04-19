import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:auronix_app/shared/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileDrawer extends StatelessWidget {
  final ProfileDrawerConfig config;

  const ProfileDrawer({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: theme.primaryColor,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),

            16.verticalSpace,

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: config.items.length,
                itemBuilder: (context, index) {
                  final item = config.items[index];
                  return Column(
                    children: [
                      _buildItem(context, item),
                      if (item.showDivider)
                        const Divider(height: 24, thickness: 1),
                    ],
                  );
                },
              ),
            ),

            _buildLogoutButton(context),

            16.verticalSpace,
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    return InkWell(
      onTap: config.onProfileTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              (config.roleColor ?? AppColors.third).withValues(alpha: 0.2),
              (config.roleColor ?? AppColors.third).withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border(bottom: BorderSide(color: colors.border, width: 1)),
        ),
        child: Column(
          children: [
            // Foto de perfil
            Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.third, width: 3),
                    image:
                        config.photoUrl != null && config.photoUrl!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(config.photoUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: AppColors.third.withValues(alpha: 0.3),
                  ),
                  child: config.photoUrl == null || config.photoUrl!.isEmpty
                      ? Icon(Icons.person, size: 40, color: colors.icon)
                      : null,
                ),
                // Badge de verificado (opcional)
                if (config.onProfileTap != null)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.third,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.primaryColor, width: 2),
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 14,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Nombre
            Text(
              config.userName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.text,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            // Email
            Text(
              config.userEmail,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Badge de rol
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: (config.roleColor ?? AppColors.third).withValues(
                  alpha: 0.2,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: config.roleColor ?? AppColors.third,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getRoleIcon(config.userRole),
                    size: 16,
                    color: config.roleColor ?? AppColors.third,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    config.userRole,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: config.roleColor ?? AppColors.third,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Item individual del drawer
  Widget _buildItem(BuildContext context, ProfileDrawerItem item) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    return ListTile(
      onTap: () {
        Navigator.pop(context); // Cerrar drawer
        item.onTap(); // Ejecutar acción
      },
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (item.iconColor ?? AppColors.third).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          item.icon,
          color: item.iconColor ?? AppColors.third,
          size: 22,
        ),
      ),
      title: Text(
        item.title,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: colors.text,
        ),
      ),
      trailing:
          item.trailing ??
          Icon(Icons.chevron_right, color: colors.textSecondary, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  /// Botón de cerrar sesión
  Widget _buildLogoutButton(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.pop(context); // Cerrar drawer
          config.onLogout(); // Ejecutar logout
        },
        icon: const Icon(Icons.logout, size: 20),
        label: Text('Cerrar sesión', style: theme.textTheme.labelLarge),
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.button,
          // iconColor: colors.icon,
          side: BorderSide(color: colors.borderPrimary, width: 1.5),
          minimumSize: const Size(double.infinity, 48),
        ),
      ),
    );
  }

  /// Helper: Icono según el rol
  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'cliente':
      case 'pasajero':
        return Icons.person;
      case 'conductor':
      case 'driver':
        return Icons.local_taxi;
      case 'gerente':
      case 'manager':
        return Icons.business_center;
      case 'admin':
      case 'administrador':
        return Icons.admin_panel_settings;
      case 'socio':
      case 'miembro':
        return Icons.card_membership;
      default:
        return Icons.badge;
    }
  }
}
