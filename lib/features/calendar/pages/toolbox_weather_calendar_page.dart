// toolbox_c(toolsbox_moduel/toolsbox 清逸出行气象 v502) WeatherCalendarFragment 的鸿蒙迁移版。
// 结构对齐 calender_weather_layout.xml:
// - 顶部居中"日历"标题
// - 黄色区块(#FFF8D8): 年月大标题 + 农历节日 + 宜/忌
// - "yyyy年M月"小标题 + haibin CalendarView 月历(riliMonthView: 日期+农历, 选中圆 #FFA572)
// - 冲煞/岁煞/五行黄历卡(v502 源码为 gone, 经用户确认迁移后显示)
// - 12 星座横向列表 + 星座解析卡(v502 源码为 gone, 经用户确认迁移后显示)
// 数据复用 CalendarAlmanacService(天api lunar + xingzuo)与 LunarUtil(农历算法)。
// 保真说明: 安卓 onCalendarSelect 中 initCalender(选中日期)被注释,
// 黄历数据仅首次(当天)请求一次, 选择日期只更新标题。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/utils/lunar_util.dart';
import '../models/chinese_calendar_bean.dart';
import '../models/xingzuo_info.dart';
import '../services/calendar_almanac_service.dart';

class ToolboxWeatherCalendarPage extends ConsumerStatefulWidget {
  const ToolboxWeatherCalendarPage({super.key});
  @override
  ConsumerState<ToolboxWeatherCalendarPage> createState() =>
      _ToolboxWeatherCalendarPageState();
}

