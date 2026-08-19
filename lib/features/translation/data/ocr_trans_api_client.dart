import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../../core/app_config.dart';
import '../../../core/network/youdao_signer.dart';
import '../domain/language_list.dart';
import '../domain/ocr_translation_result.dart';

/// 有道图片翻译 API 客户端
///
/// 对应原 Android SDK `OcrTranslate.getInstance(params).lookup(base64, ...)`，
/// 改用 HTTP API：`https://openapi.youdao.com/ocrtransapi`。
///
/// 签名算法与文本翻译相同（sha256 小写），复用 [YoudaoSigner]。
/// 密钥复用 [AppConfig.youdaoAppId] / [AppConfig.youdaoAppSecret]。
///
/// 使用与文本翻译一致的 `package:http` 表单请求实现。
class OcrTransApiClient {
  OcrTransApiClient();

  static const String _logTag = 'asdfasfcxv';
  static const String _url = 'https://openapi.youdao.com/ocrtransapi';
  static final Uuid _uuid = const Uuid();

  /// 翻译图片
  ///
  /// [base64Image] 图片 Base64 编码（不含 data:image/...;base64, 前缀）
  /// [fromLanguage] 源语言中文名
  /// [toLanguage] 目标语言中文名
  Future<OcrTranslationResult> translateImage({
    required String base64Image,
    required String fromLanguage,
    required String toLanguage,
  }) async {
    final salt = _uuid.v4();
    final curtime = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    final sign = YoudaoSigner.generateSign(
      appKey: AppConfig.youdaoAppId,
      q: base64Image,
      salt: salt,
      curtime: curtime,
      appSecret: AppConfig.youdaoAppSecret,
    );

    final fromCode = LanguageList.getCodeByName(fromLanguage);
    final toCode = LanguageList.getCodeByName(toLanguage);

    final bodyMap = <String, String>{
      'type': '1',
      'q': base64Image,
      'from': fromCode,
      'to': toCode,
      'appKey': AppConfig.youdaoAppId,
      'salt': salt,
      'sign': sign,
      'signType': 'v3',
      'curtime': curtime,
      'docType': 'json',
    };

    final uri = Uri.parse(_url);
    // 不记录完整图片 Base64、签名或密钥，避免日志泄露敏感信息及输出过大。
    // 记录的长度、语言和时间戳可用于与服务端请求日志逐项核对。
    debugPrint(
      '$_logTag OCR request: '
      'url=$uri, method=POST, '
      'contentType=application/x-www-form-urlencoded, accept=application/json, '
      'type=${bodyMap['type']}, from=$fromCode, to=$toCode, '
      'fileBase64Length=${base64Image.length}, '
      'formBodyBytes=<package:http encoded>, '
      'appKeySuffix=${_maskSuffix(AppConfig.youdaoAppId)}, '
      'salt=$salt, curtime=$curtime, signType=v3, docType=json, '
      'q=<base64 omitted>, sign=<masked>',
    );
    http.Response? response;

    // 与文本翻译一致：由 package:http 构造并发送 application/x-www-form-urlencoded 表单。
    Exception? lastError;
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        debugPrint('$_logTag OCR request attempt=${attempt + 1}/3');
        response = await http
            .post(
              uri,
              headers: const <String, String>{
                'Accept': 'application/json',
              },
              body: bodyMap,
            )
            .timeout(const Duration(seconds: 45));
        debugPrint(
          '$_logTag OCR response: status=${response.statusCode}, '
          'headers=${response.headers}, bodyLength=${response.body.length}, '
          'body=${_safeResponseLog(response.body)}',
        );
        break;
      } on Exception catch (e) {
        lastError = e;
        debugPrint(
            '$_logTag OCR request failed: attempt=${attempt + 1}/3, error=$e');
        if (attempt < 2) {
          await Future<void>.delayed(Duration(seconds: 2 << attempt));
        }
      }
    }

    if (response == null) {
      throw lastError ?? Exception('图片翻译请求失败');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('图片翻译服务暂不可用（HTTP ${response.statusCode}）');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('图片翻译结果格式异常');
    }
    final json = decoded;
    final errorCode = json['errorCode']?.toString() ?? '';
    if (errorCode != '0') {
      final message = json['msg']?.toString().trim();
      throw Exception(
        '${_getErrorMessage(errorCode)}（错误码: $errorCode）'
        '${message == null || message.isEmpty ? '' : '，$message'}',
      );
    }

    // 解析 resRegions，拼接 context + tranContent（保真原 parseResult）
    final resRegions = json['resRegions'];
    final originalBuilder = StringBuffer();
    final translatedBuilder = StringBuffer();

    for (final region in resRegions is List ? resRegions : const <dynamic>[]) {
      if (region is! Map) {
        continue;
      }
      final regionMap = Map<String, dynamic>.from(region);
      final context = regionMap['context']?.toString() ?? '';
      final tranContent = regionMap['tranContent']?.toString() ?? '';

      if (context.isNotEmpty) {
        if (originalBuilder.isNotEmpty) {
          originalBuilder.write('\n');
        }
        originalBuilder.write(context);
      }
      if (tranContent.isNotEmpty) {
        if (translatedBuilder.isNotEmpty) {
          translatedBuilder.write('\n');
        }
        translatedBuilder.write(tranContent);
      }
    }

    return OcrTranslationResult(
      originalText: originalBuilder.toString(),
      translatedText: translatedBuilder.toString(),
    );
  }

  String _maskSuffix(String value) {
    const visibleLength = 4;
    if (value.length <= visibleLength) {
      return '****';
    }
    return '***${value.substring(value.length - visibleLength)}';
  }

  String _safeResponseLog(String response) {
    const maxLength = 2000;
    return response.length <= maxLength
        ? response
        : '${response.substring(0, maxLength)}...<truncated>';
  }

  /// 错误码映射到中文提示
  ///
  /// 保真原 `OcrTranslationViewModel.getErrorMessage` 的错误提示风格，
  /// 错误码改为图片翻译 HTTP API 的错误码。
  static String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case '102':
        return '不支持的语言类型';
      case '108':
        return '图片翻译服务未开通或应用ID无效';
      case '110':
        return '图片翻译服务未绑定有效实例';
      case '1004':
        return '图片过大';
      case '1201':
        return '图片解析失败';
      case '1301':
        return '识别失败';
      case '1411':
        return '访问频率受限';
      case '1412':
        return '超过最大识别字节数';
      case '202':
        return '签名校验失败';
      case '205':
        return '应用未开通 API 接入方式';
      case '303':
        return '服务端处理异常，请缩小图片或稍后重试';
      case '411':
        return '访问频率受限，请稍后再试';
      default:
        return '翻译失败，请重试';
    }
  }
}
