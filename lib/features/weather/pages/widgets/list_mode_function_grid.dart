// 七日周报列表 - 对齐 Android WeatherChildFragment.ListModeFunctionGrid（行 659-705）
// 保真：Android 用 LazyColumn 竖向滚动 + spacedBy 10dp + 项间 Divider 0.8dp white alpha 0.2
// 鸿蒙改为普通 Column（不用 ListView）—— 因为外层已用 SingleChildScrollView 整体滑动
//   （对齐用户决策"安卓只能七日周报滑，鸿蒙整体滑动"）
// 数据为空直接返回 SizedBox.shrink()（对齐 Android if isEmpty return）
import 'package:flutter/material.dart';
import '../../models/weather_model.dart';
import 'list_mode_function_card.dart';

class ListModeFunctionGrid extends StatelessWidget {
  /// 七日天气数据列表 - 对齐 Android weather7DList（由调用方 take(7) 后传入）
  final List<DailyWeather> dailyList;

  const ListModeFunctionGrid({super.key, required this.dailyList});

  @override
  Widget build(BuildContext context) {
    // 数据为空时不显示 - 对齐 Android if (weeklyForecasts.isEmpty()) return
    if (dailyList.isEmpty) {
      return const SizedBox.shrink();
    }

    // 用 Column 循环生成 item + Divider（不用 LazyColumn/ListView，避免与外层滚动冲突）
    final children = <Widget>[];
    for (var i = 0; i < dailyList.length; i++) {
      children.add(ListModeFunctionCard(weather: dailyList[i], index: i));
      // 项间 Divider：最后一条不添加 - 对齐 Android 行 691
      if (i != dailyList.length - 1) {
        // spacedBy 10dp - LazyColumn 的 verticalArrangement.spacedBy(10.dp)
        children.add(const SizedBox(height: 10));
        // Divider 0.8dp white alpha 0.2 padding vertical 1dp - 对齐 Android 行 693-696
        children.add(Container(
          height: 0.8,
          color: const Color(0x33FFFFFF),
          margin: const EdgeInsets.symmetric(vertical: 1),
        ));
        // spacedBy 10dp - 下一项前的间距
        children.add(const SizedBox(height: 10));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}
