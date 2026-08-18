import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_routes.dart';

/// 5 个圆形图标行
///
/// 对应 Android: CarFragment.kt:421-467 CircleIconsRow
/// 交通标志/交警手势/道路信号/硬件图解/科二技巧，点击跳对应详情图页。
class CircleIconsRow extends StatelessWidget {
  const CircleIconsRow({super.key});

  // 图标数据：(标题, 图标 asset, 背景色) —— 背景色原 Android 未实际使用，保留以保持数据完整
  static const _icons = <(String, String, Color)>[
    ('交通标志', 'assets/images/che/ic_che_main_3_1.png', Color(0xFF44DCB5)),
    ('交警手势', 'assets/images/che/ic_che_main_3_2.png', Color(0xFFF9C264)),
    ('道路信号', 'assets/images/che/ic_che_main_3_3.png', Color(0xFF689EFC)),
    ('硬件图解', 'assets/images/che/ic_che_main_3_4.png', Color(0xFFAFBCFF)),
    ('科二技巧', 'assets/images/che/ic_che_main_3_5.png', Color(0xFFFFB4AF)),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: _icons
            .map(
              (item) => _CircleIconItem(
                title: item.$1,
                icon: item.$2,
                onPressed: () =>
                    context.push('${AppRoutes.carDetail}/${item.$1}'),
              ),
            )
            .toList(),
      ),
    );
  }
}

/// 单个圆形图标项
/// 对应 Android: CarFragment.kt:493-518 CircleIconItem
class _CircleIconItem extends StatelessWidget {
  final String title;
  final String icon;
  final VoidCallback onPressed;

  const _CircleIconItem({
    required this.title,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 54,
            height: 54,
            child: Image.asset(icon),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF404040),
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
