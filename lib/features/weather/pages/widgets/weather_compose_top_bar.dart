// 顶部栏 - 对齐 Android WeatherChildFragment.TopAppBar（行 209-234）
// 50dp 高 + 0xFF010C39 深蓝背景 + statusBarsPadding + 城市名居中白字 22sp SemiBold
// 点击整个栏触发 onCityClick（对齐 Android TopAppBar.Text.clickable { changeCity }）
// 保真 fallback：城市名空时显示"北京市"（对齐 Android cityName ?: "北京市"）
import 'package:flutter/material.dart';

class WeatherComposeTopBar extends StatelessWidget {
  /// 当前城市名 - 对齐 Android WeatherChildFragment.cityName
  final String cityName;

  /// 点击城市名回调 - 对齐 Android TopAppBar.Text.clickable { changeCity }
  final VoidCallback? onCityClick;

  const WeatherComposeTopBar({
    super.key,
    required this.cityName,
    this.onCityClick,
  });

  @override
  Widget build(BuildContext context) {
    // 保真 fallback：城市名空时显示"北京市"（对齐 Android cityName ?: "北京市"）
    final display = cityName.isEmpty ? '北京市' : cityName;
    return Container(
      color: const Color(0xFF010C39),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 50,
          child: GestureDetector(
            onTap: onCityClick,
            behavior: HitTestBehavior.opaque,
            child: Center(
              child: Text(
                display,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  height: 30 / 22,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
