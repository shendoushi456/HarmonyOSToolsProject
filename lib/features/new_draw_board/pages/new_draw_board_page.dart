// NewDrawBoardFragment Flutter 迁移版 - 工具聚合首页
// 对齐 Android fragment_new_drawboard.xml：8 个工具卡片入口
// 替换 HomeShellPage 的 Tab[0]（原 WifiPage）
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../router/route_names.dart';
import '../../life_tools/pages/blur/blur_page.dart';
import '../../life_tools/pages/tuya/tuya_page.dart';
import '../../image_process/models/image_process_type.dart';
import '../../image_process/pages/image_process_page.dart';
import '../../menu_home/pages/qr_scan_page.dart';
import '../../portable_tools/pages/clear_capture_page.dart';
import '../../recognition/models/recognition_type.dart';

class NewDrawBoardPage extends StatelessWidget {
  const NewDrawBoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 顶部标题栏（对齐 fragment_new_drawboard.xml:26-36 titleBar）
            SizedBox(
              height: 50,
              child: Center(
                child: const Text(
                  '首页',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            // 滚动内容
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageEditorCard(context),
                    _buildRecognitionRow(context),
                    // _buildToolsRow(context),
                    _buildGraffitiRow(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 图片编辑器大卡片（对齐 :47-104 llTpbj）
  /// 蓝色 #FF89BDE5 圆角 20dp，左侧文字+上传按钮，右侧大图
  Widget _buildImageEditorCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      padding: const EdgeInsets.fromLTRB(23, 25, 13, 25),
      decoration: BoxDecoration(
        color: AppColors.homeImageEditorCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左侧文字区（对齐 :60-93）
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '图像动漫化',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 3),
                child: Text(
                  '轻松修图，秒出质感！',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
              // 上传图片按钮（对齐 :78-91 ShapeTextView）
              GestureDetector(
                onTap: () => Navigator.push<void>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ImageProcessPage(
                      type: ImageProcessType.selfieAnime,
                    ),
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '开始转化',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.only(left: 5),
                      //   child: Image.asset(AppAssets.homeArrowRight,
                      //       width: 16, height: 16),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          // 右侧大图（对齐 :98-103 zpbjq_icon 162×133）
          Image.asset(AppAssets.homeImageEditorIcon, width: 162, height: 133),
        ],
      ),
    );
  }

  /// 3 识别卡行（对齐 :105-198）
  /// 花草/果蔬/动物，半透明白 #4DFFFFFF 圆角 10dp
  Widget _buildRecognitionRow(BuildContext context) {
    final items = [
      _RecognitionItem(
        icon: AppAssets.homePlantIcon,
        title: '花草识别',
        type: RecognitionType.plant,
      ),
      _RecognitionItem(
        icon: AppAssets.homeFruitIcon,
        title: '果蔬识别',
        type: RecognitionType.ingredient,
      ),
      _RecognitionItem(
        icon: AppAssets.homeAnimalIcon,
        title: '动物识别',
        type: RecognitionType.animal,
      ),
    ];
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 23, 20, 0),
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            Expanded(child: _buildRecognitionCard(context, items[i])),
            if (i < items.length - 1) const SizedBox(width: 9),
          ],
        ],
      ),
    );
  }

  Widget _buildRecognitionCard(BuildContext context, _RecognitionItem item) {
    return GestureDetector(
      onTap: () => context.push(RoutePaths.recognition, extra: item.type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.homeRecognitionCard,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(item.icon,
                width: double.infinity, height: 62, fit: BoxFit.fill),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                item.title,
                style: const TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 4 工具行（对齐 :200-297）
  /// 特效图/马赛克/LED灯/扫码识别，图标 66dp
  Widget _buildToolsRow(BuildContext context) {
    final tools = [
      _ToolItem(AppAssets.allToolsTextSize, '放大镜',
          () => ClearCapturePage.push(context)),
      _ToolItem(AppAssets.homeMosaicIcon, '马赛克', () => BlurPage.push(context)),
      // _ToolItem(AppAssets.homeLedIcon, 'LED灯',
      //     () => _showPlaceholder(context, 'LED灯')),
      _ToolItem(
          AppAssets.homeQrScanIcon, '扫码识别', () => QrScanPage.push(context)),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 28),
      child: Row(
        children: [
          for (final tool in tools)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: tool.onTap,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(tool.icon,
                        width: 66, height: 66, fit: BoxFit.fill),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        tool.title,
                        style:
                            const TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 2 涂鸦卡行（对齐 :298-365）
  /// 分类涂鸦/离线涂鸦，渐变 #FFF5F1E2 圆角 30dp
  Widget _buildGraffitiRow(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 30, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: _buildGraffitiCard(
              context,
              title: '分类涂鸦',
              icon: AppAssets.homeCategoryGraffitiIcon,
              onTap: () =>
                  TuyaPage.push(context, mode: 'category', title: '分类涂鸦'),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _buildGraffitiCard(
              context,
              title: '离线涂鸦',
              icon: AppAssets.homeOfflineGraffitiIcon,
              onTap: () =>
                  TuyaPage.push(context, mode: 'offline', title: '离线涂鸦'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraffitiCard(
    BuildContext context, {
    required String title,
    required String icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              AppColors.homeGraffitiGradient,
              AppColors.homeGraffitiGradient,
            ],
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: SizedBox(
          // 对齐 Android ShapeRelativeLayout 高度：marginTop 60 + 图 85 = 145
          height: 145,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 标题（左上）
              Text(
                title,
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
              // 右上箭头（对齐 :321-325 xiejt_icon 32×32）
              Positioned(
                top: 0,
                right: 0,
                child: Image.asset(AppAssets.homeGraffitiArrow,
                    width: 32, height: 32),
              ),
              // 右下大图（对齐 :326-331 flty_icon 85×85 marginTop 60）
              Positioned(
                top: 60,
                right: 0,
                child: Image.asset(icon, width: 85, height: 85),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecognitionItem {
  const _RecognitionItem({
    required this.icon,
    required this.title,
    required this.type,
  });
  final String icon;
  final String title;
  final RecognitionType type;
}

class _ToolItem {
  const _ToolItem(this.icon, this.title, this.onTap);
  final String icon;
  final String title;
  final VoidCallback onTap;
}
