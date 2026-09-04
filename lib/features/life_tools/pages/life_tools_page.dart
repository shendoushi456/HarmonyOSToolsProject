// LifeToolsPage - 生活指南入口卡片页(替换首页 index=0 tab)
// 对齐 Android LifeFragment.kt:89-463 的 ScreenContent + TopAppBar + HomeContent
// 结构:背景图 fillBounds + 透明 Scaffold + TopAppBar"常用工具" + 滚动 Column(卡片网格)
// 排除:银行卡识别(L353-366)/放大镜(L465-539 BigTools)/字体放大/扫码入口(已注释)
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:qingman_weather/features/image_process/models/image_process_type.dart';
import 'package:qingman_weather/features/image_process/pages/image_process_page.dart';
import 'package:qingman_weather/features/other_scan_tools/pages/currency_converter_page.dart';
import 'package:qingman_weather/features/portable_tools/pages/calculator_page.dart';
import 'package:qingman_weather/features/portable_tools/pages/pixel_image_page.dart';
import 'package:qingman_weather/features/portable_tools/pages/watermark_image_page.dart';
import 'checklist/checklist_page.dart';
import 'notebook/notebook_list_page.dart';
import 'tally/tally_page.dart';
import 'widgets/route_item.dart';

class LifeToolsPage extends StatelessWidget {
  const LifeToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 背景图(对齐 LifeFragment.kt:100-107 fillBounds)
          Positioned.fill(
            child: Image.asset(
              AppAssets.lifeBg,
              fit: BoxFit.fill,
            ),
          ),
          // 透明内容层(对齐 LifeFragment.kt:108-121 Scaffold containerColor transparent)
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(child: _buildHomeContent(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 顶部标题栏 - 对齐 LifeFragment.kt:128-146 TopAppBar
  /// Box(50dp + statusBarsPadding) + Text("常用工具" 22sp Medium 居中黑色)
  Widget _buildTopBar() {
    return const SizedBox(
      height: 50,
      child: Center(
        child: Text(
          '常用工具',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  /// 主内容 - 对齐 LifeFragment.kt:152-463 HomeContent
  Widget _buildHomeContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          // 记事本大卡片(对齐 LifeFragment.kt:232 Notebook, 高 225)
          NotebookCard(onTap: () => NotebookListPage.push(context)),
          const SizedBox(height: 20),
          // "常用工具"标题(对齐 LifeFragment.kt:240-246)
          const Text(
            '常用工具',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2C2C2C),
              height: 25 / 18,
            ),
          ),
          const SizedBox(height: 10),
          // 第一组卡片:旅行清单 + 计算器 / 花费记账 + 汇率换算
          _buildCardContainer(
            children: [
              Row(
                children: [
                  Expanded(
                    child: RouteItem(
                      icon: AppAssets.icTravel,
                      iconBackgroundColor: AppColors.cardTravelIconBg,
                      label: '旅行清单',
                      onTap: () => ChecklistPage.push(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RouteItem(
                      icon: AppAssets.portableToolsCalculator,
                      iconBackgroundColor: const Color(0xFFA4E1F1),
                      label: '计算器',
                      onTap: () => CalculatorPage.push(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 第二行:花费记账 + 汇率换算(原版右侧银行卡识别已排除)
              Row(
                children: [
                  Expanded(
                    child: RouteItem(
                      icon: AppAssets.icTally,
                      iconBackgroundColor: AppColors.cardTallyIconBg,
                      label: '花费记账',
                      onTap: () => TallyPage.push(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RouteItem(
                      icon: AppAssets.otherScanCurrency,
                      iconBackgroundColor: const Color(0xFFD2D2FF),
                      label: '汇率换算',
                      onTap: () => OtherCurrencyConverterPage.push(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 第二组卡片:今天吃什么(注释占位) / 图片水印 / 图像风格转换 / 人像动漫化
          _buildCardContainer(
            children: [
              Row(
                children: [
                  Expanded(
                    child: RouteItem(
                      icon: AppAssets.otherScanPixel,
                      iconBackgroundColor: const Color(0xFFFAC85C),
                      label: '像素图',
                      onTap: () => PixelImagePage.push(context),
                    ),
                  ),
                  // Expanded(
                  //
                  //   child: RouteItem(
                  //     icon: AppAssets.icEat,
                  //     iconBackgroundColor: AppColors.cardEatIconBg,
                  //     label: '今天吃什么',
                  //     onTap: () => WebToolPage.push(
                  //       context,
                  //       title: '今天吃什么',
                  //       url: 'assets/game/jintianchishenme/index.html',
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RouteItem(
                      icon: AppAssets.menuFragmentToolWatermark,
                      iconBackgroundColor: const Color(0xFFF0EDFD),
                      label: '图片水印',
                      onTap: () => WatermarkImagePage.push(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: RouteItem(
                      icon: AppAssets.otherScanStyle,
                      iconBackgroundColor: const Color(0xFFD2D2FF),
                      label: '图像风格转换',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ImageProcessPage(
                            type: ImageProcessType.styleTransfer,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RouteItem(
                      icon: AppAssets.otherScanAnime,
                      iconBackgroundColor: const Color(0xFFACCFD6),
                      label: '人像动漫化',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ImageProcessPage(
                            type: ImageProcessType.selfieAnime,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// 卡片容器 - 对齐 LifeFragment.kt:252-261 阴影+白底+圆角10+padding h20
  Widget _buildCardContainer({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}
