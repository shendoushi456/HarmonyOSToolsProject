// toolbox_c NongyeFragment(Compose 版)的 Flutter 迁移。
// 数据复用 agricultureViewModelProvider(15d/24h/预警/记录)，
// 本文件只负责展示 UI，方便后续马甲包整体替换。
// 结构：渐变背景+背景图 → 顶栏(城市/日期/农历+农业天气) → 农业天气卡
// → 24小时降水预警卡(柱状) → 农作物记录入口卡 → 农业灾害预警中心。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/utils/lunar_util.dart';
import '../../../router/route_names.dart';
import '../../weather/models/hourly_weather.dart';
import '../../weather/models/weather_model.dart';
import '../../weather/models/weather_warning.dart';
import '../../weather/viewmodels/toolbox_weather_view_model.dart';
import '../viewmodels/agriculture_view_model.dart';
import 'crop_category_select_page.dart';

class NongyePage extends ConsumerWidget {
  const NongyePage({super.key});

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
    final today = state.forecasts.isEmpty ? null : state.forecasts.first;
    return Scaffold(
      backgroundColor: const Color(0xFFF6FBFF),
      body: Stack(children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF2A9EFA),
                  Color(0xFFC7E9FD),
                  Color(0xFFF6FBFF),
                ],
              ),
            ),
          ),
        ),
        // 对齐 Android 全屏背景图 ContentScale.FillBounds
        Positioned.fill(
          child: Image.asset(AppAssets.zxxtqAgricultureBackground,
              fit: BoxFit.fill),
        ),
        SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 88),
            child: Column(children: [
              _AgricultureTopBar(cityName: state.cityName),
              _AgricultureWeatherCard(today: today),
              _PrecipitationWarningCard(hourly: state.hourlyWeather),
              _CropRecordsCard(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) =>
                        CropCategorySelectPage(warnings: state.warnings))),
              ),
              _AgricultureWarningCenter(warnings: state.warnings),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ====== 顶栏 - 对齐 AgricultureTopBar ======
class _AgricultureTopBar extends StatelessWidget {
  final String cityName;
  const _AgricultureTopBar({required this.cityName});

  Future<void> _selectCity(BuildContext context, WidgetRef ref) async {
    final changed = await context.push<bool>(RoutePaths.citySelect);
    if (changed == true) {
      // 刷新全局城市，页面内的 listen 会联动加载新城市农业数据
      await ref.read(toolboxWeatherPageViewModelProvider.notifier).loadCity();
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _dateAndLunar();
    return Consumer(builder: (context, ref, _) {
      return SizedBox(
        height: 72,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Row(children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _selectCity(context, ref),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Image.asset(AppAssets.zxxtqLocation,
                          width: 17, height: 17),
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          '${cityName.isEmpty ? '北京' : cityName}  ⌄',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ]),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '$data  农历${_lunarString()}',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Text('农业天气',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w500)),
          ]),
        ),
      );
    });
  }

  /// 对齐 Android SimpleDateFormat("MM月dd日  E", Locale.CHINA)
  static const _weekDays = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];

  String _dateAndLunar() {
    final now = DateTime.now();
    return '${now.month.toString().padLeft(2, '0')}月${now.day.toString().padLeft(2, '0')}日  ${_weekDays[now.weekday - 1]}';
  }

  /// 对齐 Android Lunar(calendar).toString()
  String _lunarString() => Lunar.fromDateTime(DateTime.now()).toString();
}

