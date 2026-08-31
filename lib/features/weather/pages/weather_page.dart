// WeatherFragment 容器页 - 对齐 Android WeatherFragment.kt + tools_fr_weather.xml(可见部分)
// 注: tools_fr_weather.xml 第一个 RelativeLayout(ViewPager 多城市天气/定位/小圆点/隐私协议列表)
//     在源 XML 中 visibility="gone", 不迁移; 可见部分 = 日历标题+设置+日历卡+2×2功能按钮。
// 布局: Column[顶行("日历"标题+设置按钮)] + ScrollView[日历卡(月份切换+WeatherCalendar) + 2×2 按钮]
// 月份范围 2004-01 ~ 2030-12, 越界按钮禁用(alpha 0.3) 对齐 WeatherFragment.updateButtonState
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_assets.dart';
import '../../../router/route_names.dart';
import '../../life_tools/pages/webview/web_tool_page.dart';
import 'history_today_page.dart';
import 'stress_relief_page.dart';
import 'widgets/weather_calendar.dart';
import 'widgets/weather_func_button.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  // 对齐 WeatherFragment.initCalendar: scrollToCurrent + 默认选中今天
  late DateTime _displayMonth;
  late DateTime _selectedDate;

  static final DateTime _minMonth = DateTime(2004, 1, 1);
  static final DateTime _maxMonth = DateTime(2030, 12, 1);

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayMonth = DateTime(now.year, now.month, 1);
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  bool get _isMin =>
      _displayMonth.year == _minMonth.year &&
      _displayMonth.month == _minMonth.month;
  bool get _isMax =>
      _displayMonth.year == _maxMonth.year &&
      _displayMonth.month == _maxMonth.month;

  void _prevMonth() {
    if (_isMin) return;
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    if (_isMax) return;
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1, 1);
    });
  }

  void _onSelectDate(DateTime d) {
    setState(() {
      _selectedDate = d;
      // 点击非本月日期时切换到该日所在月份(对齐 haibin CalendarView 行为)
      if (d.year != _displayMonth.year || d.month != _displayMonth.month) {
        _displayMonth = DateTime(d.year, d.month, 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 对齐 tools_fr_weather.xml 根 LinearLayout background #E3EEFF
      backgroundColor: const Color(0xFFE3EEFF),
      body: SafeArea(
        top: true,
        child: Column(
          children: [
            // 顶行 RelativeLayout: "日历"标题(22sp #1E1E1E, 居中) + settIv(ic_setting, 居右, centerVertical)
            // 注: 源 XML TextView 同时有 marginTop35 + centerVertical, marginTop 把标题推下与图标错位(布局 Bug);
            //     按要求标题与设置图标垂直对齐, 去除 marginTop 让两者同 centerVertical; 顶部仅留状态栏距离。
            Container(
              margin: EdgeInsets.zero,
              height: 44,
              child: Stack(
                children: [
                  // "日历"标题 居中(与 settIv 同 centerVertical 对齐)
                  const Positioned.fill(
                    child: Center(
                      child: Text(
                        '日历',
                        style: TextStyle(
                          fontSize: 22,
                          color: Color(0xFF1E1E1E),
                        ),
                      ),
                    ),
                  ),
                  // settIv: alignParentRight + centerVertical, padding5, marginRight10
                  Positioned(
                    right: 10,
                    top: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: () => context.push(RoutePaths.setting),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Image.asset(
                          AppAssets.weatherIcSetting,
                          width: 25,
                          height: 25,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 日历卡 CardView(margin20 圆角10 elevation8 白底)
                    Container(
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // 月份切换行(padding18 center_vertical):
                          //   tvCalendarMonth(16sp #1E1E1E) + ivCalendarPrev(ic_arrow_left 14dp mL10)
                          //   + ivCalendarNext(ic_arrow_right 14dp mL16)
                          Padding(
                            padding: const EdgeInsets.all(18),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '${_displayMonth.year}年${_displayMonth.month}月',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF1E1E1E),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _prevMonth,
                                  behavior: HitTestBehavior.opaque,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Opacity(
                                      opacity: _isMin ? 0.3 : 1.0,
                                      child: Image.asset(
                                        AppAssets.weatherIcArrowLeft,
                                        width: 14,
                                        height: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _nextMonth,
                                  behavior: HitTestBehavior.opaque,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: Opacity(
                                      opacity: _isMax ? 0.3 : 1.0,
                                      child: Image.asset(
                                        AppAssets.weatherIcArrowRight,
                                        width: 14,
                                        height: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // CalendarView
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 8, right: 8, bottom: 8),
                            child: WeatherCalendar(
                              displayMonth: _displayMonth,
                              selectedDate: _selectedDate,
                              onSelectDate: _onSelectDate,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 第一行按钮(marginH20 marginTop26 间距15)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: WeatherFuncButton(
                              imageAsset: AppAssets.weatherBtnJrjq,
                              label: '节日节气',
                              // btn_jrjq → EatActivity(ershisijieqi/index.html)
                              onTap: () => WebToolPage.push(
                                context,
                                title: '节日节气',
                                url: 'assets/game/ershisijieqi/index.html',
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: WeatherFuncButton(
                              imageAsset: AppAssets.weatherBtnLssdjt,
                              label: '历史上的今天',
                              // btn_lssdjt → HistoryActivity
                              onTap: () => HistoryTodayPage.push(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 第二行按钮(marginH20 marginTop16 marginBottom20 间距15)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 16,
                        bottom: 20,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: WeatherFuncButton(
                              imageAsset: AppAssets.weatherBtnShxqm,
                              label: '生活小窍门',
                              // btn_shxqm → WeatherWebViewActivity(url=xiaoqiaomen.html, title="生活技巧")
                              onTap: () => WebToolPage.push(
                                context,
                                title: '生活技巧',
                                url: 'assets/game/xiaoqiaomen.html',
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: WeatherFuncButton(
                              imageAsset: AppAssets.weatherBtnShjyl,
                              label: '如何缓解压力',
                              // btn_shjyl → ExtendedinformationActivity(flag=1)
                              onTap: () => StressReliefPage.push(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
