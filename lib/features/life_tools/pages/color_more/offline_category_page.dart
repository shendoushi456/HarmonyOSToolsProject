// OfflineCategoryPage - 离线涂鸦分类列表页
// 对齐 Android OffLineTypeActivity.java - 根据 classify 显示 4 分类线稿
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/offline_graffiti_item.dart';
import '../../viewmodels/offline_graffiti_view_model.dart';
import '../widgets/tool_top_bar.dart';
import 'offline_draw_page.dart';

/// 离线涂鸦分类列表页 - 对齐 OffLineTypeActivity
/// classify: 水果/数字/字母/曼茶罗
class OfflineCategoryPage extends ConsumerStatefulWidget {
  const OfflineCategoryPage({super.key, required this.classify});

  final String classify;

  static Future<void> push(
    BuildContext context, {
    required String classify,
  }) =>
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OfflineCategoryPage(classify: classify),
        ),
      );

  @override
  ConsumerState<OfflineCategoryPage> createState() =>
      _OfflineCategoryPageState();
}

class _OfflineCategoryPageState extends ConsumerState<OfflineCategoryPage> {
  late final List<OfflineGraffitiItem> _items;

  @override
  void initState() {
    super.initState();
    // 对齐 OffLineTypeActivity.onCreate 调 getImageItems(classify)
    _items = ref
        .read(offlineGraffitiProvider.notifier)
        .loadByClassify(widget.classify);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4FF),
      appBar: ToolTopBar(title: '${widget.classify}列表'),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            elevation: 1,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => OfflineDrawPage.push(context, item.assetPath),
              child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(item.assetPath, fit: BoxFit.contain)),
            ),
          );
        },
      ),
    );
  }
}
