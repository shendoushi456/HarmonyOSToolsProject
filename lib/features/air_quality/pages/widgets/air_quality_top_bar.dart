// 空气质量顶部栏 - 对齐 Android WeatherShChildFragment.TopAppBar
// Box(height 50dp, statusBarsPadding) + Text "空气质量" 22sp SemiBold Black center
// + Icon Settings 40dp align CenterEnd padding end 16dp → setting 路由
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../router/route_names.dart';

class AirQualityTopBar extends StatelessWidget {
  const AirQualityTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F8FC),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 50,
          child: Stack(
            children: [
              // 标题 "空气质量" - 对齐 Android Text(fillMaxWidth, align Center, 22sp SemiBold Black, lineHeight 30sp)
              const Positioned.fill(
                child: Center(
                  child: Text(
                    '空气质量',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      height: 30 / 22,
                    ),
                  ),
                ),
              ),
              // 右侧设置图标 - 对齐 Android Icon(Settings, size 40dp, align CenterEnd, padding end 16dp)
              // 点击 → SettSet2Activity(鸿蒙复用 setting 路由)
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () => context.push(RoutePaths.setting),
                  behavior: HitTestBehavior.opaque,
                  child: const Icon(
                    Icons.settings,
                    color: Colors.black,
                    size: 40,
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
