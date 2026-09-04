import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../router/route_names.dart';
import '../../menu_home/pages/qr_generate_page.dart';
import '../../menu_home/pages/qr_scan_page.dart';
import '../../recognition/models/recognition_type.dart';
import '../../scan_menu/pages/document_capture_preview_page.dart';
import '../models/menu_toolbox_c_section.dart';

/// 对齐 Android MenuFragment.kt:ScannerHomeScreen 的固定分区数据。
///
/// 整页由 [banner] / [identification] / [extraction] / [qrCard] / [toolList]
/// 五段构成，与 Android Composable 的 item 列表一一对应；智能扫描横幅按要求
/// 不带点击事件，格式转换按用户要求不迁移。
final menuToolboxCSectionsProvider = Provider<List<MenuToolboxCSection>>((ref) {
  return [
    // 1. 顶部标题不在 section 数据里，由页面固定渲染，对应 TopHeader Composable。
    // 2. 智能扫描横幅 - 仅图片，无点击事件。
    const MenuToolboxCSection.banner(AppAssets.tbcBannerSmartScan),

    // 3. 识别功能一行三卡：花草识别 / 果蔬识别 / 动物识别。
    MenuToolboxCSection.identification([
      MenuIdentificationCard(
        title: '花草识别',
        iconAsset: AppAssets.tbcIcFlower,
        backgroundColor: const Color(0xFF60C9FE),
        onTap: (context) =>
            context.push(RoutePaths.recognition, extra: RecognitionType.plant),
      ),
      MenuIdentificationCard(
        title: '果蔬识别',
        iconAsset: AppAssets.tbcIcVegetable,
        backgroundColor: const Color(0xFFF88661),
        onTap: (context) => context.push(
          RoutePaths.recognition,
          extra: RecognitionType.ingredient,
        ),
      ),
      MenuIdentificationCard(
        title: '动物识别',
        iconAsset: AppAssets.tbcIcAnimal,
        backgroundColor: const Color(0xFFFFCE4D),
        onTap: (context) => context.push(
          RoutePaths.recognition,
          extra: RecognitionType.animal,
        ),
      ),
    ]),

    // 4. 文字提取 + 二维码扫描
    MenuToolboxCSection.extraction([
      MenuExtractionCard(
        title: '文字提取',
        backgroundAsset: AppAssets.tbcBgTextExtract,
        iconAsset: AppAssets.tbcIcTextExtract,
        onTap: (context) => context.push(
          RoutePaths.recognition,
          extra: RecognitionType.text,
        ),
      ),
      MenuExtractionCard(
        title: '二维码扫描',
        backgroundAsset: AppAssets.tbcBgQrScan,
        iconAsset: AppAssets.tbcIcQrScanSmall,
        onTap: (context) => QrScanPage.push(context),
      ),
    ]),

    // 5. 制作二维码 - 对应 CreateQrCard
    MenuToolboxCSection.qrCard(
      MenuQrCard(
        title: '制作二维码',
        subtitle: '自定义内容，定制专属二维码',
        iconAsset: AppAssets.tbcIcQrCodeLarge,
        onTap: (context) => QrGeneratePage.push(context),
      ),
    ),

    // 6. 文档扫描 - 对应 ToolListItem；格式转换按要求不迁移。
    MenuToolboxCSection.toolList(
      MenuToolListItem(
        title: '文档扫描',
        subtitle: '快速扫描文档内容',
        iconAsset: AppAssets.tbcIcOcrDocument,
        onTap: (context) =>
            DocumentCapturePreviewPage.startFlow(context, title: '拍照存档'),
      ),
    ),
  ];
});