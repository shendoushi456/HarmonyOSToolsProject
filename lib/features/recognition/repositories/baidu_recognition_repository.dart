import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../models/recognition_type.dart';

/// 对齐 Android DiscernViewMode：客户端取 token 后将图片 Base64 上传百度 AI。
class BaiduRecognitionRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://aip.baidubce.com/'));
  String? _token;

  // 按需求沿用 Android HttpApi 中的客户端凭据。
  static const _apiKey = 'Sf3el8QwoIH7Ye2EF9WEuNCZ';
  static const _secretKey = 'E8smgwhedtq1fX3sjLv22rxwoplI4RoN';

  Future<Map<String, dynamic>> recognize(
    RecognitionType type,
    String imagePath,
  ) async {
    _token ??= await _loadToken();
    final image = base64Encode(await File(imagePath).readAsBytes());
    final response = await _dio.post<Map<String, dynamic>>(
      type.endpoint,
      queryParameters: {'access_token': _token},
      data: {
        'image': image,
        if (type == RecognitionType.text) 'detect_direction': 'true',
        if (type != RecognitionType.text && type != RecognitionType.bankCard)
          'baike_num': '1',
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    return response.data ?? const {};
  }

  Future<String> _loadToken() async {
    final response = await _dio.get<Map<String, dynamic>>(
      'oauth/2.0/token',
      queryParameters: {
        'grant_type': 'client_credentials',
        'client_id': _apiKey,
        'client_secret': _secretKey,
      },
    );
    final token = response.data?['access_token'] as String?;
    if (token == null || token.isEmpty) {
      throw Exception(response.data?['error_description'] ?? '获取识别凭据失败');
    }
    return token;
  }
}
