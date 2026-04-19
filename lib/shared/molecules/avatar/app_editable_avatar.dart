import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

class AppEditableAvatar extends StatelessWidget {
  const AppEditableAvatar({
    this.size = 120,
    this.image,
    this.onEdit,
    this.onTap,
    this.showEdit = true,
    this.placeholder,
    this.editIcon = Icons.edit,
    super.key,
  });

  final double size;
  final ImageProvider? image;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;
  final bool showEdit;

  /// Widget que se muestra si no hay imagen
  final Widget? placeholder;
  final IconData editIcon;

  double get _editButtonSize => size * 0.28;
  double get _editButtonRadius => size * 0.09;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Avatar ──────────────────────────────────────────────────────
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: CircleAvatar(
                radius: size / 2,

                backgroundColor: colors.textSecondary,
                foregroundImage: image,
                child: image == null
                    ? (placeholder ??
                          Icon(
                            Icons.person,
                            size: size * 0.45,
                            color: AppColors.white,
                          ))
                    : null,
              ),
            ),
          ),

          // ── Edit button ─────────────────────────────────────────────────
          if (showEdit)
            Positioned(
              right: 4,
              bottom: 4,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(_editButtonRadius),
                  child: Container(
                    width: _editButtonSize,
                    height: _editButtonSize,
                    decoration: BoxDecoration(
                      color: colors.button,
                      borderRadius: BorderRadius.circular(_editButtonRadius),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.overlay,
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      editIcon,
                      color: AppColors.secondary,
                      size: _editButtonSize * 0.55,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
