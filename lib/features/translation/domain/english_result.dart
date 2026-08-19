/// 有道作文批改 API 响应模型
///
/// 对应原 Android SDK `EnglishResult` 及其嵌套模型。
/// 从 `https://openapi.youdao.com/v3/correct_writing_text` 返回的 JSON 解析。

/// 作文批改结果（顶层）
class EnglishResult {
  EnglishResult({
    required this.totalScore,
    required this.majorScore,
    required this.essayAdvice,
    required this.essayFeedback,
  });

  factory EnglishResult.fromJson(Map<String, dynamic> json) {
    final result = _asMap(json['Result']) ?? json;
    return EnglishResult(
      totalScore: _asDouble(result['totalScore']),
      majorScore: MajorScore.fromJson(
        _asMap(result['majorScore']) ?? const <String, dynamic>{},
      ),
      essayAdvice: result['essayAdvice']?.toString() ?? '',
      essayFeedback: EssayFeedback.fromJson(
        _asMap(result['essayFeedback']) ?? const <String, dynamic>{},
      ),
    );
  }

  /// 文章最终得分
  final double totalScore;

  /// 主要得分
  final MajorScore majorScore;

  /// 文章最终评价
  final String essayAdvice;

  /// 文章批改反馈
  final EssayFeedback essayFeedback;
}

/// 主要得分
class MajorScore {
  MajorScore({
    required this.wordScore,
    required this.grammarScore,
    required this.structureScore,
    required this.topicScore,
    required this.grammarAdvice,
    required this.wordAdvice,
  });

  factory MajorScore.fromJson(Map<String, dynamic> json) {
    return MajorScore(
      wordScore: _asDouble(json['wordScore']),
      grammarScore: _asDouble(json['grammarScore']),
      structureScore: _asDouble(json['structureScore']),
      topicScore: _asDouble(json['topicScore']),
      grammarAdvice: json['grammarAdvice']?.toString() ?? '',
      wordAdvice: json['wordAdvice']?.toString() ?? '',
    );
  }

  final double wordScore;
  final double grammarScore;
  final double structureScore;
  final double topicScore;
  final String grammarAdvice;
  final String wordAdvice;
}

/// 文章批改反馈
class EssayFeedback {
  EssayFeedback({required this.sentsFeedback});

  factory EssayFeedback.fromJson(Map<String, dynamic> json) {
    final list = json['sentsFeedback'];
    return EssayFeedback(
      sentsFeedback: (list is List ? list : const <dynamic>[])
          .map(_asMap)
          .whereType<Map<String, dynamic>>()
          .map(SentsFeedback.fromJson)
          .toList(),
    );
  }

  final List<SentsFeedback> sentsFeedback;
}

/// 句子反馈
class SentsFeedback {
  SentsFeedback({
    required this.rawSent,
    required this.correctedSent,
    required this.sentFeedback,
    required this.errorPosInfos,
  });

  factory SentsFeedback.fromJson(Map<String, dynamic> json) {
    final list = json['errorPosInfos'];
    return SentsFeedback(
      rawSent: json['rawSent']?.toString() ?? '',
      correctedSent: json['correctedSent']?.toString() ?? '',
      sentFeedback: json['sentFeedback']?.toString() ?? '',
      errorPosInfos: (list is List ? list : const <dynamic>[])
          .map(_asMap)
          .whereType<Map<String, dynamic>>()
          .map(ErrorPosInfo.fromJson)
          .toList(),
    );
  }

  final String rawSent;
  final String correctedSent;
  final String sentFeedback;
  final List<ErrorPosInfo> errorPosInfos;
}

/// 错误位置信息
class ErrorPosInfo {
  ErrorPosInfo({required this.detailReason});

  factory ErrorPosInfo.fromJson(Map<String, dynamic> json) {
    return ErrorPosInfo(
      detailReason: json['detailReason']?.toString() ?? '',
    );
  }

  final String detailReason;
}

Map<String, dynamic>? _asMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return null;
}

double _asDouble(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
