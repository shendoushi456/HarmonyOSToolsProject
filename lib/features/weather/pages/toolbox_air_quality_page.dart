// toolbox_c(toolsbox_moduel/toolsbox) AirQualityFragment + AirQualityChildFragment 的鸿蒙迁移版。
// 结构对齐安卓:
// - AirQualityFragment: 居中标题"生活指南" + 小圆点指示器 + PageView 多城市
// - AirQualityChildFragment: 城市名 / AQI 渐变圆(级别+类别) / 实时温度天气 /
//   六项污染物卡片 / 健康生活方式四卡(营养/缓解压力/24节气/历史上的今天)
// 数据复用 WeatherService(和风天气 lookup + air/now + weather/now)；
// 城市列表复用 CityRepository；fragment_position 与天气页共用同一存储键(对齐安卓)。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/storage/prefs_storage.dart';
import '../../../router/route_names.dart';
import '../../home/pages/home_shell_page.dart' show homeTabIndexProvider;
import '../models/city_bean.dart';
import '../models/weather_dto.dart';
import '../repositories/city_repository.dart';
import '../services/weather_service.dart';

class ToolboxAirQualityPage extends ConsumerStatefulWidget {
  const ToolboxAirQualityPage({super.key});
  @override
  ConsumerState<ToolboxAirQualityPage> createState() =>
      _ToolboxAirQualityPageState();
}