class _ToolboxWeatherCalendarPageState
    extends ConsumerState<ToolboxWeatherCalendarPage> {
  final CalendarAlmanacService _almanacService = CalendarAlmanacService();

  // 黄历数据(对应 ChineseCalendarBean, 仅首次请求当天 - 保真安卓注释掉刷新的 Bug)
  ChineseCalendarBean? _almanac;
  // 星座解析数据(对应 XingzuoInfo, 初始"射手")
  XingzuoInfo? _xingzuoInfo;
  // 当前选中日期(对应 CalendarView 选中态)
  late DateTime _selectedDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  // 当前显示的月份(对应 CalendarView 翻页)
  late DateTime _displayMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
  PageController? _monthPageController;

  /// 12 星座横向列表 - 顺序/图标/名称对齐 CalenderWeatherAdapter
  static const _xingzuoList = [
    ['射手', AppAssets.tbCalXingzuoSheshou],
    ['摩羯', AppAssets.tbCalXingzuoMojiezuo],
    ['天秤', AppAssets.tbCalXingzuoTianpingzuo],
    ['巨蟹', AppAssets.tbCalXingzuoJuxiezuo],
    ['天蝎', AppAssets.tbCalXingzuoTianxiezuo],
    ['狮子', AppAssets.tbCalXingzuoShizizuo],
    ['处女', AppAssets.tbCalXingzuoChunvzuo],
    ['双子', AppAssets.tbCalXingzuoShuangzizuo],
    ['金牛', AppAssets.tbCalXingzuoJingniuzuo],
    ['水瓶', AppAssets.tbCalXingzuoShuipingzuo],
    ['双鱼', AppAssets.tbCalXingzuoShuangyu],
    ['白羊', AppAssets.tbCalXingzuoBaiyang],
  ];

  @override
  void initState() {
    super.initState();
    _monthPageController = PageController(initialPage: _monthPageIndex(DateTime.now()));
    // 对应 initCalender(""): 天api lunar 不传日期默认今天
    _initAlmanac();
    // 对应 initXingZuo("射手")
    _initXingZuo('射手');
  }

  @override
  void dispose() {
    _monthPageController?.dispose();
    super.dispose();
  }

  /// 月份相对索引(以 2000-01 为基准, 供 PageView 翻月)
  int _monthPageIndex(DateTime month) =>
      (month.year - 2000) * 12 + month.month - 1;

  DateTime _monthFromIndex(int index) =>
      DateTime(2000 + index ~/ 12, index % 12 + 1, 1);

  /// 对应 initCalender → initCalenderDetails
  Future<void> _initAlmanac() async {
    final bean = await _almanacService.fetchAlmanac(DateTime.now());
    if (!mounted) return;
    setState(() => _almanac = bean);
  }

  /// 对应 initXingZuo(name): 请求星座解析
  Future<void> _initXingZuo(String name) async {
    final info = await _almanacService.fetchXingzuo(name);
    if (!mounted) return;
    setState(() => _xingzuoInfo = info);
  }

  /// 对应 emptyInfo: 空文本显示"无"
  String _emptyInfo(String? str) =>
      (str == null || str.isEmpty) ? '无' : str;

  /// 对应 onCalendarSelect: 仅更新标题("yyyy年M月")，
  /// 黄历不刷新(安卓源码 initCalender(select) 被注释 - 保真)
  void _onCalendarSelect(DateTime date) {
    setState(() {
      _selectedDate = date;
      _displayMonth = DateTime(date.year, date.month, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 对应顶部"日历"标题 18sp bold black marginTop 50dp
            const Padding(
              padding: EdgeInsets.only(top: 30),
              child: Center(
                child: Text('日历',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAlmanacHeader(),
                    _buildMonthTitle(),
                    _buildCalendarView(),
                    // _buildChongshaCard(),
                    _buildXingzuoList(),
                    // 对应安卓 v502：点击星座后显示星座解析卡(title\ngrade\ncontent)
                    _buildXingzuoDetailCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 黄色区块(对应 #FFF8D8 头部)：年月大标题 + 农历节日 + 宜 + 忌
  Widget _buildAlmanacHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 10),
      color: const Color(0xFFFFF8D8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 对应 title_calender_txt_2(30sp bold #464646)。
          // 保真说明: 安卓源码从不更新该控件(XML 写死"2025/3"),
          // 此处按语义还原为当前显示月"yyyy/M"。
          Text('${_displayMonth.year}/${_displayMonth.month}',
              style: const TextStyle(
                  color: Color(0xFF464646),
                  fontSize: 30,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          // 对应 nongli_info_1: 农历节日 16sp #898989
          // Text(_emptyInfo(_almanac?.lunarFestival),
          //     style: const TextStyle(color: Color(0xFF898989), fontSize: 16)),
          // const SizedBox(height: 10),
          // 对应 v502 布局：红色"宜："标签(16sp bold) + fitness 数据(13sp)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('宜：',
                  style: TextStyle(
                      color: Color(0xFFF76F6F),
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(_emptyInfo(_almanac?.fitness),
                    style:
                        const TextStyle(color: Color(0xFFF76F6F), fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 对应 v502 布局：红色"忌："标签(16sp bold) + taboo 数据(13sp)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('忌：',
                  style: TextStyle(
                      color: Color(0xFFF76F6F),
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(_emptyInfo(_almanac?.taboo),
                    style:
                        const TextStyle(color: Color(0xFFF76F6F), fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// "yyyy年M月"小标题(对应 title_calender_txt, 随选中日期更新)
  Widget _buildMonthTitle() {
    return Padding(
      padding: const EdgeInsets.only(left: 30, top: 5),
      child: Text('${_displayMonth.year}年${_displayMonth.month}月',
          style: const TextStyle(
              color: Color(0xFF464646),
              fontSize: 20,
              fontWeight: FontWeight.bold)),
    );
  }

  /// 月历(对应 CalendarLayout + CalendarView, marginH20):
  /// 周标题(#111) + 翻月 PageView + mode_only_current + 选中圆 #FFA572
  Widget _buildCalendarView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // 周标题行 - 对齐 week_text_color #111(周日开头)
          Row(
            children: ['日', '一', '二', '三', '四', '五', '六']
                .map((w) => Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(w,
                              style: const TextStyle(
                                  color: Color(0xFF111111), fontSize: 13)),
                        ),
                      ),
                    ))
                .toList(),
          ),
          SizedBox(
            height: 6 * 58,
            child: PageView.builder(
              controller: _monthPageController,
              onPageChanged: (index) {
                final month = _monthFromIndex(index);
                setState(() => _displayMonth = month);
              },
              itemBuilder: (context, index) {
                final month = _monthFromIndex(index);
                return _MonthGrid(
                  displayMonth: month,
                  selectedDate: _selectedDate,
                  onSelectDate: _onCalendarSelect,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 冲煞/岁煞/五行卡(对应 gone 卡, 经确认显示)
  Widget _buildChongshaCard() {
    final bean = _almanac;
    final wuxingText = bean == null
        ? ''
        : '五行甲子：${_emptyInfo(bean.wuxingjiazi)} ,'
            '五行年：${_emptyInfo(bean.wuxingnayear)} ,'
            '五行月：${_emptyInfo(bean.wuxingnamonth)} , '
            '天干地支年：${_emptyInfo(bean.tiangandizhiyear)}'
            '天干地支月：${_emptyInfo(bean.tiangandizhimonth)} ,'
            '天干地支日：${_emptyInfo(bean.tiangandizhiday)}   ';
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('冲煞：',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(_emptyInfo(bean?.chongsha),
                    style: const TextStyle(color: Colors.black, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text('岁煞：',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(_emptyInfo(bean?.suisha),
                    style: const TextStyle(color: Colors.black, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(wuxingText,
              style: const TextStyle(color: Colors.black, fontSize: 13)),
        ],
      ),
    );
  }

  /// 12 星座横向列表(对应 gone 的 xingzuo_info_details_list, 经确认显示)
  Widget _buildXingzuoList() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(right: 10),
        itemCount: _xingzuoList.length,
        itemBuilder: (context, index) {
          final name = _xingzuoList[index][0];
          final icon = _xingzuoList[index][1];
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _initXingZuo(name),
            child: SizedBox(
              width: 100,
              child: Padding(
                padding: const EdgeInsets.only(left: 10, top: 10),
                child: Column(
                  children: [
                    Image.asset(icon, width: 56, height: 56),
                    const SizedBox(height: 10),
                    Text(name,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 星座解析卡(对应 gone 的 xingzuo_details 白卡, 经确认显示)
  /// 文本格式对齐安卓: title\ngrade\ncontent, 13sp #819948
  Widget _buildXingzuoDetailCard() {
    final result = _xingzuoInfo;
    final text = (result != null && result.code == 200 && result.result != null)
        ? '${result.result!.title}\n${result.result!.grade}\n${result.result!.content}'
        : '';
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(5),
            child: Text('星座解析',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: Text(text,
                style: const TextStyle(color: Color(0xFF819948), fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

/// 单月日历网格 - 对齐 haibin CalendarView(riliMonthView) + mode_only_current
/// 每个 cell: 日期(上) + 农历(下); 选中圆 #FFA572 白字; 今天红字; 农历 #CFCFCF
class _MonthGrid extends StatelessWidget {
  final DateTime displayMonth;
  final DateTime selectedDate;
  final void Function(DateTime) onSelectDate;

  const _MonthGrid({
    required this.displayMonth,
    required this.selectedDate,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final firstOfMonth =
        DateTime(displayMonth.year, displayMonth.month, 1);
    // 周日开头(DateTime.weekday: 周一=1..周日=7)
    final firstWeekday = firstOfMonth.weekday % 7;
    final daysInMonth =
        DateTime(displayMonth.year, displayMonth.month + 1, 0).day;
    // 注意: List.filled 默认 growable=false,必须显式 growable:true,
    // 否则 cells.add() 抛 UnsupportedError 导致 PageView 红屏
    final cells = List<DateTime>.filled(
        firstWeekday, DateTime(2000),
        growable: true);
    for (var d = 1; d <= daysInMonth; d++) {
      cells.add(DateTime(displayMonth.year, displayMonth.month, d));
    }
    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.95,
      padding: EdgeInsets.zero,
      children: [
        for (final date in cells)
          date.year == 2000
              // mode_only_current: 非当月格子留空
              ? const SizedBox.shrink()
              : _buildCell(date, today),
      ],
    );
  }

  Widget _buildCell(DateTime date, DateTime today) {
    final isSelected = date == selectedDate;
    final isToday = date == today;
    // 对齐 riliMonthView.onDrawText 颜色映射:
    // 选中→白; 今天→haibin 默认今天红 #ED6C60; 当月→#333333 / 农历 #CFCFCF
    final dayColor = isSelected
        ? Colors.white
        : isToday
            ? const Color(0xFFED6C60)
            : const Color(0xFF333333);
    final lunarColor = isSelected
        ? Colors.white
        : isToday
            ? const Color(0xFFED6C60)
            : const Color(0xFFCFCFCF);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onSelectDate(date),
      child: Center(
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          // 对应 onDrawSelected: 选中圆 mRadius = min(itemW,itemH)/5*2
          decoration: isSelected
              ? const BoxDecoration(
                  color: Color(0xFFFFA572), shape: BoxShape.circle)
              : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(date.day.toString(),
                  style: TextStyle(
                      color: dayColor,
                      fontSize: 14,
                      fontWeight:
                          isToday ? FontWeight.bold : FontWeight.normal)),
              Text(LunarUtil.lunarLabel(date),
                  style: TextStyle(color: lunarColor, fontSize: 9)),
            ],
          ),
        ),
      ),
    );
  }
}
