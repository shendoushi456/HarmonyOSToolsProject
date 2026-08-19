import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../../core/app_config.dart';
import '../../../core/network/youdao_signer.dart';
import '../domain/domain_type.dart';
import 'youdao_translation_response.dart';

/// 有道翻译 HTTP API 客户端
///
/// 对应原 Android `Translator`（有道 SDK），改用 HTTP API 实现。
/// 接口地址：https://openapi.youdao.com/api
class YoudaoApiClient {
  YoudaoApiClient();

  static const String _url = 'https://openapi.youdao.com/api';
  static final _uuid = const Uuid();

  /// 执行文本翻译
  ///
  /// [q] 待翻译文本
  /// [from] 源语言代码（如 auto/zh-CHS/en）
  /// [to] 目标语言代码
  /// [domainType] 领域类型，默认通用
  Future<YoudaoTranslationResponse> translate({
    required String q,
    required String from,
    required String to,
    DomainType domainType = DomainType.general,
  }) async {
    final salt = _uuid.v4();
    final curtime =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    final sign = YoudaoSigner.generateSign(
      appKey: AppConfig.youdaoAppId,
      q: q,
      salt: salt,
      curtime: curtime,
      appSecret: AppConfig.youdaoAppSecret,
    );

    final response = await http.post(
      Uri.parse(_url),
      body: {
        'q': q,
        'from': from,
        'to': to,
        'appKey': AppConfig.youdaoAppId,
        'salt': salt,
        'sign': sign,
        'signType': 'v3',
        'curtime': curtime,
        'strict': 'true',
        'domain': domainTypeToString(domainType),
        'ext': 'mp3',
        'voice': '0',
      },
    );

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return YoudaoTranslationResponse.fromJson(json);
  }

  /// 错误码映射到中文提示
  ///
  /// 注意：原 Android `TranslationViewModel.onError` 统一返回"翻译繁忙"，
  /// 此处保留映射供日志/调试使用，UI 层仍按原行为显示"翻译繁忙"。
  static String errorMessage(String errorCode) {
    switch (errorCode) {
      case '101':
        return '缺少必填参数';
      case '102':
        return '不支持的语言类型';
      case '103':
        return '翻译文本过长';
      case '108':
        return '应用ID无效';
      case '110':
        return '无相关服务的有效应用';
      case '111':
        return '开发者账号无效';
      case '202':
        return '签名校验失败';
      case '206':
        return '时间戳无效';
      case '207':
        return '重放请求';
      case '301':
        return '辞典查询失败';
      case '302':
        return '翻译查询失败';
      case '401':
        return '账户已经欠费';
      case '411':
        return '访问频率受限';
      case '412':
        return '长请求过于频繁';
      default:
        return '翻译繁忙';
    }
  }
}
