// 对齐 Android MenuFragment.kt:123-526
// 入口卡片页：背景图 + 晴墨扫描顶栏 + PDF工具4列网格 + 常用工具2个纵向卡片
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import 'image_to_pdf_page.dart';
import 'pdf_to_image_page.dart';
import 'pdf_compress_page.dart';
import 'pdf_encrypt_page.dart';
import 'qr_generate_page.dart';
import 'qr_scan_page.dart';
import 'widgets/menu_function_card.dart';
import 'widgets/menu_grid_item.dart';

class MenuHomePage extends StatelessWidget {
  const MenuHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AppAssets.menuHomeBg,
              fit: BoxFit.fill,
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        _buildSectionTitle('PDF工具'),
                        const SizedBox(height: 12),
                        _buildPdfGrid(context),
                        const SizedBox(height: 26),
                        _buildSectionTitle('常用工具'),
                        const SizedBox(height: 12),
                        _buildCommonTools(context),
                        const SizedBox(height: 26),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 顶栏 - 对齐 MenuFragment.kt:166-193 TopAppBar
  Widget _buildTopBar() {
    return const SizedBox(
      height: 50,
      child: Padding(
        padding: EdgeInsets.only(left: 20),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '晴墨扫描',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.menuSectionTitle,
            ),
          ),
        ),
      ),
    );
  }

  /// 分组标题 - 对齐 MenuFragment.kt:621-628 / 489-496
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.menuSectionTitle,
      ),
    );
  }

  /// PDF 工具 4 列网格 - 对齐 MenuFragment.kt:612-669 SecondToolsSection
  Widget _buildPdfGrid(BuildContext context) {
    final items = [
      _PdfItem('PDF转图片', AppAssets.icPdfToImage, () {
        PdfToImagePage.push(context);
      }),
      _PdfItem('图片转PDF', AppAssets.icImageToPdf, () {
        ImageToPdfPage.push(context);
      }),
      _PdfItem('压缩PDF', AppAssets.icPdfCompress, () {
        PdfCompressPage.push(context);
      }),
      _PdfItem('加密PDF', AppAssets.icPdfEncrypt, () {
        PdfEncryptPage.push(context);
      }),
    ];

    return Row(
      children: items.asMap().entries.map((entry) {
        final item = entry.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: entry.key == 0 ? 0 : 4,
              right: entry.key == items.length - 1 ? 0 : 4,
            ),
            child: MenuGridItem(
              title: item.title,
              image: item.image,
              onTap: item.onTap,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 常用工具 2 个纵向卡片 - 对齐 MenuFragment.kt:480-524 SecondToolsSection2
  Widget _buildCommonTools(BuildContext context) {
    return Column(
      children: [
        MenuFunctionCard(
          icon: AppAssets.icQrGenerate,
          iconBackgroundColor: AppColors.qrGenerateIconBg,
          label: '生成二维码',
          label2: '快速生成二维码分享',
          onTap: () => QrGeneratePage.push(context),
        ),
        const SizedBox(height: 12),
        MenuFunctionCard(
          icon: AppAssets.icQrScan,
          iconBackgroundColor: AppColors.qrScanIconBg,
          label: '扫描二维码',
          label2: '扫描二维码识别内容',
          onTap: () => QrScanPage.push(context),
        ),
      ],
    );
  }
}

class _PdfItem {
  final String title;
  final String image;
  final VoidCallback onTap;
  _PdfItem(this.title, this.image, this.onTap);
}
