import 'package:equatable/equatable.dart';

/// Estado de verificación documental de un conductor.
///
/// Gestionado íntegramente por el flujo externo (portal + admin, fuera de
/// este repo) — la app móvil solo lo lee. Ver docs/database.md (`conductor.estado_verificacion`).
enum EstadoVerificacion { pendiente, aprobado, rechazado }

extension EstadoVerificacionRaw on EstadoVerificacion {
  static EstadoVerificacion fromRaw(String? raw) {
    switch (raw) {
      case 'APROBADO':
        return EstadoVerificacion.aprobado;
      case 'RECHAZADO':
        return EstadoVerificacion.rechazado;
      case 'PENDIENTE':
      default:
        return EstadoVerificacion.pendiente;
    }
  }

  String get raw => switch (this) {
    EstadoVerificacion.aprobado => 'APROBADO',
    EstadoVerificacion.rechazado => 'RECHAZADO',
    EstadoVerificacion.pendiente => 'PENDIENTE',
  };
}

/// Respuesta de `GET /drivers/me/estado-verificacion`
/// (docs/requerimientos_backend.md sección 4.1).
class DriverVerificationStatus extends Equatable {
  final EstadoVerificacion estado;
  final String? cooperativaNombre;

  const DriverVerificationStatus({
    required this.estado,
    this.cooperativaNombre,
  });

  factory DriverVerificationStatus.fromJson(Map<String, dynamic> json) {
    return DriverVerificationStatus(
      estado: EstadoVerificacionRaw.fromRaw(
        json['estadoVerificacion'] as String?,
      ),
      cooperativaNombre: json['cooperativaNombre'] as String?,
    );
  }

  @override
  List<Object?> get props => [estado, cooperativaNombre];
}
