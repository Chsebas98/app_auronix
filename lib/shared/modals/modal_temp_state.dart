part of 'modal_temp_cubit.dart';

class ModalTempState extends Equatable {
  const ModalTempState({
    this.stringTemp1 = '',
    this.stringTemp2 = '',
    this.stringTemp3 = '',
    this.boolTemp1 = false,
    this.boolTemp2 = false,
    this.boolTemp3 = false,
  });

  final String stringTemp1;
  final String stringTemp2;
  final String stringTemp3;

  final bool boolTemp1;
  final bool boolTemp2;
  final bool boolTemp3;

  ModalTempState copyWith({
    String? stringTemp1,
    String? stringTemp2,
    String? stringTemp3,
    bool? boolTemp1,
    bool? boolTemp2,
    bool? boolTemp3,
  }) {
    return ModalTempState(
      stringTemp1: stringTemp1 ?? this.stringTemp1,
      stringTemp2: stringTemp2 ?? this.stringTemp2,
      stringTemp3: stringTemp3 ?? this.stringTemp3,
      boolTemp1: boolTemp1 ?? this.boolTemp1,
      boolTemp2: boolTemp2 ?? this.boolTemp2,
      boolTemp3: boolTemp3 ?? this.boolTemp3,
    );
  }

  @override
  List<Object> get props => [
    stringTemp1,
    stringTemp2,
    stringTemp3,
    boolTemp1,
    boolTemp2,
    boolTemp3,
  ];
}
