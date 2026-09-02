// toolbox_c WeatherFragment / WeatherChildFragment 当前 Compose UI 的 Flutter 页面。
// 仅负责视图与交互；城市、天气请求和领域模型由各自的 ViewModel/Repository 提供。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/utils/date_util.dart';
import '../../../router/route_names.dart';
import '../models/weather_model.dart';
import '../viewmodels/toolbox_weather_view_model.dart';
import '../viewmodels/weather_view_model.dart';

class ToolboxWeatherPage extends ConsumerStatefulWidget {
  const ToolboxWeatherPage({super.key});

  @override
  ConsumerState<ToolboxWeatherPage> createState() => _ToolboxWeatherPageState();
}

class _ToolboxWeatherPageState extends ConsumerState<ToolboxWeatherPage> {
  DailyWeather? _selectedForecast;

  @override
  Widget build(BuildContext context) {
    final pageState = ref.watch(toolboxWeatherPageViewModelProvider);
    final weatherState = ref.watch(weatherViewModelProvider);

    ref.listen(
      toolboxWeatherPageViewModelProvider.select((value) => value.city),
      (_, city) {
        if (city != null) {
          ref.read(weatherViewModelProvider.notifier).loadData(city);
        }
      },
    );
    ref.listen(
      weatherViewModelProvider.select((value) => value.weather),
      (previous, next) {
        if (previous != next && mounted) {
          setState(() => _selectedForecast = null);
        }
      },
    );

    if (pageState.isLoading) {
      return const ColoredBox(
        color: Color(0xFF0A0D0E),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (pageState.city == null) {
      return const ColoredBox(
        color: Color(0xFF0A0D0E),
        child:
            Center(child: Text('暂无城市', style: TextStyle(color: Colors.white))),
      );
    }

    final forecast = _selectedForecast ?? weatherState.today;
    final forecasts = weatherState.weather?.daily.take(15).toList() ?? const [];
    return Scaffold(
      backgroundColor: const Color(0xFF0A0D0E),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AppAssets.toolboxWeatherBackground,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _ToolboxWeatherTopBar(
                  cityName: weatherState.cityName,
                  onCityTap: _selectCity,
                ),
                Expanded(
                  child: weatherState.isLoading && weatherState.weather == null
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          onRefresh: () => ref
                              .read(weatherViewModelProvider.notifier)
                              .refresh(pageState.city!),
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 34),
                            children: [
                              _MainWeatherCard(weather: forecast),
                              const SizedBox(height: 20),
                              _SunriseSunsetCard(weather: forecast),
                              const SizedBox(height: 30),
                              _ForecastSection(
                                forecasts: forecasts,
                                onSelected: (value) =>
                                    setState(() => _selectedForecast = value),
                              ),
                              const SizedBox(height: 30),
                              const _LongTripCard(),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
          if (weatherState.error != null && weatherState.weather == null)
            Positioned(
              left: 24,
              right: 24,
              top: MediaQuery.paddingOf(context).top + 72,
              child: Text(
                '天气加载失败，请下拉重试',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withValues(alpha: .8)),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _selectCity() async {
    final changed = await context.push<bool>(RoutePaths.citySelect);
    if (changed == true && mounted) {
      await ref.read(toolboxWeatherPageViewModelProvider.notifier).loadCity();
    }
  }
}

class _ToolboxWeatherTopBar extends StatelessWidget {
  final String cityName;
  final VoidCallback onCityTap;

  const _ToolboxWeatherTopBar(
      {required this.cityName, required this.onCityTap});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 50,
        child: Row(
          children: [
            // 与右侧设置按钮等宽，令城市名在可用标题区域保持视觉居中。
            const SizedBox(width: 56),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onCityTap,
                child: Center(
                  child: Text(
                    cityName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 56,
              child: IconButton(
                tooltip: '设置',
                icon: const Icon(Icons.settings, color: Colors.white, size: 26),
                onPressed: () => context.push(RoutePaths.setting),
              ),
            ),
          ],
        ),
      );
}

class _MainWeatherCard extends StatelessWidget {
  final DailyWeather? weather;

  const _MainWeatherCard({this.weather});

  @override
  Widget build(BuildContext context) {
    final text = weather?.textDay.isNotEmpty == true ? weather!.textDay : '晴';
    final max = weather?.tempMax.isNotEmpty == true ? weather!.tempMax : '26';
    final min = weather?.tempMin.isNotEmpty == true ? weather!.tempMin : '15';
    return AspectRatio(
      aspectRatio: 1005 / 1068,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(AppAssets.toolboxWeatherMainCard, fit: BoxFit.fill),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 20, 28, 22),
            child: Column(
              children: [
                Expanded(
                    child: Image.asset(_bigWeatherIcon(text),
                        fit: BoxFit.contain)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$max°',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 60,
                            fontWeight: FontWeight.w500,
                            height: 1)),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(text,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          Text('$min°C ~ $max°C',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _Metric(
                        icon: AppAssets.toolboxWeatherWind,
                        value: '${weather?.windSpeedDay ?? '25'}km/h',
                        label: '风速'),
                    _Metric(
                        icon: AppAssets.toolboxWeatherPressure,
                        value: '${weather?.pressure ?? '1000'}hPa',
                        label: '气压'),
                    _Metric(
                        icon: AppAssets.toolboxWeatherHumidity,
                        value: '${weather?.humidity ?? '0'}%',
                        label: '湿度'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  const _Metric({required this.icon, required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Column(children: [
        Image.asset(icon, width: 16, height: 16),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 10)),
      ]);
}

class _SunriseSunsetCard extends StatelessWidget {
  final DailyWeather? weather;
  const _SunriseSunsetCard({this.weather});
  @override
  Widget build(BuildContext context) {
    final sunrise =
        weather?.sunrise.isNotEmpty == true ? weather!.sunrise : '06:16';
    final sunset =
        weather?.sunset.isNotEmpty == true ? weather!.sunset : '18:26';
    return AspectRatio(
      aspectRatio: 1005 / 204,
      child: Stack(fit: StackFit.expand, children: [
        Image.asset(AppAssets.toolboxWeatherSunriseCard, fit: BoxFit.fill),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              _SunTime(icon: AppAssets.toolboxWeatherSunrise, time: sunrise),
              _SunTime(
                  icon: AppAssets.toolboxWeatherSunset,
                  time: sunset,
                  reverse: true),
            ]),
            const Spacer(),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: const LinearProgressIndicator(
                  value: .55,
                  minHeight: 4,
                  backgroundColor: Color(0xFFE3E3E3),
                  valueColor: AlwaysStoppedAnimation(Color(0xFF1BCACD))),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _SunTime extends StatelessWidget {
  final String icon;
  final String time;
  final bool reverse;
  const _SunTime(
      {required this.icon, required this.time, this.reverse = false});
  @override
  Widget build(BuildContext context) {
    final children = [
      Image.asset(icon, width: 20, height: 20),
      const SizedBox(width: 8),
      Text(time, style: const TextStyle(color: Colors.white, fontSize: 16))
    ];
    return Row(children: reverse ? children.reversed.toList() : children);
  }
}

class _ForecastSection extends StatelessWidget {
  final List<DailyWeather> forecasts;
  final ValueChanged<DailyWeather> onSelected;
  const _ForecastSection({required this.forecasts, required this.onSelected});
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Center(
            child: Text('十五日预报',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600))),
        const SizedBox(height: 30),
        SizedBox(
          height: 170,
          child: forecasts.isEmpty
              ? const Center(
                  child:
                      Text('暂无预报数据', style: TextStyle(color: Colors.white70)))
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: forecasts.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 22),
                  itemBuilder: (context, index) {
                    final weather = forecasts[index];
                    return GestureDetector(
                      onTap: () => onSelected(weather),
                      child: SizedBox(
                        width: 42,
                        child: Column(children: [
                          Text(DateUtil.getWeekDay(index, weather.fxDate),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 23),
                          Image.asset(_bigWeatherIcon(weather.textDay),
                              width: 28, height: 28),
                          const SizedBox(height: 18),
                          Text(weather.tempMax,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12)),
                          const SizedBox(height: 16),
                          Text(weather.tempMin,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12)),
                          const SizedBox(height: 16),
                          Text(weather.textDay,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                              overflow: TextOverflow.ellipsis),
                        ]),
                      ),
                    );
                  },
                ),
        ),
      ]);
}

class _LongTripCard extends StatelessWidget {
  const _LongTripCard();
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => context.push(RoutePaths.longTrip),
        child: AspectRatio(
          aspectRatio: 1005 / 396,
          child: Stack(fit: StackFit.expand, children: [
            Image.asset(AppAssets.toolboxWeatherLongTrip, fit: BoxFit.fill),
            const Padding(
              padding: EdgeInsets.only(left: 20, top: 16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('长途规划',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500)),
                    SizedBox(height: 3),
                    Text('智能规划 轻松出行',
                        style: TextStyle(color: Colors.white, fontSize: 10)),
                  ]),
            ),
          ]),
        ),
      );
}

String _bigWeatherIcon(String weatherText) {
  if (weatherText.contains('雷')) {
    return AppAssets.toolboxWeatherBigThunderstorm;
  }
  if (weatherText.contains('雨') || weatherText.contains('雪')) {
    return AppAssets.toolboxWeatherBigRain;
  }
  if (weatherText.contains('云') || weatherText.contains('阴')) {
    return AppAssets.toolboxWeatherBigCloudy;
  }
  return AppAssets.toolboxWeatherBigSun;
}
