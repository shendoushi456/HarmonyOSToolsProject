// 单城市天气页 - 对齐 Android WeatherChildFragment
// Stack: 顶部背景图 438dp + 滚动内容(头部 + 预报区)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_assets.dart';
import '../models/city_bean.dart';
import '../models/weather_model.dart';
import '../viewmodels/weather_view_model.dart';
import '../../../router/route_names.dart';
import 'widgets/weather_hour_chart.dart';

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
    final forecasts = viewModel.buildForecasts(state.weather);
    final hourly = viewModel.buildHourly(state.today);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // toolbox_c WeatherChildFragment 顶部导航背景（88dp）
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              AppAssets.toolboxWeatherTopBg,
              width: double.infinity,
              height: 88,
              fit: BoxFit.fill,
            ),
          ),
          // 固定顶部导航栏 + Android 原始天气详情内容
          Positioned.fill(
            child: Column(
              children: [
                SizedBox(
                  height: 88,
                  child: Stack(
                    children: [
                      const Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 13),
                          child: Text('天气',
                              style: TextStyle(
                                  fontSize: 22, color: Color(0xFF1E1E1E))),
                        ),
                      ),
                      Positioned(
                        right: 5,
                        bottom: 13,
                        child: GestureDetector(
                          onTap: () => context.push(RoutePaths.setting),
                          child: ColorFiltered(
                            colorFilter: const ColorFilter.mode(
                                Colors.black, BlendMode.srcIn),
                            child: Image.asset(AppAssets.toolboxWeatherSetting,
                                width: 30, height: 30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: state.isLoading && state.weather == null
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _AndroidCurrentCard(state: state),
                              _AirQualityGrid(air: state.airQuality),
                              _AndroidForecastSection(
                                  today: state.today,
                                  forecasts: forecasts,
                                  hourly: hourly),
                            ],
                          ),
                        ),
                ),
              ],
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

class _AndroidForecastSection extends StatelessWidget {
  final dynamic today;
  final List<HomeForecast> forecasts;
  final List<HourForecast> hourly;
  const _AndroidForecastSection(
      {required this.today, required this.forecasts, required this.hourly});
  @override
  Widget build(BuildContext context) => Column(children: [
        WeatherHourChartCard(hourly: hourly),
        Container(
            margin: const EdgeInsets.only(top: 30, left: 20),
            alignment: Alignment.centerLeft,
            child: Row(children: [
              Image.asset(AppAssets.toolboxWeatherBarOrange,
                  width: 2, height: 14),
              const SizedBox(width: 5),
              const Text('15日天气预报',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
            ])),
        const SizedBox(height: 20),
        SizedBox(
            height: 122,
            child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: forecasts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final f = forecasts[i];
                  return Container(
                      width: 50,
                      padding: const EdgeInsets.only(top: 18),
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage(i == 0
                                  ? AppAssets.toolboxWeatherForecastToday
                                  : AppAssets.toolboxWeatherForecastNormal),
                              fit: BoxFit.fill)),
                      child: Column(children: [
                        Text(f.dayLabel,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(f.dateLabel,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Image.asset(_iconFor(f.iconDay, f.condition),
                            width: 30, height: 30)
                      ]));
                }))
      ]);
  String _iconFor(String code, String c) {
    if (code == '100') return AppAssets.toolboxWeatherIcon0d;
    if (code == '101' ||
        code == '102' ||
        code == '103' ||
        code == '104' ||
        code == '151' ||
        code == '152' ||
        code == '153' ||
        code == '154') {
      return 'assets/images/toolbox_yingtian_icon.png';
    }
    if (code == '302' || code == '303' || code == '304') {
      return 'assets/images/toolbox_dalei_icn.png';
    }
    if (code == '400' ||
        code == '401' ||
        code == '402' ||
        code == '403' ||
        code == '408' ||
        code == '409' ||
        code == '410') {
      return AppAssets.toolboxWeatherIcon7a;
    }
    if (code == '300' ||
        code == '301' ||
        code == '305' ||
        code == '306' ||
        code == '307' ||
        code == '308' ||
        code == '309' ||
        code == '310' ||
        code == '311' ||
        code == '312' ||
        code == '314' ||
        code == '315' ||
        code == '316' ||
        code == '317' ||
        code == '318' ||
        code == '350' ||
        code == '351' ||
        code == '399') {
      return 'assets/images/toolbox_xiayu_icon.png';
    }
    if (c.contains('晴')) return AppAssets.toolboxWeatherIcon0d;
    if (c.contains('雷')) return AppAssets.toolboxWeatherIcon4a;
    if (c.contains('雨')) return AppAssets.toolboxWeatherIcon6a;
    if (c.contains('雪')) return AppAssets.toolboxWeatherIcon7a;
    return AppAssets.toolboxWeatherIcon1a;
  }
}

class _AndroidCurrentCard extends StatelessWidget {
  final dynamic state;
  const _AndroidCurrentCard({required this.state});
  @override
  Widget build(BuildContext context) {
    final today = state.today;
    final cardWidth = MediaQuery.of(context).size.width - 40;
    final progress = _dayProgress(today?.sunrise ?? '', today?.sunset ?? '');
    return Container(
      width: cardWidth,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
                color: Color(0x22000000), blurRadius: 4, offset: Offset(0, 2))
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('${today?.tempMax ?? '--'}°C',
                    style: const TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E1E))),
                Row(children: [
                  Image.asset(AppAssets.toolboxWeatherLocation,
                      width: 16, height: 16),
                  const SizedBox(width: 6),
                  Text(state.cityName,
                      style: const TextStyle(
                          fontSize: 16, color: Color(0xFF1E1E1E)))
                ])
              ])),
          Image.asset(AppAssets.toolboxWeatherNowIcon, width: 92, height: 92),
        ]),
        Text('${today?.tempMin ?? '--'}°C - ${today?.tempMax ?? '--'}°C',
            style: const TextStyle(fontSize: 16, color: Color(0xFF1E1E1E))),
        const SizedBox(height: 16),
        const Text('日出日落',
            style: TextStyle(fontSize: 12, color: Color(0xFF1E1E1E))),
        const SizedBox(height: 6),
        SizedBox(
            height: 8,
            child: Stack(children: [
              Positioned.fill(
                  child: Image.asset(AppAssets.toolboxWeatherProgressTrack,
                      fit: BoxFit.fill)),
              Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                      widthFactor: progress,
                      child: Image.asset(AppAssets.toolboxWeatherProgressSun,
                          fit: BoxFit.fill)))
            ])),
        const SizedBox(height: 4),
        Row(children: [
          Image.asset(AppAssets.toolboxWeatherSunrise, width: 20, height: 20),
          const SizedBox(width: 2),
          Text(today?.sunrise ?? '--:--', style: const TextStyle(fontSize: 10)),
          const Spacer(),
          Image.asset(AppAssets.toolboxWeatherSunset, width: 20, height: 20),
          const SizedBox(width: 2),
          Text(today?.sunset ?? '--:--', style: const TextStyle(fontSize: 10))
        ]),
        const SizedBox(height: 17),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: const [
          Text('日', style: TextStyle(fontSize: 14)),
          Text('一', style: TextStyle(fontSize: 14)),
          Text('二', style: TextStyle(fontSize: 14)),
          Text('三', style: TextStyle(fontSize: 14)),
          Text('四', style: TextStyle(fontSize: 14)),
          Text('五', style: TextStyle(fontSize: 14)),
          Text('六', style: TextStyle(fontSize: 14))
        ]),
        const SizedBox(height: 10),
        Container(
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
                color: const Color(0xFFF6F6F6),
                borderRadius: BorderRadius.circular(15)),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _weekDates())),
      ]),
    );
  }

  List<Widget> _weekDates() {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday % 7));
    return List.generate(7, (i) {
      final selected = i == now.weekday % 7;
      return Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: selected
              ? const BoxDecoration(
                  color: Color(0xFF59B5F7), shape: BoxShape.circle)
              : null,
          child: Text('${start.add(Duration(days: i)).day}',
              style: TextStyle(
                  fontSize: 14,
                  color: selected ? Colors.white : const Color(0xFF1E1E1E))));
    });
  }

  double _dayProgress(String sunrise, String sunset) {
    try {
      final a = sunrise.split(':');
      final b = sunset.split(':');
      final s = int.parse(a[0]) * 60 + int.parse(a[1]);
      final e = int.parse(b[0]) * 60 + int.parse(b[1]);
      final n = DateTime.now().hour * 60 + DateTime.now().minute;
      return ((n - s) / (e - s)).clamp(0.0, 1.0);
    } catch (_) {
      return .5;
    }
  }
}

class _AirQualityGrid extends StatelessWidget {
  final dynamic air;
  const _AirQualityGrid({required this.air});
  @override
  Widget build(BuildContext context) {
    final items = [
      ['PM2.5', '细颗粒物', air?.pm2p5 ?? '--'],
      ['PM10', '粗颗粒物', air?.pm10 ?? '--'],
      ['SO₂', '二氧化硫', air?.so2 ?? '--'],
      ['NO₂', '二氧化氮', air?.no2 ?? '--'],
      ['CO', '一氧化碳', air?.co ?? '--'],
      ['O3', '臭氧', air?.o3 ?? '--'],
    ];
    return Container(
      margin: const EdgeInsets.only(top: 22, left: 20, right: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 12,
          mainAxisExtent: 50,
        ),
        itemBuilder: (_, i) => Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: const Color(0xFFEDEFF9)),
            boxShadow: const [
              BoxShadow(color: Color(0x16000000), blurRadius: 1)
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(items[i][0]!, style: const TextStyle(fontSize: 12)),
                    Text(items[i][1]!,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF848484))),
                  ],
                ),
              ),
              Text(items[i][2]!, style: const TextStyle(fontSize: 24)),
            ],
          ),
        ),
      ),
    );
  }
}
