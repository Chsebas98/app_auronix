part of 'permission_cubit.dart';

class PermissionState extends Equatable {
  final PermissionStatus ubicacion;
  final PermissionStatus ubicacionAlways;
  final PermissionStatus ubicacionWhenInUse;
  final bool checking;

  const PermissionState({
    this.ubicacionAlways = PermissionStatus.denied,
    this.ubicacionWhenInUse = PermissionStatus.denied,
    this.ubicacion = PermissionStatus.denied,

    this.checking = true,
  });

  bool get ubicacionGranted => ubicacion == PermissionStatus.granted;
  bool get ubicacionAlwaysGranted =>
      ubicacionAlways == PermissionStatus.granted;
  bool get ubicacionWhenInUseGranted =>
      ubicacionWhenInUse == PermissionStatus.granted;

  PermissionState copyWith({
    PermissionStatus? ubicacion,
    PermissionStatus? ubicacionAlways,
    PermissionStatus? ubicacionWhenInUse,

    bool? checking,
  }) {
    return PermissionState(
      ubicacion: ubicacion ?? this.ubicacion,
      ubicacionAlways: ubicacionAlways ?? this.ubicacionAlways,
      ubicacionWhenInUse: ubicacionWhenInUse ?? this.ubicacionWhenInUse,
      checking: checking ?? this.checking,
    );
  }

  @override
  List<Object> get props => [
    ubicacion,
    ubicacionAlways,
    ubicacionWhenInUse,
    checking,
  ];
}
