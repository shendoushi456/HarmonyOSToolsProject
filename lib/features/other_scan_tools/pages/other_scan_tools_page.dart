import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../menu_fragment/models/tool_definition.dart';
import '../../menu_fragment/services/tool_navigation_service.dart';
import '../../menu_fragment/viewmodels/menu_tools_view_model.dart';

/// Android OtherSaoMiaoFrgment's second-tab composition.  Definitions and
/// navigation deliberately stay outside this skin for favourites reuse.
class OtherScanToolsPage extends ConsumerWidget {
  const OtherScanToolsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tools = ref.watch(menuToolDefinitionsProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF2EFFD),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(
                height: 54,
                child: Center(
                    child: Text('工具',
                        style: TextStyle(
                            color: Color(0xFF444444),
                            fontSize: 22,
                            fontWeight: FontWeight.w500)))),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: [
                    _CategoryCard(
                        title: '图片处理',
                        tools: _forPlacement(
                            tools, MenuToolPlacement.otherScanImageProcess)),
                    const SizedBox(height: 18),
                    _CategoryCard(
                        title: '计算器',
                        tools: _forPlacement(
                            tools, MenuToolPlacement.otherScanCalculator),
                        calculatorLayout: true),
                    const SizedBox(height: 18),
                    _CategoryCard(
                        title: '其他',
                        tools: _forPlacement(
                            tools, MenuToolPlacement.otherScanOther)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ToolDefinition> _forPlacement(
    List<ToolDefinition> tools,
    MenuToolPlacement placement,
  ) =>
      tools
          .where((tool) => tool.placement == placement)
          .toList(growable: false);
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.title,
    required this.tools,
    this.calculatorLayout = false,
  });

  final String title;
  final List<ToolDefinition> tools;
  final bool calculatorLayout;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: const Color(0x24000000),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: Color(0xFF434343),
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Row(
              children: [
                for (final tool in tools)
                  Expanded(
                      child: _ToolTile(
                          tool: tool, calculatorLayout: calculatorLayout)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolTile extends StatelessWidget {
  const _ToolTile({required this.tool, required this.calculatorLayout});

  final ToolDefinition tool;
  final bool calculatorLayout;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => ToolNavigationService.open(context, tool),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  color: tool.backgroundColor,
                  borderRadius: BorderRadius.circular(8)),
              child: Image.asset(tool.iconAsset, fit: BoxFit.fill),
            ),
            const SizedBox(height: 7),
            SizedBox(
              // The Android source only had short labels.  The two requested
              // replacement image tools need a second line without clipping.
              // height: calculatorLayout || tool.title.length > 5 ? 31 : 18,
              height: 31,
              child: Text(
                tool.title,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Color(0xFF515151), fontSize: 12, height: 1.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
