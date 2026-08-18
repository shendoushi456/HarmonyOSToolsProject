/// 汽车养护项数据模型
///
/// 对应 Android: toolCarLib/CarMaintenanceActivity.kt:35-39
class CarMaintenanceItem {
  final String title;
  final String imageAsset;
  final String markdownContent;

  const CarMaintenanceItem({
    required this.title,
    required this.imageAsset,
    required this.markdownContent,
  });
}
