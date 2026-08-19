import 'package:crypto/crypto.dart';
import 'dart:convert';

/// 有道翻译 API 签名算法
///
/// 对应原 Android SDK 内部的签名逻辑，按有道 HTTP API v3 规范实现。
///
/// 签名公式：`sign = sha256(appKey + input + salt + curtime + appSecret)`
///
/// input 规则：
/// - 当 q 长度 <= 20 时，input = q
/// - 当 q 长度 > 20 时，input = q 前 10 字符 + q 长度 + q 后 10 字符
class YoudaoSigner {
  YoudaoSigner._();

  /// 计算 input 值
  static String buildInput(String q) {
    if (q.length <= 20) {
      return q;
    }
    final head = q.substring(0, 10);
    final tail = q.substring(q.length - 10);
    return '$head${q.length}$tail';
  }

  /// 生成签名
  ///
  /// [appKey] 应用 ID
  /// [q] 待翻译文本
  /// [salt] 随机字符串（UUID）
  /// [curtime] 当前 UTC 时间戳（秒）
  /// [appSecret] 应用密钥
  static String generateSign({
    required String appKey,
    required String q,
    required String salt,
    required String curtime,
    required String appSecret,
  }) {
    final input = buildInput(q);
    final raw = '$appKey$input$salt$curtime$appSecret';
    final bytes = utf8.encode(raw);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
