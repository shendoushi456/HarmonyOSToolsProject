// toolbox_c AllToolsFragment 的 Flutter UI 迁移。
// 隐藏图按需求排除；Android“特效图”位置改接既有的人像动漫化能力。
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../router/route_names.dart';
import '../../image_process/models/image_process_type.dart';
import '../../image_process/pages/image_process_page.dart';
import '../../life_tools/pages/checklist/checklist_page.dart';
import '../../life_tools/pages/color_drawing_studio_page.dart';
import '../../life_tools/pages/compass/compass_page.dart';
import '../../life_tools/pages/draw/draw_page.dart';
import '../../portable_tools/pages/pixel_image_page.dart';
import '../viewmodels/all_tools_view_model.dart';

class AllToolsPage extends StatelessWidget {
  const AllToolsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFF1A1B23),
        body: SafeArea(
          bottom: false,
          child: Column(children: [
            _TopBar(onSettings: () => context.push(RoutePaths.setting)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CreateCard(onTap: () => DrawPage.push(context)),
                      const SizedBox(height: 20),
                      Row(children: [
                        for (final item in AllToolsViewModel.quickTools)
                          Expanded(
                              child: _RoundTool(
                                  item: item,
                                  onTap: () =>
                                      _open(context, item.destination))),
                      ]),
                      const SizedBox(height: 24),
                      const Text('绘画工具',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _ToolGrid(items: AllToolsViewModel.paintingTools),
                    ]),
              ),
            ),
          ]),
        ),
      );

  static void _open(BuildContext context, AllToolsDestination destination) {
    switch (destination) {
      case AllToolsDestination.compass:
        CompassPage.push(context);
        return;
      case AllToolsDestination.selfieAnime:
        _pushProcess(context, ImageProcessType.selfieAnime);
        return;
      case AllToolsDestination.travelChecklist:
        ChecklistPage.push(context);
        return;
      case AllToolsDestination.mosaic:
        PixelImagePage.push(context);
        return;
      case AllToolsDestination.colourize:
        _pushProcess(context, ImageProcessType.colourize);
        return;
      case AllToolsDestination.traceDrawing:
        ColorDrawingStudioPage.push(context, ColorDrawingMode.trace);
        return;
      case AllToolsDestination.shapeDrawing:
        ColorDrawingStudioPage.push(context, ColorDrawingMode.shape);
        return;
      case AllToolsDestination.create:
        DrawPage.push(context);
    }
  }

  static void _pushProcess(BuildContext context, ImageProcessType type) =>
      Navigator.push<void>(context,
          MaterialPageRoute(builder: (_) => ImageProcessPage(type: type)));
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onSettings});
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 50,
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: InkResponse(
                onTap: onSettings,
                child: Image.asset(AppAssets.allToolsAndroidSettings,
                    width: 24, height: 24)),
          ),
        ),
      );
}

class _CreateCard extends StatelessWidget {
  const _CreateCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 140,
            width: double.infinity,
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [Color(0xFFFFD6A1), Color(0xFFA78BFA)])),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Image.asset(AppAssets.allToolsAndroidCreate,
                  width: 50, height: 50),
              const SizedBox(height: 12),
              const Text('开始创作',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ]),
          ),
        ),
      );
}

class _RoundTool extends StatelessWidget {
  const _RoundTool({required this.item, required this.onTap});
  final AllToolsItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkResponse(
        onTap: onTap,
        child: Column(children: [
          Image.asset(item.asset, width: 60, height: 60),
          const SizedBox(height: 8),
          Text(item.title,
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        ]),
      );
}

class _ToolGrid extends StatelessWidget {
  const _ToolGrid({required this.items});
  final List<AllToolsItem> items;

  @override
  Widget build(BuildContext context) => Column(children: [
        Row(children: [
          Expanded(
              child: _ToolCard(
                  item: items[0],
                  onTap: () =>
                      AllToolsPage._open(context, items[0].destination))),
          const SizedBox(width: 12),
          Expanded(
              child: _ToolCard(
                  item: items[1],
                  onTap: () =>
                      AllToolsPage._open(context, items[1].destination))),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: _ToolCard(
                  item: items[2],
                  onTap: () =>
                      AllToolsPage._open(context, items[2].destination))),
          const SizedBox(width: 12),
          Expanded(
              child: _ToolCard(
                  item: items[3],
                  onTap: () =>
                      AllToolsPage._open(context, items[3].destination))),
        ]),
      ]);
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({required this.item, required this.onTap});
  final AllToolsItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: const Color(0xFF2A2B35),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 140,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Image.asset(item.asset, width: 50, height: 50),
              const SizedBox(height: 12),
              Text(item.title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
            ]),
          ),
        ),
      );
}
