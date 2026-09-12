// ScanToolsFragment Flutter 迁移版 - 工具页
// 对齐 Android toolbox_c ScanToolsFragment.kt（ToolboxScreen + ToolPage + ToolCategoryPanel）
// 迁移调整（按需求）：
//   - 背景改为画板页黄背景 AppColors.homeBg（原版为顶部 yellowbgl 图片）
//   - 去掉顶部设置入口（原 TopBar 的 Settings 图标）
//   - 仅保留 3 个分类：扫描工具 / PDF处理 / 计算工具
//   - 功能项列表由两列改为一列
//   - 分类默认全部展开（原版默认收起）
//   - 当前项目已有对应功能绑定点跳，无对应功能预留点击
import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../menu_home/pages/image_to_pdf_page.dart';
import '../../menu_home/pages/pdf_encrypt_page.dart';
import '../../menu_home/pages/pdf_to_image_page.dart';
import '../../menu_home/pages/qr_scan_page.dart';
import '../../other_scan_tools/pages/base_conversion_page.dart';
import '../../recognition/models/recognition_type.dart';
import '../../recognition/pages/recognition_page.dart';
import '../../scan_menu/pages/currency_converter_page.dart';

class ScanToolsFragmentPage extends StatelessWidget {
  const ScanToolsFragmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 原版：Box(白底) + 200dp yellowbgl 顶部背景；此处按要求改为画板页黄背景
    return Scaffold(
      backgroundColor: const Color(0xFFF1EBD5),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopBar(),
            const Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    SizedBox(height: 12),
                    ToolCategoryPanel(),
                    SizedBox(height: 50), // 原版页面底部留白 Spacer(50.dp)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 页面顶部标题 "工具"（对齐原版 TopBar，去掉右侧设置图标）
  Widget _buildTopBar() {
    return const SizedBox(
      height: 50,
      child: Center(
        child: Text(
          '工具',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

/// 功能项数据类（对齐 ToolItem）
typedef _ToolTap = void Function(BuildContext context);

class _ToolItem {
  final String iconRes; // 图标资源
  final String title; // 功能名称
  final _ToolTap? onTap; // 当前项目有对应功能则绑定，否则预留 null
  const _ToolItem(this.iconRes, this.title, [this.onTap]);
}

/// 分类数据类（对齐 ToolCategory）
class _ToolCategory {
  final String categoryName;
  final List<_ToolItem> items;
  const _ToolCategory(this.categoryName, this.items);
}

/// 分类面板（对齐 ToolCategoryPanel）
/// 迁移调整：默认全部展开；每行 2 个改为一列纵排
class ToolCategoryPanel extends StatefulWidget {
  const ToolCategoryPanel({super.key});

  @override
  State<ToolCategoryPanel> createState() => _ToolCategoryPanelState();
}

class _ToolCategoryPanelState extends State<ToolCategoryPanel> {
  // 功能项数据（对齐 ToolPage 的 toolCategories，仅保留需求指定的 3 类）
  static final List<_ToolCategory> _categories = [
    _ToolCategory('扫描工具', [
      _ToolItem(AppAssets.toolBankCard, '银行卡识别',
          (c) => _toRecognition(c, RecognitionType.bankCard)),
      // _ToolItem(AppAssets.toolDocScan, '二维码扫描',
      //     (c) => DocumentCameraPage.capture(c)),
      _ToolItem(AppAssets.toolTextScan, '文字识别',
          (c) => _toRecognition(c, RecognitionType.text)),
      // 二维码扫描（用户追加入口，安卓原版无此项，复用首页扫码图标）
      _ToolItem(AppAssets.homeQrScanIcon, '二维码扫描',
          (c) => QrScanPage.push(c)),
    ]),
    _ToolCategory('PDF处理', [
      _ToolItem(
          AppAssets.toolPdfToImage, 'PDF转图片', (c) => PdfToImagePage.push(c)),
      _ToolItem(
          AppAssets.toolImageToPdf, '图片转PDF', (c) => ImageToPdfPage.push(c)),
      _ToolItem(
          AppAssets.toolPdfEncrypt, '加密PDF', (c) => PdfEncryptPage.push(c)),
    ]),
    _ToolCategory('计算工具', [
      _ToolItem(AppAssets.toolExchangeRate, '汇率换算',
          (c) => CurrencyConverterPage.push(c)),
      // _ToolItem(AppAssets.toolTally, '花费记账', (c) => TallyPage.push(c)),
      // 日期计算器/json编辑器：安卓原版为 EatActivity 加载网页，当前项目用 WebToolPage 对应
      // _ToolItem(AppAssets.toolDateCalc, '亲戚计算器',
      //     (c) => WebToolPage.push(c,
      //         title: '日期计算器',
      //         url: 'https://ol.woobx.cn/tool/date-calculator')),
      // 进制计算器（master_mianfeisaosaowang 迁入，other_scan_tools）
      _ToolItem(AppAssets.toolJsonEditor, '进制计算器',
          (c) => BaseConversionPage.push(c)),
    ]),
  ];

  // 每个分类独立的展开状态（对齐 rememberSaveable + mutableStateOf(false)，改为默认展开）
  late final Map<String, bool> _expandedMap = {
    for (final c in _categories) c.categoryName: true,
  };

  static void _toRecognition(BuildContext context, RecognitionType type) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RecognitionPage(type: type)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < _categories.length; i++) ...[
          if (i > 0) const SizedBox(height: 28), // 原版分类间距 spacedBy(28.dp)
          _buildCategory(context, _categories[i]),
        ],
      ],
    );
  }

  /// 单个分类：标题栏 + 展开的功能项列表（对齐原版单分类 Column）
  Widget _buildCategory(BuildContext context, _ToolCategory category) {
    final isExpanded = _expandedMap[category.categoryName] ?? true;
    return Column(
      children: [
        // 分类标题栏：白色圆角卡 + 阴影 + 居中标题 + 箭头
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000), // shadow elevation 3dp 近似
                blurRadius: 3,
              ),
            ],
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() {
              _expandedMap[category.categoryName] = !isExpanded;
            }),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    category.categoryName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // 展开显示上箭头(topiconl)，收起显示下箭头(bottomiconl)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Image.asset(
                      isExpanded ? AppAssets.toolArrowUp : AppAssets.toolArrowDown,
                      width: 10,
                      height: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // 功能项区域（原版 AnimatedVisibility 展开/收起，改为一列纵排）
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              children: [
                for (var i = 0; i < category.items.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12), // 原版 spacedBy(12.dp)
                  _buildToolItemButton(context, category.items[i]),
                ],
              ],
            ),
          ),
      ],
    );
  }

  /// 单个功能项卡片（对齐 ToolItemButton：高70dp、圆角10dp、白底、阴影2dp）
  Widget _buildToolItemButton(BuildContext context, _ToolItem item) {
    return GestureDetector(
      onTap: item.onTap != null ? () => item.onTap!(context) : () {},
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white, // 原版 AppColors.DarkBackground = 白色
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000), // elevation 2dp 近似
              blurRadius: 2,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Image.asset(item.iconRes, width: 40, height: 40, fit: BoxFit.contain),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    // 原版 desc Text 已注释，不显示
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
