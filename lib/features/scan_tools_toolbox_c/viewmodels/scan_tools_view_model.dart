import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_assets.dart';
import '../../../features/menu_fragment/models/tool_definition.dart';
import '../models/scan_tool_category.dart';

/// 对齐 Android ScanToolsFragment.ToolsScreen：
///   4 个分类(文件工具 / 图片处理 / 计算器 / 其他) × 各 4 个工具项。
///
/// 用户在迁移指令中要求：
/// - 文件工具整体不迁移
/// - 图片处理："特效图" 改名"图像风格转换"，"隐藏图" 改名"人像动漫化"
/// - 计算器："日期计算器" 不迁移
/// - 其他："网速测试" 改名"记事本"，"随机数生成" 改名"花费记账"，"json编辑器" 不迁移
///
/// 颜色直接还原 Kotlin 的 Color(int) 字面值；源工程 `IconBgYellowLight =
/// Color(0xFFFFFE1)` 是 7 位十六进制字面量，Compose 解读为 ARGB = 0x0FFFFFE1
/// (alpha 0x0F ≈ 6%)，实际渲染时首项的彩色框近乎不可见，图标看上去比
/// 第二项起"小"一截。这里修正为完整的浅黄 `Color(0xFFFFFEE1)`，与图案内
/// 嵌的浅黄背景一致，让三个分类的首项视觉重量对齐；其余三色按 Kotlin
/// 字面值原样保留。
final scanToolsCategoriesProvider = Provider<List<ScanToolCategory>>((ref) {
  return const [
      // 图片处理(4 项)
      ScanToolCategory(
        title: '图片处理',
        tools: [
          ScanToolItem(
            iconAsset: AppAssets.stIcPixelate,
            title: '像素图',
            backgroundColor: Color(0xFFFFFEE1),
            destination: ToolDestination.pixelImage,
          ),
          ScanToolItem(
            iconAsset: AppAssets.stIcSpecialEffects,
            title: '图像风格转换',
            backgroundColor: Color(0xFFFFE5C3),
            destination: ToolDestination.imageStyleTransfer,
          ),
          ScanToolItem(
            iconAsset: AppAssets.stIcHideImage,
            title: '人像动漫化',
            backgroundColor: Color(0xFFD9DFFF),
            destination: ToolDestination.selfieAnime,
          ),
          ScanToolItem(
            iconAsset: AppAssets.stIcColorize,
            title: '黑白上色',
            backgroundColor: Color(0xFFE9E9FF),
            destination: ToolDestination.imageColourize,
          ),
        ],
      ),
      // 计算器(3 项，去掉日期计算器)
      ScanToolCategory(
        title: '计算器',
        tools: [
          ScanToolItem(
            iconAsset: AppAssets.stIcRelationshipCalculator,
            title: '亲戚关系\n计算器',
            backgroundColor: Color(0xFFFFFEE1),
            destination: ToolDestination.relativesCalculator,
          ),
          ScanToolItem(
            iconAsset: AppAssets.stIcBaseConverter,
            title: '进制计算器',
            backgroundColor: Color(0xFFD9DFFF),
            destination: ToolDestination.baseConverter,
          ),
          ScanToolItem(
            iconAsset: AppAssets.stIcExchangeRate,
            title: '汇率换算',
            backgroundColor: Color(0xFFE9E9FF),
            destination: ToolDestination.currencyConverter,
          ),
        ],
      ),
      // 其他(3 项：网速测试→记事本、随机数生成→花费记账、今天吃什么保留；json 编辑器去掉)
      ScanToolCategory(
        title: '其他',
        tools: [
          ScanToolItem(
            iconAsset: AppAssets.stIcSpeedTest,
            title: '记事本',
            backgroundColor: Color(0xFFFFFEE1),
            destination: ToolDestination.notebook,
          ),
          ScanToolItem(
            iconAsset: AppAssets.stIcRandomNumber,
            title: '花费记账',
            backgroundColor: Color(0xFFFFE5C3),
            destination: ToolDestination.tally,
          ),
          ScanToolItem(
            iconAsset: AppAssets.stIcWhatToEat,
            title: '今天吃什么',
            backgroundColor: Color(0xFFD9DFFF),
            destination: ToolDestination.eatToday,
          ),
        ],
      ),
    ];
});