import 'package:auronix_app/core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NavItem {
  final AppTab tab;
  final String label;
  final IconData cupertino;
  final IconData material;

  const NavItem({
    required this.tab,
    required this.label,
    required this.cupertino,
    required this.material,
  });

  IconData iconFor(ThemeData theme) {
    final p = theme.platform;
    final isIOS = p == TargetPlatform.iOS || p == TargetPlatform.macOS;
    return isIOS ? cupertino : material;
  }
}

List<NavItem> tabsForRole(Roles role) {
  switch (role) {
    case Roles.rolAdmin: // SuperAdmin
      return const [
        NavItem(
          tab: AppTab.home,
          label: 'Inicio',
          cupertino: CupertinoIcons.house_fill,
          material: Icons.home_rounded,
        ),
        NavItem(
          tab: AppTab.cooperativas,
          label: 'Coops',
          cupertino: CupertinoIcons.building_2_fill,
          material: Icons.apartment_rounded,
        ),
        NavItem(
          tab: AppTab.supervision,
          label: 'Supervisión',
          cupertino: CupertinoIcons.eye_fill,
          material: Icons.visibility_rounded,
        ),
        NavItem(
          tab: AppTab.pagos,
          label: 'Pagos',
          cupertino: CupertinoIcons.creditcard_fill,
          material: Icons.payments_rounded,
        ),
        // NavItem(
        //   tab: AppTab.mas,
        //   label: 'Más',
        //   cupertino: CupertinoIcons.ellipsis_circle,
        //   material: Icons.more_horiz_rounded,
        // ),
      ];

    case Roles.rolGerente: // Gerente Cooperativa
      return const [
        NavItem(
          tab: AppTab.home,
          label: 'Inicio',
          cupertino: CupertinoIcons.house_fill,
          material: Icons.home_rounded,
        ),
        NavItem(
          tab: AppTab.pagos,
          label: 'Pagos',
          cupertino: CupertinoIcons.creditcard_fill,
          material: Icons.payments_rounded,
        ),
        NavItem(
          tab: AppTab.ganancias,
          label: 'Ganancias',
          cupertino: CupertinoIcons.money_dollar_circle_fill,
          material: Icons.savings_rounded,
        ),
        NavItem(
          tab: AppTab.gestion,
          label: 'Gestión',
          cupertino: CupertinoIcons.person_2_fill,
          material: Icons.groups_rounded,
        ),
        // NavItem(
        //   tab: AppTab.mas,
        //   label: 'Más',
        //   cupertino: CupertinoIcons.ellipsis_circle,
        //   material: Icons.more_horiz_rounded,
        // ),
      ];

    case Roles.rolDriver: // Conductor
      return const [
        NavItem(
          tab: AppTab.home,
          label: 'Inicio',
          cupertino: CupertinoIcons.house_fill,
          material: Icons.home_rounded,
        ),
        NavItem(
          tab: AppTab.viajes,
          label: 'Viajes',
          cupertino: CupertinoIcons.car_detailed,
          material: Icons.directions_car_rounded,
        ),
        // NavItem(
        //   tab: AppTab.mensajes,
        //   label: 'Mensajes',
        //   cupertino: CupertinoIcons.chat_bubble_2_fill,
        //   material: Icons.chat_bubble_rounded,
        // ),
        NavItem(
          tab: AppTab.ganancias,
          label: 'Ganancias',
          cupertino: CupertinoIcons.money_dollar_circle_fill,
          material: Icons.savings_rounded,
        ),
        NavItem(
          tab: AppTab.vehiculo,
          label: 'Vehículo',
          cupertino: CupertinoIcons.car_fill,
          material: Icons.car_rental_rounded,
        ),
        // NavItem(
        //   tab: AppTab.mas,
        //   label: 'Más',
        //   cupertino: CupertinoIcons.ellipsis_circle,
        //   material: Icons.more_horiz_rounded,
        // ),
      ];

    case Roles.rolMember: // Miembro temporal
      return const [
        NavItem(
          tab: AppTab.home,
          label: 'Inicio',
          cupertino: CupertinoIcons.house_fill,
          material: Icons.home_rounded,
        ),
        NavItem(
          tab: AppTab.asignados,
          label: 'Asignados',
          cupertino: CupertinoIcons.person_crop_circle_badge_checkmark,
          material: Icons.assignment_ind_rounded,
        ),
        NavItem(
          tab: AppTab.mensajes,
          label: 'Mensajes',
          cupertino: CupertinoIcons.chat_bubble_2_fill,
          material: Icons.chat_bubble_rounded,
        ),
        NavItem(
          tab: AppTab.ganancias,
          label: 'Ganancias',
          cupertino: CupertinoIcons.money_dollar_circle_fill,
          material: Icons.savings_rounded,
        ),
        // NavItem(
        //   tab: AppTab.mas,
        //   label: 'Más',
        //   cupertino: CupertinoIcons.ellipsis_circle,
        //   material: Icons.more_horiz_rounded,
        // ),
      ];

    case Roles.rolUser: // Pasajero
      return const [
        NavItem(
          tab: AppTab.home,
          label: 'Inicio',
          cupertino: CupertinoIcons.house_fill,
          material: Icons.home_rounded,
        ),
        // NavItem(
        //   tab: AppTab.viajes,
        //   label: 'Viajes',
        //   cupertino: CupertinoIcons.car_fill,
        //   material: Icons.directions_car_rounded,
        // ),
        NavItem(
          tab: AppTab.mensajes,
          label: 'Mensajes',
          cupertino: CupertinoIcons.chat_bubble_2_fill,
          material: Icons.chat_bubble_rounded,
        ),
        NavItem(
          tab: AppTab.guardados,
          label: 'Guardados',
          cupertino: CupertinoIcons.bookmark_fill,
          material: Icons.bookmark_rounded,
        ),
        // NavItem(
        //   tab: AppTab.cuenta,
        //   label: 'Cuenta',
        //   cupertino: CupertinoIcons.person_crop_circle,
        //   material: Icons.person_rounded,
        // ),
        // NavItem(
        //   tab: AppTab.mas,
        //   label: 'Más',
        //   cupertino: CupertinoIcons.ellipsis_circle,
        //   material: Icons.more_horiz_rounded,
        // ),
      ];
  }
}
