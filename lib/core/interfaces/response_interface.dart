import 'dart:convert';

class ResponseInterface {
  final bool response;
  final String message;
  final int codeStatus;
  final dynamic result;
  final dynamic errorDetail;

  const ResponseInterface({
    required this.response,
    required this.message,
    required this.codeStatus,
    required this.result,
    this.errorDetail,
  });

  Map<String, dynamic> toJson() => {
    'response': response,
    'message': message,
    'codeStatus': codeStatus,
    'result': result,
    'errorDetail': errorDetail,
  };

  @override
  String toString() => jsonEncode(toJson());
}
