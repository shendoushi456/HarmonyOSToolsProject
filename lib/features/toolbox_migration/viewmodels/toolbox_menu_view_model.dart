// ScanMenuActivity 的展示数据层。将 UI 文案、图片和业务标识集中，方便马甲 UI 复用。
import '../../../core/constants/app_assets.dart';

class ToolboxCategoryItem {
  const ToolboxCategoryItem({
    required this.title,
    required this.asset,
    this.categoryCode,
  });

  final String title;
  final String asset;
  final int? categoryCode;
}

class ToolboxRecognitionItem {
  const ToolboxRecognitionItem({
    required this.title,
    required this.prompt,
    required this.asset,
    required this.type,
    required this.gradient,
  });

  final String title;
  final String prompt;
  final String asset;
  final String type;
  final List<int> gradient;
}

class ToolboxMenuViewModel {
  ToolboxMenuViewModel._();
  static final instance = ToolboxMenuViewModel._();

  final onlineCategories = const [
    ToolboxCategoryItem(title: '水果', asset: AppAssets.toolboxFruit),
    ToolboxCategoryItem(title: '字母', asset: AppAssets.toolboxLetter),
    ToolboxCategoryItem(title: '数字', asset: AppAssets.toolboxNumber),
    ToolboxCategoryItem(title: '曼茶罗', asset: AppAssets.toolboxMandala),
  ];

  final offlineCategories = const [
    ToolboxCategoryItem(
        title: '卡通', asset: AppAssets.toolboxCartoon, categoryCode: 2),
    ToolboxCategoryItem(
        title: '动物', asset: AppAssets.toolboxAnimal, categoryCode: 3),
    ToolboxCategoryItem(
        title: '食物', asset: AppAssets.toolboxFood, categoryCode: 4),
    ToolboxCategoryItem(
        title: '交通', asset: AppAssets.toolboxTraffic, categoryCode: 5),
    ToolboxCategoryItem(
        title: '自然', asset: AppAssets.toolboxNature, categoryCode: 6),
    ToolboxCategoryItem(
        title: '鲜花', asset: AppAssets.toolboxFlower, categoryCode: 1),
  ];

  final recognitionItems = const [
    ToolboxRecognitionItem(
      title: '花草识别',
      prompt: '点击开始识别',
      asset: AppAssets.toolboxPlantRecognition,
      type: 'plant',
      gradient: [0xFFFFEAA2F6, 0xFFFFEE75F8],
    ),
    ToolboxRecognitionItem(
      title: '水果识别',
      prompt: '点击开始识别',
      asset: AppAssets.toolboxFruitRecognition,
      type: 'ingredient',
      gradient: [0xFFFFFCCE9A, 0xFFFFFEB66A],
    ),
    ToolboxRecognitionItem(
      title: '动物识别',
      prompt: '点击开始识别',
      asset: AppAssets.toolboxAnimalRecognition,
      type: 'animal',
      gradient: [0xFFFF99E7FC, 0xFFFF5DE1ED],
    ),
  ];
}