// ====== 农业天气卡 - 对齐 AgricultureWeatherCard ======
class _AgricultureWeatherCard extends StatelessWidget {
  final DailyWeather? today;
  const _AgricultureWeatherCard({required this.today});
  @override
  Widget build(BuildContext context) {
    // Android: air?.temp(恒空) ?: today?.tempMax ?: "--"
    final temp = today?.tempMax ?? '--';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 151,
      width: double.infinity,
      child: Stack(children: [
        Positioned.fill(
          child: Image.asset(AppAssets.zxxtqAgricultureWeatherCard,
              fit: BoxFit.fill),
        ),
        Positioned(
          left: 17,
          top: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$temp°',
                  style: const TextStyle(
                      color: Color(0xFF165DCC),
                      fontSize: 48,
                      height: 50 / 48,
                      fontWeight: FontWeight.w900)),
              Row(children: [
                const Text('适宜农事',
                    style: TextStyle(
                        color: Color(0xFF165DCC),
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF55D6BE),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Text('良好',
                      style: TextStyle(color: Colors.white, fontSize: 10)),
                ),
              ]),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(today?.textDay ?? '天气数据加载中',
                    style: const TextStyle(
                        color: Color(0xFF165DCC),
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        Positioned(
          left: 8,
          right: 8,
          bottom: 4,
          height: 42,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _AgricultureWeatherMetric(
                icon: AppAssets.zxxtqAgricultureHumidity,
                label: '湿度',
                value: '${today?.humidity ?? "--"}%',
              ).expanded(),
              _AgricultureWeatherMetric(
                icon: AppAssets.zxxtqAgricultureWind,
                label: '风速',
                value: _windSpeed(today),
              ).expanded(),
              _AgricultureWeatherMetric(
                icon: AppAssets.zxxtqLifeUv,
                label: '紫外线',
                value: '${today?.uvIndex ?? "--"}${_uvLevel(today?.uvIndex)}',
              ).expanded(),
              _AgricultureWeatherMetric(
                icon: AppAssets.zxxtqAgricultureSunshine,
                label: '日照',
                value: _daylightHours(today),
              ).expanded(),
            ],
          ),
        ),
      ]),
    );
  }
}

extension _Expanded on Widget {
  Widget expanded() => Expanded(child: this);
}

/// 单个指标 - 对齐 AgricultureWeatherMetric
class _AgricultureWeatherMetric extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  const _AgricultureWeatherMetric({
    required this.icon,
    required this.label,
    required this.value,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(icon, width: 19, height: 19),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Color(0xFF6683A6), fontSize: 7)),
              Text(value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Color(0xFF102859),
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }
}

/// 对齐 windSpeed：km/h → m/s，保留 1 位小数
String _windSpeed(DailyWeather? today) {
  final kmh = double.tryParse(today?.windSpeedDay ?? '');
  if (kmh == null) return '-- m/s';
  return '${(kmh / 3.6).toStringAsFixed(1)} m/s';
}

/// 对齐 uvLevel
String _uvLevel(String? value) {
  final uv = int.tryParse(value ?? '');
  if (uv == null) return '';
  if (uv <= 2) return '弱';
  if (uv <= 5) return '中等';
  if (uv <= 7) return '强';
  return '很强';
}

/// 对齐 daylightHours：日出→日落时长，保留 1 位小数
String _daylightHours(DailyWeather? today) {
  final start = _minutes(today?.sunrise);
  final end = _minutes(today?.sunset);
  if (start == null || end == null) return '-- h';
  return '${((end - start).clamp(0, 1 << 31) / 60).toStringAsFixed(1)} h';
}

