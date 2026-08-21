// 空气质量页 - 顶层容器 - 对齐 Android WeatherShFragment(外层 ViewPager 容器)
// 单选模式:不还原 Android 多城市 ViewPager+小圆点
// 数据:复用 weatherViewModelProvider(tab0 天气页已加载,IndexedStack build 所有 children)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'air_quality_new_child_page.dart';

class AirQualityNewPage extends ConsumerWidget {
  const AirQualityNewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const AirQualityNewChildPage();
  }
}
