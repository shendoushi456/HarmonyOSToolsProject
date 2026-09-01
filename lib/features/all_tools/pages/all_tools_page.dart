// toolbox_c AllToolsFragment 迁移版。
// 特效图、隐藏图按迁移要求排除；其余入口复用 Flutter 已有功能和数据层。
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../router/route_names.dart';
import '../../image_process/models/image_process_type.dart';
import '../../image_process/pages/image_process_page.dart';
import '../../life_tools/pages/blur/blur_page.dart';
import '../../life_tools/pages/checklist/checklist_page.dart';
import '../../life_tools/pages/color_drawing_studio_page.dart';
import '../../life_tools/pages/compass/compass_page.dart';

class AllToolsPage extends StatelessWidget {
  const AllToolsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFFFF2F2F4),
        body: SafeArea(
          bottom: false,
          child: Column(children: [
            _TopBar(onSettings: () => context.push(RoutePaths.setting)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionTitle('绘画工具'),
                      _PaintingGrid(),
                      const _SectionTitle('其他工具'),
                      _OtherTools(),
                    ]),
              ),
            ),
          ]),
        ),
      );
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onSettings});
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 50,
        child: Row(children: [
          const SizedBox(width: 50),
          const Expanded(
            child: Center(
              child: Text('工具列表',
                  style: TextStyle(fontSize: 22, color: Colors.black)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: InkResponse(
              onTap: onSettings,
              child:
                  Image.asset(AppAssets.toolboxSettings, width: 30, height: 30),
            ),
          ),
        ]),
      );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 13),
        child: Text(text,
            style: const TextStyle(fontSize: 16, color: Color(0xFF333333))),
      );
}

class _PaintingGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final entries = <_PaintingEntry>[
      _PaintingEntry('马赛克', '保护隐私更安全', AppAssets.toolboxMosaic,
          const Color(0xFFE68FEF), () => BlurPage.push(context)),
      _PaintingEntry(
          '黑白上色',
          '一键轻松还原照片颜色',
          AppAssets.toolboxColorize,
          const Color(0xFFFCB569),
          () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ImageProcessPage(
                      type: ImageProcessType.colourize)))),
      _PaintingEntry(
          '跟图绘画',
          '参照图片随意临摹',
          AppAssets.toolboxTrace,
          const Color(0xFF74CCF3),
          () => ColorDrawingStudioPage.push(context, ColorDrawingMode.trace)),
      _PaintingEntry(
          '形状绘画',
          '根据形状随意绘制',
          AppAssets.toolboxShape,
          const Color(0xFF5ADFD3),
          () => ColorDrawingStudioPage.push(context, ColorDrawingMode.shape)),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(children: [
        Row(children: [
          Expanded(child: _PaintingCard(entry: entries[0])),
          const SizedBox(width: 20),
          Expanded(child: _PaintingCard(entry: entries[1])),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _PaintingCard(entry: entries[2])),
          const SizedBox(width: 20),
          Expanded(child: _PaintingCard(entry: entries[3])),
        ]),
      ]),
    );
  }
}

class _PaintingEntry {
  const _PaintingEntry(
      this.title, this.subtitle, this.asset, this.color, this.onTap);
  final String title;
  final String subtitle;
  final String asset;
  final Color color;
  final VoidCallback onTap;
}

class _PaintingCard extends StatelessWidget {
  const _PaintingCard({required this.entry});
  final _PaintingEntry entry;

  @override
  Widget build(BuildContext context) => Material(
        color: entry.color,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: entry.onTap,
          borderRadius: BorderRadius.circular(15),
          child: SizedBox(
            height: 192,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 30, 8, 20),
              child: Column(children: [
                Image.asset(entry.asset,
                    width: 50, height: 50, fit: BoxFit.fill),
                const Spacer(),
                Text(entry.title,
                    style: const TextStyle(fontSize: 20, color: Colors.white)),
                const SizedBox(height: 3),
                Text(entry.subtitle,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 12, color: Colors.white)),
              ]),
            ),
          ),
        ),
      );
}

class _OtherTools extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Row(children: [
          Expanded(
            child: _OtherToolCard(
              title: '指南针',
              asset: AppAssets.toolboxCompass,
              onTap: () => CompassPage.push(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _OtherToolCard(
              title: '旅行清单',
              asset: AppAssets.toolboxTravel,
              onTap: () => ChecklistPage.push(context),
            ),
          ),
        ]),
      );
}

class _OtherToolCard extends StatelessWidget {
  const _OtherToolCard(
      {required this.title, required this.asset, required this.onTap});
  final String title;
  final String asset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
            child: Row(children: [
              Image.asset(asset, width: 55, height: 55, fit: BoxFit.fill),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, color: Colors.black)),
              ),
            ]),
          ),
        ),
      );
}
