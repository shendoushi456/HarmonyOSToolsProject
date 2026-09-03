import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../router/route_names.dart';
import '../../life_tools/pages/checklist/checklist_page.dart';
import '../../life_tools/pages/tally/tally_page.dart';
import '../../life_tools/pages/compass/compass_page.dart';
import '../../life_tools/pages/webview/web_tool_page.dart';
import '../../other_scan_tools/pages/relatives_calculator_page.dart';
import '../../portable_tools/pages/magnifier_camera_page.dart';
import '../../recognition/models/recognition_type.dart';
import '../../recognition/pages/recognition_page.dart';
import '../../image_process/models/image_process_type.dart';
import '../../image_process/pages/image_process_page.dart';

/// Android NewToolsFragment 的 Flutter 版工具目录。
/// 页面布局保持 Android 的“顶部三项识别 + 两列工具卡片”结构，
/// 业务页面通过独立 feature 复用，方便后续更换马甲包 UI。
class NewToolsPage extends StatelessWidget {
  const NewToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          SizedBox(
            height: 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Text('工具列表',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
                // Positioned(
                //   right: 8,
                //   child: IconButton(
                //     padding: EdgeInsets.zero,
                //     constraints:
                //         const BoxConstraints(minWidth: 40, minHeight: 40),
                //     icon: const Icon(Icons.settings_outlined,
                //         size: 26, color: Color(0xFF222222)),
                //     onPressed: () => context.push(RoutePaths.setting),
                //   ),
                // ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 13, 20, 24),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _recognitionRow(context),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text('其他工具',
                          style: TextStyle(
                              fontSize: 16, color: Color(0xFF333333))),
                    ),
                    _toolRow(context, [
                      _Tool(
                          '二十四节气',
                          'assets/images/new_tools/solar_terms.png',
                          () => WebToolPage.push(context,
                              title: '24节气',
                              url: 'assets/game/ershisijieqi/index.html')),
                      _Tool('放大镜', 'assets/images/new_tools/magnifier.png',
                          () => MagnifierCameraPage.push(context)),
                    ]),
                    const SizedBox(height: 18),
                    _toolRow(context, [
                      _Tool('旅行清单', 'assets/images/new_tools/travel.png',
                          () => ChecklistPage.push(context)),
                      _Tool('花费记账', 'assets/images/new_tools/tally.png',
                          () => TallyPage.push(context)),
                    ]),
                    const SizedBox(height: 18),
                    _toolRow(context, [
                      _Tool(
                          '人像动漫化',
                          'assets/images/new_tools/anime.png',
                              () => _openProcess(
                              context, ImageProcessType.selfieAnime)),
                      _Tool('亲戚计算器', 'assets/images/new_tools/relatives.png',
                          () => RelativesCalculatorPage.push(context)),
                    ]),
                    const SizedBox(height: 18),
                    _toolRow(context, [
                      _Tool(
                          '图片黑白上色',
                          'assets/images/new_tools/colourize.png',
                          () => _openProcess(
                              context, ImageProcessType.colourize)),
                      _Tool(
                          '图像风格转换',
                          'assets/images/new_tools/style.png',
                          () => _openProcess(
                              context, ImageProcessType.styleTransfer)),
                    ]),
                  ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _recognitionRow(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: const Color(0xFFF7F8FC),
            borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          Expanded(
              child: _Recognition('花草识别', 'assets/images/new_tools/plant.png',
                  () => _recognize(context, RecognitionType.plant))),
          Expanded(
              child: _Recognition('水果识别', 'assets/images/new_tools/fruit.png',
                  () => _recognize(context, RecognitionType.ingredient))),
          Expanded(
              child: _Recognition('动物识别', 'assets/images/new_tools/animal.png',
                  () => _recognize(context, RecognitionType.animal))),
        ]),
      );

  Widget _toolRow(BuildContext context, List<_Tool> tools) => Row(children: [
        Expanded(child: _ToolCard(tool: tools[0])),
        const SizedBox(width: 10),
        Expanded(child: _ToolCard(tool: tools[1])),
      ]);

  void _recognize(BuildContext context, RecognitionType type) => Navigator.push(
      context, MaterialPageRoute(builder: (_) => RecognitionPage(type: type)));
  void _openProcess(BuildContext context, ImageProcessType type) =>
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => ImageProcessPage(type: type)));
}

class _Recognition extends StatelessWidget {
  const _Recognition(this.label, this.image, this.onTap);
  final String label, image;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      child: Column(children: [
        Container(
            width: 90,
            height: 90,
            padding: const EdgeInsets.all(21),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Image.asset(image)),
        const SizedBox(height: 8),
        Text(label,
            style: const TextStyle(fontSize: 15, color: Color(0xFF333333))),
      ]));
}

class _Tool {
  const _Tool(this.label, this.image, this.onTap);
  const _Tool.empty()
      : label = '',
        image = '',
        onTap = null;
  final String label, image;
  final VoidCallback? onTap;
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({required this.tool});
  final _Tool tool;
  @override
  Widget build(BuildContext context) => Material(
      color: const Color(0xFFF7F8FC),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
          onTap: tool.onTap,
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
              height: 82,
              child: tool.onTap == null
                  ? const SizedBox()
                  : Row(children: [
                      Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child:
                              Image.asset(tool.image, width: 40, height: 40)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(tool.label,
                              style: const TextStyle(
                                  fontSize: 16, color: Color(0xFF333333))))
                    ]))));
}
