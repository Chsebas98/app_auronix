import 'package:auronix_app/app/theme/theme.dart';
import 'package:flutter/material.dart';

class EditableAvatar extends StatelessWidget {
  const EditableAvatar({
    super.key,
    this.size = 120,
    this.image,
    this.onEdit,
    this.onTap,
    this.showEdit = true,
    this.backgroundColor = AppColors.fourth,
    this.borderColor,
    this.borderWidth = 0,
    this.placeholder,
    this.editBackgroundColor = AppColors.nineth, // taxi yellow
    this.editIconColor = AppColors.black,
    this.editButtonSize = 34,
    this.editButtonRadius = 10,
    this.editIcon = Icons.edit,
  });

  final double size;
  final ImageProvider? image;

  final VoidCallback? onEdit;
  final VoidCallback? onTap;

  final bool showEdit;

  final Color backgroundColor;
  final Color? borderColor;
  final double borderWidth;

  /// Widget que se muestra si no hay imagen (por ejemplo un ícono o iniciales)
  final Widget? placeholder;

  // Edit button
  final Color editBackgroundColor;
  final Color editIconColor;
  final double editButtonSize;
  final double editButtonRadius;
  final IconData editIcon;

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderWidth > 0
            ? Border.all(
                color: borderColor ?? Colors.transparent,
                width: borderWidth,
              )
            : null,
      ),
      child: CircleAvatar(
        radius: size / 2,
        backgroundColor: backgroundColor,
        foregroundImage: image, // foto principal
        child: image == null
            ? (placeholder ??
                  Icon(Icons.person, size: size * 0.45, color: AppColors.white))
            : null,
      ),
    );

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: avatar,
            ),
          ),
          if (showEdit)
            Positioned(
              right: 4,
              bottom: 4,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(editButtonRadius),
                  child: Container(
                    width: editButtonSize,
                    height: editButtonSize,
                    decoration: BoxDecoration(
                      color: editBackgroundColor,
                      borderRadius: BorderRadius.circular(editButtonRadius),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 10,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      editIcon,
                      color: editIconColor,
                      size: editButtonSize * 0.55,
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
