// toolbox_c WeatherShFragment/WeatherSettingFragment(Compose 版)的 Flutter 迁移。
// 作为底部导航最后一个 Tab（设置）；按需求去掉"账户管理-撤销同意用户协议"入口。
// 数据复用 weatherViewModelProvider(城市/今日天气/空气质量)，子页面复用
// policy/about/feedback 既有路由。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_assets.dart';
import '../../../router/route_names.dart';
import '../../weather/models/weather_model.dart';
import '../../weather/viewmodels/toolbox_weather_view_model.dart';
import '../../weather/viewmodels/weather_view_model.dart';
import '../utils/app_info_util.dart';

// ====== 颜色常量 - 对齐 Android WeatherSettingFragment 顶部私有颜色 ======
const _settingBlue = Color(0xFF238BF2);
const _settingPageBackground = Color(0xFFF6FBFF);
const _settingPrimaryText = Color(0xFF1B2A40);
const _settingSecondaryText = Color(0xFF7D8CA2);

class WeatherSettingPage extends ConsumerWidget {
  const WeatherSettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(weatherViewModelProvider);
    // 与天气首页相同的城市联动；loadData 内部有幂等判断，不会重复请求
    ref.listen(toolboxWeatherPageViewModelProvider.select((s) => s.city),
        (_, city) {
      if (city != null) {
        ref.read(weatherViewModelProvider.notifier).loadData(city);
      }
    });
    final today = state.today;
    return Scaffold(
      backgroundColor: _settingPageBackground,
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
                  _settingPageBackground,
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
              // 顶部标题栏 - 对齐 58dp 白字"设置"
              const SizedBox(
                height: 58,
                width: double.infinity,
                child: Center(
                  child: Text('设置',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.w600)),
                ),
              ),
              _TemperatureDisplay(
                cityName: state.cityName,
                today: today,
                air: state.airQuality,
              ),
              const SizedBox(height: 20),
              const _SettingMenuContent(),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ====== 天气卡 - 对齐 TemperatureDisplay ======
class _TemperatureDisplay extends StatelessWidget {
  final String cityName;
  final DailyWeather? today;
  final AirQuality? air;
  const _TemperatureDisplay({
    required this.cityName,
    required this.today,
    required this.air,
  });
  @override
  Widget build(BuildContext context) {
    // Android: air?.temp(恒空) ?: selectedForecast?.tempMax ?: "--"
    final currentTemp = today?.tempMax ?? '--';
    // Android: air?.text(恒空) ?: selectedForecast?.textDay ?: "天气加载中"
    final weatherText = today?.textDay ?? '天气加载中';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 158,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF239AF2), Color(0xFF61C5F4)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.42)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(children: [
        Padding(
          padding: const EdgeInsets.only(left: 18, top: 14, bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Image.asset(AppAssets.zxxtqLocation, width: 15, height: 15),
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    cityName.isEmpty ? '北京' : cityName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ]),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$currentTemp°',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          height: 52 / 48,
                          fontWeight: FontWeight.bold)),
                  Padding(
                    padding: const EdgeInsets.only(left: 6, bottom: 7),
                    child: Text(weatherText,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(children: [
                _WeatherBadge('${today?.tempMin ?? "--"}°~${today?.tempMax ?? "--"}°'),
                const SizedBox(width: 8),
                _WeatherBadge(
                    '${today?.windDirDay ?? ""}${today?.windScaleDay ?? "--"}级'),
                const SizedBox(width: 8),
                _WeatherBadge('空气${air?.category ?? "--"} ${air?.aqi ?? "--"}'),
              ]),
            ],
          ),
        ),
        // 右侧天气图标 - 对齐 CenterEnd + padding(end=14, top=7) + 88dp
        Positioned(
          right: 14,
          top: 7,
          child: Image.asset(_dayIcon(weatherText),
              width: 88, height: 88, fit: BoxFit.contain),
        ),
      ]),
    );
  }
}

