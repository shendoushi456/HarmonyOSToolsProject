// NongyeFragment Flutter 视图。页面只消费 AgricultureViewModel，方便整体替换 UI。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_assets.dart';
import '../../weather/models/weather_model.dart';
import '../../weather/models/hourly_weather.dart';
import '../../weather/models/weather_warning.dart';
import '../../weather/viewmodels/toolbox_weather_view_model.dart';
import 'crop_category_page.dart';
import '../viewmodels/agriculture_view_model.dart';

const _pageBackground = Color(0xFF0A0D0E);

class AgriculturePage extends ConsumerWidget {
  const AgriculturePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(agricultureViewModelProvider);
    ref.listen<String?>(
      toolboxWeatherPageViewModelProvider
          .select((value) => value.city?.cityName),
      (previous, cityName) {
        if (cityName != null && cityName != previous) {
          ref.read(agricultureViewModelProvider.notifier).loadForCity(cityName);
        }
      },
    );
    final today = state.forecasts.isEmpty ? null : state.forecasts.first;
    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: const Color(0xFF1BCACD),
          onRefresh: () =>
              ref.read(agricultureViewModelProvider.notifier).load(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            children: [
              const SizedBox(height: 12),
              const Center(
                  child: Text('农业',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500))),
              const SizedBox(height: 22),
              if (state.cityName.isNotEmpty)
                Center(
                    child: Text('${state.cityName}农业气象',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12))),
              if (state.cityName.isNotEmpty) const SizedBox(height: 10),
              _PrecipitationCard(hourlyWeather: state.hourlyWeather),
              const SizedBox(height: 20),
              const Text('农业气象指标',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 3),
              const Text('关键田间环境实时监测',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
              const SizedBox(height: 16),
              _MetricGrid(today: today),
              const SizedBox(height: 16),
              GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) =>
                          CropCategoryPage(warnings: state.warnings))),
                  child: Image.asset(AppAssets.agricultureRecordBoard,
                      fit: BoxFit.fill)),
              const SizedBox(height: 25),
              _WarningCenter(warnings: state.warnings),
              const SizedBox(height: 30),
              const Center(
                  child: Text('十五日农业天气',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600))),
              const SizedBox(height: 28),
              _ForecastList(
                  forecasts: state.forecasts,
                  isLoading: state.loading,
                  errorMessage: state.errorMessage),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrecipitationCard extends StatelessWidget {
  final List<HourlyWeather> hourlyWeather;
  const _PrecipitationCard({required this.hourlyWeather});
  @override
  Widget build(BuildContext context) {
    final samples = hourlyWeather.take(24).toList();
    final precip = samples.fold<double>(
        0, (total, item) => total + (double.tryParse(item.precipitation) ?? 0));
    final peak = samples.fold<int>(
        0,
        (value, item) =>
            value > (int.tryParse(item.precipitationProbability) ?? 0)
                ? value
                : (int.tryParse(item.precipitationProbability) ?? 0));
    final bars = List<double>.generate(
        24,
        (index) => index < samples.length
            ? ((double.tryParse(samples[index].precipitationProbability) ?? 0) /
                    100)
                .clamp(0, 1)
                .toDouble()
            : 0.0);
    return Container(
      height: 251,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 13),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .3),
          borderRadius: BorderRadius.circular(15)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('24小时降水预警',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text('预计累计${precip.toStringAsFixed(1)}mm，降水概率峰值$peak%',
            style: const TextStyle(color: Colors.white, fontSize: 12)),
        const SizedBox(height: 17),
        Expanded(child: _RainBars(values: bars)),
      ]),
    );
  }
}

class _RainBars extends StatelessWidget {
  final List<double> values;
  const _RainBars({required this.values});
  @override
  Widget build(BuildContext context) => Column(children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: values
                .map(
                  (value) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1.2),
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Container(
                            height: double.infinity,
                            color: Colors.white.withValues(alpha: .94),
                          ),
                          FractionallySizedBox(
                            heightFactor: value,
                            child: Container(color: const Color(0xFF00CFD0)),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 6),
        const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('0点', style: TextStyle(color: Colors.white, fontSize: 11)),
          Text('12点', style: TextStyle(color: Colors.white, fontSize: 11)),
          Text('0点', style: TextStyle(color: Colors.white, fontSize: 11))
        ]),
      ]);
}

