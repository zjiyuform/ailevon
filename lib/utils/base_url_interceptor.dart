import 'package:dio/dio.dart';

class BaseUrlInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final override = options.extra['baseUrl'] as String?;
    if (override != null && override.isNotEmpty) {
      options.baseUrl = override;
    }
    handler.next(options);
  }
}
