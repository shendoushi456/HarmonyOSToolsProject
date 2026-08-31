import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_assets.dart';
import '../models/clean_tool_item.dart';
import '../models/image_process_type.dart';

/// 工具列表 VM：后续马甲包替换 UI 时只需复用本数据层和各功能页面。
final cleanToolsProvider = Provider<List<CleanToolItem>>((ref) => const [
      CleanToolItem(
        title: '银行卡识别',
        subtitle: '快速识别银行卡信息，方便准确查阅',
        iconAsset: AppAssets.cleanToolBankCard,
        action: CleanToolAction.bankCard,
      ),
      CleanToolItem(
        title: '图片黑白上色',
        subtitle: '智能为黑白照片上色，重现美好色彩',
        iconAsset: AppAssets.cleanToolColourize,
        action: CleanToolAction.imageProcess,
        imageProcessType: ImageProcessType.colourize,
      ),
      CleanToolItem(
        title: '图像风格转换',
        subtitle: '一键转换多种艺术画风，创作更有趣',
        iconAsset: AppAssets.cleanToolStyle,
        action: CleanToolAction.imageProcess,
        imageProcessType: ImageProcessType.styleTransfer,
      ),
      CleanToolItem(
        title: '人像动漫化',
        subtitle: '智能生成个性动漫形象，发现另一面',
        iconAsset: AppAssets.cleanToolAnime,
        action: CleanToolAction.imageProcess,
        imageProcessType: ImageProcessType.selfieAnime,
      ),
      CleanToolItem(
        title: '二维码识别',
        subtitle: '快速识别二维码内容，使用更便捷',
        iconAsset: AppAssets.cleanToolQr,
        action: CleanToolAction.qrScan,
      ),
      CleanToolItem(
        title: '文字识别',
        subtitle: '快速识别图片文字内容，提取更轻松',
        iconAsset: AppAssets.cleanToolText,
        action: CleanToolAction.textRecognition,
      ),
    ]);
