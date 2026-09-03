import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/utils/date_util.dart';
import '../../../router/route_names.dart';
import '../models/weather_model.dart';
import '../viewmodels/toolbox_weather_view_model.dart';
import '../viewmodels/weather_view_model.dart';

/// toolbox_c WeatherFragment/WeatherChildFragment 的展示层；数据由现有 Repository/VM 提供。
class ToolboxWeatherPage extends ConsumerStatefulWidget {
  const ToolboxWeatherPage({super.key});
  @override
  ConsumerState<ToolboxWeatherPage> createState() => _ToolboxWeatherPageState();
}

class _ToolboxWeatherPageState extends ConsumerState<ToolboxWeatherPage> {
  DailyWeather? selected;
  @override
  Widget build(BuildContext context) {
    final page = ref.watch(toolboxWeatherPageViewModelProvider);
    final state = ref.watch(weatherViewModelProvider);
    ref.listen(toolboxWeatherPageViewModelProvider.select((s) => s.city),
        (_, city) {
      if (city != null)
        ref.read(weatherViewModelProvider.notifier).loadData(city);
    });
    ref.listen(weatherViewModelProvider.select((s) => s.weather), (a, b) {
      if (a != b && mounted) setState(() => selected = null);
    });
    if (page.isLoading || page.city == null)
      return const Scaffold(
          backgroundColor: _bg,
          body: Center(child: CircularProgressIndicator()));
    final daily = state.weather?.daily ?? const <DailyWeather>[];
    final w = selected ?? state.today;
    return Scaffold(
        backgroundColor: _bg,
        body: Stack(children: [
          Positioned.fill(
              child: Image.asset(AppAssets.zyytHomeClouds,
                  fit: BoxFit.cover, alignment: Alignment.topCenter)),
          SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 88),
                  child: Column(children: [
                    _Title(city: _city(state.cityName), onTap: _selectCity),
                    _WeatherCard(weather: w),
                    const SizedBox(height: 29),
                    _Metrics(weather: w),
                    const SizedBox(height: 20),
                    _LongTrip(onTap: () => context.push(RoutePaths.longTrip)),
                    const SizedBox(height: 30),
                    _Trend(daily: daily)
                  ]))),
          if (state.isLoading && state.weather == null)
            const Positioned.fill(
                child: Center(child: CircularProgressIndicator()))
        ]));
  }

  String _city(String s) => s.isEmpty ? '北京市' : (s.endsWith('市') ? s : '$s市');
  Future<void> _selectCity() async {
    final changed = await context.push<bool>(RoutePaths.citySelect);
    if (changed == true && mounted)
      await ref.read(toolboxWeatherPageViewModelProvider.notifier).loadCity();
  }
}

const _bg = Color(0xFFE4F6FF);

class _Title extends StatelessWidget {
  final String city;
  final VoidCallback onTap;
  const _Title({required this.city, required this.onTap});
  @override
  Widget build(BuildContext c) => GestureDetector(
      onTap: onTap,
      child: SizedBox(
          height: 72,
          width: double.infinity,
          child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Text(city,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Color(0xFF1E1E1E),
                      fontSize: 23,
                      fontWeight: FontWeight.w600)))));
}

class _WeatherCard extends StatelessWidget {
  final DailyWeather? weather;
  const _WeatherCard({this.weather});
  @override
  Widget build(BuildContext c) {
    final hi = weather?.tempMax.isNotEmpty == true ? weather!.tempMax : '28';
    final lo = weather?.tempMin.isNotEmpty == true ? weather!.tempMin : '16';
    final t = weather?.textDay.isNotEmpty == true ? weather!.textDay : '晴';
    return Card(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        elevation: 4,
        color: const Color(0xFF8FD7F7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: SizedBox(
            height: 116,
            child: Row(children: [
              Padding(
                  padding: const EdgeInsets.only(left: 27),
                  child: Image.asset(_icon(t), width: 78, height: 78)),
              const SizedBox(width: 30),
              Expanded(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Row(children: [
                      Text(hi,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 57, height: 1)),
                      const Text('°',
                          style: TextStyle(color: Colors.white, fontSize: 28)),
                      const SizedBox(width: 12),
                      Container(
                          width: 52,
                          height: 21,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4)),
                          child: Text(t,
                              style: const TextStyle(
                                  color: Color(0xFF46B9F2), fontSize: 14)))
                    ]),
                    Text('最高${hi}°C  ｜  最低${lo}°C',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14))
                  ])),
              const SizedBox(width: 18)
            ])));
  }
}

