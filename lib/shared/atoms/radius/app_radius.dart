import 'package:flutter/material.dart';

final class AppRadius {
  AppRadius._();

  // ── Valores base ───────────────────────────────────────────────────────────
  static const double none = 0.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double full = 999.0; // Pills / círculos

  // ── BorderRadius listos para usar ──────────────────────────────────────────
  static final BorderRadius noneAll = BorderRadius.circular(none);
  static final BorderRadius xsAll = BorderRadius.circular(xs);
  static final BorderRadius smAll = BorderRadius.circular(sm);
  static final BorderRadius mdAll = BorderRadius.circular(md);
  static final BorderRadius lgAll = BorderRadius.circular(lg);
  static final BorderRadius xlAll = BorderRadius.circular(xl);
  static final BorderRadius xxlAll = BorderRadius.circular(xxl);
  static final BorderRadius fullAll = BorderRadius.circular(full);

  // ── Semánticos (por componente) ────────────────────────────────────────────
  static final BorderRadius card = smAll; // 8
  static final BorderRadius input = smAll; // 8
  static final BorderRadius button = fullAll; // pill
  static final BorderRadius dialog = mdAll; // 12
  static final BorderRadius chip = fullAll; // pill
  static final BorderRadius sheet = lgAll; // 16
  static final BorderRadius tooltip = xsAll; // 4
}
