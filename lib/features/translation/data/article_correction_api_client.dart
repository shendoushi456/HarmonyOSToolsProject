import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../../core/app_config.dart';
import '../../../core/network/youdao_signer.dart';
import '../domain/english_result.dart';

/// 有道作文批改 API 客户端
///
/// 对应原 Android SDK `CompositionCorrection.correctionEnglishTextV3`，
/// 改用 HTTP API：`https://openapi.youdao.com/v3/correct_writing_text`。
///
/// 签名算法与文本翻译相同（sha256 小写），复用 [YoudaoSigner]。
/// 当前 HTTP 作文批改接口与文本翻译共用已开通 API 服务的应用凭据。
/// 原 Android SDK 的独立初始化凭据不能直接用于该 HTTP 接入方式。
class ArticleCorrectionApiClient {
  ArticleCorrectionApiClient();

  static const String _url =
      'https://openapi.youdao.com/v3/correct_writing_text';
  static final Uuid _uuid = const Uuid();

  /// 批改英语作文
  ///
  /// [text] 作文文本（最大 10000 字符）
  /// [grade] 等级代码（default/elementary/high/cet4/cet6/graduate/toefl/gre/ielts）
  /// [title] 作文标题（可选）
  /// [modelContent] 参考范文（可选）
  Future<EnglishResult> correctArticle({
    required String text,
    String grade = 'default',
    String? title,
    String? modelContent,
  }) async {
    final salt = _uuid.v4();
    final curtime = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    final sign = YoudaoSigner.generateSign(
      appKey: AppConfig.youdaoAppId,
      q: text,
      salt: salt,
      curtime: curtime,
      appSecret: AppConfig.youdaoAppSecret,
    );

    final body = <String, String>{
      'appKey': AppConfig.youdaoAppId,
      'curtime': curtime,
      'q': text,
      'salt': salt,
      'sign': sign,
      'signType': 'v3',
      'grade': grade,
    };
    if (title != null) {
      body['title'] = title;
    }
    if (modelContent != null) {
      body['modelContent'] = modelContent;
    }

    final response = await http
        .post(
          Uri.parse(_url),
          headers: const <String, String>{
            'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8',
            'Accept': 'application/json',
          },
          body: body,
        )
        .timeout(const Duration(seconds: 60));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('批改服务暂不可用（HTTP ${response.statusCode}）');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('批改结果格式异常');
    }
    final json = decoded;

    final errorCode = json['errorCode']?.toString() ?? '';
    if (errorCode != '0') {
      final message = json['msg']?.toString().trim();
      final mappedMessage = _getErrorMessage(errorCode);
      throw Exception(
        '$mappedMessage（错误码: $errorCode）'
        '${message == null || message.isEmpty ? '' : '，$message'}',
      );
    }

    try {
      return EnglishResult.fromJson(json);
    } on Object catch (_) {
      throw Exception('批改结果解析失败');
    }
  }

  /// 错误码映射到中文提示（保真原 `getErrorMessage`）
  static String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case '101':
        return '缺少必填参数';
      case '102':
        return '不支持的语言类型';
      case '103':
        return '文本过长';
      case '108':
        return '应用ID无效';
      case '111':
        return '开发者账号无效';
      case '113':
        return '请求频繁，请稍后再试';
      default:
        return '批改失败，请重试';
    }
  }
}
