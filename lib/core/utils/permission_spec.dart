import 'package:auronix_app/app/core/permission/domain/models/interfaces/app_permission_type.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionSpec {
  final AppPermissionType type;
  final String title;
  final String description;
  final Permission permission;

  const PermissionSpec({
    required this.type,
    required this.title,
    required this.description,
    required this.permission,
  });
}

PermissionSpec specOf(AppPermissionType type) {
  switch (type) {
    case AppPermissionType.locationWhenInUse:
      return const PermissionSpec(
        type: AppPermissionType.locationWhenInUse,
        title: 'Ubicación mientras se usa la app',
        description:
            'Esto permite mejorar el seguimiento del viaje y la seguridad.',
        permission: Permission.locationWhenInUse,
      );

    case AppPermissionType.locationAlways:
      return const PermissionSpec(
        type: AppPermissionType.locationAlways,
        title: 'Ubicación en segundo plano',
        description:
            'Esto permite mejorar el seguimiento del viaje y la seguridad.',
        permission: Permission.locationAlways,
      );

    case AppPermissionType.camera:
      return const PermissionSpec(
        type: AppPermissionType.camera,
        title: 'Acceso a la cámara',
        description:
            'Necesitamos la cámara para escanear documentos o tomar fotos.',
        permission: Permission.camera,
      );

    case AppPermissionType.mediaLibrary:
      return const PermissionSpec(
        type: AppPermissionType.mediaLibrary,
        title: 'Acceso a la biblioteca multimedia',
        description:
            'Necesitamos acceso a la biblioteca multimedia para seleccionar fotos o videos.',
        permission: Permission.photos,
      );
  }
}
