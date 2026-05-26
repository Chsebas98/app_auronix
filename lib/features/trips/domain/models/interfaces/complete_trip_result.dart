class CompleteTripResult {
  final int id;
  final String estado;
  final double precioTotal;
  final double comisionMonto;
  final double montoConductor;
  final String fechaFin;

  const CompleteTripResult({
    required this.id,
    required this.estado,
    required this.precioTotal,
    required this.comisionMonto,
    required this.montoConductor,
    required this.fechaFin,
  });
}
