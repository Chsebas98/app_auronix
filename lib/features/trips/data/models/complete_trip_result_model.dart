import 'package:auronix_app/features/trips/domain/models/interfaces/complete_trip_result.dart';

class CompleteTripResultModel {
  final int id;
  final String estado;
  final double precioTotal;
  final double comisionMonto;
  final double montoConductor;
  final String fechaFin;

  const CompleteTripResultModel({
    required this.id,
    required this.estado,
    required this.precioTotal,
    required this.comisionMonto,
    required this.montoConductor,
    required this.fechaFin,
  });

  factory CompleteTripResultModel.fromJson(Map<String, dynamic> json) =>
      CompleteTripResultModel(
        id: json['id'] as int,
        estado: json['estado'] as String? ?? '',
        precioTotal: (json['precioTotal'] as num).toDouble(),
        comisionMonto: (json['comisionMonto'] as num).toDouble(),
        montoConductor: (json['montoConductor'] as num).toDouble(),
        fechaFin: json['fechaFin'] as String? ?? '',
      );

  CompleteTripResult toEntity() => CompleteTripResult(
        id: id,
        estado: estado,
        precioTotal: precioTotal,
        comisionMonto: comisionMonto,
        montoConductor: montoConductor,
        fechaFin: fechaFin,
      );
}
