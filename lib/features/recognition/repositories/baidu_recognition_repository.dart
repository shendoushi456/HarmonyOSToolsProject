import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'baidu_ai_token_repository.dart';
import '../models/recognition_type.dart';

/// 对齐 Android DiscernViewMode：客户端取 token 后将图片 Base64 上传百度 AI。
class BaiduRecognitionRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://aip.baidubce.com/'));

  Future<Map<String, dynamic>> recognize(
    RecognitionType type,
    String imagePath,
  ) async {
    final token = await BaiduAiTokenRepository.shared.getToken();
    final image = base64Encode(await File(imagePath).readAsBytes());
    final response = await _dio.post<Map<String, dynamic>>(
      type.endpoint,
      queryParameters: {'access_token': token},
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
}
