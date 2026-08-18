/// 违章代码数据模型
///
/// 对应 Android: toolCarLib/SearchViolationCodeCarActivity.kt:33-38
class ViolationCode {
  final String code;
  final String content;
  final String fine; // 罚款金额，可为数字字符串、"吊销"、空字符串
  final int points; // 扣分分值

  const ViolationCode({
    required this.code,
    required this.content,
    required this.fine,
    required this.points,
  });
}
