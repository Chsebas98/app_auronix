import 'package:auronix_app/shared/atoms/spacing/app_spacing.dart';
import 'package:auronix_app/shared/molecules/skeleton/app_skeleton_list_tile.dart';
import 'package:flutter/material.dart';

/// Marcadores de posicion animados mientras se obtienen las predicciones de
/// autocompletado (T20-C9). Reutiliza AppSkeletonListTile (shimmer ya
/// existente) en vez de un shimmer propio.
class SkeletonPredictionList extends StatelessWidget {
  const SkeletonPredictionList({this.itemCount = 4, super.key});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Buscando lugares',
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (_, __) => const AppSkeletonListTile(),
      ),
    );
  }
}
