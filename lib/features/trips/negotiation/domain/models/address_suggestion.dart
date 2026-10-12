import 'package:equatable/equatable.dart';

/// Resultado de `GET /geo/autocomplete` / `GET /geo/reverse` (docs/
/// requerimientos_backend.md sección 4.5) — proxy del backend a LocationIQ,
/// la clave de API no vive en el cliente.
class AddressSuggestion extends Equatable {
  final String label;
  final double lat;
  final double lng;

  const AddressSuggestion({
    required this.label,
    required this.lat,
    required this.lng,
  });

  factory AddressSuggestion.fromJson(Map<String, dynamic> json) {
    return AddressSuggestion(
      label: json['label'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0,
    );
  }

  @override
  List<Object?> get props => [label, lat, lng];
}
