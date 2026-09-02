// toolbox_c AirQualityFragment / AirQualityChildFragment 的 Flutter 迁入页。
// 视图只消费独立的 ToolboxAirQualityViewModel，便于后续替换整套马甲 UI。
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../router/route_names.dart';
import '../../weather/models/weather_model.dart';
import '../../weather/viewmodels/toolbox_weather_view_model.dart';
import '../viewmodels/toolbox_air_quality_view_model.dart';

class AirQualityNewPage extends ConsumerWidget {
  const AirQualityNewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(toolboxAirQualityViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AppAssets.toolboxAirQualityBackground,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          SafeArea(
            bottom: false,
            child: RefreshIndicator(
              color: const Color(0xFFFFDE80),
              onRefresh: () => ref
                  .read(toolboxAirQualityViewModelProvider.notifier)
                  .refresh(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(28, 30, 28, 42),
                children: [
                  const Center(
                    child: Text(
                      '生活指南',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  _Location(
                    cityName: state.cityName,
                    onTap: () async {
                      final changed =
                          await context.push<bool>(RoutePaths.citySelect);
                      if (changed == true && context.mounted) {
                        await ref
                            .read(toolboxWeatherPageViewModelProvider.notifier)
                            .loadCity();
                      }
                    },
                  ),
                  const SizedBox(height: 40),
                  _CurrentWeather(currentWeather: state.currentWeather),
                  const SizedBox(height: 36),
                  _AirSummary(air: state.air),
                  const SizedBox(height: 42),
                  _PollutantGrid(air: state.air),
                  const SizedBox(height: 36),
                  const _HealthSuggestions(),
                  const SizedBox(height: 32),
                  _LifeIndexGrid(weather: state.dailyWeather),
                  if (state.loading) ...[
                    const SizedBox(height: 38),
                    const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: 24),
                    Text(
                      state.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Color(0xFFE3E3E3), fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthSuggestions extends StatelessWidget {
  const _HealthSuggestions();

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const Text('健康建议',
          //     style: TextStyle(
          //         color: Colors.white,
          //         fontSize: 16,
          //         fontWeight: FontWeight.w600)),
          // const SizedBox(height: 14),
          // ClipRRect(
          //   borderRadius: BorderRadius.circular(10),
          //   child: SizedBox(
          //     height: 300,
          //     child: Stack(
          //       fit: StackFit.expand,
          //       children: [
          //         Image.asset(AppAssets.toolboxAirHealthHero,
          //             fit: BoxFit.cover),
          //         Align(
          //           alignment: Alignment.bottomCenter,
          //           child: Padding(
          //             padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          //             child: Column(
          //               mainAxisSize: MainAxisSize.min,
          //               children: [
          //                 SizedBox(
          //                   height: 104,
          //                   width: double.infinity,
          //                   child: Stack(
          //                     fit: StackFit.expand,
          //                     children: [
          //                       Image.asset(AppAssets.toolboxAirHealthFood,
          //                           fit: BoxFit.cover),
          //                       const Align(
          //                         alignment: Alignment.bottomLeft,
          //                         child: Padding(
          //                           padding: EdgeInsets.all(8),
          //                           child: Text('今日的均衡膳食，是明日的活力之源。',
          //                               style: TextStyle(
          //                                   color: Colors.white, fontSize: 10)),
          //                         ),
          //                       ),
          //                     ],
          //                   ),
          //                 ),
          //                 const SizedBox(height: 12),
          //                 const Text(
          //                     '注意：健康建议并非规范建议，也不具备法律效力，在任何时候，如有身体不适者应立即就医并遵医嘱。',
          //                     style: TextStyle(
          //                         color: Color(0xFFFF6161), fontSize: 10)),
          //               ],
          //             ),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          // const SizedBox(height: 26),
          const Text('健康建议',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          SizedBox(
            height: 90,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                _SuggestionCard(title: '营养建议', text: '适合多吃富含维生素C的水果,增强免疫力'),
                SizedBox(width: 15),
                _SuggestionCard(title: '缓解压力', text: '适当进行户外运动,呼吸新鲜空气放松身心'),
              ],
            ),
          ),
        ],
      );
}

class _SuggestionCard extends StatelessWidget {
  final String title;
  final String text;
  const _SuggestionCard({required this.title, required this.text});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 232,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(AppAssets.toolboxAirHealthCard, fit: BoxFit.cover),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Image.asset(AppAssets.toolboxAirHealthCardIcon,
                          width: 16, height: 16),
                      const SizedBox(width: 8),
                      Text(title,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14))
                    ]),
                    const SizedBox(height: 10),
                    Text(text,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                        maxLines: 2),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _LifeIndexGrid extends StatelessWidget {
  final DailyWeather? weather;
  const _LifeIndexGrid({this.weather});

  @override
  Widget build(BuildContext context) {
    final items = [
      _LifeMetric(AppAssets.toolboxAirHumidity, '湿度',
          weather == null ? '--' : '${weather!.humidity}%'),
      _LifeMetric(AppAssets.toolboxAirPressure, '气压',
          weather == null ? '--' : '${weather!.pressure}hPa'),
      _LifeMetric(AppAssets.toolboxAirVisibility, '能见度',
          weather == null ? '--' : '${weather!.vis}公里'),
      _LifeMetric(
          AppAssets.toolboxAirUv, '紫外线强度', _uvDescription(weather?.uvIndex)),
      _LifeMetric(AppAssets.toolboxAirPrecip, '降雨量',
          weather == null ? '--' : '${weather!.precip}mm'),
      _LifeMetric(
          AppAssets.toolboxAirWindDir, '风向', weather?.windDirDay ?? '--'),
      _LifeMetric(AppAssets.toolboxAirWindSpeed, '风速',
          weather == null ? '--' : '${weather!.windSpeedDay}km/h'),
      _LifeMetric(
          AppAssets.toolboxAirWindScale, '风力', weather?.windScaleDay ?? '--'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('生活指数',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        for (var i = 0; i < items.length; i += 2) ...[
          Row(children: [
            Expanded(child: _LifeMetricCard(item: items[i])),
            const SizedBox(width: 15),
            Expanded(child: _LifeMetricCard(item: items[i + 1]))
          ]),
          if (i < items.length - 2) const SizedBox(height: 12),
        ],
      ],
    );
  }

  static String _uvDescription(String? value) {
    final uv = int.tryParse(value ?? '');
    if (uv == null) return '--';
    if (uv <= 2) return '最弱';
    if (uv <= 5) return '中等';
    if (uv <= 7) return '强';
    if (uv <= 10) return '很强';
    return '极强';
  }
}

class _LifeMetric {
  final String icon;
  final String title;
  final String value;
  const _LifeMetric(this.icon, this.title, this.value);
}

class _LifeMetricCard extends StatelessWidget {
  final _LifeMetric item;
  const _LifeMetricCard({required this.item});

  @override
  Widget build(BuildContext context) => Card(
        color: const Color(0xFF272A2B),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: SizedBox(
          height: 76,
          child: Row(
            children: [
              const SizedBox(width: 16),
              Image.asset(item.icon, width: 38, height: 35),
              const SizedBox(width: 12),
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(item.value,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ]),
            ],
          ),
        ),
      );
}

class _Location extends StatelessWidget {
  final String cityName;
  final VoidCallback onTap;

  const _Location({required this.cityName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Semantics(
        button: true,
        label: '选择城市',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  AppAssets.toolboxAirQualityLocation,
                  width: 15,
                  height: 22,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 7),
                Text(
                  cityName.isEmpty ? '正在定位城市' : cityName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CurrentWeather extends StatelessWidget {
  final CurrentWeather? currentWeather;

  const _CurrentWeather({this.currentWeather});

  @override
  Widget build(BuildContext context) {
    final temperature = currentWeather?.temperature;
    final condition = currentWeather?.text ?? '';
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          _weatherAsset(condition),
          width: 72,
          height: 72,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 18),
        if (temperature != null && temperature.isNotEmpty) ...[
          Text(
            temperature,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 50,
              height: 1,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 2, bottom: 21),
            child: Text(
              '°C',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ] else
          const Text(
            '--',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 42,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  String _weatherAsset(String text) {
    if (text.contains('雷')) return AppAssets.toolboxAirQualityThunderstorm;
    if (text.contains('雨') || text.contains('雪')) {
      return AppAssets.toolboxAirQualityRain;
    }
    if (text.contains('云') || text.contains('阴') || text.contains('雾')) {
      return AppAssets.toolboxAirQualityCloudy;
    }
    return AppAssets.toolboxAirQualitySun;
  }
}

class _AirSummary extends StatelessWidget {
  final AirQuality? air;

  const _AirSummary({this.air});

  @override
  Widget build(BuildContext context) {
    final aqi = air?.aqi;
    final category = air?.category;
    return Center(
      child: SizedBox(
        width: 166,
        height: 166,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(166, 166),
              painter: _AqiArcPainter(aqi),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  aqi == null ? '--' : '$aqi',
                  style: const TextStyle(
                    color: Color(0xFFFFDE80),
                    fontSize: 38,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  category == null || category.isEmpty
                      ? '空气质量：--'
                      : '空气质量：$category',
                  style: const TextStyle(
                    color: Color(0xFFFFDE80),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AqiArcPainter extends CustomPainter {
  final int? aqi;

  const _AqiArcPainter(this.aqi);

  @override
  void paint(Canvas canvas, Size size) {
    const width = 12.0;
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: (size.shortestSide - width) / 2,
    );
    final background = Paint()
      ..color = Colors.white.withValues(alpha: .38)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    final foreground = Paint()
      ..color = const Color(0xFFFFDE80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    const start = -math.pi * 0.78;
    const sweep = math.pi * 1.56;
    canvas.drawArc(rect, start, sweep, false, background);
    if (aqi != null) {
      canvas.drawArc(
          rect, start, sweep * (aqi! / 500).clamp(0.0, 1.0), false, foreground);
    }
  }

  @override
  bool shouldRepaint(covariant _AqiArcPainter oldDelegate) =>
      oldDelegate.aqi != aqi;
}

class _PollutantGrid extends StatelessWidget {
  final AirQuality? air;

  const _PollutantGrid({this.air});

  @override
  Widget build(BuildContext context) {
    final items = [
      _Pollutant(AppAssets.toolboxAirQualityPm25, air?.pm2p5, '细颗粒物'),
      _Pollutant(AppAssets.toolboxAirQualityPm10, air?.pm10, '粗颗粒物'),
      _Pollutant(AppAssets.toolboxAirQualityNo2, air?.no2, '二氧化氮'),
      _Pollutant(AppAssets.toolboxAirQualitySo2, air?.so2, '二氧化硫'),
      _Pollutant(AppAssets.toolboxAirQualityCo, air?.co, '一氧化碳'),
      _Pollutant(AppAssets.toolboxAirQualityO3, air?.o3, '臭氧'),
    ];
    return Column(
      children: [
        for (var index = 0; index < items.length; index += 2) ...[
          Row(
            children: [
              Expanded(child: _PollutantItem(item: items[index])),
              const SizedBox(width: 26),
              Expanded(child: _PollutantItem(item: items[index + 1])),
            ],
          ),
          if (index < items.length - 2) const SizedBox(height: 31),
        ],
      ],
    );
  }
}

class _Pollutant {
  final String icon;
  final String? value;
  final String label;

  const _Pollutant(this.icon, this.value, this.label);
}

class _PollutantItem extends StatelessWidget {
  final _Pollutant item;

  const _PollutantItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 32,
          height: 32,
          child: Image.asset(item.icon, fit: BoxFit.contain),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.value?.isNotEmpty == true ? item.value! : '--',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white, fontSize: 20, height: 1.05),
              ),
              const SizedBox(height: 3),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFFE3E3E3), fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
