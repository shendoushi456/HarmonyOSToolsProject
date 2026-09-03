// NongyeFragment → ZyytAgricultureScreen Flutter 迁移。
// 数据由 AgricultureViewModel 提供，UI 可独立替换。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_assets.dart';
import '../../../router/route_names.dart';
import '../../weather/models/hourly_weather.dart';
import '../../weather/models/weather_model.dart';
import '../../weather/models/weather_warning.dart';
import '../../weather/viewmodels/toolbox_weather_view_model.dart';
import '../viewmodels/agriculture_view_model.dart';
import 'crop_category_page.dart';

const _agriBackground = Color(0xFFE4F6FF);
const _agriText = Color(0xFF1E1E1E);

class AgriculturePage extends ConsumerWidget {
  const AgriculturePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(agricultureViewModelProvider);
    ref.listen<String?>(
      toolboxWeatherPageViewModelProvider.select((item) => item.city?.cityName),
      (previous, city) {
        if (city != null && city != previous) {
          ref.read(agricultureViewModelProvider.notifier).loadForCity(city);
        }
      },
    );
    return Scaffold(
      backgroundColor: _agriBackground,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: const Color(0xFF45B4EC),
          onRefresh: () =>
              ref.read(agricultureViewModelProvider.notifier).load(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              _PageTitle(onSettings: () => context.push(RoutePaths.setting)),
              _PrecipitationCard(hourly: state.hourlyWeather),
              const Padding(
                padding: EdgeInsets.only(left: 20, top: 27),
                child: Text('农业气象指标',
                    style: TextStyle(
                        color: _agriText,
                        fontSize: 18,
                        fontWeight: FontWeight.w600)),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 3, 20, 14),
                child: Text('关键田间环境实时监测',
                    style: TextStyle(color: _agriText, fontSize: 12)),
              ),
              _Metrics(
                  today: state.forecasts.isEmpty ? null : state.forecasts.first,
                  hourly: state.hourlyWeather),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) =>
                        CropCategoryPage(warnings: state.warnings))),
                child: Container(
                  height: 126,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  clipBehavior: Clip.antiAlias,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  child: Image.asset(AppAssets.zyytAgriCropBanner,
                      fit: BoxFit.cover),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(28, 27, 20, 14),
                child: Text('重点高危预警',
                    style: TextStyle(
                        color: _agriText,
                        fontSize: 18,
                        fontWeight: FontWeight.w600)),
              ),
              _Warnings(warnings: state.warnings),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 26, 20, 14),
                child: Text('15日农业天气',
                    style: TextStyle(
                        color: _agriText,
                        fontSize: 18,
                        fontWeight: FontWeight.w600)),
              ),
              _ForecastCard(forecasts: state.forecasts, loading: state.loading),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageTitle extends StatelessWidget {
  final VoidCallback onSettings;
  const _PageTitle({required this.onSettings});
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 72,
        child: Stack(children: [
          const Center(
              child: Text('农业预警',
                  style: TextStyle(
                      color: _agriText,
                      fontSize: 23,
                      fontWeight: FontWeight.w500))),
          Positioned(
              right: 12,
              top: 12,
              child: IconButton(
                  onPressed: onSettings,
                  icon: Image.asset(AppAssets.agricultureSetting,
                      width: 26, height: 26))),
        ]),
      );
}

