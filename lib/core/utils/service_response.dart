import 'dart:convert';

class ServiceResponse {
  final bool response;
  final int statusCode;
  final String message;
  final dynamic result;
  final String? errorDetail;

  const ServiceResponse({
    required this.response,
    required this.statusCode,
    required this.message,
    this.result,
    this.errorDetail,
  });

  const ServiceResponse.empty()
    : response = false,
      statusCode = 0,
      message = '',
      result = null,
      errorDetail = null;

  // Factory para parsear desde JSON del backend
  factory ServiceResponse.fromJson(Map<String, dynamic> json) {
    return ServiceResponse(
      response: json['response'] ?? false,
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      result: json['result'],
      errorDetail: json['errorDetail'],
    );
  }

  // ✅ Factory para errores
  factory ServiceResponse.error({
    required String message,
    String? errorDetail,
    int statusCode = 500,
  }) {
    return ServiceResponse(
      response: false,
      statusCode: statusCode,
      message: message,
      result: null,
      errorDetail: errorDetail ?? message,
    );
  }

  // Factory para éxito
  factory ServiceResponse.success({
    required String message,
    dynamic result,
    int statusCode = 200,
  }) {
    return ServiceResponse(
      response: true,
      statusCode: statusCode,
      message: message,
      result: result,
      errorDetail: null,
    );
  }

  Map<String, dynamic> toJson() => {
    'response': response,
    'statusCode': statusCode,
    'message': message,
    'result': result,
    'errorDetail': errorDetail,
  };

  @override
  String toString() => jsonEncode(toJson());
}
