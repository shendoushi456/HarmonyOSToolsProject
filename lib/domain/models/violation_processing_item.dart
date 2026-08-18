/// 违章处理项数据模型
///
/// 对应 Android: toolCarLib/ViolationProcessingActivity.kt:35-38
class ViolationProcessingItem {
  final String title;
  final String markdownContent;

  const ViolationProcessingItem({
    required this.title,
    required this.markdownContent,
  });
}
