import 'dart:convert';

class JwtHelpers {
  static int? getUserId(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final sub = data['sub'] ?? data['user_id'] ?? data['id'];
      if (sub == null) return null;
      if (sub is int) return sub;
      return int.tryParse(sub.toString());
    } catch (_) {
      return null;
    }
  }
}
