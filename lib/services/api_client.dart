import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class ApiClient {
  static Uri _uri(
    String path, {
    Map<String, String?> queryParameters = const {},
  }) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('${ApiConfig.baseUrl}$normalizedPath');

    final cleanQuery = <String, String>{};
    queryParameters.forEach((key, value) {
      if (value != null && value.trim().isNotEmpty) {
        cleanQuery[key] = value;
      }
    });

    if (cleanQuery.isEmpty) return uri;
    return uri.replace(queryParameters: cleanQuery);
  }

  static Map<String, String> get _jsonHeaders => const {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=utf-8',
      };

  static Future<dynamic> _send(
    String method,
    String path, {
    Object? body,
    Map<String, String?> queryParameters = const {},
  }) async {
    final uri = _uri(path, queryParameters: queryParameters);
    final encodedBody = body == null ? null : jsonEncode(body);

    late final http.Response response;

    switch (method) {
      case 'GET':
        response = await http.get(uri, headers: _jsonHeaders);
        break;
      case 'POST':
        response = await http.post(uri, headers: _jsonHeaders, body: encodedBody);
        break;
      case 'PATCH':
        response = await http.patch(uri, headers: _jsonHeaders, body: encodedBody);
        break;
      case 'DELETE':
        response = await http.delete(uri, headers: _jsonHeaders, body: encodedBody);
        break;
      default:
        throw Exception('Unsupported API method: $method');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      var message = response.body;
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['message'] != null) {
          message = decoded['message'].toString();
        }
      } catch (_) {}

      throw Exception('API $method $path lỗi ${response.statusCode}: $message');
    }

    if (response.body.trim().isEmpty) return null;
    return jsonDecode(response.body);
  }

  static Future<dynamic> get(
    String path, {
    Map<String, String?> queryParameters = const {},
  }) {
    return _send('GET', path, queryParameters: queryParameters);
  }

  static Future<dynamic> post(
    String path, {
    Object? body,
    Map<String, String?> queryParameters = const {},
  }) {
    return _send('POST', path, body: body, queryParameters: queryParameters);
  }

  static Future<dynamic> patch(
    String path, {
    Object? body,
    Map<String, String?> queryParameters = const {},
  }) {
    return _send('PATCH', path, body: body, queryParameters: queryParameters);
  }

  static Future<dynamic> delete(
    String path, {
    Object? body,
    Map<String, String?> queryParameters = const {},
  }) {
    return _send('DELETE', path, body: body, queryParameters: queryParameters);
  }

  static Future<List<Map<String, dynamic>>> getList(
    String path, {
    Map<String, String?> queryParameters = const {},
  }) async {
    final data = await get(path, queryParameters: queryParameters);

    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    throw Exception('API $path không trả về danh sách');
  }

  static Future<Map<String, dynamic>?> getMap(
    String path, {
    Map<String, String?> queryParameters = const {},
  }) async {
    final data = await get(path, queryParameters: queryParameters);

    if (data == null) return null;

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception('API $path không trả về object');
  }
}
