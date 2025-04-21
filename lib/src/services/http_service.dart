import 'package:flutter_life_goal_management/src/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HttpService {
  final http.Client _client = http.Client();
  final String _baseUrl = dotenv.env['API_URL'] != null
      ? '${dotenv.env['API_URL']}/api/v1'
      : 'http://10.0.2.2:8000/api/v1';

  // Get auth headers with token
  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService().getToken();
    return {
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      //'Content-Type': 'application/json',
    };
  }

  Future<http.Response> get(String url,
      {Map<String, String>? headers,
      Map<String, dynamic>? queryParameters}) async {
    final uri = Uri.parse('$_baseUrl/$url');
    final uriWithParams = queryParameters != null
        ? uri.replace(
            queryParameters: queryParameters
                .map((key, value) => MapEntry(key, value.toString())))
        : uri;

    final defaultHeaders = await _getHeaders();
    headers = {
      ...defaultHeaders,
      ...(headers ?? {}),
    };

    print("GET request: $uriWithParams");
    print("Headers: $headers");

    return await _client.get(uriWithParams, headers: headers);
  }

  Future<http.Response> post(String url,
      {Map<String, String>? headers, Object? body}) async {
    print("POST request: $_baseUrl/$url");
    print("Body: $body");

    final defaultHeaders = await _getHeaders();
    headers = {
      ...defaultHeaders,
      ...(headers ?? {}),
    };

    print("Headers: $headers");

    try {
      return await _client.post(Uri.parse('$_baseUrl/$url'),
          headers: headers, body: body);
    } catch (e) {
      print("Error: $e");
      return http.Response(e.toString(), 500);
    }
  }

  Future<http.Response> put(String url,
      {Map<String, String>? headers, Object? body}) async {
    final defaultHeaders = await _getHeaders();
    headers = {
      ...defaultHeaders,
      ...(headers ?? {}),
    };

    return await _client.put(Uri.parse('$_baseUrl/$url'),
        headers: headers, body: body);
  }

  Future<http.Response> delete(String url,
      {Map<String, String>? headers, Object? body}) async {
    final defaultHeaders = await _getHeaders();
    headers = {
      ...defaultHeaders,
      ...(headers ?? {}),
    };

    return await _client.delete(Uri.parse('$_baseUrl/$url'),
        headers: headers, body: body);
  }
}
