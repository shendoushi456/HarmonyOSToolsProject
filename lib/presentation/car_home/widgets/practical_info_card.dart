import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_routes.dart';

/// 实用信息卡片
///
/// 对应 Android: CarFragment.kt:582-706 PracticalInfoCard
/// 两张卡片：车牌类型（跳详情图）+ 驾照扣分（跳驾照扣分规则页）。
class PracticalInfoCard extends StatelessWidget {
  const PracticalInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: const [
          _InfoCard(
            title: '车牌类型',
            iconAsset: 'assets/images/che/ic_che_main_4_1.png',
            iconWidth: 46,
            iconHeight: 28,
            route: '${AppRoutes.carDetail}/车牌类型',
          ),
          SizedBox(height: 10),
          _InfoCard(
            title: '驾照扣分',
            iconAsset: 'assets/images/che/ic_che_main_4_2.png',
            iconWidth: 40,
            iconHeight: 39,
            route: AppRoutes.drivingLicense,
          ),
        ],
      ),
    );
  }
}

/// 单条实用信息卡片
class _InfoCard extends StatelessWidget {
  final String title;
  final String iconAsset;
  final double iconWidth;
  final double iconHeight;
  final String route;

  const _InfoCard({
    required this.title,
    required this.iconAsset,
    required this.iconWidth,
    required this.iconHeight,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        width: double.infinity,
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            height: 76,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 46,
                      height: 46,
                      child: Center(
                        child: SizedBox(
                          width: iconWidth,
                          height: iconHeight,
                          child: Image.asset(iconAsset),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF404040),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF39D6AE),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Text(
                    '立即查询',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
