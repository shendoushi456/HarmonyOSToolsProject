/// 离线涂鸦素材模型，对齐 Android OfflineImageItem。
class OfflineGraffitiItem {
  const OfflineGraffitiItem(
      {required this.id, required this.assetPath, required this.category});
  final String id;
  final String assetPath;
  final String category;
}