class _MetricGrid extends StatelessWidget {
  final DailyWeather? today;
  const _MetricGrid({this.today});
  @override
  Widget build(BuildContext context) {
    final daylight = _daylight(today?.sunrise, today?.sunset);
    final humidity = int.tryParse(today?.humidity ?? '');
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 15,
      childAspectRatio: 1.75,
      children: [
        _MetricCard(
            title: '日照时数',
            icon: AppAssets.agricultureSunshine,
            value: daylight == null ? '--' : '${daylight}h',
            unit: '/日照时长',
            description: daylight == null ? '日照数据暂缺' : '日出至日落预计${daylight}h',
            color: const Color(0xFFFFB400)),
        _MetricCard(
            title: '阵风风力',
            icon: AppAssets.agricultureWind,
            value: today?.windScaleDay.isNotEmpty == true
                ? today!.windScaleDay
                : '--',
            unit: '级',
            description:
                '${today?.windDirDay.isNotEmpty == true ? today!.windDirDay : '未来时段'}风力较强',
            color: const Color(0xFF169DD6)),
        _MetricCard(
            title: '紫外线',
            icon: AppAssets.agricultureUv,
            value: today?.uvIndex.isNotEmpty == true ? today!.uvIndex : '--',
            unit: _uvDescription(today?.uvIndex),
            description: '防护建议：${_uvAdvice(today?.uvIndex)}',
            color: const Color(0xFFF4AC1C)),
        _MetricCard(
            title: '相对湿度',
            icon: AppAssets.agricultureHumidity,
            value: today?.humidity.isNotEmpty == true ? today!.humidity : '--',
            unit: humidity == null ? '' : '%',
            description: humidity == null
                ? '湿度数据暂缺'
                : humidity < 40
                    ? '当前空气较干燥'
                    : humidity <= 70
                        ? '当前湿度较适宜'
                        : '当前空气较湿润',
            color: const Color(0xFF1CDBF4)),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title, icon, value, unit, description;
  final Color color;
  const _MetricCard(
      {required this.title,
      required this.icon,
      required this.value,
      required this.unit,
      required this.description,
      required this.color});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(11, 10, 8, 12),
        decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .3),
            borderRadius: BorderRadius.circular(10)),
        child: Stack(children: [
          Padding(
              padding: const EdgeInsets.only(right: 31),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(5)),
                        child: Text(title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500))),
                    const SizedBox(height: 7),
                    RichText(
                        text: TextSpan(children: [
                      TextSpan(
                          text: value,
                          style: TextStyle(
                              color: color,
                              fontSize: 19,
                              fontWeight: FontWeight.w500)),
                      TextSpan(
                          text: unit,
                          style: TextStyle(color: color, fontSize: 10))
                    ])),
                    const Spacer(),
                    Text(description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: color, fontSize: 10))
                  ])),
          Positioned(
              top: 0, right: 0, child: Image.asset(icon, width: 33, height: 33))
        ]),
      );
}

class _WarningCenter extends StatelessWidget {
  final List<WeatherWarning> warnings;
  const _WarningCenter({required this.warnings});
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('农业灾害预警中心',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('颜色与等级表示灾害影响程度',
            style: TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 14),
        if (warnings.isEmpty)
          const Text('当前暂无生效农业气象预警',
              style: TextStyle(color: Colors.white70, fontSize: 13))
        else
          ...warnings.map(_WarningCard.new),
      ]);
}

class _WarningCard extends StatefulWidget {
  final WeatherWarning warning;
  const _WarningCard(this.warning);
  @override
  State<_WarningCard> createState() => _WarningCardState();
}

