import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nisab/core/config/app_config.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final baseUrl = AppConfig.apiBaseUrl.replaceFirst(RegExp(r'/$'), '');
    final values = query?.map(
      (key, value) => MapEntry(key, value.toString()),
    );
    return Uri.parse('$baseUrl$path').replace(queryParameters: values);
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final response = await _client.get(_uri(path, query));
    return _decode(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
  }) async {
    final response = await _client.post(
      _uri(path, query),
      headers: const {'Content-Type': 'application/json'},
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _client.put(
      _uri(path),
      headers: const {'Content-Type': 'application/json'},
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(response);
  }

  Map<String, dynamic> _decode(http.Response response) {
    Map<String, dynamic> data = const {};
    if (response.body.isNotEmpty) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) {
        data = decoded;
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final detail = data['detail'];
      throw ApiException(
        detail is String ? detail : 'تعذر إكمال الطلب. حاول مرة أخرى.',
        statusCode: response.statusCode,
      );
    }
    return data;
  }
}
