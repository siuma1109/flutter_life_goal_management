import 'package:flutter_life_goal_management/src/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HttpService {
  final http.Client _client = http.Client();
  final String _baseUrl = dotenv.env['API_URL'] != null
      ? '${dotenv.env['API_URL']}/api/v1'
      : 'http://10.0.2.2:8000/api/v1';
  final Map<String, String> _headers = {
    'Authorization': 'Bearer ${AuthService().getToken()}',
    'Accept': 'application/json',
  };

  Future<http.Response> get(String url,
      {Map<String, String>? headers,
      Map<String, dynamic>? queryParameters}) async {
    final uri = Uri.parse('$_baseUrl/$url');
    final uriWithParams = queryParameters != null
        ? uri.replace(
            queryParameters: queryParameters
                .map((key, value) => MapEntry(key, value.toString())))
        : uri;
    headers = {
      ..._headers,
      ...(headers ?? {}),
    };
    print("uriWithParams: $uriWithParams");
    return await _client.get(uriWithParams, headers: headers);
  }

  Future<http.Response> post(String url,
      {Map<String, String>? headers, Object? body}) async {
    print("body: $body");
    print("headers: $headers");
    print("url: $_baseUrl/$url");
    headers = {
      ..._headers,
      ...(headers ?? {}),
    };
    try {
      return await _client.post(Uri.parse('$_baseUrl/$url'),
          headers: headers, body: body);
    } catch (e) {
      print("error: $e");
      return http.Response(e.toString(), 500);
    }
  }

  Future<http.Response> put(String url,
      {Map<String, String>? headers, Object? body}) async {
    headers = {
      ..._headers,
      ...(headers ?? {}),
    };
    return await _client.put(Uri.parse('$_baseUrl/$url'),
        headers: headers, body: body);
  }

  Future<http.Response> delete(String url,
      {Map<String, String>? headers, Object? body}) async {
    headers = {
      ..._headers,
      ...(headers ?? {}),
    };
    return await _client.delete(Uri.parse('$_baseUrl/$url'),
        headers: headers, body: body);
  }
}
