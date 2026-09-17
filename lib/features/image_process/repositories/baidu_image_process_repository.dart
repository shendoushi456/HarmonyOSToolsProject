import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

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
    // 图片转黑白：本地灰度处理，不再依赖百度接口(配额易耗尽)。
    if (type == ImageProcessType.colourize) {
      return compute(
          _convertToGrayscaleSync, await image.readAsBytes());
    }
    final token = await BaiduAiTokenRepository.shared.getToken();
    final Response<Map<String, dynamic>> response;
    try {
      response = await _dio.post<Map<String, dynamic>>(
        type.endpoint,
        queryParameters: {'access_token': token},
        data: {
          'image': base64Encode(await image.readAsBytes()),
          if (type.needsStyleSelection) 'option': style.apiValue,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
    } on DioException catch (error) {
      // 诊断日志：百度返回的业务错误(error_msg/error_code)在响应体里。
      debugPrint('ImageProcess[${type.name}] http ${error.response?.statusCode}: ${error.response?.data}');
      rethrow;
    }
    final data = response.data ?? const <String, dynamic>{};
    final encodedImage = data['image'] as String?;
    if (encodedImage == null || encodedImage.isEmpty) {
      debugPrint('ImageProcess[${type.name}] api error: $data');
      throw StateError(_apiErrorText(data));
    }
    return base64Decode(encodedImage.replaceAll(RegExp(r'\s'), ''));
  }

  /// 百度业务错误转用户可理解的提示(错误码对齐百度文档)。
  static String _apiErrorText(Map<String, dynamic> data) {
    const codeText = <int, String>{
      6: '接口无调用权限，请检查百度服务是否开通',
      17: '今日识别次数已用完，请明天再试',
      18: '请求过于频繁，请稍后重试',
      19: '请求总量已超限',
      100: '识别凭据无效，请重试',
      216201: '图片格式错误，请更换图片',
      216202: '图片超出大小限制，请更换图片',
      282000: '服务端繁忙，请稍后重试',
    };
    final code = data['error_code'];
    if (code is int && codeText.containsKey(code)) {
      return codeText[code]!;
    }
    return data['error_msg'] ?? data['error_message'] ?? '图片处理失败';
  }

  /// 本地灰度转换(与安卓 BitmapPixelUtil.去色 同算法)：gray = (r+g+b)/3，
  /// 保留 alpha，输出 PNG。在 isolate 中执行避免大图卡 UI。
  static Uint8List _convertToGrayscaleSync(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw StateError('图片解码失败，请更换图片');
    }
    for (final p in decoded) {
      final gray = (p.r.toInt() + p.g.toInt() + p.b.toInt()) ~/ 3;
      p..r = gray..g = gray..b = gray;
    }
    return Uint8List.fromList(img.encodePng(decoded));
  }
}
