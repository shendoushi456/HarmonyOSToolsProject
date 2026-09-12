// AllToolsFragment Flutter 迁移版 - 工具聚合页
// 对齐 Android fragment_all_tools.xml：图像风格转换大卡片 + 2x3 网格
// 替换 HomeShellPage 的 Tab[2]（原 WeatherPage）
// 排除放大镜入口（fdjModule）
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../router/route_names.dart';
import '../../image_process/models/image_process_type.dart';
import '../../image_process/pages/image_process_page.dart';
import '../../life_tools/pages/blur/blur_page.dart';
import '../../life_tools/pages/checklist/checklist_page.dart';
import '../../life_tools/pages/tally/tally_page.dart';
import '../../life_tools/pages/webview/web_tool_page.dart';
import '../../portable_tools/pages/pixel_image_page.dart';

class AllToolsPage extends StatelessWidget {
  const AllToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStyleTransferCard(context),
                    _buildToolsGrid(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 顶栏（对齐 fragment_all_tools.xml:27-49）
  /// "涂鸦"标题居中 + 设置按钮右对齐
  Widget _buildTopBar(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          // 设置图标占位保持标题居中（对齐 RelativeLayout TextView gravity center）
          const SizedBox(width: 50),
          const Expanded(
            child: Center(
              child: Text(
                '涂鸦',
                style: TextStyle(fontSize: 22, color: Colors.black),
              ),
            ),
          ),
          // 设置按钮（对齐 settingClick alignParentRight marginRight 20）
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () => context.push(RoutePaths.setting),
              child: Image.asset(AppAssets.allToolsSetting,
                  width: 30, height: 30),
            ),
          ),
        ],
      ),
    );
  }

  /// 图像风格转换大卡片（对齐 :60-124 txdmhModule）
  /// 渐变 #FF76FCF7→#FF89BDEC，圆角 16dp
  Widget _buildStyleTransferCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 25),
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            const Color(0xFF76FCF7),
            const Color(0xFF89BDEC),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // 左侧文字（对齐 :81-103）
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Padding(
                      padding: EdgeInsets.only(top: 9),
                      child: Text(
                        '图像风格转换',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        '换种风格\n解锁图像新模样',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 右侧大图（对齐 :104-108 mtoolsl_dmh 126x126）
              Image.asset(AppAssets.allToolsStyleTransfer,
                  width: 126, height: 126, fit: BoxFit.fill),
            ],
          ),
          // "点击转换"按钮（对齐 :111-122）
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ImageProcessPage(
                    type: ImageProcessType.styleTransfer),
              ),
            ),
            child: Container(
              margin: const EdgeInsets.only(top: 28),
              padding:
                  const EdgeInsets.symmetric(horizontal: 68, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Text(
                '点击转换',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 2x3 网格 + 第四行单卡（对齐 :126-411）
  /// 排除放大镜 fdjModule，第四行只留字体放大
  Widget _buildToolsGrid(BuildContext context) {
    return Column(
      children: [
        // 第一行：二十四节气 + 马赛克（对齐 :134-201）
        // Padding(
        //   padding: const EdgeInsets.only(bottom: 12),
        //   child: Row(
        //     children: [
        //       Expanded(
        //         child: _buildToolCard(
        //           context,
        //           icon: AppAssets.allToolsSolarTerms,
        //           title: '二十四节气',
        //           onTap: () => WebToolPage.push(
        //             context,
        //             title: '24节气',
        //             url: 'assets/game/ershisijieqi/index.html',
        //           ),
        //         ),
        //       ),
        //       Expanded(
        //         child: _buildToolCard(
        //           context,
        //           icon: AppAssets.allToolsMosaic,
        //           title: '马赛克',
        //           onTap: () => BlurPage.push(context),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        // 第二行：旅行清单 + 花费记账（对齐 :202-270）
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(
                child: _buildToolCard(
                  context,
                  icon: AppAssets.allToolsTravelList,
                  title: '旅行清单',
                  onTap: () => ChecklistPage.push(context),
                ),
              ),
              Expanded(
                child: _buildToolCard(
                  context,
                  icon: AppAssets.allToolsTally,
                  title: '花费记账',
                  onTap: () => TallyPage.push(context),
                ),
              ),
            ],
          ),
        ),
        // 第三行：像素图 + 黑白上色（对齐 :271-341）
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(
                child: _buildToolCard(
                  context,
                  icon: AppAssets.allToolsPixel,
                  title: '像素图',
                  onTap: () => PixelImagePage.push(context),
                ),
              ),
              Expanded(
                child: _buildToolCard(
                  context,
                  icon: AppAssets.allToolsColorize,
                  title: '黑白上色',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ImageProcessPage(
                          type: ImageProcessType.colourize),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // 第四行：字体放大（放大镜排除，对齐 :342-411 只留 ztfd）
        // Padding(
        //   padding: const EdgeInsets.only(bottom: 12),
        //   child: Row(
        //     children: [
        //       Expanded(
        //         child: _buildToolCard(
        //           context,
        //           icon: AppAssets.allToolsTextSize,
        //           title: '字体放大',
        //           onTap: () => _showPlaceholder(context, '字体放大'),
        //         ),
        //       ),
        //       const Expanded(child: SizedBox()),
        //     ],
        //   ),
        // ),
      ],
    );
  }

  /// 小卡片（对齐 fragment_all_tools.xml 各 ShapeLinearLayout）
  /// 白底圆角 12dp elevation 2dp，图标 40x40 + 文字 16sp #FF566EC2
  Widget _buildToolCard(
    BuildContext context, {
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset(icon, width: 40, height: 40, fit: BoxFit.fill),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, color: Color(0xFF566EC2)),
            ),
          ],
        ),
      ),
    );
  }

  /// 占位入口提示
  void _showPlaceholder(BuildContext context, String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$name 功能开发中')),
    );
  }
}
