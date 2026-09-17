import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../menu_home/pages/image_to_pdf_page.dart';
import '../../../menu_home/pages/pdf_to_image_page.dart';

/// 格式转化页
///
/// 对应原 Android `PdfToImgConversionActivity`（toolbox_c pic_toolslibrary），
/// 顶栏与 TabLayout 保真还原：
/// - 粉色顶栏（#FFE0DC）：白色返回键 + 居中白色标题"格式转化"
/// - 白底青色描边（#FF51DED0）圆角 TabLayout：图片转pdf / Pdf转图片
/// - 图片转pdf：仅"添加图片"按钮，点击跳转图片转 PDF 功能页
/// - Pdf转图片：仅"选择PDF"按钮，点击跳转 PDF 转图片功能页
class FormatConvertPage extends StatefulWidget {
  const FormatConvertPage({super.key});

  @override
  State<FormatConvertPage> createState() => _FormatConvertPageState();
}

class _FormatConvertPageState extends State<FormatConvertPage> {
  /// 顶栏背景色（原 `@color/theme_color_def`）
  static const Color _headerColor = Color(0xFFFFE0DC);

  /// Tab 边框色（原 `shape_corner_blue` 描边）
  static const Color _tabBorderColor = Color(0xFFFF51DED0);

  /// Tab 未选中文字色（原 `tabTextColor`）
  static const Color _tabUnselectedColor = Color(0xFF1F1F1F);

  /// Tab 选中文字色（原 `tabSelectedTextColor`）
  static const Color _tabSelectedColor = Color(0xFF4374D0);

  /// 按钮背景色（原 `theme_pdf_add_img` / `theme_pdf_zhuanhuan` 均为黑色）
  static const Color _buttonColor = Color(0xFF000000);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 粉色顶栏
            _buildHeader(context),
            // TabLayout：200dp 宽居中，白底青色描边圆角，无指示器
            Container(
              margin: const EdgeInsets.only(top: 20),
              alignment: Alignment.center,
              child: Container(
                width: 200,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: _tabBorderColor, width: 2),
                ),
                child: TabBar(
                  indicator: const BoxDecoration(),
                  labelColor: _tabSelectedColor,
                  unselectedLabelColor: _tabUnselectedColor,
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  dividerColor: Colors.transparent,
                  tabs: const <Widget>[
                    Tab(text: '图片转pdf'),
                    Tab(text: 'Pdf转图片'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: <Widget>[
                  _buildImageToPdfTab(),
                  _buildPdfToImageTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 粉色顶栏（原 title_rl：paddingTop 50dp paddingBottom 10dp）
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _headerColor,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 10,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 居中标题（原 22sp 白色"格式转化"）
          const Text(
            '格式转化',
            style: TextStyle(
              fontSize: 22,
              color: Colors.white,
            ),
          ),
          // 返回键（原 image_back：marginLeft 16dp）
          Positioned(
            left: 16,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Image.asset(
                'assets/images/ic_white_back.png',
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Tab1：图片转pdf ====================

  /// 仅显示"添加图片"按钮，点击跳转图片转 PDF 功能页
  Widget _buildImageToPdfTab() {
    return Column(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 100,
              margin: const EdgeInsets.only(bottom: 50),
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: _buildMaterialButton(
                      text: '添加图片',
                      onPressed: _openImageToPdf,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 跳转图片转 PDF 功能页（来自 master_mianfeisaosaowang）
  Future<void> _openImageToPdf() async {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const ImageToPdfPage()),
    );
  }

  // ==================== Tab2：Pdf转图片 ====================

  /// 仅显示"选择PDF"按钮，点击跳转 PDF 转图片功能页
  ///
  /// 注意：TabBarView（PageView）会给子页强制全高约束，
  /// 必须包一层 Column 松开约束，Container 的 height: 100 才生效。
  Widget _buildPdfToImageTab() {
    return Column(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 100,
              margin: const EdgeInsets.only(bottom: 50),
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: _buildMaterialButton(
                      text: '选择PDF',
                      onPressed: _openPdfToImage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Container(
        //   height: 100,
        //   margin: const EdgeInsets.only(top: 100, left: 10, right: 10),
        //   child: Row(
        //     children: [
        //       Expanded(
        //         child: _buildMaterialButton(
        //           text: '选择PDF',
        //           onPressed: _openPdfToImage,
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }

  /// 跳转 PDF 转图片功能页（来自 master_mianfeisaosaowang，
  /// 转换结果通过顶栏保存按钮存入系统相册）
  Future<void> _openPdfToImage() async {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const PdfToImagePage()),
    );
  }

  // ==================== 公共组件 ====================

  /// MaterialButton 样式按钮（原背景 #FF000000 + 白字，无圆角）
  Widget _buildMaterialButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: _buttonColor,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox.expand(
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
