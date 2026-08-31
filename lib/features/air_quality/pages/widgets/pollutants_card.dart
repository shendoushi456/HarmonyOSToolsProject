// 6 污染物卡 2 行 3 列 - 对齐 Android WeatherShChildFragment.WeatherInfoCard（行 510-632）+ WeatherInfoCard2（行 635-758）
// Container padding h20 + Row SpaceBetween + 3 个 SizedBox(width 96, bg 0xFF333D60, radius 6, padding v12)
//   每项: Column center[ Image 18x18 + SizedBox 2 + Text 名称 12sp Normal White + SizedBox 8 + Text 数值 18sp Medium White ]
// row1: PM2.5(ic_shzn_01,"细颗粒物",pm2p5) / PM10(ic_shzn_02,"粗颗粒度",pm10) / NO2(ic_shzn_03,"二氧化氮",no2)
// row2: SO2(ic_shzn_04,"二氧化硫",so2) / CO(ic_shzn_05,"一氧化碳",co) / O3(ic_shzn_06,"臭氧",o3)
// 保真："粗颗粒度"（非"粗颗粒物"）严格按安卓原文；数值默认 "0"
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../weather/models/weather_model.dart' show AirQuality;

class PollutantsCard extends StatelessWidget {
  /// 空气质量数据 - 对齐 Android WeatherShChildFragment.air (Airbean?)
  final AirQuality? air;

  /// 是否第二行（true=SO2/CO/O3，false=PM2.5/PM10/NO2）
  final bool isRow2;

  const PollutantsCard({
    super.key,
    required this.air,
    required this.isRow2,
  });

  @override
  Widget build(BuildContext context) {
    // 保真默认值对齐 Android：pm2p5/pm10/no2/so2/co/o3 ?: "0"
    final items = isRow2
        ? [
            _PollutantItem(
              icon: AppAssets.icShzn04,
              name: '二氧化硫',
              value: (air?.so2.isNotEmpty == true) ? air!.so2 : '0',
            ),
            _PollutantItem(
              icon: AppAssets.icShzn05,
              name: '一氧化碳',
              value: (air?.co.isNotEmpty == true) ? air!.co : '0',
            ),
            _PollutantItem(
              icon: AppAssets.icShzn06,
              name: '臭氧',
              value: (air?.o3.isNotEmpty == true) ? air!.o3 : '0',
            ),
          ]
        : [
            _PollutantItem(
              icon: AppAssets.icShzn01,
              name: '细颗粒物',
              value: (air?.pm2p5.isNotEmpty == true) ? air!.pm2p5 : '0',
            ),
            _PollutantItem(
              icon: AppAssets.icShzn02,
              name: '粗颗粒度', // 保真："粗颗粒度"非"粗颗粒物"
              value: (air?.pm10.isNotEmpty == true) ? air!.pm10 : '0',
            ),
            _PollutantItem(
              icon: AppAssets.icShzn03,
              name: '二氧化氮',
              value: (air?.no2.isNotEmpty == true) ? air!.no2 : '0',
            ),
          ];

    // 对齐 Android Box(padding h20) + Row(fillMaxWidth, SpaceBetween)
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map((item) => _buildPollutantColumn(item))
            .toList(),
      ),
    );
  }

  /// 单个污染物列 - 对齐 Android Column(width 96dp, bg 0xFF333D60, RoundedCorner 6, padding v12, CenterHorizontally)
  Widget _buildPollutantColumn(_PollutantItem item) {
    return SizedBox(
      width: 96, // 对齐 width 96dp
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF333D60), // 对齐 bg 0xFF333D60
          borderRadius: BorderRadius.circular(6), // 对齐 RoundedCorner 6dp
        ),
        // 对齐 Android padding(vertical 12.dp)
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图标 18x18 - 对齐 Android AsyncImage size 18dp
            Image.asset(item.icon, width: 18, height: 18),
            const SizedBox(height: 2), // 对齐 padding top 2dp
            // 名称 12sp Normal White - 对齐 Android Text(12sp Normal White)
            Text(
              item.name,
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 8), // 对齐 padding top 8dp
            // 数值 18sp Medium White - 对齐 Android Text(18sp Medium White)
            Text(
              item.value,
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 18,
                fontWeight: FontWeight.w500, // Medium
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 污染物项数据
class _PollutantItem {
  final String icon;
  final String name;
  final String value;

  const _PollutantItem({
    required this.icon,
    required this.name,
    required this.value,
  });
}
