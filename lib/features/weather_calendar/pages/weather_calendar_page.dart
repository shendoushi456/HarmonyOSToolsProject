// 对齐 Android WeatherFragment.kt + tools_fr_weather.xml(实际为"日历" tab 页)。
// 可见结构: wifi_top_bg 顶部背景 + 标题栏("日历" + 设置图标) + 滚动区(日历卡 + 节气卡 + 历史上的今天卡)。
// 不渲染(安卓 gone/失效, 详见注释): tv_gps / iv_add_city / ll_round 圆点(单城市恒 GONE) /
//   view_pager 天气子页(布局 visibility=gone 且无代码恢复) / 底部设置块。
// 数据: WeatherCalendarViewModel(月标题一次性 + 历史描述网络替换); 月历交互组件自含。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_assets.dart';
import '../../life_tools/pages/webview/web_tool_page.dart';
import '../../setting/pages/setting_page.dart';
import '../../weather/pages/history_today_page.dart';
import '../viewmodels/weather_calendar_view_model.dart';
import 'widgets/month_calendar_view.dart';

/// 节气卡描述 - 白露为 tools_fr_weather.xml 静态原文；9月23日后(>22号)切为秋分
const String _kJieQiDesc =
    '白露，是“二十四节气”中的第15个节气，秋季第3个节气，干支历申月的结束与酉月的起始。斗指庚，太阳达黄经165度，于公历9月7—9日交节。“白露”是反映自然界寒气增长的重要节气。古人以四时配五行，秋属金，金色白，以白形容秋露，故名“白露”。';

const String _kJieQiDescQiuFen =
    '秋分（Autumnal Equinox），是二十四节气之第十六个节气，秋季第四个节气。斗指酉，太阳到达黄经180°，于每年的公历9月22至24日交节。';

class WeatherCalendarPage extends ConsumerWidget {
  const WeatherCalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(weatherCalendarViewModelProvider);
    // 节气卡：9月22日之后(含交节)显示秋分，否则显示白露
    final isQiuFen = DateTime.now().day > 22;
    final jieQiTitle = isQiuFen ? '当前节气：秋分' : '当前节气：白露';
    final jieQiDesc = isQiuFen ? _kJieQiDescQiuFen : _kJieQiDesc;
    // 状态栏高度(安卓 ImmersionBar fitsSystemWindows(false), 内容自行避让)
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            // iv_bg: wifi_top_bg(match_parent 宽 + wrap_content 高, centerCrop)
            // 紧约束宽度下 Image 按原图 1125:2436 比例定高, 下方露出白色背景, 对齐安卓
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                AppAssets.wifiTopBg,
                fit: BoxFit.fill,
              ),
            ),
            Column(
              children: [
                // rv_title 标题栏(marginTop 35 + 状态栏, paddingHorizontal 8)
                Padding(
                  padding:
                      EdgeInsets.only(top: topInset).copyWith(left: 8, right: 8),
                  child: SizedBox(
                    height: 25,
                    child: Stack(
                      children: [
                        // ll_location 居中: [ic_loc(恒隐藏, 单默认城市 isLocal=false)] + tv_location "日历" 18sp 黑
                        const Center(
                          child: Text(
                            '日历',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF000000),
                            ),
                          ),
                        ),
                        // settIv(右对齐, ic_setting 24dp + padding 5) → SettSetActivity(=现有 SettingPage 同源)
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SettingPage()),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(0),
                              child: Image.asset(
                                AppAssets.weatherIcSetting,
                                width: 24,
                                height: 24,
                                // 对齐安卓 settIv.setColorFilter(Color.BLACK) → 保留 alpha 的黑色剪影
                                color: Colors.black,
                                colorBlendMode: BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // NestedScrollView 滚动区(内容 marginH 15)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 日历卡: 白底 圆角20 阴影#999999(软处理) paddingV5, marginTop 30
                          Container(
                            margin: const EdgeInsets.only(top: 30),
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            decoration: _cardDecoration(radius: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // mToolsTodayText 16sp #1E1E1E marginV18 marginLeft20
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 18, bottom: 18, left: 20),
                                  child: Text(
                                    state.monthTitle,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF1E1E1E),
                                    ),
                                  ),
                                ),
                                // CalendarView(marginH 20)
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: MonthCalendarView(),
                                ),
                              ],
                            ),
                          ),
                          // "节日节气"标题行(marginTop 10 marginLeft 5): toolsrljq + 18sp #1E1E1E
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 10, left: 5),
                            child: _sectionTitle(
                                AppAssets.weatherCalendarJieQiIcon, '节日节气'),
                          ),
                          // 节气卡 mToolsJieQi(marginTop 15, 白 圆角15 阴影, paddingH16 V10)
                          // 点击 → WeatherWebViewActivity(24节气)
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => WebToolPage.push(
                              context,
                              title: '24节气',
                              url: 'assets/game/ershisijieqi/index.html',
                            ),
                            child: Container(
                              margin: const EdgeInsets.only(top: 15),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: _cardDecoration(radius: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    jieQiTitle,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF1E1E1E),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      state.monthTitle,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF6F6F6F),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(
                                      jieQiDesc,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF000000),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // "历史上的今天"标题行(marginTop 20 marginLeft 5): toolsrltoday + 18sp
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 20, left: 5),
                            child: _sectionTitle(
                                AppAssets.weatherCalendarTodayIcon, '历史上的今天'),
                          ),
                          // 今天卡 mToolsToday(marginTop 15, 白 圆角15 阴影, paddingH16 V10)
                          // 点击 → HistoryActivity(=现有 HistoryTodayPage)
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => HistoryTodayPage.push(context),
                            child: Container(
                              margin: const EdgeInsets.only(top: 15),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: _cardDecoration(radius: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // mToolsTadayData 14sp #1E1E1E
                                  Text(
                                    state.monthTitle,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF1E1E1E),
                                    ),
                                  ),
                                  // mToolsTadayFs 12sp 黑(初始 XML 文案, 网络替换)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(
                                      state.historyDesc,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF000000),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 分组标题行 - 对齐 android:drawableLeft + drawablePadding 10, 18sp #1E1E1E
  /// (toolsrljq/toolsrltoday 66px@xxhdpi = 22dp)
  Widget _sectionTitle(String icon, String label) {
    return Row(
      children: [
        Image.asset(icon, width: 22, height: 22),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            color: Color(0xFF1E1E1E),
          ),
        ),
      ],
    );
  }

  /// 卡片装饰 - 对齐 ShapeLinearLayout 白底 + shape_shadowColor #999999 shadowSize 5dp
  /// (降透明度 + 下移的软阴影处理, 与 wifi 列表项同规则)
  BoxDecoration _cardDecoration({required double radius}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: const [
        BoxShadow(
          color: Color(0x66999999),
          blurRadius: 5,
          offset: Offset(0, 2),
        ),
      ],
    );
  }
}