class _PrecipitationCard extends StatelessWidget {
  final List<HourlyWeather> hourly;
  const _PrecipitationCard({required this.hourly});
  @override
  Widget build(BuildContext context) {
    final samples = hourly.take(24).toList();
    final total = samples.fold<double>(
        0, (sum, item) => sum + (double.tryParse(item.precipitation) ?? 0));
    final peak = samples.fold<int>(
        0,
        (value, item) =>
            value > (int.tryParse(item.precipitationProbability) ?? 0)
                ? value
                : (int.tryParse(item.precipitationProbability) ?? 0));
    final values = samples
        .map((item) => (double.tryParse(item.precipitationProbability) ?? 0)
            .clamp(0, 100)
            .toDouble())
        .toList();
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      elevation: 3,
      color: const Color(0xFFF1FAFF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: SizedBox(
        height: 190,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('24小时降水预报',
                style: TextStyle(
                    color: _agriText,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(
                samples.isEmpty
                    ? '暂无24小时降水预报'
                    : '预计累计${total.toStringAsFixed(1)}mm，降水概率峰值$peak%',
                style: const TextStyle(color: Color(0xFF676767), fontSize: 12)),
            const SizedBox(height: 8),
            Expanded(
                child: samples.isEmpty
                    ? const Center(
                        child: Text('暂无数据',
                            style: TextStyle(
                                color: Color(0xFF8A8A8A), fontSize: 12)))
                    : _RainWave(values: values)),
          ]),
        ),
      ),
    );
  }
}

class _RainWave extends StatelessWidget {
  final List<double> values;
  const _RainWave({required this.values});
  @override
  Widget build(BuildContext context) => Column(children: [
        Expanded(child: CustomPaint(painter: _RainPainter(values))),
        const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('0点', style: TextStyle(color: _agriText, fontSize: 10)),
          Text('12点', style: TextStyle(color: _agriText, fontSize: 10)),
          Text('0点', style: TextStyle(color: _agriText, fontSize: 10))
        ]),
      ]);
}

class _RainPainter extends CustomPainter {
  final List<double> values;
  const _RainPainter(this.values);
  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxValue = values.reduce((a, b) => a > b ? a : b).clamp(1, 100);
    final points = List.generate(
        values.length,
        (i) => Offset(
            size.width * i / (values.length - 1).clamp(1, values.length),
            size.height - values[i] / maxValue * (size.height - 3)));
    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];
      final middle = (previous.dx + current.dx) / 2;
      line.cubicTo(
          middle, previous.dy, middle, current.dy, current.dx, current.dy);
    }
    final fill = Path.from(line)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();
    canvas.drawPath(fill, Paint()..color = const Color(0x664FB9EE));
    canvas.drawPath(
        line,
        Paint()
          ..color = const Color(0xFF45B4EC)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_RainPainter old) => old.values != values;
}

class _Metrics extends StatelessWidget {
  final DailyWeather? today;
  final List<HourlyWeather> hourly;
  const _Metrics({this.today, required this.hourly});
  @override
  Widget build(BuildContext context) {
    final daylight = _daylight(today?.sunrise, today?.sunset) ?? '1.2';
    final wind = hourly
        .map((item) => int.tryParse(item.windScale.split('-').first) ?? 0)
        .fold<int>(0, (max, value) => value > max ? value : max);
    final data = [
      _Metric('日照时数', '${daylight}h/偏少', '较常年少3.6h', AppAssets.zyytAgriSunHours,
          const Color(0xFFFFF4D8), const Color(0xFFFFB900)),
      _Metric(
          '阵风风力',
          '${wind > 0 ? wind : (today?.windScaleDay.isNotEmpty == true ? today!.windScaleDay : '7')}级',
          '16–18时增强',
          AppAssets.zyytAgriGust,
          const Color(0xFFCDE9F9),
          const Color(0xFF2B8EC8)),
      _Metric(
          '紫外线',
          '${today?.uvIndex.isNotEmpty == true ? today!.uvIndex : '6'}中等',
          '紫外线强度＞多年同期平均水平',
          AppAssets.zyytAgriUv,
          const Color(0xFFFFD3C9),
          const Color(0xFFFF1C1C)),
      _Metric(
          '相对湿度',
          '${today?.humidity.isNotEmpty == true ? today!.humidity : '48'}%',
          '接近常年同期',
          AppAssets.zyytAgriHumidity,
          const Color(0xFFBEE7FA),
          const Color(0xFF313CD0)),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: data.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 10,
            mainAxisExtent: 96),
        itemBuilder: (_, index) => _MetricCard(data[index]),
      ),
    );
  }
}

class _Metric {
  final String title, value, detail, icon;
  final Color background, accent;
  const _Metric(this.title, this.value, this.detail, this.icon, this.background,
      this.accent);
}

