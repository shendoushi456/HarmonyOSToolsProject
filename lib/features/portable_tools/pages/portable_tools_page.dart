import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../life_tools/pages/notebook/notebook_list_page.dart';
import '../../life_tools/pages/webview/web_tool_page.dart';
import '../../setting/pages/setting_page.dart';
import 'calculator_page.dart';
import 'clear_capture_page.dart';
import 'pixel_image_page.dart';
import 'watermark_image_page.dart';

/// 第三个 Tab：对齐 Android BianxieToolsFragment，排除放大镜与字体放大入口。
class PortableToolsPage extends StatelessWidget {
  const PortableToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(AppAssets.portableToolsHomeBg, fit: BoxFit.fill),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _TopBar(
                  onSettings: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingPage()),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 34),
                    child: Column(
                      children: [
                        _NotebookBanner(
                            onTap: () => NotebookListPage.push(context)),
                        const SizedBox(height: 26),
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => ClearCapturePage.push(context),
                          child: Image.asset(
                            AppAssets.portableToolsClearCamera,
                            width: double.infinity,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Row(children: [
                          Expanded(
                            child: _ToolCard(
                              asset: AppAssets.portableToolsSolarTerms,
                              label: '二十四节气',
                              onTap: () => WebToolPage.push(
                                context,
                                title: '二十四节气',
                                url: 'assets/game/ershisijieqi/index.html',
                              ),
                            ),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: _ToolCard(
                              asset: AppAssets.portableToolsCalculator,
                              label: '计算器',
                              onTap: () => CalculatorPage.push(context),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 18),
                        Row(children: [
                          Expanded(
                            child: _ToolCard(
                              asset: AppAssets.portableToolsPixel,
                              label: '像素图',
                              onTap: () => PixelImagePage.push(context),
                            ),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: _ToolCard(
                              asset: AppAssets.portableToolsWatermark,
                              label: '添加水印',
                              onTap: () => WatermarkImagePage.push(context),
                            ),
                          ),
                        ]),
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
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onSettings});
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(children: [
        const SizedBox(width: 56),
        const Expanded(
          child: Center(
            child: Text('便携工具',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E1E1E))),
          ),
        ),
        SizedBox(
          width: 56,
          child: IconButton(
            tooltip: '设置',
            onPressed: onSettings,
            icon: const Icon(Icons.settings_outlined,
                size: 27, color: Color(0xFF1E1E1E)),
          ),
        ),
      ]),
    );
  }
}

class _NotebookBanner extends StatelessWidget {
  const _NotebookBanner({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
        color: const Color(0xFFA6C3FC),
        borderRadius: BorderRadius.circular(16),

      child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 26),
        decoration: BoxDecoration(
          color: const Color(0xFFA6C3FC),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          const Expanded(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('记事本',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                  SizedBox(height: 3),
                  Text('请输入要添加的内容',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ]),
          ),
          Container(
            width: 82,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: const Text('点击添加',
                style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4179F2),
                    fontWeight: FontWeight.w500)),
          ),
        ]),
      ),
    ));
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard(
      {required this.asset, required this.label, required this.onTap});
  final String asset;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: 6,
      shadowColor: const Color(0x24000000),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: SizedBox(
          height: 80,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(children: [
              Image.asset(asset, width: 42, height: 42),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(label,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1E1E1E)))),
            ]),
          ),
        ),
      ),
    );
  }
}
