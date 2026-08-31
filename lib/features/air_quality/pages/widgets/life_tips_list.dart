// 3 条生活小贴士列表 - 对齐 Android WeatherShChildFragment.HistoryEventsList（行 249-274）+ LifeTipItem（行 276-313）+ getLifeTips（行 232-247）
// Column padding h20 + spacedBy 8dp → 3 条硬编码 LifeTip
// LifeTipItem: Container bg 0xFF333D60 + 圆角 6 + shadow 4dp(spotColor 0xFF333D60) + padding h10 v7 →
//   Row SpaceBetween CenterV → Expanded(Text description 14sp White lineHeight 20/14)
// 保真 Bug 1: category 字段传入但 Row 只渲染 description（不显示 category）
// 保真 Bug 2: onClick 注释掉（不跳转），不加 GestureDetector
import 'package:flutter/material.dart';

class LifeTipsList extends StatelessWidget {
  const LifeTipsList({super.key});

  @override
  Widget build(BuildContext context) {
    // 对齐 Android Column(padding h20, spacedBy 8dp)
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLifeTipItem(
            // category 字段传入但不渲染（保真 Bug 1）
            category: '健康',
            description: '每天保持8杯水的摄入量，有助于促进新陈代谢，保持身体健康',
          ),
          const SizedBox(height: 8), // spacedBy 8dp
          _buildLifeTipItem(
            category: '饮食',
            description: '早餐要吃好，营养搭配要均衡，建议包含蛋白质、碳水化合物和适量脂肪',
          ),
          const SizedBox(height: 8), // spacedBy 8dp
          _buildLifeTipItem(
            category: '居家',
            description: '定期开窗通风，保持室内空气流通，每天至少通风2-3次，每次15-30分钟',
          ),
        ],
      ),
    );
  }

  /// 单个小贴士项 - 对齐 Android LifeTipItem
  /// 保真 Bug 1: category 参数传入但 Row 只渲染 description（不显示 category）
  /// 保真 Bug 2: onClick 注释掉（不跳转），不加 GestureDetector
  Widget _buildLifeTipItem({
    required String category,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF333D60), // 对齐 bg 0xFF333D60
        borderRadius: BorderRadius.circular(6), // 对齐 RoundedCorner 6dp
        boxShadow: const [
          // 对齐 Android shadow(4dp, spotColor 0xFF333D60)
          BoxShadow(
            color: Color(0xFF333D60),
            blurRadius: 4,
          ),
        ],
      ),
      // 对齐 Android padding(h10, v7)
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 描述文字 - 对齐 Android Text(14sp White, weight(1f), lineHeight 20sp)
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 14,
                height: 20 / 14, // lineHeight 20sp
              ),
            ),
          ),
          // 保真 Bug 1: category 字段传入但 Row 只渲染 description（不显示 category）
          // 保真 Bug 2: onClick 注释掉（不跳转），不加 GestureDetector
        ],
      ),
    );
  }
}