class _Metrics extends StatelessWidget {
  final DailyWeather? weather;
  const _Metrics({this.weather});
  @override
  Widget build(BuildContext c) {
    final uv = int.tryParse(weather?.uvIndex ?? '') ?? 0;
    final u = uv <= 2
        ? '最弱'
        : uv <= 4
            ? '较弱'
            : uv <= 6
                ? '中等'
                : uv <= 9
                    ? '强烈'
                    : '很强';
    final m = [
      [
        '湿度',
        '${weather?.humidity.isNotEmpty == true ? weather!.humidity : '79'}%',
        AppAssets.zyytMetricHumidity
      ],
      [
        '气压',
        '${weather?.pressure.isNotEmpty == true ? weather!.pressure : '1000'}hPa',
        AppAssets.zyytMetricPressure
      ],
      [
        '能见度',
        '${weather?.vis.isNotEmpty == true ? weather!.vis : '14'}公里',
        AppAssets.zyytMetricVisibility
      ],
      ['紫外线强度', u, AppAssets.zyytMetricUv],
      [
        '降雨量',
        '${weather?.precip.isNotEmpty == true ? weather!.precip : '0'}mm',
        AppAssets.zyytMetricRainfall
      ],
      [
        '风向',
        weather?.windDirDay.isNotEmpty == true ? weather!.windDirDay : '东北风',
        AppAssets.zyytMetricWindDirection
      ],
      [
        '风速',
        '${weather?.windSpeedDay.isNotEmpty == true ? weather!.windSpeedDay : '2.3'}km/h',
        AppAssets.zyytMetricWindSpeed
      ],
      [
        '风力',
        '${weather?.windScaleDay.isNotEmpty == true ? weather!.windScaleDay : '2'}级',
        AppAssets.zyytMetricWindForce
      ]
    ];
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(children: [
          for (var r = 0; r < 2; r++)
            Padding(
                padding: EdgeInsets.only(bottom: r == 0 ? 16 : 0),
                child: Row(children: [
                  for (var i = 0; i < 4; i++)
                    Expanded(
                        child: Padding(
                            padding: EdgeInsets.only(right: i == 3 ? 0 : 3),
                            child: _Metric(m[r * 4 + i])))
                ]))
        ]));
  }
}

class _Metric extends StatelessWidget {
  final List<String> x;
  const _Metric(this.x);
  @override
  Widget build(BuildContext c) => Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SizedBox(
          height: 101,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Image.asset(x[2], width: 24, height: 24),
            const SizedBox(height: 8),
            Text(x[0],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF616161), fontSize: 12)),
            const SizedBox(height: 4),
            Text(x[1],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: const Color(0xFF131415),
                    fontSize: x[1].length > 7 ? 10 : 12,
                    fontWeight: FontWeight.w500))
          ])));
}

class _LongTrip extends StatelessWidget {
  final VoidCallback onTap;
  const _LongTrip({required this.onTap});
  @override
  Widget build(BuildContext c) => GestureDetector(
      onTap: onTap,
      child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          height: 131,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                  image: AssetImage(AppAssets.zyytLongTripBanner),
                  fit: BoxFit.cover)),
          child: Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                  margin: const EdgeInsets.only(left: 27, bottom: 25),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8)),
                  child: const Text('点击规划',
                      style:
                          TextStyle(color: Color(0xFF0D1E33), fontSize: 9))))));
}

