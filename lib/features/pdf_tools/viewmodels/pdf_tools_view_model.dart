import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_assets.dart';
import '../../menu_fragment/models/tool_definition.dart';

/// PDFFragment 工具项 - 对齐 PdfToolType 枚举。
/// 注意:描述文案用 getDescriptionForTool 的硬编码值,
/// 枚举自身的 description 字段("快速将PDF转换为图片"等)未被安卓使用。
class PdfToolItem {
  const PdfToolItem({
    required this.title,
    required this.description,
    required this.iconAsset,
    required this.destination,
  });

  final String title;
  final String description;
  final String iconAsset;
  final ToolDestination destination;
}

/// PDF 工具目录(4 个) - 对齐 PdfToolTabRow 顺序,
/// 图标复用 assets/images/ic_shan_main_4_x(安卓同源图)。
final pdfToolItemsProvider = Provider<List<PdfToolItem>>((ref) {
  return const [
    PdfToolItem(
      title: 'PDF转图片',
      description: '选择PDF文件，转换为图片',
      iconAsset: AppAssets.icPdfToImage, // ic_shan_main_4_2
      destination: ToolDestination.pdfToImage,
    ),
    PdfToolItem(
      title: '图片转PDF',
      description: '选择图片，转换为PDF文件',
      iconAsset: AppAssets.icImageToPdf, // ic_shan_main_4_1
      destination: ToolDestination.imageToPdf,
    ),
    PdfToolItem(
      title: '压缩PDF',
      description: '选择PDF文件，压缩文件大小',
      iconAsset: AppAssets.icPdfCompress, // ic_shan_main_4_3
      destination: ToolDestination.pdfCompress,
    ),
    PdfToolItem(
      title: '加密PDF',
      description: '选择PDF文件，添加密码保护',
      iconAsset: AppAssets.icPdfEncrypt, // ic_shan_main_4_4
      destination: ToolDestination.pdfEncrypt,
    ),
  ];
});

/// 选中工具状态 - 对齐 PdfScreenContent 的
/// remember { mutableStateOf(PdfToolType.PDF_TO_IMAGE) }。
class PdfToolsViewModel extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) => state = index;
}

final pdfToolsViewModelProvider =
    NotifierProvider<PdfToolsViewModel, int>(PdfToolsViewModel.new);
