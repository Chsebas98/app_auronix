import 'package:equatable/equatable.dart';

/// `GET /config/public` (docs/requerimientos_backend.md sección 4.4) —
/// valores de negocio que el administrador cambia desde el dashboard; el
/// cliente nunca debe hardcodearlos.
class PublicConfig extends Equatable {
  final double precioMinimoTrayecto;
  final String moneda;
  final double distanciaMaximaKm;
  final double radioBusquedaKm;
  final double rangoContraofertaMinPct;
  final double rangoContraofertaMaxPct;

  const PublicConfig({
    required this.precioMinimoTrayecto,
    required this.moneda,
    required this.distanciaMaximaKm,
    required this.radioBusquedaKm,
    required this.rangoContraofertaMinPct,
    required this.rangoContraofertaMaxPct,
  });

  /// No usa valores por defecto para campos faltantes a propósito (docs/
  /// testing.md caso #19): un JSON incompleto debe fallar el parseo y dejar
  /// que [PublicConfigService] caiga al valor cacheado o reporte
  /// indisponibilidad — nunca inventar un precio mínimo u otro valor.
  factory PublicConfig.fromJson(Map<String, dynamic> json) {
    return PublicConfig(
      precioMinimoTrayecto: (json['precioMinimoTrayecto'] as num).toDouble(),
      moneda: json['moneda'] as String,
      distanciaMaximaKm: (json['distanciaMaximaKm'] as num).toDouble(),
      radioBusquedaKm: (json['radioBusquedaKm'] as num).toDouble(),
      rangoContraofertaMinPct: (json['rangoContraofertaMinPct'] as num)
          .toDouble(),
      rangoContraofertaMaxPct: (json['rangoContraofertaMaxPct'] as num)
          .toDouble(),
    );
  }

  @override
  List<Object?> get props => [
    precioMinimoTrayecto,
    moneda,
    distanciaMaximaKm,
    radioBusquedaKm,
    rangoContraofertaMinPct,
    rangoContraofertaMaxPct,
  ];
}
