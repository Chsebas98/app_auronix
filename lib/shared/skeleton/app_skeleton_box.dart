import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:auronix_app/shared/atoms/radius/app_radius.dart';
import 'package:flutter/material.dart';

class AppSkeletonBox extends StatefulWidget {
  const AppSkeletonBox({
    this.width,
    this.height,
    this.borderRadius = AppRadius.sm,
    super.key,
  });

  final double? width;
  final double? height;
  final double borderRadius;

  @override
  State<AppSkeletonBox> createState() => _AppSkeletonBoxState();
}

class _AppSkeletonBoxState extends State<AppSkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Usa AppColorsTheme — respeta dark mode automáticamente
    final colors = context.appColors;

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final t = _controller.value;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1 + 2 * t, 0),
              end: Alignment(1 + 2 * t, 0),
              // ✅ light → gris claro / dark → gris oscuro
              colors: [
                colors.skeletonBase,
                colors.skeletonHighlight,
                colors.skeletonBase,
              ],
            ),
          ),
        );
      },
    );
  }
}
