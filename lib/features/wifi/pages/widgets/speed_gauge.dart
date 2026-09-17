// 测速仪表盘 - 对齐 Android activity_speed_net.xml 的 imageView(megabitps)+barImageView(shelf 指针)
// 指针旋转对齐 RotateAnimation(lastPosition, position) 100ms 线性插值
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';

class SpeedGauge extends StatelessWidget {
  final String backgroundAsset; // megabitps / megabyteps
  final double positionDegrees; // 对齐 getPositionByRate 结果
  const SpeedGauge({
    super.key,
    required this.backgroundAsset,
    required this.positionDegrees,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Image.asset(backgroundAsset, fit: BoxFit.contain),
          ),
          // 指针(shelf 图,按角度旋转)
          AnimatedRotation(
            turns: positionDegrees / 360,
            duration: const Duration(milliseconds: 100),
            curve: Curves.linear,
            child: Image.asset(AppAssets.wifiBoxShelf,
                width: 200, height: 200, fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }
}
