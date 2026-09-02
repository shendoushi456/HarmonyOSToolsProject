// 6 污染物卡片 - 对齐 Android WeatherShChildFragment.AirQualityCard + AirQualityRow + AirQualityCardItem
// Box(padding h 20, shadow 4dp, RoundedCorner 18dp, white, padding h 20 v 12, CenterHorizontally)
//   Column: 3 个 AirQualityRow(spacedBy 25dp, weight 1f)
//     第一行: PM2.5(细颗粒物) + PM10(粗颗粒度)
//     第二行: NO₂(二氧化氮) + SO₂(二氧化硫)
//     第三行: CO(一氧化碳) + O3(臭氧)
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../weather/models/weather_model.dart' show AirQuality;

class AirQualityPollutantsCard extends StatelessWidget {
  /// 空气质量数据 - 对齐 Android air (Airbean?)
  final AirQuality? air;

  const AirQualityPollutantsCard({super.key, this.air});

  @override
  Widget build(BuildContext context) {
    // 默认值对齐 Android: air?.pm2p5 ?: "0" 等
    final pm25 = (air?.pm2p5.isNotEmpty == true) ? air!.pm2p5 : '0';
    final pm10 = (air?.pm10.isNotEmpty == true) ? air!.pm10 : '0';
    final no2 = (air?.no2.isNotEmpty == true) ? air!.no2 : '0';
    final so2 = (air?.so2.isNotEmpty == true) ? air!.so2 : '0';
    final co = (air?.co.isNotEmpty == true) ? air!.co : '0';
    final o3 = (air?.o3.isNotEmpty == true) ? air!.o3 : '0';

    // 6 个污染物项 - 对齐 Android AirQualityCard 的 3 行
    final row1 = [
      _AirQualityItem(
          icon: AppAssets.pollutantPm25,
          title: '细颗粒物',
          name: 'PM2.5',
          value: pm25),
      _AirQualityItem(
          icon: AppAssets.pollutantPm10,
          title: '粗颗粒度',
          name: 'PM10',
          value: pm10),
    ];
    final row2 = [
      _AirQualityItem(
          icon: AppAssets.pollutantNo2, title: '二氧化氮', name: 'NO₂', value: no2),
      _AirQualityItem(
          icon: AppAssets.pollutantSo2, title: '二氧化硫', name: 'SO₂', value: so2),
    ];
    final row3 = [
      _AirQualityItem(
          icon: AppAssets.pollutantCo, title: '一氧化碳', name: 'CO', value: co),
      _AirQualityItem(
          icon: AppAssets.pollutantO3, title: '臭氧', name: 'O3', value: o3),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            // 对齐 Android shadow elevation 4dp
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        // 对齐 Android padding(horizontal 20, vertical 12)
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            // 第一行: PM2.5 + PM10
            _AirQualityRow(items: row1),
            const SizedBox(height: 12), // Spacer 12dp
            // 第二行: NO₂ + SO₂
            _AirQualityRow(items: row2),
            const SizedBox(height: 12), // Spacer 12dp
            // 第三行: CO + O3
            _AirQualityRow(items: row3),
          ],
        ),
      ),
    );
  }
}

/// 单行污染物卡片 - 对齐 Android AirQualityRow
/// Row(fillMaxWidth, spacedBy 25dp) + 每项 Expanded(weight 1f) + Center
class _AirQualityRow extends StatelessWidget {
  final List<_AirQualityItem> items;

  const _AirQualityRow({required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      // 对齐 Android horizontalArrangement = spacedBy(25dp)
      children: [
        Expanded(
          child: Center(child: _AirQualityCardItem(item: items[0])),
        ),
        const SizedBox(width: 25), // spacedBy 25dp
        Expanded(
          child: Center(child: _AirQualityCardItem(item: items[1])),
        ),
      ],
    );
  }
}

/// 污染物数据项 - 对齐 Android AirQualityItem data class
class _AirQualityItem {
  final String icon;
  final String title;
  final String name;
  final String value;

  const _AirQualityItem({
    required this.icon,
    required this.title,
    required this.name,
    required this.value,
  });
}

/// 单个污染物卡片项 - 对齐 Android AirQualityCardItem
/// Row(padding vertical 8, start 12) + Column(padding start 3, Start)
///   Row: title 13sp 0xFF666666 + name 11sp 0xFF999999 (padding start 6, top 2)
///   Row (padding top 8): 图标 28dp tint 0xFF4B9DFE + value 22sp 0xFF333333 Medium (padding start 8)
class _AirQualityCardItem extends StatelessWidget {
  final _AirQualityItem item;

  const _AirQualityCardItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      // 对齐 Android padding(vertical 8, start 12)
      padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 第一行: title + name
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // title 13sp 0xFF666666 Normal
              Text(
                item.title,
                style: const TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                ),
              ),
              // name 11sp 0xFF999999 Normal (padding start 6, top 2)
              Padding(
                padding: const EdgeInsets.only(left: 6, top: 2),
                child: Text(
                  item.name,
                  style: const TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 11,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
          // 第二行 (padding top 8): 图标 28dp tint 0xFF4B9DFE + value 22sp 0xFF333333 Medium (padding start 8)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 图标 28dp tint 0xFF4B9DFE - 对齐 Android AsyncImage size 28dp + ColorFilter.tint
                ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF4B9DFE),
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(item.icon, width: 28, height: 28),
                ),
                // value 22sp 0xFF333333 Medium (padding start 8)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    item.value,
                    style: const TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
