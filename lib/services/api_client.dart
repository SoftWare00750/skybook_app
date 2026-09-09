import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'auth_service.dart';

/// Thrown by [ApiClient] methods when the backend returns a non-2xx
/// response, or when there's no signed-in session to call it with.
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

/// A small wrapper around the SkyBook `.NET` backend for every
/// JWT-protected endpoint (bookings, wallet, profile). Auth's own
/// signup/login calls stay in [AuthService] since they run *before* a
/// token exists.
class ApiClient {
  final AuthService _authService = AuthService();

  Uri _endpoint(String path) => Uri.parse('${AppConfig.backendBaseUrl}$path');

  Future<Map<String, String>> _authHeaders() async {
    final token = await _authService.currentToken();
    if (token == null || token.isEmpty) {
      throw ApiException('You need to be signed in for this.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String path) async {
    final headers = await _authHeaders();
    final response = await http.get(_endpoint(path), headers: headers).timeout(const Duration(seconds: 15));
    return _decode(response);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final headers = await _authHeaders();
    final response = await http
        .post(_endpoint(path), headers: headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));
    return _decode(response);
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final headers = await _authHeaders();
    final response = await http
        .put(_endpoint(path), headers: headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));
    return _decode(response);
  }

  dynamic _decode(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw ApiException(body['message']?.toString() ?? 'Something went wrong (${response.statusCode}).');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Something went wrong (${response.statusCode}).');
    }
  }
}
