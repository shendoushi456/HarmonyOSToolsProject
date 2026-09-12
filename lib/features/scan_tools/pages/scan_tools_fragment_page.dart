// ScanToolsFragment.kt 的 Flutter 迁移版（toolbox_c toolsbox_moduel/toolsbox Compose 版）。
// 按需求调整：顶部"放大工具"模块替换为 MenuFragment.kt 的 PDF 工具模块；去掉顶部设置图标。
// 有对应功能的工具绑定点击事件，没有的预留空点击。
import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../image_process/models/image_process_type.dart';
import '../../image_process/pages/image_process_page.dart';
import '../../life_tools/pages/webview/web_tool_page.dart';
import '../../menu_home/pages/image_to_pdf_page.dart';
import '../../menu_home/pages/pdf_encrypt_page.dart';
import '../../menu_home/pages/pdf_to_image_page.dart';
import '../../other_scan_tools/pages/base_conversion_page.dart';
import '../../portable_tools/pages/pixel_image_page.dart';
import '../../scan_menu/pages/currency_converter_page.dart';

class ScanToolsFragmentPage extends StatelessWidget {
  const ScanToolsFragmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5FC),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // TopBar：标题"工具箱"（原 TopBar 高 90dp 内居中；设置图标按需求移除）
            const SizedBox(
              height: 90,
              child: Center(
                child: Text('生活助手',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.w500)),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 主体内容：padding(top:12, horizontal:20)，区间距 16
                    Padding(
                      padding: const EdgeInsets.only(top: 12, left: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          // 放大工具 → 按需求替换为 PDF 工具
                          PdfToolsSection(),
                          SizedBox(height: 16),
                          ImageToolsSection(),
                          SizedBox(height: 16),
                          OtherToolsSection(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50), // 页面底部留白
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

/// "PDF工具"区域（对齐 MenuFragment.kt 的 PdfToolsSection：LazyRow 横向滑动）
class PdfToolsSection extends StatelessWidget {
  const PdfToolsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PDF工具',
            style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _PdfToolCard(
                title: 'PDF转图片',
                subtitle: '文档一键转换高清图片',
                icon: AppAssets.iconPdfImg,
                onTap: () => PdfToImagePage.push(context),
              ),
              const SizedBox(width: 12),
              _PdfToolCard(
                title: '图片转PDF',
                subtitle: '图片快速整合PDF文件',
                icon: AppAssets.iconImgPdf,
                onTap: () => ImageToPdfPage.push(context),
              ),
              // const SizedBox(width: 12),
              // _PdfToolCard(
              //   title: '压缩PDF',
              //   subtitle: '优化质量 缩减体积',
              //   icon: AppAssets.iconYasuoPdf,
              //   onTap: () => PdfCompressPage.push(context),
              // ),
              const SizedBox(width: 12),
              _PdfToolCard(
                title: '加密PDF',
                subtitle: '一键加密保护隐私',
                icon: AppAssets.iconJiamiPdf,
                onTap: () => PdfEncryptPage.push(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// PDF工具单个功能项（对齐 MenuFragment AuxToolItem：白底卡片 宽130 圆角10）
class _PdfToolCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String icon;
  final VoidCallback onTap;

  const _PdfToolCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
                color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 2))
          ],
        ),
        child: Column(
          children: [
            // 原版图标 size(42) 含底部 10dp 内边距
            SizedBox(
              height: 42,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Image.asset(icon, fit: BoxFit.contain),
              ),
            ),
            Text(title,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Text(subtitle,
                style: const TextStyle(color: Color(0xFF2C2C2C), fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

/// "图片工具"区域（对齐 ScanToolsFragment ImageToolsSection）
class ImageToolsSection extends StatelessWidget {
  const ImageToolsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('图片工具',
            style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 18, bottom: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBF2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              _ImageToolItem(
                  text: '像素图',
                  icon: AppAssets.mtoolslSst,
                  onTap: () => PixelImagePage.push(context)),
              _ImageToolItem(
                  text: '人像动漫化',
                  icon: AppAssets.mtoolslTxt,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ImageProcessPage(
                              type: ImageProcessType.selfieAnime)))),
              _ImageToolItem(
                  text: '图像风格转换',
                  icon: AppAssets.mtoolslYct,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ImageProcessPage(
                              type: ImageProcessType.styleTransfer)))),
              _ImageToolItem(
                  text: '黑白上色',
                  icon: AppAssets.mtoolslHbss,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ImageProcessPage(
                              type: ImageProcessType.colourize)))),
            ],
          ),
        ),
      ],
    );
  }
}

/// 图片工具单项（对齐 ImageToolItem：图标 34dp + 文字 12sp #404040）
class _ImageToolItem extends StatelessWidget {
  final String text;
  final String icon;
  final VoidCallback onTap;

  const _ImageToolItem({
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Image.asset(icon, width: 34, height: 34),
            const SizedBox(height: 13),
            Text(text,
                maxLines: 1,
                style:
                    const TextStyle(color: Color(0xFF404040), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

/// "其他"区域（对齐 ScanToolsFragment OtherToolsSection：两行各三项白色卡片）
class OtherToolsSection extends StatelessWidget {
  const OtherToolsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('其他',
            style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        Row(
          children: [
            _OtherToolCard(
                text: '汇率换算',
                icon: AppAssets.mtoolslHlhs,
                onTap: () => CurrencyConverterPage.push(context)),
            const SizedBox(width: 24),
            _OtherToolCard(
                text: '进制计算器',
                icon: AppAssets.mtoolslJzzh,
                onTap: () => BaseConversionPage.push(context)),
            const SizedBox(width: 24),
            _OtherToolCard(
                text: '日期计算器',
                icon: AppAssets.mtoolslRqjs,
                onTap: () => WebToolPage.push(context,
                    title: '日期计算器',
                    url: 'https://ol.woobx.cn/tool/date-calculator')),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _OtherToolCard(
                text: '今天吃什么',
                icon: AppAssets.mtoolslEw,
                onTap: () => WebToolPage.push(context,
                    title: '今天吃什么',
                    url: 'assets/game/jintianchishenme/index.html')),
            const SizedBox(width: 24),
            _OtherToolCard(
                text: '随机数生成',
                icon: AppAssets.mtoolslSjs,
                onTap: () => WebToolPage.push(context,
                    title: '随机数生成',
                    url: 'https://ol.woobx.cn/tool/random-number')),
            const SizedBox(width: 24),
            _OtherToolCard(
                text: 'json编辑器',
                icon: AppAssets.mtoolslJson,
                onTap: () => WebToolPage.push(context,
                    title: 'json编辑器',
                    url: 'https://ol.woobx.cn/tool/json-editor')),
          ],
        ),
      ],
    );
  }
}

/// 其他区单项（对齐 OtherToolItem：白底圆角10卡片，图标 42dp 含顶部 10dp 内边距）
class _OtherToolCard extends StatelessWidget {
  final String text;
  final String icon;
  final VoidCallback onTap;

  const _OtherToolCard({
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 42,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Image.asset(icon, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 10),
              Text(text,
                  maxLines: 1,
                  style: const TextStyle(
                      color: Color(0xFF434343),
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}
