import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/offline_graffiti_view_model.dart';
import '../widgets/tool_top_bar.dart';
import 'offline_draw_page.dart';

/// Android OffLineTypeActivity(classify = "水果") 的 Flutter 页面。
class OfflineCategoryPage extends ConsumerWidget {
  const OfflineCategoryPage({super.key});
  static Future<void> push(BuildContext context) => Navigator.push(
      context, MaterialPageRoute(builder: (_) => const OfflineCategoryPage()));
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(offlineGraffitiProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4FF),
      appBar: const ToolTopBar(title: '水果列表'),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1),
        itemCount: items.length,
        itemBuilder: (_, index) {
          final item = items[index];
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
