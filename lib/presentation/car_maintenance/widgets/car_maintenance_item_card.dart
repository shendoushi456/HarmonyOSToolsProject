import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/car_maintenance_item.dart';
import '../../router/app_routes.dart';

/// 汽车养护项卡片
///
/// 对应 Android: CarMaintenanceActivity.kt:985-1031 CarMaintenanceItemCard
/// 100x123 Column[Card 100x100 图片 + 标题]，点击跳 Markdown 页（空实现）。
class CarMaintenanceItemCard extends StatelessWidget {
  final CarMaintenanceItem item;

  const CarMaintenanceItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(
        AppRoutes.markdown,
        extra: {'title': item.title, 'content': item.markdownContent},
      ),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 100,
        height: 123,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(item.imageAsset, fit: BoxFit.cover),
            ),
            const SizedBox(height: 6),
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF2C2C2C),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
