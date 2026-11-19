import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:auronix_app/features/auth/domain/models/user_role.dart';
import 'package:auronix_app/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Seleccion explicita de rol (Pasajero/Conductor) para el registro (T14).
/// No permite ningun valor por defecto: [selected] es null hasta que el
/// usuario elige, para que el formulario pueda exigir una eleccion real
/// (T14-C2/T14-C5) en vez de asumir un rol tacito.
class RoleSelector extends StatelessWidget {
  const RoleSelector({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final UserRole? selected;
  final ValueChanged<UserRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _RoleOption(
            label: 'Pasajero',
            icon: Icons.person_outline,
            isSelected: selected == UserRole.pasajero,
            onTap: () => onChanged(UserRole.pasajero),
          ),
        ),
        12.horizontalSpace,
        Expanded(
          child: _RoleOption(
            label: 'Conductor',
            icon: Icons.directions_car_outlined,
            isSelected: selected == UserRole.conductor,
            onTap: () => onChanged(UserRole.conductor),
          ),
        ),
      ],
    );
  }
}

class _RoleOption extends StatelessWidget {
  const _RoleOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colors.button : colors.border,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? colors.button.withValues(alpha: 0.08) : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? colors.button : colors.text),
            8.verticalSpace,
            AppText(
              label,
              variant: AppTextVariant.bodyMedium,
              color: isSelected ? colors.button : colors.text,
            ),
          ],
        ),
      ),
    );
  }
}
