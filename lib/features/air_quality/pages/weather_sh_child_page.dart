// 空气质量页主体 - 对齐 Android WeatherShChildFragment.WeatherCompose（行 176-227）
// Scaffold 0xFF010C39 + Column[AirQualityTopBar, Expanded(SingleChildScrollView(Column[
//   SizedBox10, AqiArcDisplay, PollutantsCard(row1), SizedBox10, PollutantsCard(row2), SizedBox10,
//   "生活小贴士"标题, LifeTipsList, SizedBox19
// ]))]
// 整体滑动 - 对齐 Android Column.verticalScroll(rememberScrollState())
// 数据复用 weatherViewModelProvider（tab0 天气页已加载，IndexedStack build 所有 children）
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../weather/viewmodels/weather_view_model.dart';
import 'widgets/air_quality_top_bar.dart';
import 'widgets/aqi_arc_display.dart';
import 'widgets/pollutants_card.dart';
import 'widgets/life_tips_list.dart';

class WeatherShChildPage extends ConsumerWidget {
  const WeatherShChildPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 数据复用 weatherViewModelProvider - 对齐 Android travelViewModel.airQuality
    final air = ref.watch(weatherViewModelProvider).airQuality;

    return Scaffold(
      // 对齐 Android Box(background = Color(0xFF010C39)) 深蓝背景
      backgroundColor: const Color(0xFF010C39),
      body: Column(
        children: [
          // 顶栏 - 对齐 Android Scaffold(topBar = { TopAppBar() })
          // AirQualityTopBar 自己处理 SafeArea(top: true) 状态栏
          const AirQualityTopBar(),
          // 内容区 - 对齐 Android Column(verticalScroll)
          // 整体滑动：SingleChildScrollView（对齐安卓 Column.verticalScroll）
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                // stretch 让 PollutantsCard/LifeTipsList 填满宽度，AqiArcDisplay 用 Center 居中
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Spacer 10dp - 对齐 Android Spacer(height 10.dp)
                  const SizedBox(height: 10),
                  // AQI 圆环 + 7 ValueLabel - 对齐 Android TemperatureDisplay()
                  // 用 Center 居中（stretch 下 Center 填满宽度，AqiArcDisplay SizedBox 250 居中）
                  Center(child: AqiArcDisplay(air: air)),
                  // 第一行 3 污染物 - 对齐 Android WeatherInfoCard()
                  PollutantsCard(air: air, isRow2: false),
                  // Spacer 10dp - 对齐 Android Spacer(height 10.dp)
                  const SizedBox(height: 10),
                  // 第二行 3 污染物 - 对齐 Android WeatherInfoCard2()
                  PollutantsCard(air: air, isRow2: true),
                  // Spacer 10dp - 对齐 Android Spacer(height 10.dp)
                  const SizedBox(height: 10),
                  // "生活小贴士"标题 - 对齐 Android Text("生活小贴士", 16sp Medium White, padding start20 bottom10)
                  const Padding(
                    padding: EdgeInsets.only(left: 20, bottom: 10),
                    child: Text(
                      '生活小贴士',
                      style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 16,
                        fontWeight: FontWeight.w500, // Medium
                      ),
                    ),
                  ),
                  // 3 条小贴士 - 对齐 Android HistoryEventsList()
                  const LifeTipsList(),
                  // Spacer 19dp - 对齐 Android Spacer(height 19.dp)
                  const SizedBox(height: 19),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
