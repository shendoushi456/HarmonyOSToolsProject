// 个人主页 - 对齐 Android TravelSettingFragment.kt
// 替换原 AirQualityPage（tab[3]）
// 含顶部标题栏 + 渐变头部 + 今日天气行(无点击) + 生活指数网格 + 设置菜单
// 数据从鸿蒙项目 weatherViewModelProvider 获取
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../router/route_names.dart';
import '../../air_quality/models/air_index_item.dart';
import '../../air_quality/utils/air_index_util.dart';
import '../../weather/models/weather_model.dart';
import '../../weather/repositories/city_repository.dart';
import '../../weather/viewmodels/weather_view_model.dart';

/// 个人主页 - 对齐 Android TravelSettingFragment
/// 替换原 AirQualityPage（tab[3]）
class TravelSettingPage extends ConsumerStatefulWidget {
  const TravelSettingPage({super.key});

  // 颜色常量 - 对齐 Android TravelSettingFragment
  static const Color _primaryColor = Color(0xFF0FC459);
  static const Color _gradientStart = Color(0xFFFFD364);
  static const Color _gradientEnd = Color(0xFFFFBD1A);

  // 协议 URL - 对齐 Android BuildConfig.PRIVACY_URL / USER_URL
  static const String _privacyUrl =
      'https://api.zhangshenhan1.top/agreement/bbjscx/privacy';
  static const String _userUrl =
      'https://api.zhangshenhan1.top/agreement/bbjscx/user';

  @override
  ConsumerState<TravelSettingPage> createState() => _TravelSettingPageState();
}

