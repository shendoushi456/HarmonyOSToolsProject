// 单城市天气页主体 - 对齐 Android WeatherChildFragment.WeatherCompose（行 159-206）
// Scaffold 0xFF010C39 + SafeArea(bottom false) + Column[TopBar, Expanded(SingleChildScrollView(Column))]
// 整体滑动 - 对齐用户决策"安卓只能七日周报滑，迁移后应成页面整体滑动"
//   安卓行 176 .verticalScroll(rememberScrollState()) 被注释掉，所以只能七日周报滑
//   鸿蒙启用 SingleChildScrollView 整体滑动，七日列表改普通 Column 不用 ListView
// 保真：Android ListModeFunctionCard.onItemClick = {} 空实现（行 686）
//   此处不实现 _selectedForecast 联动，顶部温度固定显示 state.today（对齐 Android now = daily.firstOrNull）
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/city_bean.dart';
import '../models/weather_model.dart' show DailyWeather;
import '../viewmodels/weather_view_model.dart';
import 'widgets/air_quality_aqi_card.dart';
import 'widgets/seven_day_report_card.dart';
import 'widgets/sunrise_sunset_card.dart';
import 'widgets/weather_compose_temperature_display.dart';
import 'widgets/weather_compose_top_bar.dart';
import 'widgets/weather_metrics_card.dart';

class WeatherComposeChildPage extends ConsumerStatefulWidget {
  /// 当前城市
  final CityBean city;

  /// 城市切换回调 - 对齐 Android TopAppBar.Text.clickable { changeCity }
  final VoidCallback? onCityClick;

  const WeatherComposeChildPage({
    super.key,
    required this.city,
    this.onCityClick,
  });

  @override
  ConsumerState<WeatherComposeChildPage> createState() =>
      _WeatherComposeChildPageState();
}

class _WeatherComposeChildPageState
    extends ConsumerState<WeatherComposeChildPage> {
  @override
  void initState() {
    super.initState();
    // 视图创建即加载 - 对齐 Android onViewCreated + onResume
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(weatherViewModelProvider.notifier).loadData(widget.city);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(weatherViewModelProvider);

    // 七日预报：直接取原始 daily 列表前 7 项
    // 对齐 Android populateForecasts 取 minOf(size, 7) 前 7 项
    final dailyList =
        state.weather?.daily.take(7).toList() ?? <DailyWeather>[];

    return Scaffold(
      backgroundColor: const Color(0xFF010C39),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 顶部栏 - 对齐 Android Scaffold.topBar { TopAppBar() }
            WeatherComposeTopBar(
              cityName: state.cityName,
              onCityClick: widget.onCityClick,
            ),
            // 内容区 - 对齐 Android Column(fillMaxSize, bg 0xFF010C39, padding top)
            // 整体滑动 - SingleChildScrollView（对齐用户决策"页面整体滑动"）
            Expanded(
              child: state.isLoading && state.weather == null
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFFFFFF),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Spacer 10dp - 对齐 Android Spacer(height 10dp)
                          const SizedBox(height: 10),
                          // 大温度展示 - 对齐 Android TemperatureDisplay()
                          WeatherComposeTemperatureDisplay(today: state.today),
                          // Spacer 20dp
                          const SizedBox(height: 20),
                          // 风速/气压/湿度/温度 4 指标卡 - 对齐 Android WeatherInfoCard()
                          WeatherMetricsCard(today: state.today),
                          // Spacer 20dp
                          const SizedBox(height: 20),
                          // 空气质量 AQI 卡 - 对齐 Android SunriseSunsetCard()（命名误导 Bug）
                          AirQualityAqiCard(air: state.airQuality),
                          // Spacer 20dp
                          const SizedBox(height: 20),
                          // 日出日落卡 - 对齐 Android SunriseSunsetCard2()
                          SunriseSunsetCard(today: state.today),
                          // 七日周报 - 对齐 Android SevenDayReport()
                          SevenDayReportCard(dailyList: dailyList),
                          // 底部留白
                          const SizedBox(height: 20),
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
