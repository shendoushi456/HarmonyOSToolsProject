import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/providers/car_maintenance_provider.dart';
import 'widgets/car_maintenance_item_card.dart';

/// 汽车养护页
///
/// 对应 Android: toolCarLib/CarMaintenanceActivity.kt
/// 白底背景 + 3 列网格 6 项养护，点击跳 Markdown 页（空实现）。
class CarMaintenancePage extends ConsumerWidget {
  const CarMaintenancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(carMaintenanceListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('汽车养护')),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(22),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 18,
            // 卡片内容为 100 高图片 + 6 间距 + 标题，网格高度不能使用默认正方形。
            mainAxisExtent: 123,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) =>
              CarMaintenanceItemCard(item: items[index]),
        ),
      ),
    );
  }
}
