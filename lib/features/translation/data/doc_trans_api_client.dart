import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../../core/app_config.dart';
import 'doc_trans_models.dart';

/// 有道文档翻译 API 客户端
///
/// 对应原 Android `DocTransApi`，使用有道文档翻译 HTTP API：
/// - 上传：`https://openapi.youdao.com/file_trans/upload`
/// - 查询：`https://openapi.youdao.com/file_trans/query`
/// - 下载：`https://openapi.youdao.com/file_trans/download`
///
/// 注意：文档翻译使用独立密钥（`AppConfig.youdaoDocAppId`），
/// 签名使用 SHA256 大写十六进制。
class DocTransApiClient {
  DocTransApiClient();

  static const String _logTag = 'wdfyqqsj';
  static const String _baseUrl = 'https://openapi.youdao.com';
  static const String _uploadUrl = '$_baseUrl/file_trans/upload';
  static const String _queryUrl = '$_baseUrl/file_trans/query';
  static const String _downloadUrl = '$_baseUrl/file_trans/download';
  static const MethodChannel _documentUploadChannel =
      MethodChannel('com.hnrs.saolaisao/document_upload');

  static const Uuid _uuid = Uuid();

  /// SHA256 签名（大写十六进制）。
  String _sha256(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString().toUpperCase();
  }

  /// 截断输入用于签名
  ///
  /// 规则：长度 <= 20 时直接使用，> 20 时取前 10 + 长度 + 后 10。
  String _truncateInput(String input) {
    if (input.length <= 20) {
      return input;
    }
    final head = input.substring(0, 10);
    final tail = input.substring(input.length - 10);
    return '$head${input.length}$tail';
  }

  /// 生成签名
  String _generateSign(String q, String salt, String curtime) {
    final input = _truncateInput(q);
    final signStr =
        '${AppConfig.youdaoDocAppId}$input$salt$curtime${AppConfig.youdaoDocAppSecret}';
    return _sha256(signStr);
  }

  /// 发送表单请求（带超时和重试）
  ///
  /// 文档翻译上传 body 较大（base64 文件，可达数 MB），鸿蒙 NetStack
  /// 可能返回 2300052/2300056 错误。通过以下措施缓解：
  /// - 手动构造 form-urlencoded body（避免 Map body 内部处理的潜在问题）
  /// - 每次请求使用独立 Client（避免 keep-alive 连接复用问题）
  /// - 120 秒超时 + 3 次指数退避重试
  /// - 捕获所有异常类型（SocketException/ClientException/TimeoutException 等）
  Future<http.Response> _postForm(
    String url,
    Map<String, String> body,
  ) async {
    // 手动构造 form-urlencoded body
    final bodyStr = body.entries
        .map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');

    const headers = <String, String>{
      'content-type': 'application/x-www-form-urlencoded',
    };
    _logRequest(
      operation: _operationFromUrl(url),
      url: url,
      fields: body,
      formBodyBytes: utf8.encode(bodyStr).length,
    );

    Exception? lastError;
    for (var attempt = 0; attempt < 3; attempt++) {
      final client = http.Client();
      try {
        debugPrint(
            '$_logTag ${_operationFromUrl(url)} request attempt=${attempt + 1}/3');
        final response = await client
            .post(Uri.parse(url), headers: headers, body: bodyStr)
            .timeout(const Duration(seconds: 120));
        _logHttpResponse(_operationFromUrl(url), response);
        return response;
      } on Exception catch (e) {
        lastError = e;
        debugPrint(
          '$_logTag ${_operationFromUrl(url)} request failed: '
          'attempt=${attempt + 1}/3, error=$e',
        );
        if (attempt < 2) {
          // 指数退避：2秒、4秒
          await Future<void>.delayed(Duration(seconds: 2 << attempt));
        }
      } finally {
        client.close();
      }
    }
    throw lastError ?? Exception('请求失败');
  }

