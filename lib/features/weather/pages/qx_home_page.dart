// QxHome 首页天气页 - 对齐 Android QxHomeFragment/QxHomeScreen/QxHomeComponents
// 迁移自 toolbox_c toolsbox_moduel weather/home（Jetpack Compose UI）
// 蓝色渐变背景 + Hero 日期区 + 实时天气卡 + 日出日落卡 + 6 日预报列表
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../router/route_names.dart';
import '../../home/pages/home_shell_page.dart';
import '../models/qx_home_ui_state.dart';
import '../viewmodels/qx_home_view_model.dart';

/// 对齐 Android QxMainFontScale：全页字号整体缩放 0.82（sp 缩放，dp 不变）
const double _kQxMainFontScale = 0.82;

/// Compose verticalGradient endY=760px（xxhdpi 3x）≈ 253 逻辑像素处渐变结束
const double _kGradientEnd = 253.0;

class QxHomePage extends ConsumerStatefulWidget {
  const QxHomePage({super.key});

  @override
  ConsumerState<QxHomePage> createState() => _QxHomePageState();
}

class _QxHomePageState extends ConsumerState<QxHomePage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 对齐 Android Fragment.onResume：从后台回到前台时刷新
    if (state == AppLifecycleState.resumed) {
      ref.read(qxHomeViewModelProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(qxHomeViewModelProvider);

    // 对齐 Android ViewPager 中切回本 Fragment 触发 onResume
    ref.listen<int>(homeTabIndexProvider, (previous, next) {
      if (previous != 0 && next == 0) {
        ref.read(qxHomeViewModelProvider.notifier).refresh();
      }
    });

    final mq = MediaQuery.of(context);
    return MediaQuery(
      data: mq.copyWith(textScaler: const TextScaler.linear(_kQxMainFontScale)),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: LayoutBuilder(
          builder: (context, constraints) {
            // 三色渐变在 _kGradientEnd 逻辑像素处收白，其余区域保持白色
            final whiteStop =
                (_kGradientEnd / constraints.maxHeight).clamp(0.0, 1.0);
            return Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: const [
                          Color(0xFF69BDF5),
                          Color(0xFFEAF7FF),
                          Colors.white,
                        ],
                        stops: [0.0, whiteStop, 1.0],
                      ),
                    ),
                  ),
                ),
                // 对齐 Android qx_home_19：alpha 0.22 + ContentScale.Crop
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.22,
                    child: Image.asset(
                      AppAssets.qxHomeBackground,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SafeArea(
                  top: true,
                  bottom: false,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 96),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _HomeHero(
                            state: state,
                            onCityClick: _openCitySelect,
                          ),
                          const SizedBox(height: 26),
                          _RealTimeWeatherCard(state: state),
                          const SizedBox(height: 20),
                          _SunriseSunsetRow(state: state),
                          const SizedBox(height: 20),
                          _ForecastListCard(forecasts: state.forecasts),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 对齐 Android QxHomeFragment.openAddCityActivity（AddCityActivity 单选模式）
  Future<void> _openCitySelect() async {
    final changed = await context.push<bool>(RoutePaths.citySelect);
    if (changed == true) {
      // 对齐 Android onResume → viewModel.refresh()
      await ref.read(qxHomeViewModelProvider.notifier).refresh();
    }
  }
}

/// 顶部 Hero 区：星期/日期/城市 + 右侧圆角图（对齐 Android HomeHero）
class _HomeHero extends StatelessWidget {
  final QxHomeUiState state;
  final VoidCallback onCityClick;

  const _HomeHero({required this.state, required this.onCityClick});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.weekday,
                    maxLines: 2,
                    overflow: TextOverflow.clip,
                    style: const TextStyle(
                      color: Color(0xFF202124),
                      fontSize: 33,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    state.dateText,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: const TextStyle(
                      color: Color(0xFF202124),
                      fontSize: 31,
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onCityClick,
                    child: Row(
                      children: [
                        Image.asset(
                          AppAssets.weatherLocation,
                          width: 18,
                          height: 18,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            state.cityName,
                            maxLines: 2,
                            overflow: TextOverflow.clip,
                            style: const TextStyle(
                              color: Color(0xFF6A747D),
                              fontSize: 18,
                              height: 1.25,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 对齐 Compose Column.weight(1f)：文字区占满剩余宽度，图片紧随其后
          ClipRRect(            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              AppAssets.qxHomeHero,
              width: 160,
              height: 160,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}

/// 实时天气卡（对齐 Android RealTimeWeatherCard）
class _RealTimeWeatherCard extends StatelessWidget {
  final QxHomeUiState state;

  const _RealTimeWeatherCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF9ED8FF), Color(0xFF55B9F6)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '实时天气',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Image.asset(
                state.weatherIconPath,
                width: 90,
                height: 90,
              ),
              const SizedBox(width: 22),
              Text(
                state.temperature,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                '°',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.condition,
                      maxLines: 2,
                      overflow: TextOverflow.clip,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                    Text(
                      state.tempRange,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 34),
          Row(
            children: [
              for (var i = 0; i < state.metrics.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(child: _MetricItem(metric: state.metrics[i])),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// 实时指标项（对齐 Android RealTimeWeatherCard.metrics 行内元素）
class _MetricItem extends StatelessWidget {
  final QxWeatherMetricUi metric;

  const _MetricItem({required this.metric});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 34,
          child: Center(
            child: Image.asset(
              metric.iconPath,
              width: 30,
              height: 30,
            ),
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                metric.label,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              Text(
                metric.value,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 日出日落双卡（对齐 Android SunriseSunsetRow）
class _SunriseSunsetRow extends StatelessWidget {
  final QxHomeUiState state;

  const _SunriseSunsetRow({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SunTimeCard(
            title: '日出',
            time: state.sunrise,
            iconPath: AppAssets.qxHomeSunriseIcon,
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: _SunTimeCard(
            title: '日落',
            time: state.sunset,
            iconPath: AppAssets.qxHomeSunsetIcon,
          ),
        ),
      ],
    );
  }
}

/// 单张日出/日落卡（对齐 Android SunTimeCard：上部图标 + 下部浅灰信息条）
class _SunTimeCard extends StatelessWidget {
  final String title;
  final String time;
  final String iconPath;

  const _SunTimeCard({
    required this.title,
    required this.time,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.18,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  color: Colors.white,
                  alignment: Alignment.center,
                  child: Image.asset(iconPath, width: 74, height: 74),
                ),
              ),
              Container(
                height: 78,
                color: const Color(0xFFF6F6F6),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 23,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      time,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 预报列表卡（对齐 Android ForecastListCard + QxSoftCard）
class _ForecastListCard extends StatelessWidget {
  final List<QxForecastDayUi> forecasts;

  const _ForecastListCard({required this.forecasts});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < forecasts.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            _ForecastRow(forecast: forecasts[i], isFirst: i == 0),
          ],
        ],
      ),
    );
  }
}

/// 单条预报行（对齐 Android ForecastListCard 行布局 weight 1.2/1/0.7/0.7）
class _ForecastRow extends StatelessWidget {
  final QxForecastDayUi forecast;
  final bool isFirst;

  const _ForecastRow({required this.forecast, required this.isFirst});

  @override
  Widget build(BuildContext context) {
    final color = isFirst ? const Color(0xFF2095FF) : const Color(0xFF30343A);
    return Row(
      children: [
        Expanded(
          flex: 12,
          child: Text(
            forecast.label,
            maxLines: 2,
            overflow: TextOverflow.clip,
            style: TextStyle(color: color, fontSize: 18),
          ),
        ),
        Expanded(
          flex: 10,
          child: SizedBox(
            height: 34,
            child: Center(
              child: Image.asset(
                forecast.iconPath,
                fit: BoxFit.contain,
                height: 34,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 7,
          child: Text(
            forecast.high,
            textAlign: TextAlign.end,
            style: TextStyle(color: color, fontSize: 18),
          ),
        ),
        Expanded(
          flex: 7,
          child: Text(
            forecast.low,
            textAlign: TextAlign.end,
            style: TextStyle(color: color, fontSize: 18),
          ),
        ),
      ],
    );
  }
}
