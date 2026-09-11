// 分类页 - 对齐 Android OtherSaoMiaoFrgment.kt ToolsScreen
// 差异：背景由安卓橙色渐变(#FFC68C→White)改为百宝箱页蓝背景(#D8EFFF)
// 已迁移的功能接真实跳转，其余预留点击待接。
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../router/route_names.dart';
import '../../menu_home/pages/image_to_pdf_page.dart';
import '../../menu_home/pages/pdf_compress_page.dart';
import '../../menu_home/pages/pdf_encrypt_page.dart';
import '../../menu_home/pages/pdf_to_image_page.dart';
import '../../image_process/models/image_process_type.dart';
import '../../image_process/pages/image_process_page.dart';
import '../../life_tools/pages/webview/web_tool_page.dart';
import '../../other_scan_tools/pages/base_conversion_page.dart';
import '../../other_scan_tools/pages/currency_converter_page.dart';
import '../../other_scan_tools/pages/relatives_calculator_page.dart';
import '../../portable_tools/pages/magnifier_camera_page.dart';
import '../../portable_tools/pages/pixel_image_page.dart';
import '../../portable_tools/pages/watermark_image_page.dart';
import '../../qr/pages/qr_generator_page.dart';
import '../../qr/pages/qr_scanner_page.dart';
import '../../recognition/models/recognition_type.dart';

/// 顶栏标题色(对齐安卓 #4C4C4C，与 toolsTitleText 相同值)
const _titleText = Color(0xFF4C4C4C);

/// 分类标题/工具名文本色(对齐安卓 #303030)
const _itemText = Color(0xFF303030);

/// 百宝箱页蓝背景(more_page.dart 同色)
const _blueBackground = Color(0xFFD8EFFF);

/// 单个工具网格项数据
class ToolItem {
  final String name;
  final int iconIndex;
  const ToolItem(this.name, this.iconIndex);
}

/// 一个分类区块：标题 + 工具列表
class CategorySection {
  final String title;
  final List<ToolItem> tools;
  const CategorySection(this.title, this.tools);
}

