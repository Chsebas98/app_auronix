/// Datos de vehiculo/conductor para mostrar en pantalla (T27-C2/C4).
///
/// GAP DE BACKEND (igual que el login con Google, ver memoria del
/// proyecto): micro-auronix no expone ningun endpoint que devuelva
/// placa/modelo por vehicleId — `FleetController` solo permite ASIGNAR un
/// vehiculo a un conductor, su respuesta no incluye estos datos. Mientras
/// el backend no agregue ese contrato, [VehicleInfo.placeholder] devuelve
/// datos de ejemplo fijos para no bloquear la UI. Cuando el backend lo
/// agregue, reemplazar el uso de `VehicleInfo.placeholder()` por una
/// llamada real al repositorio usando `trip.vehicleId`/`trip.driverId`.
class VehicleInfo {
  final String placa;
  final String modelo;
  final String driverName;

  const VehicleInfo({
    required this.placa,
    required this.modelo,
    required this.driverName,
  });

  factory VehicleInfo.placeholder() => const VehicleInfo(
    placa: 'PBA-1234',
    modelo: 'Toyota Corolla 2022',
    driverName: 'Conductor asignado',
  );
}
