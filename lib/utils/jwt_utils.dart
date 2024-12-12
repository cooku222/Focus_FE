import 'dart:convert';

class JWTUtils {
  /// Decodes a JWT token and returns its payload as a Map.
  static Map<String, dynamic> decodeJWT(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid JWT token');
    }

    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    return json.decode(decoded) as Map<String, dynamic>;
  }

  /// Extracts the userId from the JWT token.
  static String? getUserId(String token) {
    try {
      final payload = decodeJWT(token);
      return payload['userId'] as String?;
    } catch (e) {
      print('Error decoding JWT: $e');
      return null;
    }
  }
}
