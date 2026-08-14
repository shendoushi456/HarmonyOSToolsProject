// Dio 网络客户端单例 - 对齐 Android WeatherHttpManager
// 超时 120s,统一 baseUrl,自动附加 API Key
import 'package:dio/dio.dart';
import '../constants/api_config.dart';

class DioClient {
  DioClient._();

  static Dio? _instance;

  /// 获取 Dio 单例
  static Dio get instance {
    _instance ??= _create();
    return _instance!;
  }

  static Dio _create() {
    final dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: ApiConfig.connectTimeout),
      receiveTimeout: const Duration(seconds: ApiConfig.receiveTimeout),
      headers: const {
        'Connection': 'Keep-Alive',
        'Content-Type': 'application/json; charset=utf-8',
      },
    ));

    // 请求拦截器:自动附加 key 参数
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.queryParameters['key'] = ApiConfig.apiKey;
        handler.next(options);
      },
    ));

    return dio;
  }
}
