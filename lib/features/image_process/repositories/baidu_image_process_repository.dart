import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../recognition/repositories/baidu_ai_token_repository.dart';
import '../models/image_process_type.dart';

/// 对齐 Android DiscernViewMode：将图片 Base64 表单提交至百度图像处理接口。
class BaiduImageProcessRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://aip.baidubce.com/'));

  Future<Uint8List> process({
    required ImageProcessType type,
    required File image,
    ImageStyleOption style = ImageStyleOption.cartoon,
  }) async {
    final token = await BaiduAiTokenRepository.shared.getToken();
    final response = await _dio.post<Map<String, dynamic>>(
      type.endpoint,
      queryParameters: {'access_token': token},
      data: {
        'image': base64Encode(await image.readAsBytes()),
        if (type.needsStyleSelection) 'option': style.apiValue,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    final data = response.data ?? const <String, dynamic>{};
    final encodedImage = data['image'] as String?;
    if (encodedImage == null || encodedImage.isEmpty) {
      throw StateError(data['error_msg'] ?? data['error_message'] ?? '图片处理失败');
    }
    return base64Decode(encodedImage.replaceAll(RegExp(r'\s'), ''));
  }
}
