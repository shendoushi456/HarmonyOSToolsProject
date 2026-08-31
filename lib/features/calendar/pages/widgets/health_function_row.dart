// 健康生活方式 4 卡片入口 - 对齐 Android NewFunctionRow1（行 264-365）+ NewFunctionRow2（行 136-261）
// 2 行 × 2 列，Padding h20 包裹 Row，Row spacedBy 16
// 每张卡片：Expanded(Container height 46 + white bg + radius 5 + shadow 2dp + GestureDetector) →
//   Row padding h5 centerV spacedBy 8: Image(icon) + Text(12sp w500 0xFF131415)
// 点击：营养(flag=0)→healthInfo路由 / 缓解压力(flag=1)→healthInfo路由 / 24节气→solarTerms路由 / 历史今天→historyToday路由
// 保真：安卓 clickable(indication=null) 无 ripple，用 GestureDetector
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../router/route_names.dart';

/// 第一行：营养 / 如何缓解压力 - 对齐 Android NewFunctionRow1
class HealthFunctionRow1 extends StatelessWidget {
  const HealthFunctionRow1({super.key});

  @override
  Widget build(BuildContext context) {
    // 对齐 Android Row padding h20 fillMaxWidth, spacedBy 16dp
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // 营养 - 对齐 Android Card(ic_jkshfs_01, "营养", onClick → ExtendedinformationActivity flag=0)
          _buildCard(
            icon: AppAssets.icJkshfs01,
            label: '营养',
            onTap: () => context.push(RoutePaths.healthInfo, extra: {'flag': 0}),
          ),
          const SizedBox(width: 16), // spacedBy 16dp
          // 如何缓解压力? - 对齐 Android Card(ic_jkshfs_02, "如何缓解压力?", onClick → ExtendedinformationActivity flag=1)
          _buildCard(
            icon: AppAssets.icJkshfs02,
            label: '如何缓解压力?',
            onTap: () => context.push(RoutePaths.healthInfo, extra: {'flag': 1}),
          ),
        ],
      ),
    );
  }
}

/// 第二行：24节气 / 历史上的今天 - 对齐 Android NewFunctionRow2
class HealthFunctionRow2 extends StatelessWidget {
  const HealthFunctionRow2({super.key});

  @override
  Widget build(BuildContext context) {
    // 对齐 Android Row padding h20 fillMaxWidth, spacedBy 16dp
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // 24节气 - 对齐 Android Card(ic_jkshfs_03, "24节气", onClick → EatActivity 加载 ershisijieqi/index.html)
          _buildCard(
            icon: AppAssets.icJkshfs03,
            label: '24节气',
            onTap: () => context.push(RoutePaths.solarTerms),
          ),
          const SizedBox(width: 16), // spacedBy 16dp
          // 历史上的今天 - 对齐 Android Card(ic_jkshfs_04, "历史上的今天", onClick → HistoryActivity)
          _buildCard(
            icon: AppAssets.icJkshfs04,
            label: '历史上的今天',
            onTap: () => context.push(RoutePaths.historyToday),
          ),
        ],
      ),
    );
  }
}

/// 单张卡片 - 对齐 Android Card(weight 1f, height 46, elevation 2, RoundedCorner 5, white bg)
Widget _buildCard({
  required String icon,
  required String label,
  required VoidCallback onTap,
}) {
  return Expanded(
    // 对齐 Android weight(1f)
    child: Container(
      height: 46, // 对齐 height 46dp
      decoration: BoxDecoration(
        color: Colors.white, // containerColor white
        borderRadius: BorderRadius.circular(5), // RoundedCorner 5dp
        boxShadow: const [
          // 对齐 Android elevation 2dp
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 2,
            offset: Offset(0, 2),
          ),
        ],
      ),
      // 保真：安卓 clickable(indication=null) 无 ripple，用 GestureDetector 不用水波纹
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5), // 对齐 padding h5
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start, // 左对齐（用户要求：不要居中）
            mainAxisSize: MainAxisSize.max, // 填满宽度让左对齐生效
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 图标 - 对齐 Android Image(painterResource ic_jkshfs_0X)
              // 用户要求改小：指定 20x20（原图偏大）
              Image.asset(icon, width: 20, height: 20),
              const SizedBox(width: 8), // spacedBy 8dp
              // 文字 - 对齐 Android Text(12sp Medium 0xFF131415)
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF131415),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
