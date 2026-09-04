import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../router/route_names.dart';
import '../models/menu_toolbox_c_section.dart';
import '../viewmodels/menu_toolbox_c_view_model.dart';

/// 对齐 Android MenuFragment.kt:ScannerHomeScreen。
///
/// UI / 功能 / 数据分层：view 层只读取 [menuToolboxCSectionsProvider] 中的
/// `MenuToolboxCSection` 描述并渲染，整套跳转和资源都从 view model 注入，
/// 整体换马甲包时只需替换 view model + 资源即可保留交互行为。
class MenuFragmentPage extends ConsumerWidget {
  const MenuFragmentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sections = ref.watch(menuToolboxCSectionsProvider);
    final banner = _firstOfKind(
      sections,
      MenuToolboxCSectionKind.banner,
    ).bannerAsset!;
    final identification = _firstOfKind(
      sections,
      MenuToolboxCSectionKind.identification,
    ).identificationCards;
    final extraction = _firstOfKind(
      sections,
      MenuToolboxCSectionKind.extraction,
    ).extractionCards;
    final qrCard = _firstOfKind(
      sections,
      MenuToolboxCSectionKind.qrCard,
    ).qrCard!;
    final toolListItem = _firstOfKind(
      sections,
      MenuToolboxCSectionKind.toolList,
    ).toolListItem!;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F1),
      body: Stack(
        children: [
          // 全屏背景纹理(shap_topbar_bg.png)，与 Android Image.fillMaxSize + Crop 一致
          Positioned.fill(
            child: Image.asset(
              AppAssets.tbcShapTopbarBg,
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            bottom: false,
            child: ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                _buildTopHeader(context),
                _buildSmartScanBanner(banner),
                const SizedBox(height: 30),
                _buildIdentificationGrid(identification),
                const SizedBox(height: 20),
                _buildExtractionTools(extraction),
                const SizedBox(height: 30),
                _buildCreateQrCard(context, qrCard),
                const SizedBox(height: 30),
                _buildToolListItem(context, toolListItem),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 顶部 44dp 标题栏 - 对应 TopHeader Composable
  Widget _buildTopHeader(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Center(
            child: Text(
              '首页',
              style: TextStyle(
                color: Color(0xFF444444),
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Positioned(
          //   right: 0,
          //   child: IconButton(
          //     tooltip: '设置',
          //     onPressed: () => context.push(RoutePaths.setting),
          //     icon: Image.asset(
          //       AppAssets.menuFragmentSettings,
          //       width: 24,
          //       height: 24,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  /// 按 kind 取出首个匹配段，view 层不再依赖段的位置索引。
  MenuToolboxCSection _firstOfKind(
    List<MenuToolboxCSection> sections,
    MenuToolboxCSectionKind kind,
  ) {
    return sections.firstWhere(
      (s) => s.kind == kind,
      orElse: () => throw StateError('缺少 $kind 段，请检查 view model 配置'),
    );
  }

  /// 智能扫描横幅 - 仅图片，不带点击事件，对应 SmartScanBanner
  Widget _buildSmartScanBanner(String asset) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          asset,
          width: double.infinity,
          height: 142,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  /// 识别一行三卡 - 对应 IdentificationGrid
  Widget _buildIdentificationGrid(List<MenuIdentificationCard> cards) {
    return Row(
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          if (i > 0) const SizedBox(width: 9),
          Expanded(
            child: _IdentificationCardWidget(card: cards[i]),
          ),
        ],
      ],
    );
  }

  /// 文字提取 + 二维码扫描 - 对应 ExtractionTools
  Widget _buildExtractionTools(List<MenuExtractionCard> cards) {
    return Row(
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          if (i > 0) const SizedBox(width: 17),
          Expanded(
            child: _ExtractionCardWidget(card: cards[i]),
          ),
        ],
      ],
    );
  }

  /// 制作二维码卡片 - 对应 CreateQrCard
  Widget _buildCreateQrCard(BuildContext context, MenuQrCard card) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => card.onTap(context),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFFFFA549),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 23),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            card.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Image.asset(
                            AppAssets.tbcIcArrowRightWhite,
                            width: 16,
                            height: 8,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          card.subtitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Image.asset(
                    card.iconAsset,
                    width: 40,
                    height: 40,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 文档扫描列表项 - 对应 ToolListItem(裁剪格式转换)
  Widget _buildToolListItem(BuildContext context, MenuToolListItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => item.onTap(context),
        child: Ink(
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            child: Row(
              children: [
                Image.asset(
                  item.iconAsset,
                  width: 60,
                  height: 66,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          color: Color(0xFF64A0F9),
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        style: const TextStyle(
                          color: Color(0xFFA2C6FB),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 识别功能卡片，对应 Android IdentificationCard Composable
class _IdentificationCardWidget extends StatelessWidget {
  const _IdentificationCardWidget({required this.card});
  final MenuIdentificationCard card;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => card.onTap(context),
        child: Ink(
          width: 105,
          height: 105,
          decoration: BoxDecoration(
            color: card.backgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Image.asset(
                    card.iconAsset,
                    width: 60,
                    height: 60,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                color: Colors.white.withValues(alpha: 0.6),
                padding: const EdgeInsets.symmetric(vertical: 6),
                alignment: Alignment.center,
                child: Text(
                  card.title,
                  style: const TextStyle(
                    color: Color(0xFF1C1C1C),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 文字提取/二维码扫描卡片，对应 Android ExtractionCard Composable
class _ExtractionCardWidget extends StatelessWidget {
  const _ExtractionCardWidget({required this.card});
  final MenuExtractionCard card;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => card.onTap(context),
        child: Ink(
          height: 184,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            image: DecorationImage(
              image: AssetImage(card.backgroundAsset),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              // 半透明黑色遮罩
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              // 居中的图标 + 文字
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      card.iconAsset,
                      width: 30,
                      height: 30,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      card.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}