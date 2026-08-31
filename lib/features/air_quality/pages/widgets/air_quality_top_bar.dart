// 空气质量页顶部栏 - 对齐 Android WeatherShChildFragment.TopAppBar（行 315-358）
// 50dp 高 + 0xFF010C39 深蓝背景 + statusBarsPadding + "生活指南" 22sp White SemiBold 居中
// 右上角设置齿轮(40dp White, padding end 16, → setting 路由)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../router/route_names.dart';

class AirQualityTopBar extends StatelessWidget {
  const AirQualityTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    // 对齐 Android Box(fillMaxWidth, statusBarsPadding, bg 0xFF010C39, height 50dp)
    return Container(
      color: const Color(0xFF010C39),
      child: SafeArea(
        top: true,
        bottom: false,
        child: SizedBox(
          height: 50,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 标题 "生活指南" 居中 - 对齐 Android Text(22sp SemiBold White, center, lineHeight 30)
              const Center(
                child: Text(
                  '生活指南',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 22,
                    fontWeight: FontWeight.w600, // SemiBold
                    height: 30 / 22, // lineHeight 30sp
                  ),
                ),
              ),
              // 右上角设置齿轮 - 对齐 Android Icon(Icons.Default.Settings, 40dp White, align CenterEnd, padding end 16)
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () => context.push(RoutePaths.setting),
                  behavior: HitTestBehavior.opaque,
                  child: const Center(
                    child: Icon(
                      Icons.settings,
                      size: 40,
                      color: Color(0xFFFFFFFF),
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
