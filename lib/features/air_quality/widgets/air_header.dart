// 空气质量顶部头部 - 对齐 Android AirQualityDashboardFragment.AirHeader(行 126-225)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../router/route_names.dart';
import '../../weather/models/weather_model.dart';
import '../utils/air_index_util.dart';

class AirHeader extends StatelessWidget {
  final AirQuality? airQuality;
  final DailyWeather? today;
  final VoidCallback? onSettingClick;

  const AirHeader({
    super.key,
    required this.airQuality,
    required this.today,
    this.onSettingClick,
  });

  @override
  Widget build(BuildContext context) {
    // aqi 默认 80 - 对齐行 132
    final aqi = airQuality?.aqi ?? 80;
    // category 三级 fallback - 对齐行 133-135
    final airCat = airQuality?.category;
    final category = (airCat != null && airCat.isNotEmpty)
        ? airCat
        : today != null
            ? AirIndexUtil.getAirQuality(today!.tempMax, today!.humidity)
            : AirIndexUtil.aqiCategory(aqi);

    final topPadding = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: 310,
      child: Stack(
        children: [
          // "空气质量"标题 - statusBarsPadding + top 13
          Positioned(
            top: topPadding + 13,
            left: 0,
            right: 0,
            child: const Center(
              child: Text(
                '空气质量',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // 设置按钮 - TopEnd, 44dp 圆, Icons.settings 25dp white
          Positioned(
            top: topPadding + 7,
            right: 10,
            child: GestureDetector(
              onTap: onSettingClick ?? () => context.push(RoutePaths.setting),
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                child: const Icon(Icons.settings, color: Colors.white, size: 25),
              ),
            ),
          ),
          // AQI 卡片 - top 113, horizontal 20, height 167, 渐变背景
          Positioned(
            top: 113,
            left: 20,
            right: 20,
            child: Container(
              height: 167,
              padding: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.airGradientStart, AppColors.airGradientEnd],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 左侧: AQI 数值 + 实时更新 + category
                  SizedBox(
                    width: 134,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          aqi.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 60,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            children: [
                              const Text(
                                '实时更新',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 17),
                                child: Text(
                                  category,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 右侧: 实时更新图标
                  Image.asset(
                    AppAssets.airRefresh,
                    width: 108,
                    height: 108,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
