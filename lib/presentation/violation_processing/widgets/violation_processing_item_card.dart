import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/violation_processing_item.dart';
import '../../router/app_routes.dart';

/// 违章处理项卡片
///
/// 对应 Android: ViolationProcessingActivity.kt:606-646 ViolationProcessingItemCard
/// 白底圆角卡片 + 标题 + 右箭头，点击展示条目的 Markdown 内容。
class ViolationProcessingItemCard extends StatelessWidget {
  final ViolationProcessingItem item;

  const ViolationProcessingItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(
        AppRoutes.markdown,
        extra: {'title': item.title, 'content': item.markdownContent},
      ),
      child: Container(
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF363636),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(
                width: 22,
                height: 22,
                child:
                    Image.asset('assets/images/car/ic_car_violation_arrow.png'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
