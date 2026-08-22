// LifeToolsPage - 生活指南入口卡片页(替换首页 index=0 tab)
// 对齐 Android LifeFragment.kt:89-463 的 ScreenContent + TopAppBar + HomeContent
// 结构:背景图 fillBounds + 透明 Scaffold + TopAppBar"常用工具" + 滚动 Column(卡片网格)
// 排除:银行卡识别(L353-366)/放大镜(L465-539 BigTools)/字体放大/扫码入口(已注释)
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import 'blur/blur_page.dart';
import 'checklist/checklist_page.dart';
import 'compass/compass_page.dart';
import 'draw/draw_page.dart';
import 'notebook/notebook_list_page.dart';
import 'tally/tally_page.dart';
import 'webview/web_tool_page.dart';
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
          // 第一组卡片:旅行清单 + 指南针(对齐 LifeFragment.kt:263-300)
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
                      icon: AppAssets.icCompass,
                      iconBackgroundColor: AppColors.cardCompassIconBg,
                      label: '指南针',
                      onTap: () => CompassPage.push(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 第二行:花费记账(原版右侧银行卡识别已排除,留空占位)
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
                  const Expanded(child: SizedBox()),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 第二组卡片:今天吃什么 / json编辑器 / 画板 / 马赛克(对齐 LifeFragment.kt:372-454)
          _buildCardContainer(
            children: [
              Row(
                children: [
                  Expanded(
                    child: RouteItem(
                      icon: AppAssets.icBlur,
                      iconBackgroundColor: AppColors.cardBlurIconBg,
                      label: '马赛克',
                      onTap: () => BlurPage.push(context),
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
                      icon: AppAssets.icJson,
                      iconBackgroundColor: AppColors.cardJsonIconBg,
                      label: 'json编辑器',
                      onTap: () => WebToolPage.push(
                        context,
                        title: 'json编辑器',
                        url: 'https://ol.woobx.cn/tool/json-editor',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: RouteItem(
                      icon: AppAssets.icDraw,
                      iconBackgroundColor: AppColors.cardDrawIconBg,
                      label: '画板',
                      onTap: () => DrawPage.push(context),
                    ),
                  ),
                  const SizedBox(width: 12),

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
