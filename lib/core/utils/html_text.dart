import 'package:flutter/material.dart';

/// 食谱数据只使用 br、b、font 等简单标签；转换为原生富文本，避免引入未验证的鸿蒙 WebView/HTML 依赖。
List<InlineSpan> recipeHtmlToSpans(String source, TextStyle baseStyle) {
  final normalized = source
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'</?(?:b|strong)>', caseSensitive: false), '')
      .replaceAll(RegExp(r'</?font[^>]*>', caseSensitive: false), '')
      .replaceAll(RegExp(r'<[^>]*>'), '');
  final text = normalized
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>');

  final parts = text.split(RegExp(r'(第\s*\d+\s*步)'));
  return parts.where((part) => part.isNotEmpty).map<InlineSpan>((part) {
    final isStep = RegExp(r'^第\s*\d+\s*步$').hasMatch(part.trim());
    return TextSpan(
      text: part,
      style: isStep
          ? baseStyle.copyWith(
              color: const Color(0xFF5E35B1), fontWeight: FontWeight.bold)
          : baseStyle,
    );
  }).toList(growable: false);
}
