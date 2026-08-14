// 空气质量页 - 对齐 Android AirQualityDashboardFragment
// 复用 WeatherViewModel 的 airQuality 和 today 数据
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_assets.dart';
import '../../weather/viewmodels/weather_view_model.dart';
import '../utils/air_index_util.dart';
import '../widgets/air_header.dart';
import '../widgets/air_index_card.dart';

class AirQualityPage extends ConsumerWidget {
  const AirQualityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(weatherViewModelProvider);
    final indices = AirIndexUtil.buildIndices(state.today);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 顶部天空背景图 238dp - 对齐 AirQualityScreen
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              AppAssets.skyBackground,
              width: double.infinity,
              height: 238,
              fit: BoxFit.fill,
            ),
          ),
          // 滚动内容
          Positioned.fill(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 18),
              children: [
                AirHeader(
                  airQuality: state.airQuality,
                  today: state.today,
                ),
                ...indices.map((item) => AirIndexCard(item: item)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