class _Trend extends StatelessWidget {
  final List<DailyWeather> daily;
  const _Trend({required this.daily});
  @override
  Widget build(BuildContext c) => Card(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      elevation: 4,
      color: const Color(0xFF8FD7F7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SizedBox(
          height: 297,
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(children: [
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    child: const Text('最近15天天气',
                        style: TextStyle(
                            color: Color(0xFF83D5FA),
                            fontSize: 16,
                            fontWeight: FontWeight.w500))),
                const SizedBox(height: 18),
                Expanded(
                    child: ClipRect(
                        child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                                width: 15 * _weatherDayWidth,
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                        child: CustomPaint(
                                            painter: _TemperatureLines(
                                                highs: List.generate(
                                                    15,
                                                    (i) => (int.tryParse(
                                                                i < daily.length
                                                                    ? daily[i]
                                                                        .tempMax
                                                                    : '') ??
                                                            28)
                                                        .toDouble()),
                                                lows: List.generate(
                                                    15,
                                                    (i) => (int.tryParse(
                                                                i < daily.length ? daily[i].tempMin : '') ??
                                                            16)
                                                        .toDouble())))),
                                    Row(
                                        children: List.generate(15, (i) {
                                      final w =
                                          i < daily.length ? daily[i] : null;
                                      final t = w?.textDay.isNotEmpty == true
                                          ? w!.textDay
                                          : '晴';
                                      final hi =
                                          int.tryParse(w?.tempMax ?? '') ?? 28;
                                      final lo =
                                          int.tryParse(w?.tempMin ?? '') ?? 16;
                                      return SizedBox(
                                          width: _weatherDayWidth,
                                          child: Column(children: [
                                            Text(
                                                i == 0
                                                    ? '今天'
                                                    : w == null
                                                        ? '—'
                                                        : DateUtil.getWeekDay(
                                                            i, w.fxDate),
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12)),
                                            const SizedBox(height: 17),
                                            Image.asset(_icon(t),
                                                width: 23, height: 23),
                                            const SizedBox(height: 17),
                                            Text('${hi}°C',
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12)),
                                            const SizedBox(height: 10),
                                            const Expanded(child: SizedBox()),
                                            const SizedBox(height: 2),
                                            Text('${lo}°C',
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12)),
                                            const SizedBox(height: 15),
                                            Text(t,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12))
                                          ]));
                                    }))
                                  ],
                                )))))
              ]))));
}

const _weatherDayWidth = 43.0;

class _TemperatureLines extends CustomPainter {
  final List<double> highs;
  final List<double> lows;
  const _TemperatureLines({required this.highs, required this.lows});
  @override
  void paint(Canvas canvas, Size size) {
    if (highs.isEmpty) return;
    // The values are deliberately drawn in the two gaps between the labels:
    // high-temperature line below its label, low-temperature line above it.
    // Keeping the ranges independent also prevents an extreme forecast from
    // reaching either text row.
    Path pathFor(List<double> values, double top, double bottom, Color color) {
      final minValue = values.reduce((a, b) => a < b ? a : b);
      final maxValue = values.reduce((a, b) => a > b ? a : b);
      final range = (maxValue - minValue).abs() < 1 ? 1 : maxValue - minValue;
      double yFor(int index) => maxValue == minValue
          ? (top + bottom) / 2
          : bottom - (values[index] - minValue) / range * (bottom - top);
      final path = Path();
      for (var i = 0; i < values.length; i++) {
        final x = i * _weatherDayWidth + _weatherDayWidth / 2;
        final y = yFor(i);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          final previousX = (i - 1) * _weatherDayWidth + _weatherDayWidth / 2;
          final previousY = yFor(i - 1);
          final middle = (previousX + x) / 2;
          path.cubicTo(middle, previousY, middle, y, x, y);
        }
        canvas.drawCircle(Offset(x, y), 2.4, Paint()..color = color);
      }
      return path;
    }

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 92, size.width, 33));
    canvas.drawPath(
        pathFor(highs, 95, 122, const Color(0xFFFFA012)),
        Paint()
          ..color = const Color(0xFFFFA012)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4);
    canvas.restore();

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 143, size.width, 35));
    canvas.drawPath(
        pathFor(lows, 146, 174, const Color(0xFF3178FF)),
        Paint()
          ..color = const Color(0xFF3178FF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TemperatureLines oldDelegate) =>
      oldDelegate.highs != highs || oldDelegate.lows != lows;
}

String _icon(String t) {
  if (t.contains('雷')) return AppAssets.zyytWeatherThunder;
  if (t.contains('雾') || t.contains('霾')) return AppAssets.zyytWeatherFog;
  if (t.contains('云') || t.contains('阴') || t.contains('雨') || t.contains('雪'))
    return AppAssets.zyytWeatherPartlyCloudy;
  return AppAssets.zyytWeatherSunny;
}
