// 日出日落卡 - 对齐 Android WeatherChildFragment.SunriseSunsetCard2（行 511-621）
// Container margin h 20 + bg 0xFF333D60 + RoundedCorner 10 + padding all 15 → Column:
//   Row SpaceBetween: 日出 Row center spacing 8 [Image sunriseIcon 12x9 + Text sunrise 8sp 0xFFE8E8E8]
//                    日落 Row center spacing 8 [Image sunsetIcon 12x9 + Text sunset 8sp 0xFFE8E8E8]
//   Spacer 13
//   进度行: LayoutBuilder + Stack [Container width=progressRatio bg 0xFF8CC6F1 + Positioned(left=progress*maxWidth-9) Image daylightSunIcon 18x18]
//   Spacer 2
//   底部进度条 Container padding h 9 height 4 bg 0xFFE3E3E3 radius 2
// 保真默认值：sunrise="06:16" / sunset="18:26"（对齐 Android 行 540/560）
// _calculateDaylightProgress 对齐 Android TravelViewModel.calculateDaylightProgress
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../models/weather_model.dart';

class SunriseSunsetCard extends StatelessWidget {
  /// 今日天气数据 - 对齐 Android WeatherChildFragment.now (Weather7D?)
  final DailyWeather? today;

  const SunriseSunsetCard({super.key, this.today});

  @override
  Widget build(BuildContext context) {
    // 保真默认值对齐 Android：sunrise="06:16"（行 540），sunset="18:26"（行 560）
    final sunrise = (today?.sunrise.isNotEmpty == true) ? today!.sunrise : '06:16';
    final sunset = (today?.sunset.isNotEmpty == true) ? today!.sunset : '18:26';

    final progress = _calculateDaylightProgress(
      today?.sunrise,
      today?.sunset,
    );

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
          // 日出/日落时间行 - 对齐 Android Row SpaceBetween
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 日出 - 对齐 Android Row center spacedBy 8 [Image ic_feng_main_3_1 12x9 + Text 8sp]
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    AppAssets.sunriseIcon,
                    width: 12,
                    height: 9,
                  ),
                  const SizedBox(width: 8), // spacedBy 8dp
                  Text(
                    sunrise,
                    style: const TextStyle(
                      color: Color(0xFFE8E8E8),
                      fontSize: 8,
                      fontWeight: FontWeight.normal,
                      height: 10 / 8,
                    ),
                  ),
                ],
              ),
              // 日落 - 对齐 Android Row center spacedBy 8 [Image ic_feng_main_3_2 12x9 + Text 8sp]
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    AppAssets.sunsetIcon,
                    width: 12,
                    height: 9,
                  ),
                  const SizedBox(width: 8), // spacedBy 8dp
                  Text(
                    sunset,
                    style: const TextStyle(
                      color: Color(0xFFE8E8E8),
                      fontSize: 8,
                      fontWeight: FontWeight.normal,
                      height: 10 / 8,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Spacer 13dp
          const SizedBox(height: 13),
          // 进度行 - 对齐 Android Row fillMaxWidth [Box fillMaxWidth(progress) height 0 bg 0xFF8CC6F1 + Image ic_sun 18dp]
          // 太阳图标位置跟随进度末端（LayoutBuilder + Stack + Positioned）
          LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              // 太阳图标 18dp，居中在进度末端：left = progress*maxWidth - 9（图标半径）
              // 保真对齐 Android：Box fillMaxWidth(progress) 后跟 Image 18dp，太阳在进度末端
              final sunLeft = (progress * maxWidth) - 9;
              return SizedBox(
                height: 18,
                width: maxWidth,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // 进度条横线 - 对齐 Android Box height 0 bg 0xFF8CC6F1（height 0 视觉不可见，但语义保留）
                    // 此处用 2dp 高的线让视觉可见，对齐 Android 设计意图
                    Positioned(
                      left: 0,
                      top: 8,
                      child: Container(
                        width: progress * maxWidth,
                        height: 2,
                        color: const Color(0xFF8CC6F1),
                      ),
                    ),
                    // 太阳图标 18dp - 对齐 Android Image ic_sun 18dp
                    Positioned(
                      left: sunLeft < 0 ? 0 : sunLeft,
                      top: 0,
                      child: Image.asset(
                        AppAssets.daylightSunIcon,
                        width: 18,
                        height: 18,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // Spacer 2dp
          const SizedBox(height: 2),
          // 底部进度条 - 对齐 Android Box padding h 9 height 4 bg 0xFFE3E3E3 radius 2
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9),
            child: Container(
              height: 4,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE3E3E3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 计算日照进度 - 对齐 Android TravelViewModel.calculateDaylightProgress
/// 保真：默认 sunrise="06:00" / sunset="18:00"（对齐 Android 行 502-503）
/// 逻辑：解析 "HH:mm" → currentSec/sunriseSec/sunsetSec
///       progress = (current - sunrise) / (sunset - sunrise)
///       若 sunset <= sunrise 或解析失败返回 0，否则 clamp(0, 1)
double _calculateDaylightProgress(String? sunriseStr, String? sunsetStr) {
  // 保真默认值：sunriseStr 空时 "06:00"，sunsetStr 空时 "18:00"
  final sunrise = (sunriseStr == null || sunriseStr.isEmpty) ? '06:00' : sunriseStr;
  final sunset = (sunsetStr == null || sunsetStr.isEmpty) ? '18:00' : sunsetStr;

  try {
    final sr = _parseHHmm(sunrise);
    final ss = _parseHHmm(sunset);
    if (sr == null || ss == null) return 0;

    final now = DateTime.now();
    final currentSec = now.hour * 3600 + now.minute * 60;
    final sunriseSec = sr[0] * 3600 + sr[1] * 60;
    final sunsetSec = ss[0] * 3600 + ss[1] * 60;

    final total = sunsetSec - sunriseSec;
    // 对齐 Android：如果日出时间晚于或等于日落时间，返回 0.0
    if (total <= 0) return 0;

    final elapsed = currentSec - sunriseSec;
    final progress = elapsed / total;
    // 对齐 Android：max(0f, min(1f, progress))
    return progress.clamp(0.0, 1.0);
  } catch (_) {
    // 对齐 Android：ParseException / Exception → return 0f
    return 0;
  }
}

/// 解析 "HH:mm" 格式 - 返回 [hour, minute] 或 null
/// 不用 Dart 3.0 records（SDK 下限 2.19.6 未启用），改用 List<int> 长度 2
List<int>? _parseHHmm(String value) {
  final parts = value.split(':');
  if (parts.length != 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
  return [hour, minute];
}
