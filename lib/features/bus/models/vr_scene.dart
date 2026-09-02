// VR 实景数据模型 - 对齐 Android hotSceniclib 的 VrScene。
class VrScene {
  const VrScene({
    required this.imageAsset,
    required this.title,
    required this.subtitle,
    required this.url,
  });

  /// Flutter 本地封面图路径。
  final String imageAsset;
  final String title;
  final String subtitle;

  /// 第三方 720yun 全景页地址；全景渲染仍由网页自身负责。
  final String url;
}
