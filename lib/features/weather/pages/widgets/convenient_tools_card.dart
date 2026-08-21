// 便捷工具卡片 - 对齐 Android WeatherChildFragment.JiankYingyCard + ToolsItemCard
// "便捷工具"标题 16sp Medium 0xFF2A78A7 (padding start 20, bottom 16)
// Column(padding horizontal 20, spacedBy 16): 2 个 ToolsItemCard
//   - 二十四节气 → 跳 24 节气 H5 页
//   - 历史上的今天 → 跳历史今天页
// ToolsItemCard: shadow 4dp + RoundedCorner 10dp + white bg + padding(h 12, v 17)
//                图标 50dp + 标题 13sp Medium 0xFF2A78A7 + 副标题 10sp 0xFF666666 + 右箭头 18dp
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../router/route_names.dart';

class ConvenientToolsCard extends StatelessWidget {
  const ConvenientToolsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "便捷工具"标题 - 对齐 Android Text("便捷工具", 16sp Medium 0xFF2A78A7, padding start 20 bottom 16)
        const Padding(
          padding: EdgeInsets.only(left: 20, bottom: 16),
          child: Text(
            '便捷工具',
            style: TextStyle(
              color: Color(0xFF2A78A7),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 17 / 16,
            ),
          ),
        ),
        // 2 个 ToolsItemCard - 对齐 Android Column(padding horizontal 20, spacedBy 16)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              ToolsItemCard(
                title: '二十四节气',
                dayLabel: '当前节气一目了然',
                icon: AppAssets.weatherToolSolarTerms,
                onTap: () => context.push(RoutePaths.solarTerms),
              ),
              const SizedBox(height: 16),
              ToolsItemCard(
                title: '历史上的今天',
                dayLabel: '一键探索历事件',
                icon: AppAssets.weatherToolHistoryToday,
                onTap: () => context.push(RoutePaths.historyToday),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 单个工具卡片 - 对齐 Android WeatherChildFragment.ToolsItemCard
class ToolsItemCard extends StatelessWidget {
  /// 标题 - 13sp Medium 0xFF2A78A7
  final String title;

  /// 副标题 - 10sp 0xFF666666
  final String dayLabel;

  /// 图标路径 - 50dp
  final String icon;

  /// 点击回调 - 对齐 Android modifier.clickable
  final VoidCallback? onTap;

  const ToolsItemCard({
    super.key,
    required this.title,
    required this.dayLabel,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
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
        // 内边距 - 对齐 Android padding(horizontal 12, vertical 17)
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 17),
        child: Row(
          children: [
            // 左侧图标 50dp - 对齐 Android AsyncImage size 50dp
            Image.asset(icon, width: 50, height: 50),
            // 中间标题+副标题
            Padding(
              padding: const EdgeInsets.only(left: 11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题 13sp Medium 0xFF2A78A7
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF2A78A7),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // 副标题 10sp 0xFF666666 (padding top 5)
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      dayLabel,
                      style: const TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 10,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 右侧箭头 18dp - Spacer 推到最右
            const Spacer(),
            Image.asset(AppAssets.arrowRightIcon, width: 18, height: 18),
          ],
        ),
      ),
    );
  }
}