class _MetricCard extends StatelessWidget {
  final _Metric item;
  const _MetricCard(this.item);
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: item.background, borderRadius: BorderRadius.circular(10)),
      child: Stack(children: [
        Padding(
            padding: const EdgeInsets.only(right: 28),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.title,
                  style: const TextStyle(
                      color: _agriText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 7),
              Text(item.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: item.accent,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(item.detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: item.accent, fontSize: 9))
            ])),
        Positioned(
            right: 0,
            top: 0,
            child: Image.asset(item.icon, width: 30, height: 30))
      ]));
}

class _Warnings extends StatelessWidget {
  final List<WeatherWarning> warnings;
  const _Warnings({required this.warnings});
  @override
  Widget build(BuildContext context) {
    final data = warnings
        .where((item) => item.messageType.toLowerCase() != 'cancel')
        .take(2)
        .map(_Warning.fromApi)
        .toList();
    if (data.isEmpty) {
      data.addAll(const [
        _Warning('干热风', '仅严重影响小麦灌浆，造成籽粒干瘪减产',
            '田间及时灌溉补水，喷施叶面肥；麦田提前疏通通风渠，降低田间温度。', Color(0xFFFFBD97)),
        _Warning('干旱', '全品类粮食缺水枯死、无法播种',
            '铺设滴灌 / 喷灌设施，地膜覆盖保墒；缺水地块浅耕松土，减少土壤水分蒸发。', Color(0xFFB8967F))
      ]);
    }
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
            children: data
                .map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _WarningCard(item)))
                .toList()));
  }
}

class _Warning {
  final String title, danger, action;
  final Color color;
  const _Warning(this.title, this.danger, this.action, this.color);
  factory _Warning.fromApi(WeatherWarning warning) => _Warning(
      warning.eventName.isEmpty ? warning.headline : warning.eventName,
      warning.description.isEmpty ? warning.criteria : warning.description,
      warning.instruction.isEmpty ? '请根据气象预警及时采取防护措施。' : warning.instruction,
      _warningColor(warning));
}

class _WarningCard extends StatelessWidget {
  final _Warning item;
  const _WarningCard(this.item);
  @override
  Widget build(BuildContext context) => Card(
      color: const Color(0xFFF1FAFF),
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 12, 13, 14),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                  child: Text(item.title,
                      style: const TextStyle(
                          color: _agriText,
                          fontSize: 16,
                          fontWeight: FontWeight.w600))),
              Container(
                  width: 26,
                  height: 26,
                  decoration:
                      BoxDecoration(color: item.color, shape: BoxShape.circle))
            ]),
            const SizedBox(height: 9),
            Text('危害：${item.danger}',
                style: const TextStyle(
                    color: Color(0xFF565656), fontSize: 12, height: 1.5)),
            const SizedBox(height: 3),
            Text('预防措施：${item.action}',
                style: TextStyle(color: item.color, fontSize: 12, height: 1.5))
          ])));
}

class _ForecastCard extends StatelessWidget {
  final List<DailyWeather> forecasts;
  final bool loading;
  const _ForecastCard({required this.forecasts, required this.loading});
  @override
  Widget build(BuildContext context) {
    final list = forecasts.take(15).toList();
    return Container(
      height: 300,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(12, 17, 12, 10),
      decoration: BoxDecoration(
          color: const Color(0xFF67D1F5),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Color(0x33000000), blurRadius: 4)
          ]),
      clipBehavior: Clip.antiAlias,
      child: list.isEmpty
          ? Center(
              child: Text(loading ? '正在加载十五日农业天气…' : '暂无预报数据',
                  style: const TextStyle(color: Colors.white)))
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: list.length * _agriForecastDayWidth,
                child: Stack(children: [
                  Positioned.fill(
                      child: CustomPaint(
                          painter: _ForecastLinesAll(
                    highs: list
                        .map((e) => double.tryParse(e.tempMax) ?? 0)
                        .toList(),
                    lows: list
                        .map((e) => double.tryParse(e.tempMin) ?? 0)
                        .toList(),
                  ))),
                  Row(
                      children: List.generate(list.length, (index) {
                    final item = list[index];
                    return SizedBox(
                        width: _agriForecastDayWidth,
                        child: Column(children: [
                          Text(index == 0 ? '今天' : _week(item.fxDate),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12)),
                          const SizedBox(height: 9),
                          Text(_monthDay(item.fxDate),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 11)),
                          const SizedBox(height: 18),
                          Icon(_weatherIcon(item.textDay),
                              color: Colors.white, size: 25),
                          Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(item.textDay,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 11))),
                          Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text('${item.tempMax}°',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 13))),
                          const Expanded(child: SizedBox()),
                          Text('${item.tempMin}°',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12))
                        ]));
                  })),
                ]),
              ),
            ),
    );
  }
}

