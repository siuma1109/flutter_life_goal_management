import 'package:flutter_life_goal_management/src/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class HttpService {
  final http.Client _client = http.Client();
  final String _baseUrl = dotenv.env['API_URL'] != null
      ? '${dotenv.env['API_URL']}/api/v1'
      : 'http://10.0.2.2:8000/api/v1';

  // Global NavigatorState key to access navigation from outside the widget tree
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // Get auth headers with token
  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService().getToken();
    return {
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      //'Content-Type': 'application/json',
    };
  }

  // Handle API response - check for 401 Unauthorized
  Future<http.Response> _handleResponse(http.Response response) async {
    if (response.statusCode == 401) {
      print("Unauthorized access detected (401). Logging out user...");

      // Logout the user
      await AuthService().logOut();

      // Navigate to login page using context-independent navigation
      // Use post-frame callback to avoid navigation during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (navigatorKey.currentContext != null) {
          // Show a snackbar notification
          ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
            const SnackBar(
              content: Text('Session expired. Please login again.'),
              backgroundColor: Colors.red,
            ),
          );

          // Navigate to login page
          GoRouter.of(navigatorKey.currentContext!).go('/login');
        }
      });
    }
    return response;
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

    final result = await _client.get(uriWithParams, headers: headers);
    return _handleResponse(result);
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
      final response = await _client.post(Uri.parse('$_baseUrl/$url'),
          headers: headers, body: body);
      return _handleResponse(response);
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

    final response = await _client.put(Uri.parse('$_baseUrl/$url'),
        headers: headers, body: body);
    return _handleResponse(response);
  }

  Future<http.Response> delete(String url,
      {Map<String, String>? headers, Object? body}) async {
    final defaultHeaders = await _getHeaders();
    headers = {
      ...defaultHeaders,
      ...(headers ?? {}),
    };

    final response = await _client.delete(Uri.parse('$_baseUrl/$url'),
        headers: headers, body: body);
    return _handleResponse(response);
  }
}
