// toolbox_c(ToolsboxModuel/toolsbox) WeatherFragment + WeatherChildFragment 的鸿蒙迁移版。
// 结构对齐安卓:
// - WeatherFragment: 顶栏(定位+城市+时间/设置) + 小圆点指示器 + PageView 多城市
// - WeatherChildFragment: 7日预报卡 / 中央温度卡(Lottie) / 日出日落 / 生活小窍门 / 每日一句
// 数据复用 WeatherService(和风天气 lookup + 7d)；城市列表复用 CityRepository。
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/storage/prefs_storage.dart';
import '../../../core/utils/date_util.dart';
import '../../../router/route_names.dart';
import '../models/city_bean.dart';
import '../models/weather_dto.dart';
import '../repositories/city_repository.dart';
import '../services/weather_service.dart';

/// 每日一句条目(对应 Android GoodArticle)
class _GoodArticle {
  final String content;
  final String title;
  const _GoodArticle({required this.content, required this.title});

  factory _GoodArticle.fromJson(Map<String, dynamic> json) => _GoodArticle(
        content: json['content']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
      );
}

class ToolboxWeatherHomePage extends ConsumerStatefulWidget {
  const ToolboxWeatherHomePage({super.key});
  @override
  ConsumerState<ToolboxWeatherHomePage> createState() =>
      _ToolboxWeatherHomePageState();
}

