// 空气质量生活指数卡片 - 对齐 Android AirIndexCard(行 227-293)
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/air_index_item.dart';
import 'air_icons_painter.dart';

class AirIndexCard extends StatelessWidget {
  final AirIndexItem item;

  const AirIndexCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 13),
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 图标区:44dp 圆,airTagBlue 背景
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.airTagBlue,
              shape: BoxShape.circle,
            ),
            child: item.imageAsset != null
                ? Image.asset(
                    item.imageAsset!,
                    width: 44,
                    height: 44,
                    fit: BoxFit.contain,
                  )
                : CustomPaint(
                    size: const Size(32, 32),
                    painter: painterForType(item.iconType),
                  ),
          ),
          // 标题
          Padding(
            padding: const EdgeInsets.only(left: 18),
            child: Text(
              item.title,
              style: const TextStyle(
                color: AppColors.qmtqText,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
            ),
          ),
          // 右侧数值标签
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                height: 28,
                width: 88,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.airTagBlue,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.value,
                  style: const TextStyle(
                    color: AppColors.qmtqText,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
