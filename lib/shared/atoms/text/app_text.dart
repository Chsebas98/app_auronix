import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

enum AppTextVariant {
  displayLarge,
  displayMedium,
  displaySmall,
  headlineLarge,
  headlineMedium,
  headlineSmall,
  titleLarge,
  titleMedium,
  titleSmall,
  bodyLarge,
  bodyMedium,
  bodySmall,
  labelLarge,
  labelMedium,
  labelSmall,
}

class AppText extends StatelessWidget {
  const AppText(
    this.text, {
    this.variant = AppTextVariant.bodyMedium,
    this.color,
    this.align,
    this.maxLines,
    this.overflow,
    this.fontWeight,
    super.key,
  });

  final String text;
  final AppTextVariant variant;
  final Color? color;
  final TextAlign? align;
  final int? maxLines;
  final TextOverflow? overflow;
  final FontWeight? fontWeight;

  @override
  Widget build(BuildContext context) {
    final style = _resolveStyle(context);

    return AutoSizeText(
      text,
      textAlign: align,
      maxLines: maxLines,
      overflow: overflow ?? (maxLines != null ? TextOverflow.ellipsis : null),
      style: style.copyWith(color: color, fontWeight: fontWeight),
    );
  }

  TextStyle _resolveStyle(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return switch (variant) {
      AppTextVariant.displayLarge => tt.displayLarge!,
      AppTextVariant.displayMedium => tt.displayMedium!,
      AppTextVariant.displaySmall => tt.displaySmall!,
      AppTextVariant.headlineLarge => tt.headlineLarge!,
      AppTextVariant.headlineMedium => tt.headlineMedium!,
      AppTextVariant.headlineSmall => tt.headlineSmall!,
      AppTextVariant.titleLarge => tt.titleLarge!,
      AppTextVariant.titleMedium => tt.titleMedium!,
      AppTextVariant.titleSmall => tt.titleSmall!,
      AppTextVariant.bodyLarge => tt.bodyLarge!,
      AppTextVariant.bodyMedium => tt.bodyMedium!,
      AppTextVariant.bodySmall => tt.bodySmall!,
      AppTextVariant.labelLarge => tt.labelLarge!,
      AppTextVariant.labelMedium => tt.labelMedium!,
      AppTextVariant.labelSmall => tt.labelSmall!,
    };
  }
}