class _ToolboxWeatherHomePageState
    extends ConsumerState<ToolboxWeatherHomePage> {
  final CityRepository _cityRepository = CityRepository();
  final WeatherService _weatherService = WeatherService();

  // 城市列表(对应 cityList)
  List<CityBean> _cities = const [];
  // 每个城市 7 天预报数据(对应 WeatherChildFragment.mForecastList)
  final Map<int, List<Weather7DDTO>> _dailyByCity = {};
  // 当前页(对应 mCurIndex)
  int _curIndex = 0;
  // 每日一句数据(对应 WeatherChildViewModel.goodArticle)
  List<_GoodArticle> _articles = const [];
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

  /// 对应 WeatherFragment.onResume → initWeatherData：
  /// 读缓存城市列表，空则写默认北京。
  Future<void> _initData() async {
    final cities = await _cityRepository.loadCities();
    final articles = await _loadArticles();
    if (!mounted) return;
    var index = PrefsStorage.loadPosition();
    if (index > cities.length - 1) index = cities.length - 1;
    // 区分是否添加城市跳转过来的：跳到新添加的页面
    final saveCurrentItem = PrefsStorage.loadSaveCurrentItem();
    if (saveCurrentItem) {
      PrefsStorage.saveSaveCurrentItem(true);
      index = cities.length - 1;
    }
    _dailyByCity.clear();
    _pageController?.dispose();
    _pageController = PageController(initialPage: index < 0 ? 0 : index);
    setState(() {
      _cities = cities;
      _articles = articles;
      _curIndex = index < 0 ? 0 : index;
    });
    // 对应 showCity() 内为每个城市创建 WeatherChildFragment 并各自 initData
    for (var i = 0; i < cities.length; i++) {
      _loadWeather(i, cities[i]);
    }
  }

  /// 对应 AssetsUtils.getJson("good_article.json")
  Future<List<_GoodArticle>> _loadArticles() async {
    try {
      final raw = await rootBundle.loadString(AppAssets.goodArticle);
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => _GoodArticle.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  /// 对应 WeatherUtils.getCityLocationID + getWeather7Day
  Future<void> _loadWeather(int index, CityBean city) async {
    try {
      final location = await _weatherService.lookupCity(city.cityName);
      final info = await _weatherService.getWeather7d(location.id);
      if (!mounted) return;
      setState(() => _dailyByCity[index] = info.daily);
    } catch (_) {
      // 对齐安卓 onFail() 空实现
    }
  }

  String _weekDayStr() {
    const weeks = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
    final now = DateTime.now();
    return weeks[now.weekday - 1];
  }

  /// 对应 initView 内时间拼接："星期X  " + 上午/下午 + HH:mm
  String _timeText() {
    final now = DateTime.now();
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    final amPm = now.hour < 12 ? '上午' : '下午';
    return '${_weekDayStr()}  $amPm$hh:$mm';
  }

  /// 对应 openAddCityActivity
  Future<void> _openAddCity() async {
    await context.push(RoutePaths.citySelect);
    if (!mounted) return;
    // 对齐 onResume → initWeatherData 重新读取城市列表
    final cities = await _cityRepository.loadCities();
    if (!mounted) return;
    var index = PrefsStorage.loadPosition();
    if (index > cities.length - 1) index = cities.length - 1;
    final saveCurrentItem = PrefsStorage.loadSaveCurrentItem();
    if (saveCurrentItem) {
      PrefsStorage.saveSaveCurrentItem(true);
      index = cities.length - 1;
    }
    _dailyByCity.clear();
    _pageController?.dispose();
    _pageController = PageController(initialPage: index < 0 ? 0 : index);
    setState(() {
      _cities = cities;
      _curIndex = index < 0 ? 0 : index;
    });
    for (var i = 0; i < cities.length; i++) {
      _loadWeather(i, cities[i]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: _cities.isEmpty
            ? const SizedBox.shrink()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(),
                  // 单城市隐藏小圆点(对应 llRound.visibility)
                  if (_cities.length > 1) _buildDots(),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      children: [
                        for (var i = 0; i < _cities.length; i++)
                          _CityWeatherContent(
                            daily: _dailyByCity[i] ?? const [],
                            articles: _articles,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// 对应 onPageSelected：记录位置、刷新城市名与圆点
  void _onPageChanged(int i) {
    PrefsStorage.savePosition(i);
    setState(() => _curIndex = i);
  }

  /// 顶栏：ic_loc + 城市名(22sp 黑) + 时间(14sp #464646)；右侧设置入口
  Widget _buildTitle() {
    final cityName =
        _cities.isEmpty ? '' : _cities[_curIndex.clamp(0, _cities.length - 1)].cityName;
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 对应 ll_location 点击 → AddCityActivity
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _openAddCity,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Image.asset(AppAssets.tbWeatherLoc,
                      width: 25, height: 25),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cityName,
                        style: const TextStyle(
                            color: Colors.black, fontSize: 22)),
                    Text(_timeText(),
                        style: const TextStyle(
                            color: Color(0xFF464646), fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          // 对应 settIv 点击 → SettSetActivity
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.push(RoutePaths.setting),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Image.asset(AppAssets.tbWeatherSetting, height: 25),
            ),
          ),
        ],
      ),
    );
  }

  /// 小圆点指示器(对应 llRound)：4dp 圆点，选中亮/未选灰
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
}

/// 单个城市天气内容(对应 WeatherChildFragment 布局 tools_fr_weather_child.xml)
class _CityWeatherContent extends StatefulWidget {
  final List<Weather7DDTO> daily;
  final List<_GoodArticle> articles;
  const _CityWeatherContent({required this.daily, required this.articles});

  @override
  State<_CityWeatherContent> createState() => _CityWeatherContentState();
}

class _CityWeatherContentState extends State<_CityWeatherContent>
    with TickerProviderStateMixin {
  // 对应 numAnim：温度数字从 0 数到 tempMax，1050ms DecelerateInterpolator
  late final AnimationController _numAnim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1050),
  );
  // 对应 tvTemp 点击重播的 in_bottom 动画(位移20%+渐显+105%→100%缩放)
  late final AnimationController _showInAnim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  @override
  void initState() {
    super.initState();
    _startNumAnim();
  }

  @override
  void didUpdateWidget(covariant _CityWeatherContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.daily != widget.daily) _startNumAnim();
  }

  @override
  void dispose() {
    _numAnim.dispose();
    _showInAnim.dispose();
    super.dispose();
  }

  void _startNumAnim() {
    if (_numAnim.isAnimating) _numAnim.stop();
    _numAnim.forward(from: 0);
  }

  Weather7DDTO? get _today =>
      widget.daily.isNotEmpty ? widget.daily.first : null;

  /// 对应 getWeatherType(iconDay)：
  /// 注意保真——安卓源码 HAZE/HAIL/空 分支缺少 return，
  /// 实际落到方法末尾返回 WEATHER_CLEAR。
  String _lottieAsset(String iconId) {
    const clear = AppAssets.lottieSunny;
    switch (iconId) {
      case '100':
        return clear;
      case '101':
      case '151':
      case '153':
      case '103':
        return AppAssets.lottieWindy;
      case '102':
      case '104':
      case '152':
      case '154':
        return AppAssets.lottieFoggy;
      case '300':
      case '301':
      case '303':
      case '305':
      case '306':
      case '307':
      case '308':
      case '309':
      case '310':
      case '311':
      case '312':
      case '314':
      case '315':
      case '316':
      case '317':
      case '318':
      case '350':
      case '351':
      case '399':
        return AppAssets.lottieShower;
      case '400':
      case '401':
      case '402':
      case '403':
      case '408':
      case '409':
      case '410':
        return AppAssets.lottieSnow;
      case '404':
      case '405':
      case '406':
      case '456':
      case '457':
      case '499':
        return AppAssets.lottieShower;
      case '500':
      case '501':
      case '502':
        return AppAssets.lottieFoggy;
      // 503-515(霾)、313(冰雹)、""(雷)：安卓 when 分支缺 return，按保真落到 CLEAR
      default:
        return clear;
    }
  }

  /// 对应 WeatherUtils.setWeatherDayStatus：晴/阴多云/雷/雨 四种图标
  String _dayIcon(String textDay) {
    if (textDay.contains('晴')) return AppAssets.tbWeatherSunny;
    if (textDay.contains('阴') || textDay.contains('多云')) {
      return AppAssets.tbWeatherCloudy;
    }
    if (textDay.contains('雷')) return AppAssets.tbWeatherThunder;
    if (textDay.contains('雨')) return AppAssets.tbWeatherRain;
    // 未匹配时保持 XML 初始 src ic_0d
    return AppAssets.tbWeatherSunny;
  }

  @override
  Widget build(BuildContext context) {
    final today = _today;
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildForecast7d(),
          _buildCenterCard(today),
          _buildSunriseCard(today),
          _buildTips(),
          _buildBottom(today),
        ],
      ),
    );
  }

  /// 7 日预报横向列表(对应 layout_forecast7d + Forecast7dAdapter)
  Widget _buildForecast7d() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 14, bottom: 22),
      child: SizedBox(
        height: 110,
        child: widget.daily.isEmpty
            ? const SizedBox.shrink()
            : ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.daily.length,
                separatorBuilder: (_, __) => const SizedBox(width: 0),
                itemBuilder: (context, position) {
                  final item = widget.daily[position];
                  final isFirst = position == 0;
                  // 对应 Forecast7dAdapter：首卡 #1BCACD 背景白字
                  final textColor =
                      isFirst ? Colors.white : const Color(0xFF2C2C2C);
                  return Container(
                    width: 80,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: isFirst
                          ? const Color(0xFF1BCACD)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Column(
                      children: [
                        Text(DateUtil.getWeekDay(position, item.fxDate),
                            style: TextStyle(color: textColor, fontSize: 12)),
                        const SizedBox(height: 10),
                        Image.asset(_dayIcon(item.textDay),
                            width: 24, height: 24),
                        const SizedBox(height: 10),
                        Text(
                          '${item.tempMax}°C/${item.tempMin}°C',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: textColor, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  /// 中央温度卡(对应 weather_center_bg 背景卡)
  Widget _buildCenterCard(Weather7DDTO? today) {
    final tempMax = int.tryParse(today?.tempMax ?? '') ?? 0;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppAssets.tbWeatherCenterBg),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    // 温度数字：白色→#1BCACD 顶部到底部渐变(对应 setTextViewStyles)
                    GestureDetector(
                      onTap: () => _showInAnim.forward(from: 0),
                      child: AnimatedBuilder(
                        animation: Listenable.merge([_numAnim, _showInAnim]),
                        builder: (context, child) {
                          final t = _showInAnim.isAnimating
                              ? Curves.easeOut.transform(_showInAnim.value)
                              : 1.0;
                          final value =
                              (tempMax * _numAnim.value).round().toString();
                          return Opacity(
                            opacity: t,
                            child: FractionalTranslation(
                              // in_bottom: fromYDelta 20% → 0
                              translation: Offset(0, (1 - t) * 0.2),
                              child: Transform.scale(
                                scale: 1 + (1 - t) * 0.05,
                                child: ShaderMask(
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.white, Color(0xFF1BCACD)],
                                  ).createShader(bounds),
                                  child: Text(
                                    value,
                                    style: const TextStyle(
                                      fontSize: 80,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1BCACD),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // 对应 tv_now：安卓源码写死 "空气质量：优"
                    const Text('空气质量：优',
                        style:
                            TextStyle(color: Color(0xFF1BCACD), fontSize: 14)),
                    const SizedBox(height: 10),
                    Text('最高温度:${today?.tempMax ?? ''}℃',
                        style: const TextStyle(
                            color: Color(0xFF1BCACD), fontSize: 14)),
                  ],
                ),
              ),
              // 对应 lottie_view 100dp，按 iconDay 切换动画
              Padding(
                padding: const EdgeInsets.only(right: 26),
                child: Lottie.asset(
                  _lottieAsset(today?.iconDay ?? ''),
                  width: 100,
                  height: 100,
                  repeat: true,
                ),
              ),
            ],
          ),
          // 三项指标：风速(vis)/气压(pressure)/湿度(precip)——按安卓字段保真
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(
              children: [
                _metric(AppAssets.tbWeatherWind,
                    '${today?.vis ?? ''}km/h', '风速'),
                _metric(AppAssets.tbWeatherPressure,
                    '${today?.pressure ?? ''}hPa', '气压'),
                _metric(AppAssets.tbWeatherWater,
                    '${today?.precip ?? ''}%', '湿度'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(String icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Image.asset(icon, width: 28, height: 28),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(color: Colors.black, fontSize: 16)),
          const SizedBox(height: 10),
          Text(label,
              style: const TextStyle(color: Color(0xFF7D7D7D), fontSize: 14)),
        ],
      ),
    );
  }

  /// 日出日落卡(对应 card_sunrise_main)：渐变背景 + 进度条
  Widget _buildSunriseCard(Weather7DDTO? today) {
    final sunrise = today?.sunrise ?? '';
    final sunset = today?.sunset ?? '';
    // 对应 showForestD7ata：max=日落小时，progress=当前小时(超出则取日落)
    double? progress;
    if (sunrise.isNotEmpty && sunset.isNotEmpty) {
      final subEnd = int.tryParse(sunset.split(':').first) ?? 0;
      var current = DateTime.now().hour;
      if (current > subEnd) current = subEnd;
      if (subEnd > 0) progress = current / subEnd;
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFEAD2), Color(0xFFCFFEFF)],
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(AppAssets.tbWeatherSunUp, width: 16, height: 16),
              const SizedBox(width: 4),
              Text(sunrise,
                  style: const TextStyle(color: Colors.black, fontSize: 12)),
              const Spacer(),
              Text(sunset,
                  style: const TextStyle(color: Colors.black, fontSize: 12)),
              const SizedBox(width: 4),
              Image.asset(AppAssets.tbWeatherSunDown, width: 16, height: 16),
            ],
          ),
          const SizedBox(height: 10),
          // 对应 progress_shap：#E3E3E3 背景圆角3，进度渐变 #FFBF6E→#77FFFF
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              height: 5,
              child: Stack(
                children: [
                  Container(color: const Color(0xFFE3E3E3)),
                  if (progress != null)
                    FractionallySizedBox(
                      widthFactor: progress.clamp(0.0, 1.0),
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFFFBF6E), Color(0xFF77FFFF)],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 生活小窍门(对应 initTipsList 的 11 条固定文案 + LiveTipsAdapter)
  Widget _buildTips() {
    const tips = [
      '取新鲜桔子皮若干，分散放入冰箱内，三天后打开冰箱，清香扑鼻，异味全无。',
      '切洋葱等蔬菜时，可将其去皮放入冰箱冷冻室存放数小时后再切，就不会刺眼流泪了。',
      '杯中的果汁放在托盘上运送，只要在杯中插入一支汤匙，果汁不会溢出了。',
      '维C之王：猕猴桃。',
      '每天喝足 8 杯水，保持身体水分平衡，提高新陈代谢。',
      '每天坚持 30 分钟运动，如快走、瑜伽或深蹲，增强心肺功能。',
      '多吃蔬菜水果，少吃油炸、加工食品，补充优质蛋白质。',
      '保证 7-8 小时高质量睡眠，睡前少玩手机，远离蓝光。',
      '每小时站起来活动 5 分钟，避免腰椎和颈椎疲劳。',
      '用眼 40 分钟后休息 5-10 分钟，多眨眼，多看远处放松眼睛。',
      '适当放松，听音乐、冥想或深呼吸，减轻压力，提高免疫力。',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
          child: Text('生活小窍门',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ),
        for (final tip in tips)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7D2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(tip,
                style:
                    const TextStyle(color: Color(0xFF858585), fontSize: 12)),
          ),
      ],
    );
  }

  /// 底部白色圆角容器(对应 home_weather_bottom_shap)，
  /// 内含 layout_article(layout_guide_living 在安卓为 gone 不迁移)。
  /// 保真说明：安卓源码 include 初始 visibility="gone" 且仅设置文本、
  /// 从未调用 setVisibility(VISIBLE)，因此每日一句实际不可见，这里保持隐藏。
  Widget _buildBottom(Weather7DDTO? today) {
    final day = DateTime.now().day;
    _GoodArticle? article;
    if (widget.articles.isNotEmpty && day >= 1 && day <= widget.articles.length) {
      article = widget.articles[day - 1];
    }
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 17),
      padding: const EdgeInsets.only(bottom: 50),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Visibility(
        visible: false,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEDE3),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('“每日\n一句”',
                  style: TextStyle(color: Color(0xFFCF6D37), fontSize: 16)),
              const SizedBox(width: 21),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(article?.content ?? '',
                        style: const TextStyle(
                            color: Color(0xFF2C2C2C), fontSize: 14)),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2, right: 16),
                        child: Text(
                            article == null ? '' : '——${article.title}',
                            style: const TextStyle(
                                color: Color(0xFF2C2C2C), fontSize: 14)),
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