  /// 上传文档
  ///
  /// [q] Base64 编码的文档内容
  /// [fileName] 文件名
  /// [fileType] 文件类型（pdf/doc/docx）
  /// [langFrom] 源语言代码
  /// [langTo] 目标语言代码
  Future<DocUploadResponse> uploadDocument({
    required String q,
    required String fileName,
    required String fileType,
    required String langFrom,
    required String langTo,
  }) async {
    // 2300052/2300056 表示 NetStack 在拿到业务响应前连接被关闭。仅对此
    // 类传输错误重试一次；每次都生成新的 salt/sign，避免触发有道 207 重放保护。
    for (var attempt = 0; attempt < 2; attempt++) {
      final salt = _uuid.v4();
      final curtime =
          (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
      final sign = _generateSign(q, salt, curtime);
      final body = <String, String>{
        'q': q,
        'fileName': fileName,
        'fileType': fileType,
        'langFrom': langFrom,
        'langTo': langTo,
        'appKey': AppConfig.youdaoDocAppId,
        'salt': salt,
        'curtime': curtime,
        'sign': sign,
        'signType': 'v3',
        'docType': 'json',
      };

      try {
        _logRequest(
          operation: 'upload',
          url: _uploadUrl,
          fields: body,
        );
        debugPrint('$_logTag upload request attempt=${attempt + 1}/2');
        // 鸿蒙设备使用原生 NetStack，避开 Dart Socket 上传大表单时的
        // SocketWrite failed / Connection reset by peer。
        final responseBody = await _documentUploadChannel.invokeMethod<String>(
          'upload',
          <String, Object>{
            'url': _uploadUrl,
            'fields': body,
          },
        );

        if (responseBody == null || responseBody.isEmpty) {
          throw Exception('上传失败: 原生网络层未返回响应');
        }
        debugPrint(
          '$_logTag upload response: bodyLength=${responseBody.length}, '
          'body=${_safeResponseLog(responseBody)}',
        );
        final json = jsonDecode(responseBody) as Map<String, dynamic>;
        final result = DocUploadResponse.fromJson(json);
        if (!result.isSuccess) {
          throw Exception(
            '上传失败: errorCode=${result.errorCode}, msg=${result.msg}',
          );
        }
        return result;
      } on PlatformException catch (error) {
        debugPrint(
          '$_logTag upload native request failed: '
          'attempt=${attempt + 1}/2, code=${error.code}, '
          'message=${error.message}, details=${error.details}',
        );
        if (attempt == 0 && _isRetryableUploadError(error)) {
          debugPrint(
            'Document upload connection closed; retrying with a new signature.',
          );
          await Future<void>.delayed(const Duration(milliseconds: 800));
          continue;
        }
        rethrow;
      }
    }

    throw StateError('文档上传重试流程异常结束');
  }

  bool _isRetryableUploadError(PlatformException error) {
    final detail = '${error.code} ${error.message ?? ''}';
    return detail.contains('2300052') || detail.contains('2300056');
  }

  /// 查询翻译状态
  Future<DocQueryResponse> queryStatus(String flownumber) async {
    final salt = _uuid.v4();
    final curtime = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    // 签名用 flownumber 作为 q
    final sign = _generateSign(flownumber, salt, curtime);

    final response = await _postForm(
      _queryUrl,
      <String, String>{
        'flownumber': flownumber,
        'appKey': AppConfig.youdaoDocAppId,
        'salt': salt,
        'curtime': curtime,
        'sign': sign,
        'signType': 'v3',
        'docType': 'json',
      },
    );

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final result = DocQueryResponse.fromJson(json);
    if (!result.isSuccess) {
      throw Exception('查询失败: errorCode=${result.errorCode}, msg=${result.msg}');
    }
    return result;
  }

  /// 下载翻译后的文件
  ///
  /// 返回文件字节流。失败（API 返回 JSON）时抛异常。
  Future<List<int>> downloadFile(
    String flownumber, {
    String downloadFileType = 'pdf',
  }) async {
    final salt = _uuid.v4();
    final curtime = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    // 签名用 flownumber 作为 q
    final sign = _generateSign(flownumber, salt, curtime);

    final response = await _postForm(
      _downloadUrl,
      <String, String>{
        'flownumber': flownumber,
        'downloadFileType': downloadFileType,
        'appKey': AppConfig.youdaoDocAppId,
        'salt': salt,
        'curtime': curtime,
        'sign': sign,
        'signType': 'v3',
        'docType': 'json',
      },
    );

    final contentType = response.headers['content-type'] ?? '';

    // 如果是 JSON，说明下载失败，解析错误信息
    if (contentType.contains('application/json')) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final errorCode = json['errorCode']?.toString() ?? '';
      final errorMsg = json['msg']?.toString() ?? '未知错误';
      throw Exception('翻译失败: $errorMsg (错误码: $errorCode)');
    }

    final bytes = response.bodyBytes;
    if (bytes.isEmpty) {
      throw Exception('下载内容为空');
    }

    return bytes;
  }

  String _operationFromUrl(String url) {
    if (url == _queryUrl) {
      return 'query';
    }
    if (url == _downloadUrl) {
      return 'download';
    }
    return 'request';
  }

  void _logRequest({
    required String operation,
    required String url,
    required Map<String, String> fields,
    int? formBodyBytes,
  }) {
    final safeFields = fields.entries
        .map((entry) =>
            '${entry.key}=${_safeFieldValue(entry.key, entry.value)}')
        .join(', ');
    debugPrint(
      '$_logTag $operation request: '
      'url=$url, method=POST, '
      'contentType=application/x-www-form-urlencoded; charset=UTF-8, '
      'fields={$safeFields}'
      '${formBodyBytes == null ? '' : ', formBodyBytes=$formBodyBytes'}',
    );
  }

  String _safeFieldValue(String key, String value) {
    switch (key) {
      case 'q':
        return '<base64 omitted, length=${value.length}>';
      case 'sign':
        return '<masked>';
      case 'appKey':
        return _maskSuffix(value);
      case 'flownumber':
        return _maskSuffix(value);
      default:
        return value;
    }
  }

  String _maskSuffix(String value) {
    const visibleLength = 4;
    if (value.length <= visibleLength) {
      return '****';
    }
    return '***${value.substring(value.length - visibleLength)}';
  }

  void _logHttpResponse(String operation, http.Response response) {
    debugPrint(
      '$_logTag $operation response: '
      'status=${response.statusCode}, headers=${response.headers}, '
      'bodyLength=${response.body.length}, body=${_safeResponseLog(response.body)}',
    );
  }

  String _safeResponseLog(String response) {
    const maxLength = 2000;
    return response.length <= maxLength
        ? response
        : '${response.substring(0, maxLength)}...<truncated>';
  }
}
