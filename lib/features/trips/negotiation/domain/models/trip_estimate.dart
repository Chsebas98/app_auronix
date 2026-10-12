import 'package:equatable/equatable.dart';

/// Resultado de `POST /trips/estimate` (docs/requerimientos_backend.md
/// sección 4.1, docs/flow.md sección 3) — el backend calcula distancia,
/// duración y precio sugerido; el cliente nunca estima estos valores
/// localmente. El backend rechaza la solicitud (con mensaje claro) si
/// `distanciaKm > 150` o si origen/destino caen en países distintos.
class TripEstimate extends Equatable {
  final double distanciaKm;
  final double duracionEstimadaMin;
  final double precioSugerido;
  final String moneda;

  const TripEstimate({
    required this.distanciaKm,
    required this.duracionEstimadaMin,
    required this.precioSugerido,
    required this.moneda,
  });

  factory TripEstimate.fromJson(Map<String, dynamic> json) {
    return TripEstimate(
      distanciaKm: (json['distanciaKm'] as num).toDouble(),
      duracionEstimadaMin: (json['duracionEstimadaMin'] as num).toDouble(),
      precioSugerido: (json['precioSugerido'] as num).toDouble(),
      moneda: json['moneda'] as String,
    );
  }

  @override
  List<Object?> get props => [
    distanciaKm,
    duracionEstimadaMin,
    precioSugerido,
    moneda,
  ];
}
