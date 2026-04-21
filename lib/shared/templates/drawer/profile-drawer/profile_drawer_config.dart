import 'package:flutter/material.dart'
    show Color, VoidCallback, Widget, IconData;

/// Configuración completa del ProfileDrawer
class ProfileDrawerConfig {
  final String userName;
  final String userEmail;
  final String userRole; // "Cliente", "Conductor", "Gerente", etc.
  final String? photoUrl;
  final Color? roleColor; // Color del badge del rol
  final List<ProfileDrawerItem> items;
  final VoidCallback onLogout;
  final VoidCallback? onProfileTap; // Opcional: tap en el header

  const ProfileDrawerConfig({
    required this.userName,
    required this.userEmail,
    required this.userRole,
    this.photoUrl,
    this.roleColor,
    required this.items,
    required this.onLogout,
    this.onProfileTap,
  });
}

/// Item individual del drawer
class ProfileDrawerItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final Widget? trailing; // Badge, contador, etc.
  final bool showDivider; // Mostrar divider después de este item

  const ProfileDrawerItem({
    required this.title,
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.trailing,
    this.showDivider = false,
  });
}
