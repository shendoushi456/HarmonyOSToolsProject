import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_routes.dart';
import '../theme/app_colors.dart';
import 'widgets/car_maintenance_card.dart';
import 'widgets/circle_icons_row.dart';
import 'widgets/practical_info_card.dart';
import 'widgets/violation_handling_card.dart';
import 'widgets/violation_query_card.dart';

/// 首页（CarFragment 第一个页面）
///
/// 对应 Android: CarFragment.kt:152-223 CarContent()
/// Scaffold + 绿色顶栏（标题"首页" + 右上角设置图标）+ ListView 6 卡片区块。
class CarHomePage extends StatelessWidget {
  const CarHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('首页'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: '设置',
            // 对应 Android: CarFragment.onConfirm → ScanMenuActivity.getCarFragment() 的 onConfirm 回调
            // 跳转到 SettSet2Activity（设置页，当前为占位）
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: ColoredBox(
        color: AppColors.pageBg,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          children: const [
            // item 1：违章代码查询主卡片
            ViolationQueryCard(),
            SizedBox(height: 12),
            // item 2：违章处理 + 汽车养护（两卡片并排）
            _DualCardRow(),
            SizedBox(height: 12),
            // item 3：5 个圆形图标
            CircleIconsRow(),
            // item 4：实用信息标题
            _SectionTitle('实用信息', topPadding: 18),
            // item 5：实用信息卡片（车牌类型 + 驾照扣分）
            PracticalInfoCard(),
          ],
        ),
      ),
    );
  }
}

/// 违章处理 + 汽车养护（两卡片并排）
/// 对应 Android: CarFragment.kt:167-181
class _DualCardRow extends StatelessWidget {
  const _DualCardRow();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: ViolationHandlingCard()),
          SizedBox(width: 12),
          Expanded(child: CarMaintenanceCard()),
        ],
      ),
    );
  }
}

/// 区块标题
/// 对应 Android: CarFragment.kt:190-198 / 207-217 的 Text item
class _SectionTitle extends StatelessWidget {
  final String text;
  final double topPadding;

  const _SectionTitle(this.text, {this.topPadding = 0});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, topPadding, 20, 0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryText,
        ),
      ),
    );
  }
}
