import 'dart:convert';

class ResponseModel {
  final bool response;
  final String codeStatus;
  final String message;
  final dynamic result;
  final dynamic extraDetail;

  const ResponseModel({
    required this.response,
    required this.codeStatus,
    required this.message,
    this.result,
    this.extraDetail,
  });

  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    return ResponseModel(
      response: json['response'] ?? false,
      codeStatus: json['codeStatus']?.toString() ?? '500',
      message: json['message']?.toString() ?? 'Fallo del servicio',
      result: json['result'],
      extraDetail: json['extraDetail'],
    );
  }

  Map<String, dynamic> toJson() => {
    'response': response,
    'codeStatus': codeStatus,
    'message': message,
    'result': result,
    'extraDetail': extraDetail,
  };
  @override
  String toString() => jsonEncode(toJson());
}
