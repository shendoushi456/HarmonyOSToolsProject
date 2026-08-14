// 单城市天气页 - 对齐 Android WeatherChildFragment
// Stack: 顶部背景图 438dp + 滚动内容(头部 + 预报区)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_assets.dart';
import '../models/city_bean.dart';
import '../viewmodels/weather_view_model.dart';
import 'widgets/current_weather_header.dart';
import 'widgets/forecast_content.dart';

class WeatherChildPage extends ConsumerStatefulWidget {
  final CityBean city;

  const WeatherChildPage({super.key, required this.city});

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
    final forecasts = viewModel.buildForecasts(state.weather);
    final hourly = viewModel.buildHourly(state.today);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 顶部天空背景图 438dp
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              AppAssets.skyBackground,
              width: double.infinity,
              height: 438,
              fit: BoxFit.fill,
            ),
          ),
          // 滚动内容
          Positioned.fill(
            child: state.isLoading && state.weather == null
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: EdgeInsets.only(
                      bottom: 18,
                      top: MediaQuery.of(context).padding.top,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CurrentWeatherHeader(
                          cityName: state.cityName,
                          today: state.today,
                          airQuality: state.airQuality,
                          onCityClick: () {
                            // 本期仅预留入口
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('敬请期待'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                        ForecastContent(
                          today: state.today,
                          forecasts: forecasts,
                          hourly: hourly,
                        ),
                      ],
                    ),
                  ),
          ),
          // 错误提示
          if (state.error != null && state.weather == null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 80,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '加载失败: ${state.error}',
                  style: TextStyle(color: Colors.red.shade700, fontSize: 14),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
