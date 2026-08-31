import 'package:dio/dio.dart';

/// 百度 AI 的共享访问令牌。凭据沿用 Android 原工程，令牌在有效期内复用。
class BaiduAiTokenRepository {
  BaiduAiTokenRepository._();

  static final BaiduAiTokenRepository shared = BaiduAiTokenRepository._();

  static const _apiKey = 'Sf3el8QwoIH7Ye2EF9WEuNCZ';
  static const _secretKey = 'E8smgwhedtq1fX3sjLv22rxwoplI4RoN';

  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://aip.baidubce.com/'));
  String? _token;
  DateTime? _expiresAt;

  Future<String> getToken() async {
    if (_token != null &&
        _expiresAt != null &&
        DateTime.now().isBefore(_expiresAt!)) {
      return _token!;
    }
    final response = await _dio.get<Map<String, dynamic>>(
      'oauth/2.0/token',
      queryParameters: {
        'grant_type': 'client_credentials',
        'client_id': _apiKey,
        'client_secret': _secretKey,
      },
    );
    final data = response.data ?? const <String, dynamic>{};
    final token = data['access_token'] as String?;
    if (token == null || token.isEmpty) {
      throw StateError(data['error_description'] ?? '获取识别凭据失败');
    }
    final seconds = (data['expires_in'] as num?)?.toInt() ?? 2592000;
    _token = token;
    // 提前一分钟刷新，避免请求发送时令牌刚好过期。
    _expiresAt = DateTime.now().add(Duration(seconds: seconds - 60));
    return token;
  }
}
