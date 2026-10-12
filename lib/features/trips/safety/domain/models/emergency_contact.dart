import 'package:equatable/equatable.dart';

/// `contacto_emergencia` (docs/database.md) — obligatorio: un usuario debe
/// tener al menos uno antes de publicar una solicitud o ponerse DISPONIBLE.
class EmergencyContact extends Equatable {
  final String id;
  final String nombre;
  final String telefono;
  final String relacion;

  const EmergencyContact({
    required this.id,
    required this.nombre,
    required this.telefono,
    required this.relacion,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'].toString(),
      nombre: json['nombre'] as String? ?? '',
      telefono: json['telefono'] as String? ?? '',
      relacion: json['relacion'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [id, nombre, telefono, relacion];
}
