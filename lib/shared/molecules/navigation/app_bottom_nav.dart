import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/shared/atoms/radius/app_radius.dart';
import 'package:auronix_app/shared/atoms/spacing/app_spacing.dart';
import 'package:auronix_app/shared/templates/appbar/bottom-appbar/models/interfaces/shared_item_nav.dart';

import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    required this.role,
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final Roles role;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = tabsForRole(role);
    final selectedColor = AppColors.third;
    final unselectedColor = theme.dividerColor;

    return SafeArea(
      top: false,
      child: Row(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isSelected = i == currentIndex;

          return Expanded(
            child: InkResponse(
              onTap: () => onTap(i),
              radius: 28,
              containedInkWell: true,
              highlightShape: BoxShape.rectangle,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.x2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.iconFor(theme),
                      size: 24,
                      color: isSelected ? selectedColor : unselectedColor,
                    ),
                    const SizedBox(height: AppSpacing.x1),
                    Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isSelected ? selectedColor : unselectedColor,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: AppSpacing.x1),
                    // ── Indicador animado ──────────────────────────────
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      height: 3,
                      width: isSelected ? 22 : 0,
                      decoration: BoxDecoration(
                        color: isSelected ? selectedColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
