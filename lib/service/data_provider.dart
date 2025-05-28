import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

class DataProvider {
  static final BaseOptions _options = BaseOptions(
    sendTimeout: const Duration(milliseconds: 30000),
    receiveTimeout: const Duration(milliseconds: 30000),
  );

  final Dio _dio;

  DataProvider() : _dio = Dio(_options) {
    //TODO: comment off interceptors if you don't want to log dio requests
    // _dio.interceptors.add(LogInterceptor(responseBody: true));
    // //TODO: interceptor ends here
    // // if (!kIsWeb) {
    // //   _dio.httpClientAdapter = IOHttpClientAdapter(
    // //     createHttpClient: () {
    // //       final HttpClient client = HttpClient();
    // //       client.badCertificateCallback =
    // //           (X509Certificate cert, String host, int port) => true;
    // //       return client;
    // //     },
    // //   );
    // // }
  }

  Future<Response<dynamic>?> fetchData(
    String method,
    String url, {
    dynamic data,
    dynamic query,
    dynamic header,
  }) async {

    try {
      DateTime startTime = DateTime.now();
      Response response = await _dio.request(
        url,
        data: data,
        queryParameters: query,
        options: Options(
          headers: header,
          method: method.toUpperCase(),
        ),
      );
      DateTime endTime = DateTime.now();
      Duration diff = endTime.difference(startTime);

      if (kDebugMode) {
        print("$url: ${diff.inMilliseconds} Milliseconds");
      }

      return response;
    } on DioException catch (exception) {
      if (kDebugMode) {
        print("DioException: $exception");
        print("Dio Url: ${url}");
        print("Dio query: ${query}");
        print("Dio data: ${data}");

      }
      return exception.response;
    }
  }
}
