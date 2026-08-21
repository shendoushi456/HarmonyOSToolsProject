// 空气质量页主体 - 对齐 Android WeatherShChildFragment.WeatherCompose
// Scaffold 0xFFF5F8FC + TopAppBar + Column.verticalScroll(AqiCircleDisplay + WeatherInfoCard + AirQualityPollutantsCard)
// 数据来源:watch weatherViewModelProvider(state.airQuality + state.today)
// 不主动 loadData:依赖 tab0 天气页加载,IndexedStack 会 build 所有 children
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../weather/viewmodels/weather_view_model.dart';
import 'widgets/air_quality_top_bar.dart';
import 'widgets/aqi_circle_display.dart';
import 'widgets/weather_info_card.dart';
import 'widgets/air_quality_pollutants_card.dart';

class AirQualityNewChildPage extends ConsumerWidget {
  const AirQualityNewChildPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // watch weatherViewModelProvider - 对齐 Android travelViewModel.airQuality/nowWeather collect
    // 城市切换在 tab0 天气页进行,空气质量页自动跟随
    final state = ref.watch(weatherViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 顶部栏 - 对齐 Android Scaffold.topBar { TopAppBar() }
            const AirQualityTopBar(),
            // 内容区 - 对齐 Android Column(verticalScroll)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 对齐 Android Spacer 20dp + TemperatureDisplay() + Spacer 20dp
                    const SizedBox(height: 20),
                    AqiCircleDisplay(air: state.airQuality),
                    const SizedBox(height: 20),
                    // 对齐 Android WeatherInfoCard() + Spacer 20dp
                    WeatherInfoCard(today: state.today),
                    const SizedBox(height: 20),
                    // 对齐 Android AirQualityCard() + Spacer 19dp
                    AirQualityPollutantsCard(air: state.airQuality),
                    const SizedBox(height: 19),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
