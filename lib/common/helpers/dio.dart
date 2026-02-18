import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import 'package:flutter_event/common/constants/remote_data_source_consts.dart';
import 'package:flutter_event/common/helpers/storage.dart';

class DioHelper {
  DioHelper._internal();
  static final DioHelper shared = DioHelper._internal();

  Dio? _dio;

  Dio getClient() {
    // Reuse instance (lebih irit & konsisten)
    if (_dio != null) return _dio!;

    final dio = Dio(
      BaseOptions(
        baseUrl: RemoteDataSourceConsts.baseUrl,
        // Timeout (sesuaikan kebutuhan)
        connectTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),

        // Optional: kalau mau tetap dapat response body pada 4xx/5xx tanpa throw otomatis
        // validateStatus: (status) => status != null && status >= 200 && status < 500, ini dianggap 400, 500 selalu makanya return try
      ),
    );

    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return client;
      },
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await StorageHelper.getToken();
          if (token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (e, handler) {
          // Socket / no internet
          if (e.error is SocketException) {
            return handler.next(e);
          }

          // Timeout (Dio v5)
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.sendTimeout ||
              e.type == DioExceptionType.receiveTimeout) {
            return handler.next(e);
          }

          return handler.next(e);
        },
      ),
    );

    _dio = dio;
    return dio;
  }
}
