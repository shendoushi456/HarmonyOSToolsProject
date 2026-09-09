// toolbox_c WeatherFragment/WeatherChildFragment(Compose 版)的 Flutter 迁移。
// 数据层复用 weatherViewModelProvider / toolboxWeatherPageViewModelProvider，
// 本文件只负责展示 UI，方便后续马甲包整体替换。
// 对齐 Android 结构：Hero 渐变头图 → 当前天气卡 → 24小时预报 → 长途规划入口
// → 15日天气(仅列表，按需求去掉折线 Tab) → 空气质量 → 生活建议。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/utils/date_util.dart';
import '../../../router/route_names.dart';
import '../models/hourly_weather.dart';
import '../models/weather_model.dart';
import '../viewmodels/toolbox_weather_view_model.dart';
import '../viewmodels/weather_view_model.dart';

class WeatherHomePage extends ConsumerStatefulWidget {
  const WeatherHomePage({super.key});
  @override
  ConsumerState<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends ConsumerState<WeatherHomePage> {
  /// 15日天气选中行(对齐 WeatherChildFragment.selectedIndex)
  int _selectedIndex = 0;

  /// 当前天气卡的"HH:mm 更新"时间，对齐 Android remember{...} 只计算一次
  late final String _updatedAt = _formatHourMinute(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final page = ref.watch(toolboxWeatherPageViewModelProvider);
    final state = ref.watch(weatherViewModelProvider);
    ref.listen(toolboxWeatherPageViewModelProvider.select((s) => s.city),
        (_, city) {
      if (city != null) {
        ref.read(weatherViewModelProvider.notifier).loadData(city);
      }
    });
    // 对齐 Android LaunchedEffect(forecasts)：预报数据变化时选中行复位
    ref.listen(weatherViewModelProvider.select((s) => s.weather), (_, weather) {
      if (mounted && (weather?.daily.isNotEmpty ?? false)) {
        setState(() => _selectedIndex = 0);
      }
    });

    if (page.isLoading || page.city == null) {
      return const Scaffold(
        backgroundColor: _pageBackground,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final daily = state.weather?.daily ?? const <DailyWeather>[];
    final now = state.today;

    return Scaffold(
      backgroundColor: _pageBackground,
      body: SingleChildScrollView(
        child: Column(children: [
          _WeatherHero(
            cityName: state.cityName,
            today: now,
            air: state.airQuality,
            onSelectCity: _selectCity,
          ),
          Container(
            width: double.infinity,
            color: _pageBackground,
            padding: const EdgeInsets.only(bottom: 88),
            child: Column(children: [
              // 对齐 Android Modifier.offset(y = -19)：卡片上移压住 Hero，
              // 但不改变后续兄弟组件的布局位置。
              Transform.translate(
                offset: const Offset(0, -19),
                child: _WeatherInfoCard(
                  now: now,
                  updatedAt: _updatedAt,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
              _TwentyFourHourCard(
                hourly: state.hourly,
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),
              _LongTripEntryCard(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                onTap: () => context.push(RoutePaths.longTrip),
              ),
              _FifteenDayCard(
                daily: daily,
                selectedIndex: _selectedIndex,
                onSelected: (index) =>
                    setState(() => _selectedIndex = index),
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),
              _AirQualityCard(
                air: state.airQuality,
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              _LifeIndexCard(
                now: now,
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  /// 对齐 TravelViewModel.changeCity：跳城市选择页后刷新本地城市
  Future<void> _selectCity() async {
    final changed = await context.push<bool>(RoutePaths.citySelect);
    if (changed == true && mounted) {
      await ref.read(toolboxWeatherPageViewModelProvider.notifier).loadCity();
    }
  }
}

String _formatHourMinute(DateTime time) =>
    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

// ====== 颜色常量 - 对齐 WeatherComponents.kt 顶部私有颜色 ======
const _pageBackground = Color(0xFFF6FBFF);
const _pageText = Color(0xFF222222);
const _secondaryText = Color(0xFF8B95A7);
const _designBlue = Color(0xFF219CF3);
const _paleBlue = Color(0xFFEAF6FF);
const _dividerBlue = Color(0xFFE4F2FF);
const _healthyGreen = Color(0xFF35C486);
const _titleBarBlue = Color(0xFF2F80ED);

/// 天气卡通用容器 - 对齐 WeatherCard：白底、15dp 圆角、3dp 阴影
class _WeatherCardShell extends StatelessWidget {
  final EdgeInsetsGeometry margin;
  final Widget child;
  const _WeatherCardShell({required this.margin, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// 卡片标题 - 对齐 CardTitle：左侧 3x15 蓝条 + 15sp 粗体 + 可选尾随内容
class _CardTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const _CardTitle({required this.title, this.trailing});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 12, top: 10, bottom: 8),
      child: Row(children: [
        Container(
          width: 3,
          height: 15,
          decoration: BoxDecoration(
            color: _titleBarBlue,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 6),
          child: Text(title,
              style: const TextStyle(
                  color: _pageText,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
        ),
        const Spacer(),
        if (trailing != null) trailing!,
      ]),
    );
  }
}

// ====== 顶部 Hero - 对齐 WeatherChildFragment.WeatherHero ======
class _WeatherHero extends StatelessWidget {
  final String cityName;
  final DailyWeather? today;
  final AirQuality? air;
  final VoidCallback onSelectCity;
  const _WeatherHero({
    required this.cityName,
    required this.today,
    required this.air,
    required this.onSelectCity,
  });
  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    // Android: air?.temp?.takeIf{isNotBlank} ?: today?.tempMax ?: "26"
    // 和风 air/now 不含 temp 字段，实际恒走 tempMax 分支，此处保持等价链
    final temp = today?.tempMax ?? '26';
    final text = today?.textDay ?? '多云';
    return Container(
      height: 286,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2A9EFA), Color(0xFF2CA3F7)],
        ),
      ),
      child: Stack(children: [
        // 底部城市剪影：宽撑满、高142、FillWidth + BottomCenter
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SizedBox(
            height: 142,
            width: double.infinity,
            child: Image.asset(
              AppAssets.zxxtqWeatherCityscape,
              fit: BoxFit.fitWidth,
              alignment: Alignment.bottomCenter,
            ),
          ),
        ),
        // 顶部城市栏：statusBarsPadding + 高55 + 水平28
        Positioned(
          left: 0,
          right: 0,
          top: statusBarHeight,
          child: SizedBox(
            height: 55,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onSelectCity,
                child: Row(children: [
                  Image.asset(AppAssets.zxxtqLocation,
                      width: 17, height: 17),
                  const SizedBox(width: 8),
                  Text(
                    cityName.isEmpty ? '北京市' : cityName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 7),
                  const Text('⌄',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ]),
              ),
            ),
          ),
        ),
        // 大温度列：statusBarsPadding + padding(start 24, top 63)
        Positioned(
          left: 24,
          top: statusBarHeight + 63,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$temp°',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 62,
                          height: 65 / 62,
                          fontWeight: FontWeight.w900)),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 8),
                    child: Text(text,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4, top: 4),
                child: Text(
                  '最高 ${today?.tempMax ?? "--"}°  最低 ${today?.tempMin ?? "--"}°',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(children: [
                  Image.asset(AppAssets.zxxtqAirLeaf,
                      width: 14, height: 14),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      '空气${air?.category ?? "--"} ${air?.aqi ?? "--"}',
                      style: const TextStyle(
                          color: Color(0xFF596579), fontSize: 12),
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
        // 云图：CenterEnd + padding(top 22, end 13) + 180x132
        Positioned(
          top: (286 - 132) / 2 + 22,
          right: 13,
          child: Image.asset(AppAssets.zxxtqWeatherHeroCloud,
              width: 180, height: 132, fit: BoxFit.contain),
        ),
      ]),
    );
  }
}

// ====== 当前天气卡 - 对齐 WeatherInfoCardScreen ======
class _WeatherInfoCard extends StatelessWidget {
  final DailyWeather? now;
  final String updatedAt;
  final EdgeInsetsGeometry margin;
  const _WeatherInfoCard({
    required this.now,
    required this.updatedAt,
    required this.margin,
  });
  @override
  Widget build(BuildContext context) {
    return _WeatherCardShell(
      margin: margin,
      child: Column(children: [
        _CardTitle(
          title: '当前天气',
          trailing: Text('$updatedAt 更新',
              style: const TextStyle(color: _secondaryText, fontSize: 9)),
        ),
        IntrinsicHeight(
          child: Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _WeatherMetric(
                  icon: AppAssets.zxxtqMetricTemperature,
                  label: '体感温度',
                  value: '${now?.tempMax ?? "--"}°',
                ).expanded(),
                const _MetricDivider(),
                _WeatherMetric(
                  icon: AppAssets.zxxtqMetricHumidity,
                  label: '湿度',
                  value: '${now?.humidity ?? "--"}%',
                ).expanded(),
                const _MetricDivider(),
                _WeatherMetric(
                  icon: AppAssets.zxxtqMetricWind,
                  label: '风速',
                  value:
                      '${now?.windScaleDay ?? "--"}级${now?.windDirDay ?? ""}',
                ).expanded(flex: 6),
                const _MetricDivider(),
                _WeatherMetric(
                  icon: AppAssets.zxxtqMetricComfort,
                  label: '舒适度',
                  value: _comfortText(now),
                ).expanded(),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

extension _Expanded on Widget {
  /// Android weight(1f)/weight(1.2f) → Expanded flex 5/6
  Widget expanded({int flex = 5}) => Expanded(flex: flex, child: this);
}

/// 指标间分隔线 - 对齐 MetricDivider
class _MetricDivider extends StatelessWidget {
  const _MetricDivider();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: _dividerBlue,
    );
  }
}

/// 单个指标 - 对齐 WeatherMetric
class _WeatherMetric extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  const _WeatherMetric({
    required this.icon,
    required this.label,
    required this.value,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(children: [
        Image.asset(icon, width: 30, height: 30),
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(label,
              style:
                  const TextStyle(color: _secondaryText, fontSize: 9)),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: _pageText,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}

/// 对齐 comfortText：max>=32 偏热，<=10 偏冷，否则舒适；无数据时舒适
String _comfortText(DailyWeather? now) {
  final max = int.tryParse(now?.tempMax ?? '');
  if (max == null) return '舒适';
  if (max >= 32) return '偏热';
  if (max <= 10) return '偏冷';
  return '舒适';
}

// ====== 24小时预报卡 - 对齐 TwentyFourHourWeatherScreen ======
class _TwentyFourHourCard extends StatelessWidget {
  final List<HourlyWeather> hourly;
  final EdgeInsetsGeometry margin;
  const _TwentyFourHourCard({required this.hourly, required this.margin});
  @override
  Widget build(BuildContext context) {
    return _WeatherCardShell(
      margin: margin,
      child: Column(children: [
        const _CardTitle(title: '24小时预报'),
        if (hourly.isEmpty)
          // 对齐空态：7 个占位项，首项选中
          SizedBox(
            height: 118,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  7,
                  (index) => _HourPlaceholder(
                    time: _currentHourLabel(index),
                    selected: index == 0,
                  ),
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 118,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 7),
              itemCount: hourly.take(24).length,
              separatorBuilder: (_, __) => const SizedBox(width: 2),
              itemBuilder: (_, index) {
                final item = hourly[index];
                return _HourWeatherItem(
                  time: _hourLabel(item.fxTime),
                  weatherText: item.text,
                  temp: item.temp,
                  windScale: item.windScale,
                  selected: index == 0,
                );
              },
            ),
          ),
      ]),
    );
  }
}

/// 占位小时项 - 对齐 HourPlaceholder(45dp 宽)
class _HourPlaceholder extends StatelessWidget {
  final String time;
  final bool selected;
  const _HourPlaceholder({required this.time, required this.selected});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 45,
      height: double.infinity,
      decoration: BoxDecoration(
        color: selected ? _paleBlue : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(time,
              style: TextStyle(
                  color: selected ? _designBlue : _secondaryText,
                  fontSize: 9)),
          const SizedBox(height: 35),
          const Text('--°',
              style: TextStyle(
                  color: _pageText,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
          const Text('--',
              style: TextStyle(color: _secondaryText, fontSize: 8)),
        ],
      ),
    );
  }
}

/// 小时项 - 对齐 HourWeatherItem(47dp 宽)
class _HourWeatherItem extends StatelessWidget {
  final String time;
  final String weatherText;
  final String temp;
  final String windScale;
  final bool selected;
  const _HourWeatherItem({
    required this.time,
    required this.weatherText,
    required this.temp,
    required this.windScale,
    required this.selected,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 47,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: selected ? _paleBlue : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(children: [
        Text(time,
            style: TextStyle(
                color: selected ? _designBlue : _secondaryText,
                fontSize: 9,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Image.asset(_dayIcon(weatherText),
              width: 29, height: 29),
        ),
        Text('$temp°',
            style: const TextStyle(
                color: _pageText,
                fontSize: 14,
                fontWeight: FontWeight.bold)),
        Text(weatherText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: _secondaryText, fontSize: 8)),
        Text('$windScale级',
            style: const TextStyle(color: _secondaryText, fontSize: 8)),
      ]),
    );
  }
}

/// 对齐 Android toHourLabel：从 ISO 时间提取 HH:mm
String _hourLabel(String fxTime) {
  final match = RegExp(r'(?:^|[T\s])(\d{2}:\d{2})').firstMatch(fxTime);
  return match?.group(1) ?? '--:--';
}

/// 对齐 currentHourLabel：当前时间 + offset 小时，格式 HH:mm
String _currentHourLabel(int offset) {
  final time =
      DateTime.now().add(Duration(hours: offset));
  return _formatHourMinute(time);
}

/// 对齐 WeatherUtils.getWeatherDayIcon：晴→sun，阴/多云→cloudy，
/// 雷→rain(原代码注释掉了 thunderstorm，保真复用 rain)，雨→rain，默认 sun
String _dayIcon(String weatherText) {
  if (weatherText.contains('晴')) return AppAssets.weatherDaySun;
  if (weatherText.contains('阴') || weatherText.contains('多云')) {
    return AppAssets.weatherDayCloudy;
  }
  if (weatherText.contains('雷')) return AppAssets.weatherDayRain;
  if (weatherText.contains('雨')) return AppAssets.weatherDayRain;
  return AppAssets.weatherDaySun;
}

// ====== 长途规划入口卡 - 对齐 LongTripHomeEntryCard ======
class _LongTripEntryCard extends StatelessWidget {
  final EdgeInsetsGeometry margin;
  final VoidCallback onTap;
  const _LongTripEntryCard({required this.margin, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        constraints: const BoxConstraints(minHeight: 80),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(children: [
          Image.asset(AppAssets.zxxtqLongTripRoute,
              width: 56, height: 56),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('长途规划',
                    style: TextStyle(
                        color: Color(0xFF147FE4),
                        fontSize: 18,
                        fontWeight: FontWeight.w600)),
                Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text('规划长途行程，查看沿途天气',
                      maxLines: 1,
                      style:
                          TextStyle(color: Color(0xFF596579), fontSize: 11)),
                ),
              ],
            ),
          ),
          const Text('›',
              style: TextStyle(
                  color: Color(0xFF147FE4),
                  fontSize: 28,
                  fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}

// ====== 15日天气卡 - 对齐 FifteenDayWeatherScreen(按需求仅保留列表) ======
class _FifteenDayCard extends StatelessWidget {
  final List<DailyWeather> daily;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final EdgeInsetsGeometry margin;
  const _FifteenDayCard({
    required this.daily,
    required this.selectedIndex,
    required this.onSelected,
    required this.margin,
  });
  @override
  Widget build(BuildContext context) {
    return _WeatherCardShell(
      margin: margin,
      child: Column(children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, right: 8, top: 10, bottom: 8),
          child: Row(children: [
            Text('15日天气',
                style: TextStyle(
                    color: _pageText,
                    fontSize: 19,
                    fontWeight: FontWeight.bold)),
            Spacer(),
          ]),
        ),
        if (daily.isEmpty)
          const SizedBox(
            height: 180,
            width: double.infinity,
            child: Center(
              child: Text('天气数据加载中',
                  style: TextStyle(color: _secondaryText, fontSize: 13)),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: _FifteenDayList(
              forecasts: daily.take(15).toList(),
              selectedIndex: selectedIndex,
              onSelected: onSelected,
            ),
          ),
      ]),
    );
  }
}

/// 15日列表 - 对齐 FifteenDayListView
class _FifteenDayList extends StatelessWidget {
  final List<DailyWeather> forecasts;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  const _FifteenDayList({
    required this.forecasts,
    required this.selectedIndex,
    required this.onSelected,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(forecasts.length, (index) {
        final forecast = forecasts[index];
        final selected = index == selectedIndex;
        final row = GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onSelected(index),
          child: Container(
            height: 48,
            color: selected ? const Color(0xFFD8F2FF) : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(children: [
              SizedBox(
                width: 40,
                child: Text(
                  index == 0
                      ? '今天'
                      : DateUtil.getWeekDay(index, forecast.fxDate),
                  style: TextStyle(
                      color: selected
                          ? const Color(0xFF164B63)
                          : _pageText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(
                width: 57,
                child: Text(_monthDay(forecast.fxDate),
                    style: const TextStyle(
                        color: _secondaryText, fontSize: 13)),
              ),
              Image.asset(_dayIcon(forecast.textDay),
                  width: 28, height: 28),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(forecast.textDay,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(color: _pageText, fontSize: 14)),
              ).expanded(),
              Text('${forecast.tempMin}°-${forecast.tempMax}°',
                  style: const TextStyle(
                      color: _pageText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ]),
          ),
        );
        return Column(children: [
          row,
          if (index != forecasts.length - 1)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              height: 1,
              color: const Color(0xFFF0F4FA),
            ),
        ]);
      }),
    );
  }
}

/// 对齐 Android toMonthDay："yyyy-MM-dd" → "MM/dd"
String _monthDay(String date) {
  final parts = date.split('-');
  if (parts.length == 3) return '${parts[1]}/${parts[2]}';
  return date;
}

// ====== 空气质量卡 - 对齐 AirQualityScreen ======
class _AirQualityCard extends StatelessWidget {
  final AirQuality? air;
  final EdgeInsetsGeometry margin;
  const _AirQualityCard({required this.air, required this.margin});
  @override
  Widget build(BuildContext context) {
    final pollutants = <_Pollutant>[
      _Pollutant('PM2.5', _orDash(air?.pm2p5)),
      _Pollutant('PM10', _orDash(air?.pm10)),
      _Pollutant('SO₂', _orDash(air?.so2)),
      _Pollutant('NO₂', _orDash(air?.no2)),
      _Pollutant('O₃', _orDash(air?.o3)),
      _Pollutant('CO', _orDash(air?.co)),
    ];
    return _WeatherCardShell(
      margin: margin,
      child: Column(children: [
        const _CardTitle(title: '空气质量'),
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 12),
          child: Row(children: [
            SizedBox(
              width: 103,
              height: 82,
              child: Stack(children: [
                Positioned.fill(
                  child: CustomPaint(painter: _AirGaugePainter(air?.aqi ?? 0)),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 17),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${air?.aqi ?? 0}',
                            style: const TextStyle(
                                color: _pageText,
                                fontSize: 22,
                                fontWeight: FontWeight.w500)),
                        Text(air?.category ?? '--',
                            style: const TextStyle(
                                color: _pageText, fontSize: 9)),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(_airDescription(air),
                        style: const TextStyle(
                            color: _secondaryText, fontSize: 7)),
                  ),
                ),
              ]),
            ),
            Container(
              width: 1,
              height: 68,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              color: _dividerBlue,
            ),
            Expanded(
              child: Column(
                children: [
                  for (var row = 0; row < 2; row++)
                    Padding(
                      padding: EdgeInsets.only(bottom: row == 0 ? 10 : 0),
                      child: Row(children: [
                        for (var col = 0; col < 3; col++)
                          _PollutantValue(
                            name: pollutants[row * 3 + col].name,
                            value: pollutants[row * 3 + col].value,
                          ).expanded(),
                      ]),
                    ),
                ],
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

/// 污染物键值对 - 对齐 Android pollutants 组合
class _Pollutant {
  final String name;
  final String value;
  const _Pollutant(this.name, this.value);
}

/// 对齐 AirGauge：155° 起、230° 扫描弧，底色/进度绿，进度最小 8%
class _AirGaugePainter extends CustomPainter {
  final int value;
  const _AirGaugePainter(this.value);
  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 8.0;
    final progress =
        (value.clamp(0, 300) / 300).clamp(0.08, 1.0);
    final rect = Rect.fromLTWH(
        stroke, stroke, size.width - stroke * 2, size.width - stroke * 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, _radians(155), _radians(230), false,
        paint..color = const Color(0xFFDDF5EA));
    canvas.drawArc(rect, _radians(155), _radians(230 * progress), false,
        paint..color = const Color(0xFF4FD98E));
  }

  double _radians(double degrees) => degrees * 3.141592653589793 / 180;

  @override
  bool shouldRepaint(covariant _AirGaugePainter oldDelegate) =>
      oldDelegate.value != value;
}

/// 污染物条目 - 对齐 PollutantValue
class _PollutantValue extends StatelessWidget {
  final String name;
  final String value;
  const _PollutantValue({required this.name, required this.value});
  @override
  Widget build(BuildContext context) {
    // 对齐 Android：(value/100 ?: 0.2f).coerceIn(0.15, 0.85)，解析失败回退 0.2
    final parsed = double.tryParse(value);
    final fraction = parsed == null
        ? 0.2
        : (parsed / 100).clamp(0.15, 0.85);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$name  $value',
            maxLines: 1,
            style: const TextStyle(color: Color(0xFF596579), fontSize: 8)),
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Container(
            height: 2,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F3EB),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: fraction,
              child: Container(color: _healthyGreen),
            ),
          ),
        ),
      ],
    );
  }
}

String _orDash(String? value) =>
    (value == null || value.isEmpty) ? '--' : value;

/// 对齐 airDescription
String _airDescription(AirQuality? air) {
  switch (air?.category) {
    case '优':
      return '空气清新，快去呼吸吧';
    case '良':
      return '空气良好，适宜外出';
    case null:
    case '':
      return '空气数据加载中';
    default:
      return '外出请注意适当防护';
  }
}

// ====== 生活建议卡 - 对齐 LifeIndexScreen ======
class _LifeIndexCard extends StatelessWidget {
  final DailyWeather? now;
  final EdgeInsetsGeometry margin;
  const _LifeIndexCard({required this.now, required this.margin});
  @override
  Widget build(BuildContext context) {
    final max = (int.tryParse(now?.tempMax ?? '') ?? 26).toString();
    final min = (int.tryParse(now?.tempMin ?? '') ?? 18).toString();
    final humidity = (int.tryParse(now?.humidity ?? '') ?? 50).toString();
    final condition = now?.textDay ?? '';
    final uv = (int.tryParse(now?.uvIndex ?? '') ?? 3).toString();
    final items = [
      _LifeAdvice(
        icon: AppAssets.zxxtqLifeClothes,
        title: '穿衣',
        value: _generateDressing(max, min),
        note: (int.tryParse(min) ?? 18) < 20 ? '早晚微凉' : '体感舒适',
      ),
      _LifeAdvice(
        icon: AppAssets.zxxtqLifeUv,
        title: '紫外线',
        value: _generateUvDescription(uv),
        note: _generateUv(uv),
      ),
      _LifeAdvice(
        icon: AppAssets.zxxtqLifeCar,
        title: '洗车',
        value: _generateCarWash(condition, now?.precip ?? ''),
        note: condition.contains('雨') ? '注意降雨' : '未来无雨',
      ),
      _LifeAdvice(
        icon: AppAssets.zxxtqLifeSport,
        title: '运动',
        value: _generateSport(max, min, condition, humidity),
        note: '适宜运动',
      ),
    ];
    return _WeatherCardShell(
      margin: margin,
      child: Column(children: [
        const _CardTitle(title: '生活建议'),
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, bottom: 9),
          child: Row(children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(width: 4),
              _LifeAdviceItem(item: items[i]).expanded(),
            ],
          ]),
        ),
      ]),
    );
  }
}

class _LifeAdvice {
  final String icon;
  final String title;
  final String value;
  final String note;
  const _LifeAdvice({
    required this.icon,
    required this.title,
    required this.value,
    required this.note,
  });
}

/// 对齐 LifeAdviceItem：58dp 高浅蓝胶囊
class _LifeAdviceItem extends StatelessWidget {
  final _LifeAdvice item;
  const _LifeAdviceItem({required this.item});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4FF),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(children: [
        Image.asset(item.icon, width: 34, height: 38),
        Padding(
          padding: const EdgeInsets.only(left: 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.title,
                  maxLines: 1,
                  style: const TextStyle(
                      color: _secondaryText, fontSize: 7)),
              Text(item.value,
                  maxLines: 1,
                  style: const TextStyle(
                      color: _pageText,
                      fontSize: 8,
                      fontWeight: FontWeight.w600)),
              Text(item.note,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: _secondaryText, fontSize: 6)),
            ],
          ),
        ),
      ]),
    );
  }
}

// ====== 生活指数生成 - 对齐 TravelViewModel 中的纯函数 ======

/// 穿衣指数：对齐 generateDressing
String _generateDressing(String tempMax, String tempMin) {
  final maxTemp = int.tryParse(tempMax) ?? 0;
  final minTemp = int.tryParse(tempMin) ?? 0;
  final avgTemp = (maxTemp + minTemp) ~/ 2;
  if (avgTemp >= 30) return '短袖';
  if (avgTemp >= 22) return 'T恤';
  if (avgTemp >= 15) return '夹克';
  if (avgTemp >= 8) return '毛衣';
  return '棉服';
}

/// 紫外线描述：对齐 generateUvDescription
String _generateUvDescription(String uvIndexStr) {
  final uv = int.tryParse(uvIndexStr);
  if (uv == null) return '较弱';
  if (uv <= 2) return '最弱';
  if (uv <= 5) return '中等';
  if (uv <= 7) return '强';
  if (uv <= 10) return '很强';
  return '极强';
}

/// 紫外线防护建议：对齐 generateUv
String _generateUv(String uvIndexStr) {
  final uv = int.tryParse(uvIndexStr);
  if (uv == null) return '无需防护';
  if (uv <= 2) return '无需防护';
  if (uv <= 5) return '适当防护';
  if (uv <= 7) return '注意防晒';
  if (uv <= 10) return '避免暴晒';
  return '务必防晒';
}

/// 洗车指数：对齐 generateCarWash
String _generateCarWash(String weatherCondition, String precip) {
  final precipitation = double.tryParse(precip) ?? 0.0;
  if (weatherCondition.contains('雨') || weatherCondition.contains('雪')) {
    return '不适宜';
  }
  if (weatherCondition.contains('沙尘') || weatherCondition.contains('霾')) {
    return '不适宜';
  }
  if (precipitation > 0.5) return '不适宜';
  if (weatherCondition.contains('多云') || weatherCondition.contains('阴')) {
    return '较适宜';
  }
  if (weatherCondition.contains('晴') || weatherCondition.contains('少云')) {
    return '适宜';
  }
  return '适宜';
}

/// 运动指数：对齐 generateSport
String _generateSport(
    String tempMax, String tempMin, String weatherCondition, String humidity) {
  final maxTemp = int.tryParse(tempMax) ?? 20;
  final minTemp = int.tryParse(tempMin) ?? 15;
  final humidityValue = int.tryParse(humidity) ?? 50;
  final avgTemp = (maxTemp + minTemp) ~/ 2;
  if (weatherCondition.contains('雨') || weatherCondition.contains('雪')) {
    return '不适宜';
  }
  if (weatherCondition.contains('雾') || weatherCondition.contains('霾')) {
    return '不适宜';
  }
  if (avgTemp > 35 || avgTemp < -5) return '不适宜';
  if (avgTemp > 32 || avgTemp < 0) return '较不适宜';
  if (humidityValue > 85) return '较不适宜';
  if (avgTemp >= 15 && avgTemp <= 25 && humidityValue >= 40 && humidityValue <= 70) {
    return '适宜';
  }
  return '较适宜';
}