/// 白色半透明胶囊 - 对齐 WeatherBadge
class _WeatherBadge extends StatelessWidget {
  final String text;
  const _WeatherBadge(this.text);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text,
          maxLines: 1,
          style: const TextStyle(color: Colors.white, fontSize: 9)),
    );
  }
}

/// 对齐 WeatherUtils.getWeatherDayIcon：晴→sun，阴/多云→cloudy，
/// 雷→rain(原代码注释掉了 thunderstorm)，雨→rain，默认 sun
String _dayIcon(String weatherText) {
  if (weatherText.contains('晴')) return AppAssets.weatherDaySun;
  if (weatherText.contains('阴') || weatherText.contains('多云')) {
    return AppAssets.weatherDayCloudy;
  }
  if (weatherText.contains('雷')) return AppAssets.weatherDayRain;
  if (weatherText.contains('雨')) return AppAssets.weatherDayRain;
  return AppAssets.weatherDaySun;
}

// ====== 菜单区 - 对齐 SettingMenuContent(去掉账户管理/撤销同意用户协议) ======
class _SettingMenuContent extends StatelessWidget {
  const _SettingMenuContent();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SettingGroupTitle('协议与服务'),
          _SettingGroupCard(children: [
            _SettingMenuItem(
              icon: AppAssets.settingTabUserAgreement,
              title: '用户协议',
              onTap: () => context.push(
                RoutePaths.policy,
                extra: {'title': '用户协议', 'url': SettingUrls.user},
              ),
            ),
            const _SettingDivider(),
            _SettingMenuItem(
              icon: AppAssets.settingTabPrivacy,
              title: '隐私协议',
              onTap: () => context.push(
                RoutePaths.policy,
                extra: {'title': '隐私协议', 'url': SettingUrls.policy},
              ),
            ),
            const _SettingDivider(),
            _SettingMenuItem(
              icon: AppAssets.settingTabAbout,
              title: '关于我们',
              onTap: () => context.push(RoutePaths.about),
            ),
            const _SettingDivider(),
            _SettingMenuItem(
              icon: AppAssets.settingTabFeedback,
              title: '意见反馈',
              onTap: () => context.push(RoutePaths.feedback),
            ),
          ]),
        ],
      ),
    );
  }
}

/// 分组标题 - 对齐 SettingGroupTitle
class _SettingGroupTitle extends StatelessWidget {
  final String title;
  const _SettingGroupTitle(this.title);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(title,
          style: const TextStyle(
              color: _settingPrimaryText,
              fontSize: 17,
              fontWeight: FontWeight.bold)),
    );
  }
}

/// 分组白卡 - 对齐 SettingGroupCard(16dp 圆角 + 3dp 阴影)
class _SettingGroupCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingGroupCard({required this.children});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

/// 分隔线 - 对齐 SettingDivider(start=60, end=14)
class _SettingDivider extends StatelessWidget {
  const _SettingDivider();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 60, right: 14),
      height: 1,
      color: const Color(0xFFEDF3F9),
    );
  }
}

/// 菜单项 - 对齐 SettingMenuItem(56dp 高 + 32dp 圆形图标底 + 右箭头)
class _SettingMenuItem extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback onTap;
  const _SettingMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 56,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(children: [
            // 32dp 圆形浅蓝底 + 17dp 图标(tint SettingBlue)
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFEAF5FF),
                shape: BoxShape.circle,
              ),
              child: ColorFiltered(
                colorFilter:
                    const ColorFilter.mode(_settingBlue, BlendMode.srcIn),
                child: Image.asset(icon, width: 17, height: 17),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: _settingPrimaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
              ),
            ),
            // 右箭头(tint SettingSecondaryText)
            ColorFiltered(
              colorFilter: const ColorFilter.mode(
                  _settingSecondaryText, BlendMode.srcIn),
              child:
                  Image.asset(AppAssets.arrowRight, width: 14, height: 14),
            ),
          ]),
        ),
      ),
    );
  }
}
