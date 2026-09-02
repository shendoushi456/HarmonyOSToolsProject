// “我的”页 - 对齐 Android TravelSettingFragment.ScreenContent。
// 页面消费既有 WeatherViewModel / CityRepository；功能入口仅保留本次要求迁移的四项。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../features/setting/utils/app_info_util.dart';
import '../../../features/weather/models/weather_model.dart';
import '../../../features/weather/repositories/city_repository.dart';
import '../../../features/weather/viewmodels/weather_view_model.dart';
import '../../../router/route_names.dart';

class TravelSettingPage extends ConsumerStatefulWidget {
  const TravelSettingPage({super.key});

  @override
  ConsumerState<TravelSettingPage> createState() => _TravelSettingPageState();
}

class _TravelSettingPageState extends ConsumerState<TravelSettingPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCurrentCity());
  }

  Future<void> _loadCurrentCity() async {
    final cities = await ref.read(cityRepositoryProvider).loadCities();
    if (!mounted || cities.isEmpty) return;
    await ref.read(weatherViewModelProvider.notifier).loadData(cities.first);
  }

  @override
  Widget build(BuildContext context) {
    final weather = ref.watch(weatherViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.toolboxProfileBlue,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _WeatherHeader(
                cityName: weather.cityName,
                today: weather.today,
                airQuality: weather.airQuality,
                onCityTap: _chooseCity,
                onWeatherTap: () => context.push(RoutePaths.weatherDetail),
              ),
              _ProfileContent(onAction: _handleAction),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAction(_ProfileAction action) {
    switch (action) {
      case _ProfileAction.privacy:
        context.push(
          RoutePaths.policy,
          extra: const {'title': '隐私协议', 'url': SettingUrls.policy},
        );
        return;
      case _ProfileAction.agreement:
        context.push(
          RoutePaths.policy,
          extra: const {'title': '用户条款', 'url': SettingUrls.user},
        );
        return;
      case _ProfileAction.about:
        context.push(RoutePaths.about);
        return;
      case _ProfileAction.feedback:
        context.push(RoutePaths.feedback);
        return;
    }
  }

  Future<void> _chooseCity() async {
    final changed = await context.push<bool>(RoutePaths.citySelect);
    if (changed == true && mounted) await _loadCurrentCity();
  }
}

class _WeatherHeader extends StatelessWidget {
  const _WeatherHeader({
    required this.cityName,
    required this.today,
    required this.airQuality,
    required this.onCityTap,
    required this.onWeatherTap,
  });

  final String cityName;
  final DailyWeather? today;
  final AirQuality? airQuality;
  final VoidCallback onCityTap;
  final VoidCallback onWeatherTap;

  @override
  Widget build(BuildContext context) {
    final currentTemp = today?.tempMax ?? '28';
    final condition = today?.textDay ?? '多云';
    final minTemp = today?.tempMin ?? '25';
    final maxTemp = today?.tempMax ?? '31';
    final wind = '${today?.windDirDay ?? '东南风'}${today?.windScaleDay ?? '4'}级';
    final air = airQuality?.category ?? '优';

    return Container(
      width: double.infinity,
      color: AppColors.toolboxProfileBlue,
      padding: const EdgeInsets.fromLTRB(20, 23, 20, 20),
      child: Column(
        children: [
          Semantics(
            button: true,
            label: '切换城市',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onCityTap,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    AppAssets.toolboxProfileLocation,
                    width: 22,
                    height: 22,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cityName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 25),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onWeatherTap,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentTemp,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 84,
                        height: 1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text(
                      '°',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 72,
                        height: 1,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 84, left: 4),
                  child: Text(
                    condition,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Image.asset(
                  AppAssets.toolboxProfileWeather,
                  width: 135,
                  height: 115,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onWeatherTap,
            child: Row(
              children: [
                Text(
                  '$minTemp°-$maxTemp°',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  wind,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 14),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '空气 $air',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.onAction});

  final ValueChanged<_ProfileAction> onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      padding: const EdgeInsets.only(top: 35, bottom: 71),
      child: Column(
        children: [
          const _WelcomeCard(),
          // Android 原页在欢迎卡和地址卡间有 33dp；地址功能按需求排除，
          // 保留其后的节奏以维持原始功能网格的垂直位置。
          const SizedBox(height: 53),
          _FunctionRow(
            items: [
              _ProfileItem(
                title: '隐私协议',
                asset: AppAssets.toolboxProfilePrivacy,
                action: _ProfileAction.privacy,
              ),
              _ProfileItem(
                title: '用户条款',
                asset: AppAssets.toolboxProfileAgreement,
                action: _ProfileAction.agreement,
              ),
              _ProfileItem(
                title: '意见反馈',
                asset: AppAssets.toolboxProfileFeedback,
                action: _ProfileAction.feedback,
              ),
            ],
            onAction: onAction,
          ),
          const SizedBox(height: 12),
          _FunctionRow(
            items: [
              _ProfileItem(
                title: '关于我们',
                asset: AppAssets.toolboxProfileAbout,
                action: _ProfileAction.about,
              ),
              null,
              null,
            ],
            onAction: onAction,
          ),
        ],
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Image.asset(
            AppAssets.icLogo,
            width: 72,
            height: 72,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '欢迎使用${AppInfoUtil.appName}',
                style: const TextStyle(
                  color: AppColors.toolboxProfileText,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.toolboxProfileVersion,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '软件版本V${AppInfoUtil.version}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FunctionRow extends StatelessWidget {
  const _FunctionRow({required this.items, required this.onAction});

  final List<_ProfileItem?> items;
  final ValueChanged<_ProfileAction> onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            Expanded(
              child: items[index] == null
                  ? const SizedBox(height: 104)
                  : _FunctionCard(item: items[index]!, onAction: onAction),
            ),
            if (index < items.length - 1) const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }
}

class _FunctionCard extends StatelessWidget {
  const _FunctionCard({required this.item, required this.onAction});

  final _ProfileItem item;
  final ValueChanged<_ProfileAction> onAction;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: item.title,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onAction(item.action),
        child: Container(
          height: 104,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                item.asset,
                width: 36,
                height: 36,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 4),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.toolboxProfileFunctionText,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileItem {
  const _ProfileItem({
    required this.title,
    required this.asset,
    required this.action,
  });

  final String title;
  final String asset;
  final _ProfileAction action;
}

enum _ProfileAction { privacy, agreement, about, feedback }
