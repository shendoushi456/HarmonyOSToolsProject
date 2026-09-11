import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_assets.dart';
import '../../menu_fragment/models/tool_definition.dart';

/// MenuFragment(Compose 版)首页的识别卡数据 - 对齐 RecognizeTools
class MenuRecognitionItem {
  const MenuRecognitionItem({
    required this.title,
    required this.iconAsset,
    required this.backgroundColor,
    required this.destination,
  });

  final String title;
  final String iconAsset;
  final Color backgroundColor;
  final ToolDestination destination;
}

/// MenuFragment(Compose 版)首页的文档工具卡数据 - 对齐 SecondToolsSection2
class MenuFunctionItem {
  const MenuFunctionItem({
    required this.label,
    required this.description,
    required this.iconAsset,
    required this.destination,
  });

  final String label;
  final String description;
  final String iconAsset;
  final ToolDestination destination;
}

/// 首页识别卡目录(3 个) - 数据放 ViewModel 层,便于整体换皮复用。
/// 按安卓顺序:花草识别/水果识别/动物识别。
final menuRecognitionItemsProvider = Provider<List<MenuRecognitionItem>>((ref) {
  return const [
    MenuRecognitionItem(
      title: '花草识别',
      iconAsset: AppAssets.menuToolsPlant,
      backgroundColor: Color(0xFFFFDFDF),
      destination: ToolDestination.recognitionPlant,
    ),
    MenuRecognitionItem(
      title: '水果识别',
      iconAsset: AppAssets.menuToolsFruit,
      backgroundColor: Color(0xFFC6EBFF),
      destination: ToolDestination.recognitionIngredient,
    ),
    MenuRecognitionItem(
      title: '动物识别',
      iconAsset: AppAssets.menuToolsAnimal,
      backgroundColor: Color(0xFFFFF4CF),
      destination: ToolDestination.recognitionAnimal,
    ),
  ];
});

/// 首页文档工具卡目录(4 个) - 对齐 SecondToolsSection2 顺序:
/// 拍照存档/文字识别/扫描二维码/生成二维码。
/// 注意:安卓 FunctionCard 的 iconBackgroundColor 参数实际未参与渲染,保真不渲染背景。
final menuFunctionItemsProvider = Provider<List<MenuFunctionItem>>((ref) {
  return const [
    MenuFunctionItem(
      label: '拍照存档',
      description: '高清扫描纸质文档',
      iconAsset: AppAssets.menuToolsPhotoArchive,
      destination: ToolDestination.photoArchive,
    ),
    MenuFunctionItem(
      label: '文字识别',
      description: '从图片中提取文字',
      iconAsset: AppAssets.menuToolsTextRecognition,
      destination: ToolDestination.recognitionText,
    ),
    MenuFunctionItem(
      label: '扫描二维码',
      description: '快速识别各类二维码内容',
      iconAsset: AppAssets.icQrScan,
      destination: ToolDestination.qrScan,
    ),
    MenuFunctionItem(
      label: '生成二维码',
      description: '将文本快速生成为二维码',
      iconAsset: AppAssets.icQrGenerate,
      destination: ToolDestination.qrGenerate,
    ),
  ];
});

/// 顶栏天气小图标映射 - 对齐 WlWeatherUtils.getWeatherDayIcon:
/// 晴→sun / 阴·多云→cloudy / 雷→thunderstorm / 雨→rain / 其他→sun
String menuToolsWeatherIcon(String? condition) {
  if (condition == null || condition.isEmpty) {
    return AppAssets.menuToolsWeatherSun;
  }
  if (condition.contains('晴')) {
    return AppAssets.menuToolsWeatherSun;
  }
  if (condition.contains('阴') || condition.contains('多云')) {
    return AppAssets.menuToolsWeatherCloudy;
  }
  if (condition.contains('雷')) {
    return AppAssets.menuToolsWeatherThunder;
  }
  if (condition.contains('雨')) {
    return AppAssets.menuToolsWeatherRain;
  }
  return AppAssets.menuToolsWeatherSun;
}
