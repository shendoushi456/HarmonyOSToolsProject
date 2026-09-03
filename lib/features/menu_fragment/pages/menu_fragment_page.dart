import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../router/route_names.dart';
import '../models/tool_definition.dart';
import '../services/tool_navigation_service.dart';
import '../viewmodels/menu_tools_view_model.dart';

/// Flutter implementation of toolbox_c's MenuFragment.
///
/// It intentionally owns only the Android-matched layout.  Its tools and
/// destinations remain in the catalogue/view-model layer for reuse by the
/// future favourites feature and by replacement app skins.
class MenuFragmentPage extends ConsumerWidget {
  const MenuFragmentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tools = ref.watch(menuToolDefinitionsProvider);
    final banner = tools.firstWhere(
      (tool) => tool.placement == MenuToolPlacement.qrBanner,
    );
    final quickActions = tools
        .where((tool) => tool.placement == MenuToolPlacement.quickAction)
        .toList(growable: false);
    final commonTools = tools
        .where((tool) => tool.placement == MenuToolPlacement.commonTool)
        .toList(growable: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF2EFFD),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _MenuTopBar(onSettingsTap: () => context.push(RoutePaths.setting)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _QrGenerateBanner(
                      tool: banner,
                      onTap: () => ToolNavigationService.open(context, banner),
                    ),
                    const SizedBox(height: 20),
                    _QuickActionsRow(tools: quickActions),
                    const SizedBox(height: 20),
                    const Text(
                      '常用工具',
                      style: TextStyle(
                        color: Color(0xFF434343),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _CommonToolsGrid(tools: commonTools),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTopBar extends StatelessWidget {
  const _MenuTopBar({required this.onSettingsTap});

  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // const Text(
          //   '首页',
          //   style: TextStyle(
          //     color: Color(0xFF444444),
          //     fontSize: 22,
          //     fontWeight: FontWeight.w500,
          //   ),
          // ),

          const Positioned.fill(
            child: Center(
              child: Text(
                '首页',
                style: TextStyle(
                  color: Color(0xFF444444),
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Positioned(
            right: 12,
            child: IconButton(
              tooltip: '设置',
              onPressed: onSettingsTap,
              icon: Image.asset(
                AppAssets.menuFragmentSettings,
                width: 24,
                height: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QrGenerateBanner extends StatelessWidget {
  const _QrGenerateBanner({required this.tool, required this.onTap});

  final ToolDefinition tool;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 103,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: AssetImage(tool.iconAsset),
              fit: BoxFit.fill,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tool.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tool.subtitle!,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({required this.tools});

  final List<ToolDefinition> tools;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final tool in tools)
          _QuickActionItem(
            tool: tool,
            onTap: () => ToolNavigationService.open(context, tool),
          ),
      ],
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  const _QuickActionItem({required this.tool, required this.onTap});

  final ToolDefinition tool;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: tool.backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.asset(tool.iconAsset, fit: BoxFit.fill),
              ),
              const SizedBox(height: 6),
              Text(
                tool.title,
                maxLines: 1,
                overflow: TextOverflow.visible,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF515151), fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommonToolsGrid extends StatelessWidget {
  const _CommonToolsGrid({required this.tools});

  final List<ToolDefinition> tools;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tools.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 11,
        childAspectRatio: 162 / 176,
      ),
      itemBuilder: (_, index) => _CommonToolCard(
        tool: tools[index],
        onTap: () => ToolNavigationService.open(context, tools[index]),
      ),
    );
  }
}

class _CommonToolCard extends StatelessWidget {
  const _CommonToolCard({required this.tool, required this.onTap});

  final ToolDefinition tool;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: tool.backgroundColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tool.title,
                    style: const TextStyle(
                      color: Color(0xFF434343),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tool.subtitle!,
                    style: const TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: Image.asset(
                tool.iconAsset,
                width: 90,
                height: 90,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