class _WarningCardState extends State<_WarningCard> {
  var expanded = false;
  @override
  Widget build(BuildContext context) {
    final warning = widget.warning;
    final color = _warningColor(warning);
    final impact =
        warning.description.isEmpty ? warning.criteria : warning.description;
    return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GestureDetector(
            onTap: () => setState(() => expanded = !expanded),
            child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border(left: BorderSide(color: color, width: 7))),
                padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Image.asset(AppAssets.agricultureWarning,
                            width: 20, height: 20),
                        const SizedBox(width: 7),
                        Expanded(
                            child: Text(
                                warning.eventName.isEmpty
                                    ? warning.headline
                                    : warning.eventName,
                                style: const TextStyle(
                                    color: Color(0xFF26343E),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)))
                      ]),
                      const SizedBox(height: 8),
                      Text('严重程度：${_severity(warning.severity)}',
                          style: const TextStyle(
                              color: Color(0xFF59636B), fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('影响：$impact',
                          maxLines: expanded ? null : 1,
                          overflow: expanded ? null : TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Color(0xFF59636B), fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                          '行动：${warning.instruction.isEmpty ? '请关注预警信息并采取防范措施' : warning.instruction}',
                          maxLines: expanded ? null : 1,
                          overflow: expanded ? null : TextOverflow.ellipsis,
                          style: TextStyle(
                              color: color,
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                      if (expanded && warning.senderName.isNotEmpty)
                        Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text('发布单位：${warning.senderName}',
                                style: const TextStyle(
                                    color: Color(0xFF59636B), fontSize: 12)))
                    ]))));
  }
}

class _ForecastList extends StatelessWidget {
  final List<DailyWeather> forecasts;
  final bool isLoading;
  final String? errorMessage;
  const _ForecastList(
      {required this.forecasts, required this.isLoading, this.errorMessage});
  @override
  Widget build(BuildContext context) => SizedBox(
      height: 170,
      child: forecasts.isEmpty
          ? Center(
              child: Text(isLoading ? '正在加载十五日农业天气…' : errorMessage ?? '暂无预报数据',
                  style: const TextStyle(color: Colors.white70)))
          : ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: forecasts.length > 15 ? 15 : forecasts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 22),
              itemBuilder: (_, index) {
                final item = forecasts[index];
                return SizedBox(
                    width: 42,
                    child: Column(children: [
                      Text(index == 0 ? '今天' : _week(item.fxDate),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 18),
                      Icon(_weatherIcon(item.textDay),
                          color: Colors.white, size: 28),
                      const SizedBox(height: 14),
                      Text(item.tempMax,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12)),
                      const SizedBox(height: 10),
                      Text(item.tempMin,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12)),
                      const SizedBox(height: 10),
                      Text(item.textDay,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12))
                    ]));
              }));
}

String? _daylight(String? sunrise, String? sunset) {
  final a = _minutes(sunrise);
  final b = _minutes(sunset);
  if (a == null || b == null || b < a) return null;
  final result = (b - a) / 60;
  return result == result.roundToDouble()
      ? result.toStringAsFixed(0)
      : result.toStringAsFixed(1);
}

int? _minutes(String? text) {
  final p = text?.split(':');
  if (p == null || p.length != 2) return null;
  final h = int.tryParse(p[0]);
  final m = int.tryParse(p[1]);
  return h == null || m == null ? null : h * 60 + m;
}

String _uvDescription(String? value) {
  final n = int.tryParse(value ?? '');
  if (n == null) return '';
  return n <= 2
      ? '弱'
      : n <= 5
          ? '中等'
          : n <= 7
              ? '强'
              : '很强';
}

String _uvAdvice(String? value) {
  final n = int.tryParse(value ?? '');
  if (n == null) return '紫外线数据暂缺';
  return n <= 2
      ? '可正常户外活动'
      : n <= 5
          ? '建议适当防晒'
          : '请做好防晒防护';
}

Color _warningColor(WeatherWarning warning) =>
    warning.red != null && warning.green != null && warning.blue != null
        ? Color.fromARGB(255, warning.red!, warning.green!, warning.blue!)
        : {
              'red': const Color(0xFFFF3F46),
              'orange': const Color(0xFFFF8A3D),
              'yellow': const Color(0xFFFFB21A),
              'blue': const Color(0xFF3C9DF2)
            }[warning.colorCode.toLowerCase()] ??
            const Color(0xFF4C7DFF);
String _severity(String value) =>
    {
      'extreme': '特别严重',
      'severe': '严重',
      'moderate': '较重',
      'minor': '一般'
    }[value.toLowerCase()] ??
    '--';
String _week(String date) {
  final value = DateTime.tryParse(date);
  return value == null
      ? date
      : const ['周一', '周二', '周三', '周四', '周五', '周六', '周日'][value.weekday - 1];
}

IconData _weatherIcon(String text) => text.contains('雷')
    ? Icons.thunderstorm
    : text.contains('雨') || text.contains('雪')
        ? Icons.umbrella
        : text.contains('云') || text.contains('阴')
            ? Icons.cloud
            : Icons.wb_sunny;