class _ToolboxAirQualityPageState
    extends ConsumerState<ToolboxAirQualityPage> {
  final CityRepository _cityRepository = CityRepository();
  final WeatherService _weatherService = WeatherService();

  List<CityBean> _cities = const [];
  // 每个城市的空气质量数据(对应 AirQualityChildFragment.updateView)
  final Map<int, AirbeanDTO> _airByCity = {};
  // 每个城市的实时天气(温度+天气文字)
  final Map<int, AirbeanDTO> _nowByCity = {};
  int _curIndex = 0;
  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  /// 对应 AirQualityFragment.onResume → initDataRequest
  Future<void> _initData() async {
    final cities = await _cityRepository.loadCities();
    if (cities.isEmpty) return;
    if (!mounted) return;
    // 对齐安卓 onResume：读取 fragment_position 并跳到该页(与天气页共用键)
    final position = PrefsStorage.loadPosition();
    _pageController?.dispose();
    _pageController = PageController(
        initialPage: position > cities.length - 1 ? cities.length - 1 : position);
    setState(() {
      _cities = cities;
      _curIndex =
          position > cities.length - 1 ? cities.length - 1 : position;
    });
    // 对应 initViewPager 内为每个城市创建 AirQualityChildFragment 并各自 initData
    for (var i = 0; i < cities.length; i++) {
      _loadData(i, cities[i]);
    }
  }

  /// 对应 initData：lookup → getWeatherAirNow + getWeatherNow
  Future<void> _loadData(int index, CityBean city) async {
    try {
      final location = await _weatherService.lookupCity(city.cityName);
      final results = await Future.wait([
        _weatherService.getAirNow(location.id),
        _weatherService.getWeatherNow(location.id),
      ]);
      final air = results[0].now;
      final now = results[1].now;
      if (!mounted) return;
      setState(() {
        if (air != null) _airByCity[index] = air;
        if (now != null) _nowByCity[index] = now;
      });
    } catch (_) {
      // 对齐安卓 onFail() 空实现
    }
  }

  /// 对应 setCurrentLocationName：标题固定"生活指南"，
  /// 定位图标仅当当前城市 isLocal 时可见
  Widget _buildTitle() {
    final showLoc =
        _cities.isNotEmpty && (_cities[_curIndex.clamp(0, _cities.length - 1)].isLocal);
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 8, right: 8),
      child: SizedBox(
        height: 30,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 对应 iv_loc：gone/visible 由 isLocal 决定
            Visibility(
              visible: showLoc,
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child:
                    Image.asset(AppAssets.tbWeatherLoc, width: 25, height: 25),
              ),
            ),
            const Text('生活指南',
                style: TextStyle(color: Color(0xFF393939), fontSize: 18)),
          ],
        ),
      ),
    );
  }

  /// 小圆点指示器(对应 llRound)：与天气页同款 bg selector
  Widget _buildDots() {
    return Container(
      margin: const EdgeInsets.only(top: 2, bottom: 3),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < _cities.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Image.asset(
                i == _curIndex
                    ? AppAssets.tbWeatherDotEnable
                    : AppAssets.tbWeatherDotDisable,
                width: 4,
                height: 4,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 对齐安卓 AirQualityFragment.onResume：每次切回本 Tab 都重新读城市列表、
    // 重新请求数据，并无条件跳到 fragment_position(天气页滑动时保存的位置)
    // 本分支 3 Tab：天气(0)/日历(1)/生活指南(2)
    ref.listen(homeTabIndexProvider, (prev, next) {
      if (next == 2) _initData();
    });
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: _cities.isEmpty
            ? const SizedBox.shrink()
            : Column(
                children: [
                  _buildTitle(),
                  _buildDots(),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      // 对齐安卓 onPageSelected：仅刷新圆点与标题，不保存位置
                      onPageChanged: (i) => setState(() => _curIndex = i),
                      children: [
                        for (var i = 0; i < _cities.length; i++)
                          _AirQualityChildContent(
                            cityName: _cities[i].cityName,
                            air: _airByCity[i],
                            now: _nowByCity[i],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// 单个城市内容(对应 AirQualityChildFragment 布局 tools_fr_air_quality_child.xml)
class _AirQualityChildContent extends StatelessWidget {
  final String cityName;
  final AirbeanDTO? air;
  final AirbeanDTO? now;

  const _AirQualityChildContent({
    required this.cityName,
    this.air,
    this.now,
  });

  /// 对应 WeatherUtils.setWeatherDayStatus：晴/阴多云/雷/雨 四种图标，
  /// 未匹配保持 XML 初始 src(sun_down_icon)
  String _statusIcon(String text) {
    if (text.contains('晴')) return AppAssets.tbWeatherSunny;
    if (text.contains('阴') || text.contains('多云')) {
      return AppAssets.tbWeatherCloudy;
    }
    if (text.contains('雷')) return AppAssets.tbWeatherThunder;
    if (text.contains('雨')) return AppAssets.tbWeatherRain;
    return AppAssets.tbWeatherSunDown;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLocation(),
            _buildAqiRow(),
            _buildPollutantDetails(),
            _buildHealthSection(context),
          ],
        ),
      ),
    );
  }

  /// 城市名(对应 location_air_txt：dingwei_air_icon + 16sp #464646)
  Widget _buildLocation() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 10, bottom: 20),
      child: Row(
        children: [
          Image.asset(AppAssets.tbAirLocation, width: 18, height: 18),
          const SizedBox(width: 10),
          Text(cityName,
              style: const TextStyle(color: Color(0xFF464646), fontSize: 16)),
        ],
      ),
    );
  }

  /// AQI 渐变圆(116dp shap_air_round_bg) + 右侧温度天气(对应中部 LinearLayout)
  Widget _buildAqiRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: [
          Container(
            width: 116,
            height: 116,
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFFFEAD2), Color(0xFFCFFEFF)],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(air?.level ?? '0',
                    style: const TextStyle(
                        color: Color(0xFF1BCACD),
                        fontSize: 30,
                        fontWeight: FontWeight.bold)),
                Text(' 空气质量：${air?.category ?? ''}',
                    style: const TextStyle(
                        color: Color(0xFF1BCACD), fontSize: 12)),
              ],
            ),
          ),
          const Spacer(),
          Column(
            children: [
              Image.asset(_statusIcon(now?.text ?? ''), width: 50, height: 50),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(now?.temp ?? '28',
                      style: const TextStyle(
                          color: Color(0xFF464646),
                          fontSize: 30,
                          fontWeight: FontWeight.bold)),
                  const Text('°C',
                      style:
                          TextStyle(color: Color(0xFF464646), fontSize: 14)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 六项污染物卡片(对应 item_air_quality_detail 两行三列)
  /// 保真说明：前两张卡文案均为"细颗粒物"，与安卓源码一致；
  /// 第二张实际取 pm10，第五张 label "一氧化碳" 取 co 字段。
  Widget _buildPollutantDetails() {
    const colors = [
      Color(0xFFFFEAD2),
      Color(0xFFCFFEFF),
      Color(0xFFCFFFE4),
      Color(0xFFE8FFCF),
      Color(0xFFE3D2FF),
      Color(0xFFFFEAD1),
    ];
    const icons = [
      AppAssets.tbAirMenu1,
      AppAssets.tbAirMenu2,
      AppAssets.tbAirMenu3,
      AppAssets.tbAirMenu4,
      AppAssets.tbAirMenu5,
      AppAssets.tbAirMenu6,
    ];
    const labels = ['细颗粒物', '细颗粒物', '二氧化氮', '二氧化硫', '一氧化碳', '臭氧'];
    final values = [
      air?.pm2p5 ?? '24',
      air?.pm10 ?? '24',
      air?.no2 ?? '24',
      air?.so2 ?? '24',
      air?.co ?? '24',
      air?.o3 ?? '24',
    ];
    // 对齐安卓 margin：行内三卡 左边距 3/10/15，其余 3
    const rowMargins = [
      EdgeInsets.fromLTRB(3, 3, 3, 3),
      EdgeInsets.fromLTRB(10, 3, 10, 3),
      EdgeInsets.fromLTRB(15, 3, 3, 3),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13),
      child: Column(
        children: [
          for (var row = 0; row < 2; row++)
            Padding(
              padding: EdgeInsets.only(top: row == 0 ? 0 : 14),
              child: Row(
                children: [
                  for (var col = 0; col < 3; col++)
                    Expanded(
                      child: Container(
                        height: 120,
                        margin: rowMargins[col],
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colors[row * 3 + col],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(icons[row * 3 + col],
                                width: 24, height: 24),
                            const SizedBox(height: 10),
                            Text(labels[row * 3 + col],
                                style: const TextStyle(
                                    color: Color(0xFF818181), fontSize: 12)),
                            const SizedBox(height: 10),
                            Text(values[row * 3 + col],
                                style: const TextStyle(
                                    color: Color(0xFF393939),
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold)),
                          ],
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

  /// 健康生活方式(对应"健康生活方式"标题 + 2x2 卡片)
  Widget _buildHealthSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20, top: 10),
          child: Text('健康生活方式',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Row(
            children: [
              const SizedBox(width: 20),
              Expanded(
                child: _healthCard(
                  context,
                  icon: AppAssets.tbAirNutrition,
                  title: '营养',
                  subtitle: '每日营养摄入指南',
                  onTap: () => context.push(RoutePaths.nutrition),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _healthCard(
                  context,
                  icon: AppAssets.tbAirStress,
                  title: '缓解压力',
                  subtitle: '压力管理与放松技巧',
                  onTap: () => context.push(RoutePaths.stress),
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const SizedBox(width: 20),
            Expanded(
              child: _healthCard(
                context,
                icon: AppAssets.tbAirSolarTerms,
                title: '24节气',
                subtitle: '当前节气',
                onTap: () => context.push(RoutePaths.solarTerms),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _healthCard(
                context,
                icon: AppAssets.tbAirHistoryToday,
                title: '历史上的今天',
                subtitle: '探索历史事件',
                onTap: () => context.push(RoutePaths.historyToday),
              ),
            ),
            const SizedBox(width: 20),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  /// 单张健康卡(对应 bg_corner_rectangle_32 #F9FAFB 圆角10 高138)
  Widget _healthCard(
    BuildContext context, {
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 138,
        padding: const EdgeInsets.only(left: 20, top: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(icon, width: 28, height: 28),
                const SizedBox(height: 10),
                Text(title,
                    style: const TextStyle(
                        color: Color(0xFF464646),
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            Text(subtitle,
                style: const TextStyle(color: Color(0xFF8D8E8E), fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
