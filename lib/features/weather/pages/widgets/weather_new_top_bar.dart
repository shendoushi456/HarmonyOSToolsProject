// 顶部栏 - 对齐 Android WeatherChildFragment.TopAppBar
// 50dp 高 + F5F8FC 背景 + statusBarsPadding + Row(Start 对齐)
// 定位图标 20dp(黑色 tint) + 城市名 22sp SemiBold(点击触发 changeCity)
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';

class WeatherNewTopBar extends StatelessWidget {
  /// 当前城市名
  final String cityName;

  /// 点击城市名回调 - 对齐 Android TopAppBar.Text.clickable { changeCity }
  final VoidCallback? onCityClick;

  const WeatherNewTopBar({
    super.key,
    required this.cityName,
    this.onCityClick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F8FC),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 定位图标 20dp(黑色 tint) - padding start 20
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Colors.black,
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    AppAssets.weatherLocation,
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
              // 城市名 22sp SemiBold(点击触发 changeCity) - padding start 8
              GestureDetector(
                onTap: onCityClick,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    cityName,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      height: 30 / 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
