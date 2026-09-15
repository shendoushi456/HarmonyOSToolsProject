import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../router/route_names.dart';
import '../../life_tools/pages/draw/draw_page.dart';
import '../../menu_fragment/models/tool_definition.dart';
import '../../menu_fragment/services/tool_navigation_service.dart';
import '../../life_tools/pages/webview/web_tool_page.dart';

/// 对齐 toolbox_c ScanToolsFragment.kt (sao 版工具页)：
/// ic_sao_main_bg 背景 + "工具"顶栏(右侧设置) + 文件工具/图片处理/计算器/其他 4 分组
class SaoToolsPage extends ConsumerWidget {
  const SaoToolsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 对齐 ScreenContent(): ic_sao_main_bg 全屏背景 FillBounds
          Positioned.fill(
            child: Image.asset(
              AppAssets.saoMainBg,
              fit: BoxFit.fill,
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildTopBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        // 文件工具区域
                        _Section(
                          title: '文件工具',
                          rows: [
                            [
                              _ToolEntry(
                                'PDF转图片',
                                AppAssets.saoTools11,
                                (context) => ToolNavigationService.openDestination(
                                  context,
                                  ToolDestination.pdfToImage,
                                ),
                              ),
                              _ToolEntry(
                                '图片转PDF',
                                AppAssets.saoTools12,
                                (context) => ToolNavigationService.openDestination(
                                  context,
                                  ToolDestination.imageToPdf,
                                ),
                              ),
                            ],
                            [
                              // _ToolEntry(
                              //   '压缩PDF',
                              //   AppAssets.saoTools13,
                              //   (context) => ToolNavigationService.openDestination(
                              //     context,
                              //     ToolDestination.pdfCompress,
                              //   ),
                              // ),
                              _ToolEntry(
                                '加密PDF',
                                AppAssets.saoTools14,
                                (context) => ToolNavigationService.openDestination(
                                  context,
                                  ToolDestination.pdfEncrypt,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),
                        // 图片处理区域
                        _Section(
                          title: '图片处理',
                          rows: [
                            [
                              _ToolEntry(
                                '像素图',
                                AppAssets.saoTools21,
                                (context) => ToolNavigationService.openDestination(
                                  context,
                                  ToolDestination.pixelImage,
                                ),
                              ),
                              // 对齐安卓 PictureLowPoly 入口位，复用图像风格转换功能页
                              _ToolEntry(
                                '图像风格转换',
                                AppAssets.saoTools22,
                                (context) => ToolNavigationService.openDestination(
                                  context,
                                  ToolDestination.imageStyleTransfer,
                                ),
                              ),
                            ],
                            [
                              // 对齐安卓 PictureHide 入口位，复用人像动漫化功能页
                              _ToolEntry(
                                '人像动漫化',
                                AppAssets.saoTools23,
                                (context) => ToolNavigationService.openDestination(
                                  context,
                                  ToolDestination.selfieAnime,
                                ),
                              ),
                              _ToolEntry(
                                '黑白上色',
                                AppAssets.saoTools24,
                                (context) => ToolNavigationService.openDestination(
                                  context,
                                  ToolDestination.imageColourize,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),
                        // 计算器区域
                        _Section(
                          title: '计算器',
                          rows: [
                            [
                              _ToolEntry(
                                '亲戚关系\n计算器',
                                AppAssets.saoTools31,
                                (context) => ToolNavigationService.openDestination(
                                  context,
                                  ToolDestination.relativesCalculator,
                                ),
                              ),
                              _ToolEntry(
                                '日期计算器',
                                AppAssets.saoTools32,
                                (context) => ToolNavigationService.openDestination(
                                  context,
                                  ToolDestination.dateCalculator,
                                ),
                              ),
                            ],
                            [
                              _ToolEntry(
                                '进制计算器',
                                AppAssets.saoTools33,
                                (context) => ToolNavigationService.openDestination(
                                  context,
                                  ToolDestination.baseConverter,
                                ),
                              ),
                              _ToolEntry(
                                '汇率换算',
                                AppAssets.saoTools34,
                                (context) => ToolNavigationService.openDestination(
                                  context,
                                  ToolDestination.currencyConverter,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 14),
                        // 其他区域
                        const _Section(
                          title: '其他',
                          useOtherPadding: true,
                          rows: [
                            [
                              _ToolEntry('画板', AppAssets.saoTools41, _openDraw),
                              _ToolEntry(
                                '随机数生成',
                                AppAssets.saoTools42,
                                _openRandomNumber,
                              ),
                            ],
                            [
                              _ToolEntry(
                                '今天吃什么',
                                AppAssets.saoTools43,
                                _openEatToday,
                              ),
                              _ToolEntry(
                                'json编辑器',
                                AppAssets.saoTools44,
                                _openJsonEditor,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 44),
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

  /// 对齐 TopAppBar(): statusBarsPadding + 50dp，"工具" 22sp Medium 居中，
  /// 右侧设置图标 26dp(padding end 30) -> onConfirmClicked -> SettSet2Activity
  Widget _buildTopBar(BuildContext context) {
    return SizedBox(
      height: 50,
      width:double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Text(
            '工具',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF131415),
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
          Positioned(
            right: 30,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => context.push(RoutePaths.setting),
              child: const Icon(
                Icons.settings,
                size: 26,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> _openDraw(BuildContext context) => DrawPage.push(context);

  /// 对齐 EatActivity(KEY=https://ol.woobx.cn/tool/random-number)
  static Future<void> _openRandomNumber(BuildContext context) =>
      WebToolPage.push(
        context,
        title: '随机数生成',
        url: 'https://ol.woobx.cn/tool/random-number',
      );

  /// 对齐 EatActivity(KEY=file:///android_asset/game/jintianchishenme/index.html)
  static Future<void> _openEatToday(BuildContext context) =>
      ToolNavigationService.openDestination(context, ToolDestination.eatToday);

  /// 对齐 EatActivity(KEY=https://ol.woobx.cn/tool/json-editor)
  static Future<void> _openJsonEditor(BuildContext context) => WebToolPage.push(
        context,
        title: 'json编辑器',
        url: 'https://ol.woobx.cn/tool/json-editor',
      );
}

/// 分组容器 - 对齐 FileToolsSection 等：
/// White 60% 圆角10，padding H18 V20("其他"为 start19 end18 top22 bottom24)
class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.rows,
    this.useOtherPadding = false,
  });

  final String title;
  final List<List<_ToolEntry>> rows;
  final bool useOtherPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: useOtherPadding
          ? const EdgeInsets.fromLTRB(19, 22, 18, 24)
          : const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF353535),
              height: 22 / 16,
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _ToolRow(entries: rows[i]),
          ],
        ],
      ),
    );
  }
}

/// 工具行 - 白卡圆角10 + 阴影，padding H14 V10，项间距 12
class _ToolRow extends StatelessWidget {
  const _ToolRow({required this.entries});

  final List<_ToolEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          // 对齐 Compose shadow(elevation=1.dp, RoundedCornerShape(10))
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          for (var i = 0; i < entries.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(child: entries[i].build(context)),
          ],
        ],
      ),
    );
  }
}

/// 工具项 - 图标 44dp + Spacer10 + 文字 12sp Medium 0xFF353535
/// onTap 为 null 时仅展示不响应(鸿蒙端无对应功能的预留项)
class _ToolEntry {
  const _ToolEntry(this.title, this.icon, this.onTap);

  final String title;
  final String icon;
  final void Function(BuildContext context)? onTap;

  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap == null ? null : () => onTap!(context),
      child: Row(
        children: [
          Image.asset(icon, width: 44, height: 44, fit: BoxFit.contain),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF353535),
                height: 17 / 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
