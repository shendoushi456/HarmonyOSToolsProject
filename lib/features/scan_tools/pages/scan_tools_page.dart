// CleanMainFragment 的 Flutter 迁移页：上方识别快捷入口和下方纵向工具列表。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../router/route_names.dart';
import '../../image_process/models/clean_tool_item.dart';
import '../../image_process/pages/image_process_page.dart';
import '../../image_process/viewmodels/clean_tools_view_model.dart';
import '../../menu_home/pages/qr_scan_page.dart';
import '../../recognition/models/recognition_type.dart';

/// Android item_tab_clear_layout.xml 的六项列表版式。
class ScanToolsPage extends ConsumerWidget {
  const ScanToolsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tools = ref.watch(cleanToolsProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFE3EEFF),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(AppAssets.wifiTopBg, fit: BoxFit.fill),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 20, bottom: 25),
                  child: Text(
                    '工具',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 20),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: _RecognitionShortcut(
                                iconAsset: AppAssets.cleanShortcutPlant,
                                title: '花草识别',
                                onTap: () => _openRecognition(
                                  context,
                                  RecognitionType.plant,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _RecognitionShortcut(
                                iconAsset: AppAssets.cleanShortcutIngredient,
                                title: '果蔬识别',
                                onTap: () => _openRecognition(
                                  context,
                                  RecognitionType.ingredient,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _RecognitionShortcut(
                                iconAsset: AppAssets.cleanShortcutAnimal,
                                title: '动物识别',
                                onTap: () => _openRecognition(
                                  context,
                                  RecognitionType.animal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(20, 25, 20, 0),
                        padding: const EdgeInsets.symmetric(horizontal: 17),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: tools.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 6),
                          itemBuilder: (_, index) => _CleanToolListItem(
                            item: tools[index],
                            onTap: () => _openTool(context, tools[index]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openTool(BuildContext context, CleanToolItem item) {
    switch (item.action) {
      case CleanToolAction.bankCard:
        context.push(RoutePaths.recognition, extra: RecognitionType.bankCard);
        return;
      case CleanToolAction.textRecognition:
        context.push(RoutePaths.recognition, extra: RecognitionType.text);
        return;
      case CleanToolAction.qrScan:
        QrScanPage.push(context);
        return;
      case CleanToolAction.imageProcess:
        Navigator.push<void>(
          context,
          MaterialPageRoute(
            builder: (_) => ImageProcessPage(type: item.imageProcessType!),
          ),
        );
        return;
    }
  }

  void _openRecognition(BuildContext context, RecognitionType type) {
    context.push(RoutePaths.recognition, extra: type);
  }
}

/// 对齐 Android CleanMainFragment 的三列 102dp 识别入口。
class _RecognitionShortcut extends StatelessWidget {
  const _RecognitionShortcut({
    required this.iconAsset,
    required this.title,
    required this.onTap,
  });

  final String iconAsset;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Column(
            children: [
              Image.asset(iconAsset, width: 102, height: 102),
              const SizedBox(height: 8),
              Text(title,
                  style: const TextStyle(
                    color: Color(0xFF353535),
                    fontSize: 12,
                  )),
            ],
          ),
        ),
      );
}

class _CleanToolListItem extends StatelessWidget {
  const _CleanToolListItem({required this.item, required this.onTap});

  final CleanToolItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Image.asset(item.iconAsset, width: 52, height: 52),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Color(0xFF1E1E1E),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF848484),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Image.asset(AppAssets.scanItemArrow, width: 13, height: 13),
            ],
          ),
        ),
      ),
    );
  }
}
