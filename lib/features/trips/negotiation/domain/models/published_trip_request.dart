import 'package:equatable/equatable.dart';

/// Resultado de `POST /trips/requests` (docs/database.md `solicitud_viaje`,
/// docs/flow.md sección 3) — la solicitud recién publicada, visible para
/// conductores `DISPONIBLE` dentro de 10 km hasta `expiraEn` (5 minutos
/// fijos, sin extensión posible).
class PublishedTripRequest extends Equatable {
  final String id;
  final String estado;
  final double precioPublicado;
  final String moneda;
  final DateTime expiraEn;

  const PublishedTripRequest({
    required this.id,
    required this.estado,
    required this.precioPublicado,
    required this.moneda,
    required this.expiraEn,
  });

  factory PublishedTripRequest.fromJson(Map<String, dynamic> json) {
    return PublishedTripRequest(
      id: json['id'].toString(),
      estado: json['estado'] as String? ?? 'PUBLICADA',
      precioPublicado: (json['precioPublicado'] as num).toDouble(),
      moneda: json['moneda'] as String,
      expiraEn: DateTime.parse(json['expiraEn'] as String),
    );
  }

  @override
  List<Object?> get props => [id, estado, precioPublicado, moneda, expiraEn];
}
