import 'package:auronix_app/app/theme/theme.dart';
import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/shared/shared.dart';
import 'package:flutter/material.dart';

class BottomNavigationHome extends StatelessWidget {
  const BottomNavigationHome({
    super.key,
    required this.role,
    required this.currentIndex,
    required this.onTap,
  });

  final Roles role;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = tabsForRole(role);

    // PRO: usa un color de “accent” consistente (amarillo taxi o el que tengas para highlight)
    final selectedColor = AppColors.third;
    final unselectedColor = theme.dividerColor;

    return SafeArea(
      top: false,
      child: Row(
        children: List.generate(items.length, (i) {
          final it = items[i];
          final selected = i == currentIndex;

          return Expanded(
            child: InkResponse(
              onTap: () => onTap(i),
              // PRO: radio agradable (se siente más “iOS/Android”)
              radius: 28,
              containedInkWell: true,
              highlightShape: BoxShape.rectangle,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      it.iconFor(theme),
                      size: 24,
                      color: selected ? selectedColor : unselectedColor,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      it.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: selected ? selectedColor : unselectedColor,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),

                    // underline / indicator
                    const SizedBox(height: 6),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      height: 3,
                      width: selected ? 22 : 0, // subrayado corto tipo pro
                      decoration: BoxDecoration(
                        color: selected ? selectedColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(999),
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
