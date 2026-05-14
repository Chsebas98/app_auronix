import 'dart:convert';

class EarningsPoint {
  const EarningsPoint({
    required this.label,
    required this.amount,
    required this.index,
  });

  final String label; // "8am", "10am"
  final double amount; // $45.00
  final int index; // posicion en el eje X

  const EarningsPoint.empty() : label = '', amount = 0.0, index = 0;

  Map<String, dynamic> toJson() {
    return {'label': label, 'amount': amount, 'index': index};
  }

  @override
  String toString() => jsonEncode(toJson());
}