class _TravelSettingPageState extends ConsumerState<TravelSettingPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentCityWeather();
    });
  }

  Future<void> _loadCurrentCityWeather() async {
    final cities = await ref.read(cityRepositoryProvider).loadCities();
    if (!mounted || cities.isEmpty) return;
    await ref.read(weatherViewModelProvider.notifier).loadData(cities.first);
  }

  @override
  Widget build(BuildContext context) {
    final weatherState = ref.watch(weatherViewModelProvider);
    final today = weatherState.today;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // 顶部标题栏 - 对齐 Android TopAppBar
          SliverToBoxAdapter(child: _TopAppBar()),
          // 内容区域 - 对齐 Android Column(verticalScroll)
          SliverToBoxAdapter(
            child: Column(
              children: [
                // 渐变头部 - 对齐 Android TopGradientSection
                _TopGradientSection(),
                // 今日天气行 - 对齐 Android ScreenContent 中的 Row
                // 关键：去掉点击效果（Android 端 .clickable → WlWeatherActivity，鸿蒙端不跳转）
                _TodayWeatherRow(today: today),
                // 生活指数网格 - 对齐 Android LifeIndexGrid
                _LifeIndexGrid(today: today),
                const SizedBox(height: 20),
                // 设置菜单列表 - 对齐 Android SettingsMenuList
                _SettingsMenuList(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 顶部标题栏 - 对齐 Android TravelSettingFragment.TopAppBar
/// 绿色背景，"个人主页"标题，50dp 高
class _TopAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: TravelSettingPage._primaryColor,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      height: MediaQuery.of(context).padding.top + 50,
      alignment: Alignment.center,
      child: const Text(
        '个人主页',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// 渐变头部 - 对齐 Android TopGradientSection
/// 水平渐变卡片，含 app logo + 欢迎文字 + 版本号
class _TopGradientSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 30),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              TravelSettingPage._gradientStart,
              TravelSettingPage._gradientEnd
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo - 对齐 Android Image(ic_logo, size=80dp, clip=CircleShape)
              ClipOval(
                child: Image.asset(
                  AppAssets.icLogo,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
              // 欢迎文字 - 对齐 Android Text("欢迎使用${appName}", 18sp, SemiBold, White)
              const Text(
                '欢迎使用瞬息天气通',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 18 / 18,
                ),
              ),
              const SizedBox(height: 10),
              // 版本号 - 对齐 Android Box(white bg) { Text("软件版本V${version}", 12sp, 0xFFFFBE1C) }
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '软件版本V1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFFFBE1C),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 今日天气行 - 对齐 Android ScreenContent 中的 Row
/// 水平渐变卡片，显示 tempMin/tempMax
/// 关键：去掉点击效果（Android 端 .clickable → WlWeatherActivity，鸿蒙端纯展示）
class _TodayWeatherRow extends StatelessWidget {
  const _TodayWeatherRow({required this.today});

  final DailyWeather? today;

  @override
  Widget build(BuildContext context) {
    // 对齐 Android: "今日天气- 最低："+nowWeather?.tempMin+" 最高："+nowWeather?.tempMax
    final tempMin = today?.tempMin ?? '--';
    final tempMax = today?.tempMax ?? '--';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        height: 50,
        // 对齐 Android: Brush.horizontalGradient(listOf(Color(0xfffd364), Color(0xffbd1a)))
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              TravelSettingPage._gradientStart,
              TravelSettingPage._gradientEnd
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.only(left: 20),
        child: Row(
          children: [
            // 对齐 Android Text("今日天气- 最低：{tempMin} 最高：{tempMax}", White)
            Expanded(
              child: Text(
                '今日天气- 最低：$tempMin 最高：$tempMax',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            // 右箭头 - 对齐 Android Image(arrow_right)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Image.asset(AppAssets.arrowRight, width: 16, height: 16),
            ),
          ],
        ),
      ),
    );
  }
}

/// 生活指数网格 - 对齐 Android LifeIndexGrid
/// 2行×3列，每卡含图标 + 标题 + 描述
class _LifeIndexGrid extends StatelessWidget {
  const _LifeIndexGrid({required this.today});

  final DailyWeather? today;

  /// 构建生活指数列表 - 复用 AirIndexUtil 计算方法 + 自定义图标
  /// 对齐 Android TravelSettingFragment.LifeIndexGrid
  /// 注意：AirIndexItem.title = 计算值（如"炎热"），value = 类别名（如"穿衣"）
  List<AirIndexItem> _buildLifeIndexItems() {
    final tempMax = today?.tempMax ?? '25';
    final tempMin = today?.tempMin ?? '15';
    final humidity = today?.humidity ?? '50';
    final weatherCondition = today?.textDay ?? '晴';
    final uvIndex = today?.uvIndex ?? '5';

    // 穿衣指数 - 内联计算（对齐 AirIndexUtil.buildIndices 中的内联逻辑）
    final maxTempInt = int.tryParse(tempMax) ?? 25;
    final minTempInt = int.tryParse(tempMin) ?? 15;
    final average = (maxTempInt + minTempInt) ~/ 2;
    final dressing = average >= 28
        ? '炎热'
        : average >= 20
            ? '较舒适'
            : average >= 10
                ? '较凉'
                : '寒冷';

    return [
      // 穿衣 - 对齐 Android ic_ling_main_2_1
      AirIndexItem(
        title: dressing,
        value: '穿衣',
        imageAsset: AppAssets.lifeIndexDressing,
        iconType: AirIconType.clothing,
      ),
      // 旅行 - 对齐 Android ic_ling_main_2_2
      AirIndexItem(
        title: AirIndexUtil.generateTravel(tempMax, weatherCondition),
        value: '旅行',
        imageAsset: AppAssets.lifeIndexTravel,
        iconType: AirIconType.travel,
      ),
      // 紫外线 - 对齐 Android ic_ling_main_2_6
      AirIndexItem(
        title: AirIndexUtil.generateUvDescription(uvIndex),
        value: '紫外线',
        imageAsset: AppAssets.lifeIndexUv,
        iconType: AirIconType.sun,
      ),
      // 防晒 - 对齐 Android ic_ling_main_2_3
      AirIndexItem(
        title: AirIndexUtil.generateUvDescription(uvIndex),
        value: '防晒',
        imageAsset: AppAssets.lifeIndexSunscreen,
        iconType: AirIconType.sun,
      ),
      // 交通 - 对齐 Android ic_ling_main_2_4
      AirIndexItem(
        title: AirIndexUtil.generateTraffic(weatherCondition),
        value: '交通',
        imageAsset: AppAssets.lifeIndexTraffic,
        iconType: AirIconType.transit,
      ),
      // 化妆 - 对齐 Android ic_ling_main_2_5
      AirIndexItem(
        title: AirIndexUtil.generateMakeup(tempMax, humidity, weatherCondition),
        value: '化妆',
        imageAsset: AppAssets.lifeIndexMakeup,
        iconType: AirIconType.sun,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final items = _buildLifeIndexItems();

    // 手动分 2 行 × 3 列（对齐 Android lifeIndexItems.chunked(3)）
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: List.generate((items.length / 3).ceil(), (rowIndex) {
          final start = rowIndex * 3;
          final end = (start + 3 > items.length) ? items.length : start + 3;
          final rowItems = items.sublist(start, end);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: rowItems
                  .map((item) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 7.5),
                          child: _LifeIndexCard(item: item),
                        ),
                      ))
                  .toList(),
            ),
          );
        }),
      ),
    );
  }
}

