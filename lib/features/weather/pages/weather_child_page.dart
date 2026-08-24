// 单城市天气页 - 对齐 Android WeatherChildFragment。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/city_bean.dart';
import '../viewmodels/weather_view_model.dart';
import 'widgets/weather_child_content.dart';

class WeatherChildPage extends ConsumerStatefulWidget {
  final CityBean city;

  /// 城市切换回调 - 对齐 Android WeatherChildFragment.onCityClick
  /// 由父级 WeatherPage 传入,跳转到城市选择页
  final VoidCallback? onCityClick;

  const WeatherChildPage({
    super.key,
    required this.city,
    this.onCityClick,
  });

  @override
  ConsumerState<WeatherChildPage> createState() => _WeatherChildPageState();
}

class _WeatherChildPageState extends ConsumerState<WeatherChildPage> {
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
    final viewModel = ref.read(weatherViewModelProvider.notifier);
    final hourly = viewModel.buildHourly(state.hourlyWeather);

    return Scaffold(
      body: state.isLoading && state.weather == null
          ? const Center(child: CircularProgressIndicator())
          : WeatherChildContent(
              cityName: state.cityName,
              today: state.today,
              daily: state.weather?.daily ?? const [],
              hourly: hourly,
              airQuality: state.airQuality,
              onCityClick: widget.onCityClick,
            ),
    );
  }
}