const _agriForecastDayWidth = 52.0;

class _ForecastLinesAll extends CustomPainter {
  final List<double> highs, lows;
  const _ForecastLinesAll({required this.highs, required this.lows});
  @override
  void paint(Canvas canvas, Size size) {
    if (highs.isEmpty) return;
    void drawSeries(
        List<double> values, double top, double bottom, Color color) {
      final minValue = values.reduce((a, b) => a < b ? a : b);
      final maxValue = values.reduce((a, b) => a > b ? a : b);
      final range = (maxValue - minValue).abs() < 1 ? 1 : maxValue - minValue;
      double yFor(int index) => maxValue == minValue
          ? (top + bottom) / 2
          : bottom - (values[index] - minValue) / range * (bottom - top);
      final path = Path();
      for (var i = 0; i < values.length; i++) {
        final point = Offset(
            i * _agriForecastDayWidth + _agriForecastDayWidth / 2, yFor(i));
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
        canvas.drawCircle(point, 2.2, Paint()..color = color);
      }
      canvas.drawPath(
          path,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.3);
    }

    // These clip regions are the spaces between the temperature labels.  The
    // painter lives inside the same scrollable content as the day columns, so
    // it cannot drift when the forecast is moved horizontally.
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 124, size.width, 39));
    drawSeries(highs, 127, 160, const Color(0xFFFFA012));
    canvas.restore();

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 187, size.width, 47));
    drawSeries(lows, 190, 230, const Color(0xFF3178FF));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ForecastLinesAll oldDelegate) =>
      oldDelegate.highs != highs || oldDelegate.lows != lows;
}

String? _daylight(String? sunrise, String? sunset) {
  final start = _minutes(sunrise);
  final end = _minutes(sunset);
  if (start == null || end == null || end < start) return null;
  final value = (end - start) / 60;
  return value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);
}

int? _minutes(String? value) {
  final parts = value?.split(':');
  if (parts == null || parts.length != 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  return hour == null || minute == null ? null : hour * 60 + minute;
}

Color _warningColor(WeatherWarning warning) =>
    warning.red != null && warning.green != null && warning.blue != null
        ? Color.fromARGB(255, warning.red!, warning.green!, warning.blue!)
        : {
              'red': const Color(0xFFFF4B4B),
              'orange': const Color(0xFFFF9145),
              'yellow': const Color(0xFFFFCC20),
              'blue': const Color(0xFF4D8DA4)
            }[warning.colorCode.toLowerCase()] ??
            const Color(0xFFFF9145);
String _monthDay(String value) {
  final parts = value.split('-');
  return parts.length == 3 ? '${parts[1]}/${parts[2]}' : value;
}

String _week(String value) {
  final date = DateTime.tryParse(value);
  return date == null
      ? value
      : const ['周一', '周二', '周三', '周四', '周五', '周六', '周日'][date.weekday - 1];
}

IconData _weatherIcon(String text) => text.contains('雷') || text.contains('雨')
    ? Icons.thunderstorm
    : text.contains('雾') || text.contains('霾')
        ? Icons.foggy
        : text.contains('云') || text.contains('阴')
            ? Icons.cloud
            : Icons.wb_sunny;
