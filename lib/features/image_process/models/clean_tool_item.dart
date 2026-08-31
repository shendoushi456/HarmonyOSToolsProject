import 'image_process_type.dart';

enum CleanToolAction {
  bankCard,
  imageProcess,
  qrScan,
  textRecognition,
}

/// CleanMainFragment 的纵向列表数据。资源和跳转意图与展示层解耦。
class CleanToolItem {
  const CleanToolItem({
    required this.title,
    required this.subtitle,
    required this.iconAsset,
    required this.action,
    this.imageProcessType,
  });

  final String title;
  final String subtitle;
  final String iconAsset;
  final CleanToolAction action;
  final ImageProcessType? imageProcessType;
}
