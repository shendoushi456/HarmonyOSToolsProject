// Android WeatherChildFragment 详情内容的 Flutter 还原。
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/utils/date_util.dart';
import '../../../../core/utils/weather_icon_util.dart';
import '../../models/weather_model.dart';

const _panelColor = Color(0x5C050F17);
const _pageBlue = Color(0xFF1365BE);

class WeatherChildContent extends StatefulWidget {
  final String cityName;
  final DailyWeather? today;
  final List<DailyWeather> daily;
  final List<HourForecast> hourly;
  final AirQuality? airQuality;
  final VoidCallback? onCityClick;

  const WeatherChildContent({
    super.key,
    required this.cityName,
    required this.today,
    required this.daily,
    required this.hourly,
    required this.airQuality,
    this.onCityClick,
  });

  @override
  State<WeatherChildContent> createState() => _WeatherChildContentState();
}

class _WeatherChildContentState extends State<WeatherChildContent> {
  int _selectedDay = 0;

  @override
  Widget build(BuildContext context) {
    final selected = widget.daily.isEmpty
        ? widget.today
        : widget.daily[_selectedDay.clamp(0, widget.daily.length - 1)];
    return Container(
      color: _pageBlue,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AppAssets.weatherChildBackground,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                    child: Text(
                      '天气',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _TemperatureHero(
                    cityName: widget.cityName,
                    weather: selected,
                    onCityClick: widget.onCityClick,
                  ),
                  const SizedBox(height: 18),
                  _WeatherMetricPanel(weather: widget.today),
                  const SizedBox(height: 16),
                  _SectionPanel(
                    title: '24小时天气',
                    child: _HourlyWeatherList(hourly: widget.hourly),
                  ),
                  const SizedBox(height: 16),
                  _SectionPanel(
                    title: '15日天气',
                    child: _DailyWeatherList(
                      daily: widget.daily,
                      selectedIndex: _selectedDay,
                      onSelected: (index) =>
                          setState(() => _selectedDay = index),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionPanel(
                    title: '温度趋势',
                    child: _TemperatureTrend(
                      daily: widget.daily,
                      selectedIndex: _selectedDay,
                      selectedWeather: selected,
                      onSelected: (index) =>
                          setState(() => _selectedDay = index),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionPanel(
                    title: '实时空气质量',
                    child: _AirQualityContent(airQuality: widget.airQuality),
                  ),
                  const SizedBox(height: 16),
                  _SectionPanel(
                    title: '出行指数',
                    child: _LifeIndexGrid(weather: selected),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TemperatureHero extends StatelessWidget {
  final String cityName;
  final DailyWeather? weather;
  final VoidCallback? onCityClick;

  const _TemperatureHero({
    required this.cityName,
    required this.weather,
    this.onCityClick,
  });

  @override
  Widget build(BuildContext context) {
    final condition = weather?.textDay ?? '--';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${weather?.tempMax ?? '--'}°',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 52,
                  height: 1,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 5),
              GestureDetector(
                onTap: onCityClick,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on_outlined,
                        color: Colors.white, size: 15),
                    const SizedBox(width: 3),
                    Text(
                      cityName,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 9),
              Text(
                '$condition  ${weather?.tempMax ?? '--'}°-${weather?.tempMin ?? '--'}°',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
        Image.asset(
          WeatherIconUtil.largeIcon(condition),
          width: 142,
          height: 142,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}

class _WeatherMetricPanel extends StatelessWidget {
  final DailyWeather? weather;

  const _WeatherMetricPanel({required this.weather});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _panelColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          _Metric(
            icon: AppAssets.weatherChildWindIcon,
            label: '风速',
            value: '${weather?.windSpeedDay ?? '--'}km/h',
          ),
          _Metric(
            icon: AppAssets.weatherChildPressureIcon,
            label: '气压',
            value: '${weather?.pressure ?? '--'}hPa',
          ),
          _Metric(
            icon: AppAssets.weatherChildHumidityIcon,
            label: '湿度',
            value: '${weather?.humidity ?? '--'}%',
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _Metric({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Column(
          children: [
            Image.asset(icon,color: Colors.white, width: 24, height: 24),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(color: Colors.white, fontSize: 12)),
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _SectionPanel extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionPanel({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 19),
      decoration: BoxDecoration(
        color: _panelColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _HourlyWeatherList extends StatelessWidget {
  final List<HourForecast> hourly;

  const _HourlyWeatherList({required this.hourly});

  @override
  Widget build(BuildContext context) {
    if (hourly.isEmpty) return const _EmptyWeatherData();
    return SizedBox(
      height: 96,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: hourly.length,
        separatorBuilder: (_, __) => const SizedBox(width: 18),
        itemBuilder: (_, index) {
          final item = hourly[index];
          return SizedBox(
            width: 39,
            child: Column(
              children: [
                Text(item.time,
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
                const SizedBox(height: 8),
                Image.asset(WeatherIconUtil.smallIcon(item.condition),
                    width: 30, height: 30),
                const SizedBox(height: 7),
                Text(item.temperature,
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DailyWeatherList extends StatelessWidget {
  final List<DailyWeather> daily;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _DailyWeatherList({
    required this.daily,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (daily.isEmpty) return const _EmptyWeatherData();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: List.generate(math.min(15, daily.length), (index) {
          final item = daily[index];
          return InkWell(
            onTap: () => onSelected(index),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 48,
                    child: Text(
                      DateUtil.getWeekDay(index, item.fxDate),
                      style: TextStyle(
                        color: index == selectedIndex
                            ? const Color(0xFFFFC248)
                            : Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 52,
                    child: Text(
                      _monthDay(item.fxDate),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                  Image.asset(WeatherIconUtil.smallIcon(item.textDay),
                      width: 36, height: 36),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(item.textDay,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 15)),
                  ),
                  Text(
                    '${item.tempMax}°/${item.tempMin}°',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _TemperatureTrend extends StatelessWidget {
  final List<DailyWeather> daily;
  final int selectedIndex;
  final DailyWeather? selectedWeather;
  final ValueChanged<int> onSelected;

  const _TemperatureTrend({
    required this.daily,
    required this.selectedIndex,
    required this.selectedWeather,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (daily.isEmpty) return const _EmptyWeatherData();
    final data = daily.take(7).toList();
    return Column(
      children: [
        _SelectedTemperatureDetail(weather: selectedWeather),
        const SizedBox(height: 12),
        SizedBox(
          height: 235,
          child: Padding(
            padding: const EdgeInsets.only(left: 42, right: 15),
            child: CustomPaint(
              painter: _TemperatureTrendPainter(data, selectedIndex),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 35, right: 8),
          child: Row(
            children: List.generate(data.length, (index) {
              return Expanded(
                child: InkWell(
                  onTap: () => onSelected(index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      children: [
                        Text(_monthDay(data[index].fxDate),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 10)),
                        if (index == selectedIndex)
                          Container(
                              width: 8,
                              height: 2,
                              margin: const EdgeInsets.only(top: 3),
                              color: const Color(0xFF1F7FAF)),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _SelectedTemperatureDetail extends StatelessWidget {
  final DailyWeather? weather;

  const _SelectedTemperatureDetail({required this.weather});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: 132,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 5),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFF1F7FAF),
                borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
              ),
              child: Text(
                _dateLabel(weather?.fxDate ?? ''),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            _TemperatureLegend(
              color: const Color(0xFF1F7FAF),
              label: '最高温度',
              value: '${weather?.tempMax ?? '--'}°',
            ),
            _TemperatureLegend(
              color: const Color(0xFFFFC248),
              label: '最低温度',
              value: '${weather?.tempMin ?? '--'}°',
            ),
          ],
        ),
      ),
    );
  }
}

class _TemperatureLegend extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _TemperatureLegend({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          children: [
            Container(width: 16, height: 2, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(color: Color(0xFF1E1E1E), fontSize: 10)),
            const Spacer(),
            Text(value,
                style: const TextStyle(color: Color(0xFF1E1E1E), fontSize: 10)),
          ],
        ),
      );
}

class _TemperatureTrendPainter extends CustomPainter {
  final List<DailyWeather> daily;
  final int selectedIndex;

  _TemperatureTrendPainter(this.daily, this.selectedIndex);

  @override
  void paint(Canvas canvas, Size size) {
    final high = daily.map((e) => int.tryParse(e.tempMax) ?? 0).toList();
    final low = daily.map((e) => int.tryParse(e.tempMin) ?? 0).toList();
    final minValue = low.reduce(math.min) - 5;
    final maxValue = high.reduce(math.max) + 5;
    final range = math.max(1, maxValue - minValue);
    const left = 4.0;
    final bottom = size.height - 8;
    final usableWidth = size.width - left - 8;
    final usableHeight = size.height - 16;
    double y(int value) => 8 + (maxValue - value) / range * usableHeight;
    double x(int index) =>
        left +
        (daily.length == 1 ? 0 : index * usableWidth / (daily.length - 1));

    final axisPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1;
    canvas.drawLine(const Offset(4, 4), Offset(left, bottom), axisPaint);
    canvas.drawLine(
        Offset(left, bottom), Offset(size.width, bottom), axisPaint);
    final highPaint = Paint()
      ..color = const Color(0xFF1F7FAF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final lowPaint = Paint()
      ..color = const Color(0xFFFFC248)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final highPath = Path()..moveTo(x(0), y(high[0]));
    final lowPath = Path()..moveTo(x(0), y(low[0]));
    for (var index = 1; index < daily.length; index++) {
      highPath.lineTo(x(index), y(high[index]));
      lowPath.lineTo(x(index), y(low[index]));
    }
    canvas.drawPath(highPath, highPaint);
    canvas.drawPath(lowPath, lowPaint);
    for (var index = 0; index < daily.length; index++) {
      final selected = index == selectedIndex;
      canvas.drawCircle(Offset(x(index), y(high[index])), selected ? 4 : 2,
          Paint()..color = const Color(0xFF1F7FAF));
      canvas.drawCircle(Offset(x(index), y(low[index])), selected ? 4 : 2,
          Paint()..color = const Color(0xFFFFC248));
    }
  }

  @override
  bool shouldRepaint(covariant _TemperatureTrendPainter oldDelegate) =>
      oldDelegate.daily != daily || oldDelegate.selectedIndex != selectedIndex;
}

class _AirQualityContent extends StatelessWidget {
  final AirQuality? airQuality;

  const _AirQualityContent({required this.airQuality});

  @override
  Widget build(BuildContext context) {
    final aqi = airQuality?.aqi ?? 0;
    final pollutants = <_PollutantItem>[
      _PollutantItem('PM2.5', '细颗粒物', airQuality?.pm2p5 ?? '--'),
      _PollutantItem('PM10', '粗颗粒物', airQuality?.pm10 ?? '--'),
      _PollutantItem('SO₂', '二氧化硫', airQuality?.so2 ?? '--'),
      _PollutantItem('NO₂', '二氧化氮', airQuality?.no2 ?? '--'),
      _PollutantItem('CO', '一氧化碳', airQuality?.co ?? '--'),
      _PollutantItem('O₃', '臭氧', airQuality?.o3 ?? '--'),
    ];
    return Column(
      children: [
        SizedBox(
          height: 250,
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                  painter: _AqiArcPainter(aqi), size: const Size(170, 170)),
              Container(
                width: 120,
                height: 120,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('AQI空气指数',
                        style:
                            TextStyle(color: Color(0xFF666666), fontSize: 12)),
                    Text('$aqi',
                        style: const TextStyle(
                            color: Color(0xFF3792ED), fontSize: 30)),
                    Text(airQuality?.category ?? '未知',
                        style: const TextStyle(
                            color: Color(0xFF666666), fontSize: 16)),
                  ],
                ),
              ),
              const Positioned(top: 19, child: _AqiLabel('150  轻度')),
              const Positioned(top: 55, right: 40, child: _AqiLabel('200 中度')),
              const Positioned(right: 35, child: _AqiLabel('300 重度')),
              const Positioned(
                  bottom: 46, right: 45, child: _AqiLabel('500 严重')),
              const Positioned(bottom: 46, left: 57, child: _AqiLabel('0 健康')),
              const Positioned(left: 40, child: _AqiLabel('50 优')),
              const Positioned(top: 57, left: 57, child: _AqiLabel('100 良')),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 9),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('污染物详情',
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.55,
              crossAxisSpacing: 12,
              mainAxisSpacing: 8,
            ),
            itemCount: pollutants.length,
            itemBuilder: (_, index) {
              final item = pollutants[index];
              return Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                    color: const Color(0x4DFFFFFF),
                    borderRadius: BorderRadius.circular(5)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(item.abbreviation,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500)),
                    Text(item.name,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 11)),
                    Align(
                        alignment: Alignment.centerRight,
                        child: Text(item.value,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18))),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AqiLabel extends StatelessWidget {
  final String value;
  const _AqiLabel(this.value);

  @override
  Widget build(BuildContext context) =>
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 12));
}

class _PollutantItem {
  final String abbreviation;
  final String name;
  final String value;

  const _PollutantItem(this.abbreviation, this.name, this.value);
}

class _AqiArcPainter extends CustomPainter {
  final int aqi;
  _AqiArcPainter(this.aqi);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(10, 10, size.width - 20, size.height - 20);
    final base = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 15;
    canvas.drawArc(rect, 3 * math.pi / 4, 3 * math.pi / 2, false, base);
    final active = Paint()
      ..shader =
          const LinearGradient(colors: [Color(0xFF1F7FEF), Color(0xFF74C1E9)])
              .createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 15;
    canvas.drawArc(rect, 3 * math.pi / 4,
        3 * math.pi / 2 * (aqi.clamp(0, 300) / 300), false, active);
  }

  @override
  bool shouldRepaint(covariant _AqiArcPainter oldDelegate) =>
      oldDelegate.aqi != aqi;
}

class _LifeIndexGrid extends StatelessWidget {
  final DailyWeather? weather;
  const _LifeIndexGrid({required this.weather});

  @override
  Widget build(BuildContext context) {
    final tempMax = int.tryParse(weather?.tempMax ?? '') ?? 20;
    final tempMin = int.tryParse(weather?.tempMin ?? '') ?? 15;
    final humidity = int.tryParse(weather?.humidity ?? '') ?? 50;
    final condition = weather?.textDay ?? '晴';
    final uv = int.tryParse(weather?.uvIndex ?? '') ?? 0;
    final average = (tempMax + tempMin) ~/ 2;
    final items = <_LifeIndexItem>[
      _LifeIndexItem(
          '穿衣指数', _clothing(average), AppAssets.weatherChildClothingIcon),
      _LifeIndexItem('防晒指数', _sunblock(uv), AppAssets.weatherChildSunblockIcon),
      _LifeIndexItem('旅游指数', _travel(tempMax, condition),
          AppAssets.weatherChildTravelIcon),
      _LifeIndexItem('运动指数', _sport(average, humidity, condition),
          AppAssets.weatherChildSportIcon),
      _LifeIndexItem('洗车', _carWash(condition, weather?.precip ?? ''),
          AppAssets.weatherChildCarWashIcon),
      _LifeIndexItem('紫外线', _uvDescription(uv), AppAssets.weatherChildUvIcon),
      _LifeIndexItem(
          '交通', _traffic(condition), AppAssets.weatherChildTrafficIcon),
      _LifeIndexItem('化妆', _makeup(tempMax, humidity, condition),
          AppAssets.weatherChildMakeupIcon),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: .83,
          crossAxisSpacing: 6,
          mainAxisSpacing: 13,
        ),
        itemCount: items.length,
        itemBuilder: (_, index) {
          final item = items[index];
          return Column(
            children: [
              Image.asset(item.icon, width: 37, height: 37),
              const SizedBox(height: 5),
              Text(item.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 11)),
              const SizedBox(height: 2),
              Text(item.title,
                  style: const TextStyle(color: Colors.white, fontSize: 10)),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyWeatherData extends StatelessWidget {
  const _EmptyWeatherData();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child:
            Text('暂无天气数据', style: TextStyle(color: Colors.white, fontSize: 14)),
      );
}

class _LifeIndexItem {
  final String title;
  final String description;
  final String icon;

  const _LifeIndexItem(this.title, this.description, this.icon);
}

String _monthDay(String value) {
  final date = DateTime.tryParse(value);
  if (date == null) return value;
  return '${date.month}/${date.day}';
}

String _dateLabel(String value) {
  final date = DateTime.tryParse(value);
  if (date == null) return value;
  return '${date.month}月${date.day}日';
}

String _clothing(int temperature) => temperature >= 30
    ? '短袖'
    : temperature >= 22
        ? 'T恤'
        : temperature >= 15
            ? '夹克'
            : temperature >= 8
                ? '毛衣'
                : '棉服';

String _sunblock(int uv) => uv <= 2
    ? '无需防护'
    : uv <= 5
        ? '适当防护'
        : uv <= 7
            ? '注意防晒'
            : uv <= 10
                ? '避免暴晒'
                : '务必防晒';
String _uvDescription(int uv) => uv <= 2
    ? '最弱'
    : uv <= 5
        ? '中等'
        : uv <= 7
            ? '强'
            : uv <= 10
                ? '很强'
                : '极强';
String _travel(int temperature, String condition) =>
    (condition.contains('雨') || condition.contains('雪'))
        ? '不宜出游'
        : (temperature > 35 || temperature < 0)
            ? '谨慎出游'
            : '适宜出游';
String _traffic(String condition) => (condition.contains('雨') ||
        condition.contains('雪') ||
        condition.contains('雾'))
    ? '请慢行'
    : '宜出行';
String _sport(int average, int humidity, String condition) => (condition
            .contains('雨') ||
        condition.contains('雪') ||
        condition.contains('雾') ||
        condition.contains('霾') ||
        average > 35 ||
        average < -5)
    ? '不适宜'
    : (average > 32 || average < 0 || humidity > 85)
        ? '较不适宜'
        : (average >= 15 && average <= 25 && humidity >= 40 && humidity <= 70)
            ? '适宜'
            : '较适宜';
String _carWash(String condition, String precip) => (condition.contains('雨') ||
        condition.contains('雪') ||
        condition.contains('沙尘') ||
        condition.contains('霾') ||
        (double.tryParse(precip) ?? 0) > .5)
    ? '不适宜'
    : (condition.contains('多云') || condition.contains('阴'))
        ? '较适宜'
        : '适宜';
String _makeup(int temperature, int humidity, String condition) =>
    (condition.contains('雨') || condition.contains('雪'))
        ? '防水彩妆'
        : (temperature >= 28 && humidity >= 75)
            ? '控油定妆'
            : (condition.contains('风') && temperature <= 15)
                ? '注意保湿'
                : temperature >= 30
                    ? '宜清爽些'
                    : temperature <= 5
                        ? '需重保湿'
                        : '适宜妆容';
