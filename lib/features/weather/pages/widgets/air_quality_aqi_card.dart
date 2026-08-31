// 空气质量 AQI 卡 - 对齐 Android WeatherChildFragment.SunriseSunsetCard（行 434-509）
// 保真说明：Android 函数名是"日出日落"(SunriseSunsetCard) 但实际渲染 AQI（命名误导 Bug）。
//           此处保真保留渲染内容（AQI），文件名/类名改清晰为 AirQualityAqiCard，注释标注原 Bug。
// Container margin h 20 + bg 0xFF333D60 + RoundedCorner 10 + padding all 15 → Column:
//   "空气质量" 12sp 0xFFE8E8E8 lineHeight 14/12
//   Row SpaceBetween End height 20: AQI 18sp 0xFFE8E8E8 + category 8sp 0xFFE8E8E8 Right
//   Spacer 3
//   进度条 Container height 6 bg 0xFFE3E3E3 radius 2 + 子进度 width=(aqi/500).clamp(0,1) bg 0xFF8CC6F1 radius 2
// 保真默认值：aqi=0 / category="暂无"
import 'package:flutter/material.dart';
import '../../models/weather_model.dart';

class AirQualityAqiCard extends StatelessWidget {
  /// 空气质量数据 - 对齐 Android WeatherChildFragment.air (Airbean?)
  final AirQuality? air;

  const AirQualityAqiCard({super.key, this.air});

  @override
  Widget build(BuildContext context) {
    // 保真默认值对齐 Android：aqi=0（行 465），category="暂无"（行 472）
    final aqiValue = air?.aqi ?? 0;
    final category = (air?.category.isNotEmpty == true) ? air!.category : '暂无';

    // 进度 = aqi / 500，clamp [0,1] - 对齐 Android 行 493-495
    final progress = (aqiValue / 500).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF333D60),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // "空气质量"标题 - 对齐 Android Text("空气质量", 12sp 0xFFE8E8E8, lineHeight 14)
          const Text(
            '空气质量',
            style: TextStyle(
              color: Color(0xFFE8E8E8),
              fontSize: 12,
              fontWeight: FontWeight.normal,
              height: 14 / 12,
            ),
          ),
          // AQI 数值 + category - 对齐 Android Row SpaceBetween Bottom height 20dp
          SizedBox(
            height: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // AQI 数值 18sp 0xFFE8E8E8
                Text(
                  '$aqiValue',
                  style: const TextStyle(
                    color: Color(0xFFE8E8E8),
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                // category 8sp 0xFFE8E8E8 Right
                Text(
                  category,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Color(0xFFE8E8E8),
                    fontSize: 8,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          // Spacer 3dp
          const SizedBox(height: 3),
          // 进度条 - 对齐 Android Box height 6dp bg 0xFFE3E3E3 radius 2 + 子 Box fillMaxWidth(progress) bg 0xFF8CC6F1
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Container(
              height: 6,
              width: double.infinity,
              color: const Color(0xFFE3E3E3),
              child: FractionallySizedBox(
                widthFactor: progress,
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF8CC6F1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
