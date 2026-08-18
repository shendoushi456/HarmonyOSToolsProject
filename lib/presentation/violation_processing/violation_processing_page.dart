import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/providers/violation_processing_provider.dart';
import 'widgets/violation_processing_item_card.dart';

/// 违章处理列表页
///
/// 对应 Android: toolCarLib/ViolationProcessingActivity.kt
/// 白底背景 + ListView 5 项违章处理，点击查看详情内容。
class ViolationProcessingPage extends ConsumerWidget {
  const ViolationProcessingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(violationProcessingListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('违章处理')),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: ViolationProcessingItemCard(item: items[index]),
                  );
                },
                childCount: items.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
