import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/providers/indicator_light_provider.dart';
import '../../../domain/models/indicator_light.dart';
import '../../router/app_routes.dart';
import 'indicator_light_card.dart';

/// 指示灯横向滚动区域（首页预览）
///
/// 对应 Android: CarFragment.kt:470-490 IndicatorLightSection
/// LazyRow 横向滚动 21 个指示灯卡片，点击跳指示灯完整列表页。
class IndicatorLightSection extends ConsumerWidget {
  const IndicatorLightSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lights = ref.watch(indicatorLightListProvider);
    return SizedBox(
      width: double.infinity,
      // 横向 ListView 嵌套在首页纵向 ListView 中，必须给出确定高度；
      // 否则会收到无限高度约束并导致 viewport 布局失败，首页可能呈现空白。
      height: 68,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: lights.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final light = lights[index];
          return _IndicatorLightPreviewCard(light: light, onTap: () => context.push(AppRoutes.indicatorLight));
        },
      ),
    );
  }
}

/// 首页预览用的指示灯卡片（点击统一跳完整列表页）
class _IndicatorLightPreviewCard extends StatelessWidget {
  final IndicatorLight light;
  final VoidCallback onTap;

  const _IndicatorLightPreviewCard({required this.light, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IndicatorLightCard(
      name: light.name,
      description: light.description,
      iconAsset: light.iconAsset,
      onTap: onTap,
    );
  }
}
