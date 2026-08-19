import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/providers/indicator_light_provider.dart';
import '../../../domain/models/indicator_light.dart';
import '../router/app_routes.dart';
import '../theme/app_colors.dart';

/// 指示灯完整列表页
///
/// 对应 Android: toolCarLib/CarIndicatorLightActivity.kt
/// 灰背景 + 橙色说明文字 + ListView 21 项指示灯（图标 + 名称 + 描述）。
class IndicatorLightPage extends ConsumerWidget {
  const IndicatorLightPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lights = ref.watch(indicatorLightListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('汽车指示灯')),
      body: ColoredBox(
        color: const Color(0xFFF5F5F5),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: lights.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              if (index == 0) {
                // 说明文字
                return Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                          fontSize: 8, color: AppColors.indicatorOrange),
                      children: [
                        TextSpan(
                            text: '说明：',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        TextSpan(
                          text: '部分车型的故障指示灯有所区别，此处仅供参考',
                          style: TextStyle(height: 11 / 8),
                        ),
                      ],
                    ),
                  ),
                );
              }
              final light = lights[index - 1];
              return _IndicatorLightFullCard(
                light: light,
                onTap: () => context.push(
                  AppRoutes.indicatorLightDetail,
                  extra: light,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// 指示灯卡片（完整版，对应 CarIndicatorLightActivity.IndicatorLightCard）
/// 原 Android 支持 isTextIcon 文字图标，但数据中 isTextIcon 全为 false，故仅渲染图片图标。
class _IndicatorLightFullCard extends StatelessWidget {
  final IndicatorLight light;
  final VoidCallback onTap;

  const _IndicatorLightFullCard({required this.light, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 左侧图标
              SizedBox(
                width: 50,
                height: 50,
                child: Image.asset(light.iconAsset),
              ),
              const SizedBox(width: 19),
              // 右侧文字
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      light.name,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Color(0xFF404040),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      light.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF777777),
                        height: 20 / 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
