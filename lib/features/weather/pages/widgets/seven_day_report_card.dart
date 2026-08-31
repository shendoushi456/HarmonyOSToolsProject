// 七日周报容器 - 对齐 Android WeatherChildFragment.SevenDayReport（行 624-652）
// Container padding top 20 + bg 0xFF333D60 + RoundedCorner(topLeft 30, topRight 30) + padding h 20 → Column:
//   Spacer 20 + "七日周报" 16sp 白 SemiBold lineHeight 22/16 + Spacer 12 + ListModeFunctionGrid
import 'package:flutter/material.dart';
import '../../models/weather_model.dart';
import 'list_mode_function_grid.dart';

class SevenDayReportCard extends StatelessWidget {
  /// 七日天气数据列表 - 对齐 Android weather7DList（由调用方 take(7) 后传入）
  final List<DailyWeather> dailyList;

  const SevenDayReportCard({super.key, required this.dailyList});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF333D60),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Spacer 20dp - 对齐 Android Spacer(height 20dp)
          const SizedBox(height: 20),
          // 标题 - 对齐 Android Text("七日周报", 16sp 白 SemiBold, lineHeight 22)
          const Text(
            '七日周报',
            style: TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 22 / 16,
            ),
          ),
          // Spacer 12dp - 对齐 Android Spacer(height 12dp)
          const SizedBox(height: 12),
          // 七日天气列表 - 对齐 Android MapModeBottomFunctionCard → ListModeFunctionGrid
          ListModeFunctionGrid(dailyList: dailyList),
        ],
      ),
    );
  }
}
