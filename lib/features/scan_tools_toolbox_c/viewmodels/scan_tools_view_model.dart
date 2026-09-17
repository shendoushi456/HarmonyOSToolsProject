import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_assets.dart';
import '../../../features/menu_fragment/models/tool_definition.dart';
import '../models/scan_tool_category.dart';

/// 对齐 Android ScanToolsFragment.ToolsScreen：
///   文件工具 / 图片处理 / 计算器 / 其他 四个分类。
///
/// 用户在早期迁移指令中做的马甲调整(保留不动)：
/// - 图片处理："特效图" 改名"图像风格转换"，"隐藏图" 改名"人像动漫化"
/// - 其他："网速测试" 改名"记事本"，"随机数生成" 改名"花费记账"
///
/// 2026-09-17 补齐 ScanToolsFragment 缺失功能(保留上述改名项，追加新项)：
/// - 文件工具 4 个 PDF 模块(master_mianfeisaosaowang，PDF转图片带保存到相册)
/// - 图片处理追加 特效图/隐藏图(65fb1c3 LowPolyPage/HiddenImagePage)
/// - 计算器追加 日期计算器(f30166b，WebToolPage 打开在线工具)
/// - 其他追加 网速测试(f97812d SpeedNetPage)/随机数生成/json编辑器(f30166b)
///
/// 颜色直接还原 Kotlin 的 Color(int) 字面值；源工程 `IconBgYellowLight =
/// Color(0xFFFFFE1)` 是 7 位十六进制字面量，Compose 解读为 ARGB = 0x0FFFFFE1
/// (alpha 0x0F ≈ 6%)，实际渲染时首项的彩色框近乎不可见，图标看上去比
/// 第二项起"小"一截。这里修正为完整的浅黄 `Color(0xFFFFFEE1)`，与图案内
/// 嵌的浅黄背景一致，让三个分类的首项视觉重量对齐；其余三色按 Kotlin
/// 字面值原样保留。
final scanToolsCategoriesProvider = Provider<List<ScanToolCategory>>((ref) {
  return const [
      // 文件工具(4 项 - ScanToolsFragment 原版分类，此前整体未迁移)
      ScanToolCategory(
        title: '文件工具',
        tools: [
          ScanToolItem(
            iconAsset: AppAssets.icPdfToImage,
            title: 'PDF转图片',
            backgroundColor: Color(0xFFFFFEE1),
            destination: ToolDestination.pdfToImage,
          ),
          ScanToolItem(
            iconAsset: AppAssets.icImageToPdf,
            title: '图片转PDF',
            backgroundColor: Color(0xFFFFE5C3),
            destination: ToolDestination.imageToPdf,
          ),
          ScanToolItem(
            iconAsset: AppAssets.icPdfCompress,
            title: '压缩PDF',
            backgroundColor: Color(0xFFD9DFFF),
            destination: ToolDestination.pdfCompress,
          ),
          ScanToolItem(
            iconAsset: AppAssets.icPdfEncrypt,
            title: '加密PDF',
            backgroundColor: Color(0xFFE9E9FF),
            destination: ToolDestination.pdfEncrypt,
          ),
        ],
      ),
      // 图片处理(原有 4 项保留 + 追加特效图/隐藏图，共 6 项 3 行)
      ScanToolCategory(
        title: '图片处理',
        tools: [
          ScanToolItem(
            iconAsset: AppAssets.stIcPixelate,
            title: '像素图',
            backgroundColor: Color(0xFFFFFEE1),
            destination: ToolDestination.pixelImage,
          ),
          // ScanToolItem(
          //   iconAsset: AppAssets.stIcSpecialEffects,
          //   title: '图像风格转换',
          //   backgroundColor: Color(0xFFFFE5C3),
          //   destination: ToolDestination.imageStyleTransfer,
          // ),
          // ScanToolItem(
          //   iconAsset: AppAssets.stIcHideImage,
          //   title: '人像动漫化',
          //   backgroundColor: Color(0xFFD9DFFF),
          //   destination: ToolDestination.selfieAnime,
          // ),
          ScanToolItem(
            iconAsset: AppAssets.otherScanStyle,
            title: '特效图',
            backgroundColor: Color(0xFFFFFEE1),
            destination: ToolDestination.lowPoly,
          ),
          ScanToolItem(
            iconAsset: AppAssets.otherScanHiddenImage,
            title: '隐藏图',
            backgroundColor: Color(0xFFFFE5C3),
            destination: ToolDestination.hiddenImage,
          ),
          ScanToolItem(
            iconAsset: AppAssets.stIcColorize,
            title: '图片转黑白',
            backgroundColor: Color(0xFFE9E9FF),
            destination: ToolDestination.imageColourize,
          ),
        ],
      ),
      // 计算器(原有 3 项保留 + 追加日期计算器，共 4 项 2 行)
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
            iconAsset: AppAssets.otherScanDate,
            title: '日期计算器',
            backgroundColor: Color(0xFFFFE5C3),
            destination: ToolDestination.dateCalculator,
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
      // 其他(原有 3 项保留 + 追加网速测试/随机数生成/json编辑器，共 6 项 3 行)
      ScanToolCategory(
        title: '其他',
        tools: [
          // ScanToolItem(
          //   iconAsset: AppAssets.stIcSpeedTest,
          //   title: '记事本',
          //   backgroundColor: Color(0xFFFFFEE1),
          //   destination: ToolDestination.notebook,
          // ),
          // ScanToolItem(
          //   iconAsset: AppAssets.stIcRandomNumber,
          //   title: '花费记账',
          //   backgroundColor: Color(0xFFFFE5C3),
          //   destination: ToolDestination.tally,
          // ),
          ScanToolItem(
            iconAsset: AppAssets.wifiToolsCesuIcon,
            title: '网速测试',
            backgroundColor: Color(0xFFE9E9FF),
            destination: ToolDestination.speedTest,
          ),
          ScanToolItem(
            iconAsset: AppAssets.otherScanRandom,
            title: '随机数生成',
            backgroundColor: Color(0xFFFFFEE1),
            destination: ToolDestination.randomNumber,
          ),
          ScanToolItem(
            iconAsset: AppAssets.stIcWhatToEat,
            title: '今天吃什么',
            backgroundColor: Color(0xFFD9DFFF),
            destination: ToolDestination.eatToday,
          ),
          ScanToolItem(
            iconAsset: AppAssets.mtoolslJson,
            title: 'json编辑器',
            backgroundColor: Color(0xFFFFE5C3),
            destination: ToolDestination.jsonEditor,
          ),
        ],
      ),
    ];
});