/// 生活指数单个卡片 - 对齐 Android LifeIndexCard
class _LifeIndexCard extends StatelessWidget {
  const _LifeIndexCard({required this.item});

  final AirIndexItem item;

  @override
  Widget build(BuildContext context) {
    // 对齐 Android backgroundColor: Color(0xFFFFD36A) 或 PRIMARY_COLOR
    final bgColor = item.iconType == AirIconType.travel
        ? TravelSettingPage._primaryColor
        : TravelSettingPage._gradientStart;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 图标 - 对齐 Android AsyncImage(icon, 36dp, tint=backgroundColor)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(bgColor, BlendMode.srcIn),
                child: Image.asset(item.imageAsset!, width: 36, height: 36),
              ),
            ),
            // 标题 - 对齐 Android Text(title, 16sp, Medium, 0xFF1E1E1E)
            Text(
              item.title,
              style: const TextStyle(
                color: Color(0xFF1E1E1E),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            // 描述 - 对齐 Android Text(description, 10sp, Normal, 0xFF1E1E1E)
            Text(
              item.value,
              style: const TextStyle(
                color: Color(0xFF1E1E1E),
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// 设置菜单列表 - 对齐 Android SettingsMenuList
/// 白底圆角卡片，4 个菜单项
class _SettingsMenuList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      _SettingMenuItemData(
        icon: AppAssets.settingPrivacy,
        text: '隐私协议',
        onTap: () => GoRouter.of(context).push(
          RoutePaths.policy,
          extra: {'title': '隐私协议', 'url': TravelSettingPage._privacyUrl},
        ),
      ),
      _SettingMenuItemData(
        icon: AppAssets.settingUserTerms,
        text: '用户条款',
        onTap: () => GoRouter.of(context).push(
          RoutePaths.policy,
          extra: {'title': '用户条款', 'url': TravelSettingPage._userUrl},
        ),
      ),
      _SettingMenuItemData(
        icon: AppAssets.settingFeedback,
        text: '意见反馈',
        onTap: () => GoRouter.of(context).push(RoutePaths.feedback),
      ),
      _SettingMenuItemData(
        icon: AppAssets.settingAbout,
        text: '关于我们',
        onTap: () => GoRouter.of(context).push(RoutePaths.about),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: items
              .map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 26),
                    child: _SettingMenuItem(data: item),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

/// 设置菜单项数据
class _SettingMenuItemData {
  final String icon;
  final String text;
  final VoidCallback onTap;
  const _SettingMenuItemData(
      {required this.icon, required this.text, required this.onTap});
}

/// 设置菜单项 - 对齐 Android SettingMenuItem
class _SettingMenuItem extends StatelessWidget {
  const _SettingMenuItem({required this.data});
  final _SettingMenuItemData data;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: data.onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(data.icon, width: 24, height: 24),
              const SizedBox(width: 12),
              Text(
                data.text,
                style: const TextStyle(
                  color: Color(0xFF3C3C3C),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          // 右箭头 - 对齐 Android Image(ic_my_more)
          Image.asset(AppAssets.icMyMore, width: 16, height: 16),
        ],
      ),
    );
  }
}
