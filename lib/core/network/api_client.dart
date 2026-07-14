import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_config.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient(this.storage)
    : dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
        ),
      ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.read(key: 'access_token');
          if (token != null) options.headers['Authorization'] = 'Bearer $token';
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 &&
              error.requestOptions.extra['retried'] != true &&
              !error.requestOptions.path.contains('/auth/')) {
            try {
              await refresh();
              final request = error.requestOptions..extra['retried'] = true;
              request.headers['Authorization'] =
                  'Bearer ${await storage.read(key: 'access_token')}';
              return handler.resolve(await dio.fetch(request));
            } catch (_) {}
          }
          handler.next(error);
        },
      ),
    );
  }
  final Dio dio;
  final FlutterSecureStorage storage;

  Future<Map<String, dynamic>> request(
    String method,
    String path, {
    Object? data,
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await dio.request(
        path,
        data: data,
        queryParameters: query,
        options: Options(method: method),
      );
      return response.data is Map<String, dynamic>
          ? response.data
          : {'items': response.data};
    } on DioException catch (e) {
      final body = e.response?.data;
      final detail = body is Map ? (body['detail'] ?? body) : null;
      throw ApiException(
        detail is Map
            ? (detail['message']?.toString() ?? 'تعذر إتمام الطلب')
            : 'تعذر الاتصال بالخادم',
        code: detail is Map ? detail['code']?.toString() : null,
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> saveTokens(Map<String, dynamic> data) async {
    await storage.write(
      key: 'access_token',
      value: data['access_token'] as String,
    );
    await storage.write(
      key: 'refresh_token',
      value: data['refresh_token'] as String,
    );
  }

  Future<void> refresh() async {
    final token = await storage.read(key: 'refresh_token');
    if (token == null) throw const ApiException('انتهت الجلسة');
    final response = await Dio(
      BaseOptions(baseUrl: ApiConfig.baseUrl),
    ).post('/auth/refresh', data: {'refresh_token': token});
    await saveTokens(Map<String, dynamic>.from(response.data));
  }
}
