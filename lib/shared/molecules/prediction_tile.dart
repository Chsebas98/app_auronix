import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:auronix_app/features/home/domain/entities/place_prediction.dart';
import 'package:auronix_app/shared/atoms/radius/app_radius.dart';
import 'package:auronix_app/shared/atoms/spacing/app_spacing.dart';
import 'package:auronix_app/shared/atoms/text/app_text.dart';
import 'package:flutter/material.dart';

/// Item de la lista de sugerencias de autocompletado. Area tactil minima
/// 44dp de alto y Semantics de boton (T20-C8).
class PredictionTile extends StatelessWidget {
  const PredictionTile({
    required this.prediction,
    required this.onTap,
    super.key,
  });

  final PlacePrediction prediction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Semantics(
      button: true,
      label: prediction.secondaryText.isNotEmpty
          ? '${prediction.mainText}, ${prediction.secondaryText}'
          : prediction.mainText,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.smAll,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: colors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppText(
                          prediction.mainText,
                          variant: AppTextVariant.bodyMedium,
                          color: colors.text,
                          fontWeight: FontWeight.w600,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (prediction.secondaryText.isNotEmpty)
                          AppText(
                            prediction.secondaryText,
                            variant: AppTextVariant.bodySmall,
                            color: colors.textSecondary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
