import 'dart:math';

import 'english_result.dart';

/// 文章批改结果（UI 展示用）
///
/// 对应原 Android `ArticleCorrectionResult`，从 [EnglishResult] 转换而来。
class ArticleCorrectionResult {
  ArticleCorrectionResult({
    required this.overallScore,
    required this.vocabularyScore,
    required this.grammarScore,
    required this.logicScore,
    required this.contentScore,
    required this.comment,
    required this.errorList,
  });

  /// 从 EnglishResult 转换为 UI 模型
  ///
  /// 保真原 `toUiModel()`：contentScore 用随机数 15-20
  ///（原项目注释"api 一直返回为 0"，用随机数替代，属原项目 Bug，保真保留）。
  factory ArticleCorrectionResult.fromEnglishResult(EnglishResult result) {
    final random = Random();
    return ArticleCorrectionResult(
      overallScore: result.totalScore,
      vocabularyScore: result.majorScore.wordScore,
      grammarScore: result.majorScore.grammarScore,
      logicScore: result.majorScore.structureScore,
      // 保真：API 返回 topicScore=0，原项目用 15-20 随机数替代
      contentScore: (random.nextInt(6) + 15).toDouble(),
      comment: _buildComment(result),
      errorList: _buildErrorList(result),
    );
  }

  /// 综合评分
  final double overallScore;

  /// 词汇得分
  final double vocabularyScore;

  /// 语法得分
  final double grammarScore;

  /// 逻辑得分
  final double logicScore;

  /// 内容得分
  final double contentScore;

  /// 点评
  final String comment;

  /// 错误列表
  final List<ErrorItem> errorList;

  /// 构建点评文本（保真原 `buildComment`）
  static String _buildComment(EnglishResult result) {
    final sb = StringBuffer();

    final essayAdvice = result.essayAdvice;
    if (essayAdvice.isNotEmpty) {
      sb.write(essayAdvice);
    }

    final score = result.majorScore;
    if (sb.isNotEmpty) {
      sb.write('\n');
    }
    final grammarAdvice = score.grammarAdvice;
    if (grammarAdvice.isNotEmpty) {
      sb.write('语法: $grammarAdvice\n');
    }
    final wordAdvice = score.wordAdvice;
    if (wordAdvice.isNotEmpty) {
      sb.write('词汇: $wordAdvice\n');
    }

    final text = sb.toString().trim();
    return text.isEmpty ? '暂无点评' : text;
  }

  /// 构建错误列表（保真原 `buildErrorList`）
  static List<ErrorItem> _buildErrorList(EnglishResult result) {
    return result.essayFeedback.sentsFeedback
        .where((feedback) => feedback.rawSent.isNotEmpty)
        .map((feedback) => ErrorItem(
              originalSentence: feedback.rawSent,
              correctedSentence: feedback.correctedSent.isEmpty
                  ? feedback.rawSent
                  : feedback.correctedSent,
              errorReason: _buildErrorReason(feedback),
            ))
        .toList();
  }

  /// 构建错误原因（保真原 `buildErrorReason`）
  static String _buildErrorReason(SentsFeedback feedback) {
    final reasons = <String>[];

    final sentFeedback = feedback.sentFeedback;
    if (sentFeedback.isNotEmpty) {
      reasons.add(sentFeedback);
    }

    for (final errorPos in feedback.errorPosInfos) {
      final detailReason = errorPos.detailReason;
      if (detailReason.isNotEmpty) {
        reasons.add(detailReason);
      }
    }

    final joined = reasons.join('; ');
    return joined.isEmpty ? '无' : joined;
  }
}

/// 错误项
class ErrorItem {
  ErrorItem({
    required this.originalSentence,
    required this.correctedSentence,
    required this.errorReason,
  });

  /// 原句
  final String originalSentence;

  /// 正确句子
  final String correctedSentence;

  /// 错误原因
  final String errorReason;
}