/// 分类页 - 仅 UI，预留点击事件
class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _blueBackground,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          _buildTopAppBar(context),
          Expanded(child: _buildBody()),
        ]),
      ),
    );
  }

  /// 顶部应用栏 - 对齐 ToolTopAppBar：左标题居中 + 右设置图标
  Widget _buildTopAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 44,
        child: Row(children: [
          Expanded(
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(left: 16),
              child: const Text(
                '分类',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _titleText,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // 预留点击事件：原安卓跳转 SettingToolActivity
          // GestureDetector(
          //   onTap: () {},
          //   child: Image.asset(AppAssets.categorySettings,
          //       width: 28, height: 28),
          // ),
        ]),
      ),
    );
  }

  /// 主体：按分类区块纵向排列，每块内为 2 列网格
  Widget _buildBody() {
    final sections = getCategoryData();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final section = sections[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 分类标题 - 对齐 CategoryHeader：16sp Bold #303030，上16下8
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Text(section.title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _itemText)),
            ),
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                mainAxisExtent: 100,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: section.tools.length,
              itemBuilder: (context, i) =>
                  _buildToolItemCard(context, section.tools[i]),
            ),
          ],
        );
      },
    );
  }

  /// 单个工具卡片 - 对齐 ToolItemCard：高100、圆角12、阴影2、白底居中
  Widget _buildToolItemCard(BuildContext context, ToolItem tool) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      // 已迁移功能按名称跳转，其余预留点击事件(原安卓跳对应 Activity)
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _onToolTap(context, tool.name),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AppAssets.quanTool(tool.iconIndex),
                width: 56, height: 56, fit: BoxFit.contain),
            const SizedBox(height: 8),
            Text(tool.name,
                style: const TextStyle(fontSize: 14, color: _itemText),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  /// 工具项点击分发：仅接入项目中已迁移的功能，未迁移的保持空实现
  void _onToolTap(BuildContext context, String name) {
    switch (name) {
      // === 识别类(复用 recognition 页) ===
      case '文字识别':
        context.push(RoutePaths.recognition, extra: RecognitionType.text);
        break;
      case '植物识别':
        context.push(RoutePaths.recognition, extra: RecognitionType.plant);
        break;
      case '动物识别':
        context.push(RoutePaths.recognition, extra: RecognitionType.animal);
        break;
      case '果蔬识别':
        context.push(RoutePaths.recognition, extra: RecognitionType.ingredient);
        break;
      // === 已迁移工具页 ===
      case '指南针':
        context.push(RoutePaths.compass);
        break;
      case '计算器':
        context.push(RoutePaths.calculator);
        break;
      case '像素图':
        PixelImagePage.push(context);
        break;
      // === PDF 工具(master_mianfeisaosaowang 迁移) ===
      case 'PDF转图片':
        PdfToImagePage.push(context);
        break;
      case '图片转PDF':
        ImageToPdfPage.push(context);
        break;
      case '压缩PDF':
        PdfCompressPage.push(context);
        break;
      case '加密PDF':
        PdfEncryptPage.push(context);
        break;
      // === 百度图像处理(master_mianfeisaosaowang 迁移) ===
      case '黑白上色':
        _pushImageProcess(context, ImageProcessType.colourize);
        break;
      // 特效图：安卓原版为 LowPoly 效果，Flutter 侧映射为百度图像风格转换
      case '图像风格转换':
        _pushImageProcess(context, ImageProcessType.styleTransfer);
        break;
      case '人像动漫化':
        _pushImageProcess(context, ImageProcessType.selfieAnime);
        break;
      // === 图像工具/计算器/网页工具(master_mianfeisaosaowang 迁移) ===
      case '添加水印':
        WatermarkImagePage.push(context);
        break;
      case '放大镜':
        MagnifierCameraPage.push(context);
        break;
      case '汇率换算':
        OtherCurrencyConverterPage.push(context);
        break;
      case '亲戚关系计算器':
        RelativesCalculatorPage.push(context);
        break;
      case '进制计算器':
        BaseConversionPage.push(context);
        break;
      case '今天吃什么':
        WebToolPage.push(context,
            title: '今天吃什么',
            url: 'assets/game/jintianchishenme/index.html');
        break;
      // === 二维码工具(master_saolaisao 迁移) ===
      case '二维码扫描':
        _pushPage(context, const QrScannerPage());
        break;
      case '二维码生成':
        _pushPage(context, const QrGeneratorPage());
        break;
      // 其余功能尚未迁移，预留
      default:
        break;
    }
  }

  /// 通用压栈跳转
  void _pushPage(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  /// 进入百度图像处理页(相机拍摄/相册选图 → 调用百度 API → 保存到相册)
  void _pushImageProcess(BuildContext context, ImageProcessType type) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ImageProcessPage(type: type)),
    );
  }

  /// 分类数据 - 对齐 getCategoryData()，注释项(取色器/网速测试/文件清理)同样保留为注释
  List<CategorySection> getCategoryData() {
    return const [
      // === 二维码扫描分类 ===
      CategorySection('扫描工具', [
        ToolItem('二维码扫描', 1),
        ToolItem('文字识别', 2),
        ToolItem('植物识别', 3),
        ToolItem('动物识别', 4),
        ToolItem('果蔬识别', 5),
        // ToolItem('菜谱识别', 6),
      ]),
      // === 文件工具分类 ===
      CategorySection('PDF工具', [
        ToolItem('PDF转图片', 7),
        ToolItem('图片转PDF', 8),
        // ToolItem('压缩PDF', 9),
        ToolItem('加密PDF', 10),
      ]),
      // === 设备工具分类 ===
      CategorySection('图片工具', [
        ToolItem('二维码生成', 11),
        ToolItem('添加水印', 12),
        ToolItem('人像动漫化', 13),
        // ToolItem('马赛克', 14),
        ToolItem('像素图', 15),
        ToolItem('图像风格转换', 16),
        // 预留：ToolItem('取色器', 17),
        ToolItem('黑白上色', 18),
        // ToolItem('隐藏图', 19),
      ]),
      // === 计算器分类 ===
      CategorySection('计算器', [
        ToolItem('计算器', 25),
        ToolItem('汇率换算', 26),
        ToolItem('亲戚关系计算器', 27),
        // ToolItem('日期计算器', 28),
        ToolItem('进制计算器', 29),
      ]),
      // === 其他分类 ===
      CategorySection('其他', [
        // ToolItem('画板', 30),
        ToolItem('今天吃什么', 31),
        // 预留：ToolItem('网速测试', 33),
        // ToolItem('望远镜', 21),
        ToolItem('放大镜', 22),
        ToolItem('指南针', 23),
        // 预留：ToolItem('文件清理', 35),
      ]),
    ];
  }
}