int? _minutes(String? value) {
  final parts = value?.split(':');
  if (parts == null || parts.length != 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  return (hour == null || minute == null) ? null : hour * 60 + minute;
}

// ====== 24小时降水预警卡 - 对齐 PrecipitationWarningCard ======
class _PrecipitationWarningCard extends StatelessWidget {
  final List<HourlyWeather> hourly;
  const _PrecipitationWarningCard({required this.hourly});
  @override
  Widget build(BuildContext context) {
    final samples = hourly.take(24).toList();
    final precipitation = samples.fold<double>(
        0, (sum, item) => sum + (double.tryParse(item.precipitation) ?? 0));
    var peak = 0;
    for (final item in samples) {
      final pop = int.tryParse(item.precipitationProbability) ?? 0;
      if (pop > peak) peak = pop;
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 15, bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE2F3FC),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('24小时降水预警',
            style: TextStyle(
                color: Color(0xFF26343E),
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
              '预计累计${_formatOneDecimal(precipitation)}mm，降水概率峰值$peak%',
              style: const TextStyle(color: Color(0xFF73818C), fontSize: 10)),
        ),
        SizedBox(
          height: 142,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(children: [
              SizedBox(
                height: 118,
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: CustomPaint(
                      painter: _PrecipitationBarsPainter(samples
                          .map((item) =>
                              (double.tryParse(
                                      item.precipitationProbability) ??
                                  0)
                              .clamp(0, 100)
                              .toDouble())
                          .toList())),
                ),
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('0点',
                      style: TextStyle(color: Color(0xFF6683A6), fontSize: 9)),
                  Text('12点',
                      style: TextStyle(color: Color(0xFF6683A6), fontSize: 9)),
                  Text('0点',
                      style: TextStyle(color: Color(0xFF6683A6), fontSize: 9)),
                ],
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

/// 对齐 Android DecimalFormat("0.#")：保留 1 位小数并去掉末尾 0
String _formatOneDecimal(double value) {
  final rounded = value.toStringAsFixed(1);
  return rounded.endsWith('.0') ? rounded.substring(0, rounded.length - 2) : rounded;
}

/// 降水概率柱状图 - 对齐 PrecipitationBars(24 根圆角柱，白色轨道+蓝色进度)
class _PrecipitationBarsPainter extends CustomPainter {
  final List<double> values;
  const _PrecipitationBarsPainter(this.values);
  @override
  void paint(Canvas canvas, Size size) {
    final loaded = values.take(24).toList();
    final display = List<double>.generate(
        24, (index) => index < loaded.length ? loaded[index] : 0);
    const columnWidth = 5.0;
    final spacing = (size.width - columnWidth * 24) / 23;
    final trackHeight = size.height;
    final trackPaint = Paint()..color = Colors.white.withValues(alpha: 0.96);
    final progressPaint = Paint()..color = const Color(0xFF21A9E0);
    for (var index = 0; index < display.length; index++) {
      final x = index * (columnWidth + spacing);
      final trackRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, 0, columnWidth, trackHeight),
        const Radius.circular(2),
      );
      canvas.drawRRect(trackRect, trackPaint);
      final progressHeight = trackHeight * display[index] / 100;
      if (progressHeight > 0) {
        final progressRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
              x, trackHeight - progressHeight, columnWidth, progressHeight),
          const Radius.circular(2),
        );
        canvas.drawRRect(progressRect, progressPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PrecipitationBarsPainter oldDelegate) =>
      oldDelegate.values != values;
}

// ====== 农作物记录入口卡 - 对齐 CropRecordsCard ======
class _CropRecordsCard extends StatelessWidget {
  final VoidCallback onTap;
  const _CropRecordsCard({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        height: 154,
        width: double.infinity,
        child: Stack(children: [
          Positioned.fill(
            child: Image.asset(AppAssets.agricultureRecordBoard,
                fit: BoxFit.fill),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 24, top: 14, right: 18),
              child: Row(children: [
                Image.asset(AppAssets.agricultureRecordIllustration,
                    width: 86, height: 81),
                // 对齐 Android Column.weight(1f)：文字约束在插图右侧剩余宽度内换行
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '做好农作物记录与灾害预防，摸清作物生长规律，防范灾害减损，科学管护，推动农业精细化稳产增收。',
                          style: TextStyle(
                              color: Color(0xFF26384F),
                              fontSize: 10.5,
                              height: 15 / 10.5),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 7),
                          width: 80,
                          height: 25,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFF238BF2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text('点击使用',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

// ====== 农业灾害预警中心 - 对齐 AgricultureWarningCenter ======
class _AgricultureWarningCenter extends StatelessWidget {
  final List<WeatherWarning> warnings;
  const _AgricultureWarningCenter({required this.warnings});
  @override
  Widget build(BuildContext context) {
    final active = warnings
        .where((item) => item.messageType.toLowerCase() != 'cancel')
        .toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Image.asset(AppAssets.agricultureWarning, width: 20, height: 20),
          const Padding(
            padding: EdgeInsets.only(left: 7),
            child: Text('农业灾害预警中心',
                style: TextStyle(
                    color: Color(0xFF1F7DEF),
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ),
        ]),
        const SizedBox(height: 12),
        if (active.isEmpty)
          const _NoWarningCard()
        else
          for (var index = 0; index < active.take(3).length; index++) ...[
            _WarningCard(warning: active[index]),
            if (index != active.take(3).length - 1) const SizedBox(height: 10),
          ],
      ]),
    );
  }
}

/// 空态卡 - 对齐 NoWarningCard
class _NoWarningCard extends StatelessWidget {
  const _NoWarningCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFFDFF7EB),
            shape: BoxShape.circle,
          ),
          child: const Text('✓',
              style: TextStyle(
                  color: Color(0xFF25B878),
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('当前暂无生效预警',
                  style: TextStyle(
                      color: Color(0xFF1B2A40),
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text('适宜开展常规农事，请持续关注天气变化',
                    style: TextStyle(color: Color(0xFF66758A), fontSize: 10)),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

/// 预警卡 - 对齐 WarningCard(点击展开/收起)
class _WarningCard extends StatefulWidget {
  final WeatherWarning warning;
  const _WarningCard({required this.warning});
  @override
  State<_WarningCard> createState() => _WarningCardState();
}

class _WarningCardState extends State<_WarningCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final warning = widget.warning;
    final severityColor = _warningColor(warning);
    final title = warning.eventName.isNotEmpty
        ? warning.eventName
        : warning.headline.isNotEmpty
            ? warning.headline
            : '农业灾害预警';
    final impact = warning.description.isNotEmpty
        ? warning.description
        : (warning.criteria.isEmpty ? '影响信息暂缺' : warning.criteria);
    final action = warning.instruction.isNotEmpty
        ? warning.instruction
        : '请关注最新预警并及时采取防范措施';
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: severityColor.withValues(alpha: 0.22),
                shape: BoxShape.circle,
              ),
              child: Text('!',
                  style: TextStyle(
                      color: severityColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 7),
                child: Text(title,
                    style: const TextStyle(
                        color: Color(0xFF1E1E1E),
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            Text('严重程度：${_severityLabel(warning.severity)}',
                style: TextStyle(color: severityColor, fontSize: 11)),
          ]),
          Padding(
            padding: const EdgeInsets.only(left: 7, top: 7),
            child: Text('危害：$impact',
                maxLines: _expanded ? null : 2,
                overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Color(0xFF464646), fontSize: 11)),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 7, top: 6),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
              decoration: BoxDecoration(
                color: severityColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('预防措施：$action',
                  maxLines: _expanded ? null : 2,
                  overflow:
                      _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  style: TextStyle(color: severityColor, fontSize: 10)),
            ),
          ),
        ]),
      ),
    );
  }
}

/// 对齐 warningColor：优先 RGB，其次色码映射
Color _warningColor(WeatherWarning warning) {
  if (warning.red != null && warning.green != null && warning.blue != null) {
    return Color.fromARGB(
        255, warning.red!, warning.green!, warning.blue!);
  }
  switch (warning.colorCode.toLowerCase()) {
    case 'red':
      return const Color(0xFFE35858);
    case 'orange':
      return const Color(0xFFFF9045);
    case 'yellow':
      return const Color(0xFFF2A51A);
    case 'blue':
      return const Color(0xFF3C9DF2);
    default:
      return const Color(0xFFF77979);
  }
}

/// 对齐 severityLabel
String _severityLabel(String severity) {
  switch (severity.toLowerCase()) {
    case 'extreme':
      return '特级';
    case 'severe':
      return '高级';
    case 'moderate':
      return '中级';
    case 'minor':
      return '一般';
    default:
      return '提示';
  }
}
