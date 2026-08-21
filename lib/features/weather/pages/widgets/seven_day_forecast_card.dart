// 七日预报卡片 - 对齐 Android WeatherChildFragment.SevenDayReport + SevenDayWeatherCard
// SevenDayReport: Column padding h 20 + shadow 4dp + RoundedCorner 18dp + white bg + padding 18dp
// SevenDayWeatherCard: ListView 横向 spacedBy 20dp + take(7) + Box width 50dp + RoundedCorner 100dp
//   选中 0xFF66B7F6 + Column padding v 16 spacedBy 8 CenterHorizontally:
//     星期 12sp + 日期 12sp + 天气图标 36dp + 温度 12sp
// 点击时通过 onSelected 通知父级更新顶部 TemperatureDisplay - 对齐 Android
//   onForecastSelected = { forecast -> selectedForecast = forecast; now = forecast }
import 'package:flutter/material.dart';
import '../../../../core/utils/date_util.dart';
import '../../../../core/utils/weather_icon_util.dart';
import '../../models/weather_model.dart';

class SevenDayForecastCard extends StatefulWidget {
  /// 七日天气数据列表 - 对齐 Android weather7DList: List<Weather7D>
  /// 由调用方 take(7) 后传入
  final List<DailyWeather> dailyList;

  /// 选中某天时的回调 - 对齐 Android onForecastSelected: (forecast) -> Unit
  /// 父级据此更新 TemperatureDisplay 显示该天数据
  final ValueChanged<DailyWeather>? onSelected;

  /// 当前选中索引 - 可选外部控制(用于 weather 变化时重置)
  /// 不传则由本地 state 维护
  final int? selectedIndex;

  const SevenDayForecastCard({
    super.key,
    required this.dailyList,
    this.onSelected,
    this.selectedIndex,
  });

  @override
  State<SevenDayForecastCard> createState() => _SevenDayForecastCardState();
}

class _SevenDayForecastCardState extends State<SevenDayForecastCard> {
  /// 当前选中索引 - 对齐 Android SevenDayWeatherCard.selectedIndex (默认 0)
  int _localSelectedIndex = 0;

  /// 获取当前选中索引(优先用外部传入)
  int get _selectedIndex => widget.selectedIndex ?? _localSelectedIndex;

  @override
  void initState() {
    super.initState();
    // 对齐 Android LaunchedEffect: weather7DList 非空时 selectedIndex = 0
    if (widget.dailyList.isNotEmpty) {
      _localSelectedIndex = 0;
    }
  }

  @override
  void didUpdateWidget(SevenDayForecastCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 对齐 Android LaunchedEffect(weather7DList): 列表变化时重置 selectedIndex=0
    // 父级重建时会创建新的 List，不能只比较 List 实例，否则点击后选中态
    // 会立即被重置为第一个日期。
    if (_hasForecastDatesChanged(oldWidget.dailyList, widget.dailyList) &&
        widget.selectedIndex == null) {
      _localSelectedIndex = 0;
    }
  }

  bool _hasForecastDatesChanged(
    List<DailyWeather> previous,
    List<DailyWeather> current,
  ) {
    if (previous.length != current.length) return true;

    for (var index = 0; index < current.length; index++) {
      if (previous[index].fxDate != current[index].fxDate) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dailyList.isEmpty) {
      // 对齐 Android: weather7DList.isEmpty 时 return
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "七日预报"标题 - 对齐 Android Text("七日预报", 16sp Medium 0xFF2A78A7, padding start 20 bottom 16)
        const Padding(
          padding: EdgeInsets.only(left: 20, bottom: 16),
          child: Text(
            '七日预报',
            style: TextStyle(
              color: Color(0xFF2A78A7),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 17 / 16,
            ),
          ),
        ),
        // SevenDayReport - 对齐 Android Column(padding h 20, shadow 4dp, RoundedCorner 18dp, white, padding 18dp)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(18),
            child: _buildSevenDayWeatherCard(),
          ),
        ),
      ],
    );
  }

  /// 七日天气卡片 - 对齐 Android SevenDayWeatherCard LazyRow(spacedBy 20dp, take 7)
  Widget _buildSevenDayWeatherCard() {
    return SizedBox(
      height: 160, // 容纳 Column(padding v 16, spacedBy 8) 内容
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.dailyList.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: 20), // spacedBy 20dp
        itemBuilder: (context, index) {
          final forecast = widget.dailyList[index];
          final isSelected = index == _selectedIndex;
          return _buildForecastItem(forecast, index, isSelected);
        },
      ),
    );
  }

  /// 单个预报项 - 对齐 Android Box(width 50dp, RoundedCorner 100dp, 选中 0xFF66B7F6)
  Widget _buildForecastItem(
    DailyWeather forecast,
    int index,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        // 本地更新选中索引(用于背景色显示) - 对齐 Android selectedIndex = index
        if (widget.selectedIndex == null) {
          setState(() {
            _localSelectedIndex = index;
          });
        }
        // 通知父级更新顶部 TemperatureDisplay - 对齐 Android
        //   onForecastSelected = { forecast -> selectedForecast = forecast; now = forecast }
        widget.onSelected?.call(forecast);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 50,
        decoration: BoxDecoration(
          // 选中蓝色 0xFF66B7F6, 未选中白色
          color: isSelected ? const Color(0xFF66B7F6) : Colors.white,
          borderRadius: BorderRadius.circular(100),
        ),
        // 对齐 Android Column padding vertical 16dp
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          // 对齐 Android verticalArrangement = spacedBy(8dp)
          // 不设 mainAxisAlignment(默认 start), crossAxisAlignment CenterHorizontally
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 星期文本 - 对齐 Android DateUtil.getWeekDay(index, fxDate) 12sp
            Text(
              DateUtil.getWeekDay(index, forecast.fxDate),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8), // spacedBy 8dp
            // 日期 - 对齐 Android forecast.fxDate.substring(5) "MM-dd" 12sp
            // 保真: Android 用 substring(5) 去掉 "yyyy-" 得 "MM-dd"
            Text(
              forecast.fxDate.length >= 6
                  ? forecast.fxDate.substring(5)
                  : forecast.fxDate,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 8), // spacedBy 8dp
            // 天气图标 36dp - 对齐 Android AsyncImage(getWeatherDayIcon(forecast.textDay)) 36dp
            Image.asset(
              WeatherIconUtil.dayIcon(forecast.textDay),
              width: 36,
              height: 36,
            ),
            const SizedBox(height: 8), // spacedBy 8dp
            // 温度范围 - 对齐 Android "${forecast.tempMin}°-${forecast.tempMax}°" 12sp
            Text(
              '${forecast.tempMin}°-${forecast.tempMax}°',
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
