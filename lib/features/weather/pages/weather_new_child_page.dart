// 单城市天气页主体 - 对齐 Android WeatherChildFragment.WeatherCompose
// Scaffold F5F8FC + 顶部栏 + Column.verticalScroll(TemperatureDisplay + 便捷工具 + 七日预报)
// _selectedForecast: 用户点击七日预报某天后,顶部 TemperatureDisplay 跟着变化
//   对齐 Android onForecastSelected = { forecast -> selectedForecast = forecast; now = forecast }
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/city_bean.dart';
import '../models/weather_model.dart';
import '../viewmodels/weather_view_model.dart';
import 'widgets/weather_new_top_bar.dart';
import 'widgets/temperature_display.dart';
import 'widgets/convenient_tools_card.dart';
import 'widgets/seven_day_forecast_card.dart';

class WeatherNewChildPage extends ConsumerStatefulWidget {
  /// 当前城市
  final CityBean city;

  /// 城市切换回调 - 对齐 Android TopAppBar.Text.clickable { changeCity }
  final VoidCallback? onCityClick;

  const WeatherNewChildPage({
    super.key,
    required this.city,
    this.onCityClick,
  });

  @override
  ConsumerState<WeatherNewChildPage> createState() =>
      _WeatherNewChildPageState();
}

class _WeatherNewChildPageState extends ConsumerState<WeatherNewChildPage> {
  /// 用户选中的预报项(对齐 Android selectedForecast / now)
  /// null 时回退到 state.today(对齐 Android 初始 now = daily.firstOrNull)
  /// 点击七日预报某天时被赋值,顶部 TemperatureDisplay 跟着变化
  DailyWeather? _selectedForecast;

  @override
  void initState() {
    super.initState();
    // 视图创建即加载(对齐 Android onViewCreated + onResume)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(weatherViewModelProvider.notifier).loadData(widget.city);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(weatherViewModelProvider);

    // 监听 weather 数据变化 - 对齐 Android LaunchedEffect(weather7DList):
    //   weather7DList 变化时 selectedIndex=0, now=weather7DList[0]
    //   即 weather 数据更新(首次加载/城市切换)时重置选中为 null,回退到 state.today
    ref.listen(
      weatherViewModelProvider.select((s) => s.weather),
      (previous, next) {
        if (previous != next) {
          // weather 数据变化,重置用户选择(回退到 state.today)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _selectedForecast = null;
              });
            }
          });
        }
      },
    );

    // 七日预报:直接取原始 daily 列表前 7 项(对齐 Android weather7DList.take(7))
    final dailyList =
        state.weather?.daily.take(7).toList() ?? <DailyWeather>[];

    // 顶部展示的预报项:优先用户选择,否则回退到今日(对齐 Android now 变量)
    final displayForecast = _selectedForecast ?? state.today;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 顶部栏 - 对齐 Android Scaffold.topBar { TopAppBar() }
            WeatherNewTopBar(
              cityName: state.cityName,
              onCityClick: widget.onCityClick,
            ),
            // 内容区 - 对齐 Android Column(verticalScroll)
            Expanded(
              child: state.isLoading && state.weather == null
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 大温度展示区 - 对齐 Android TemperatureDisplay()
                          // 使用 displayForecast: 点击七日预报时跟着变化
                          const SizedBox(height: 20),
                          TemperatureDisplay(today: displayForecast),
                          const SizedBox(height: 20),
                          // 便捷工具 - 对齐 Android Text("便捷工具") + JiankYingyCard()
                          const ConvenientToolsCard(),
                          const SizedBox(height: 20),
                          // 七日预报 - 对齐 Android Text("七日预报") + SevenDayReport()
                          // onSelected: 点击某天时更新 _selectedForecast,触发顶部重绘
                          SevenDayForecastCard(
                            dailyList: dailyList,
                            onSelected: (forecast) {
                              setState(() {
                                _selectedForecast = forecast;
                              });
                            },
                          ),
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
