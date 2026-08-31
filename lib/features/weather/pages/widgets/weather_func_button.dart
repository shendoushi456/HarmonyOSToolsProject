// WeatherFragment 2×2 功能按钮 - 对齐 tools_fr_weather.xml btn_jrjq/btn_lssdjt/btn_shxqm/btn_shjyl
// 结构: RelativeLayout(160dp) + ImageView(btn_0X, fitXY) + 底部白字 16sp paddingBottom10
import 'package:flutter/material.dart';

class WeatherFuncButton extends StatelessWidget {
  /// 按钮背景图(btn_01~04)
  final String imageAsset;

  /// 底部文字
  final String label;

  /// 点击回调
  final VoidCallback? onTap;

  const WeatherFuncButton({
    super.key,
    required this.imageAsset,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // XML: layout_height 160dp
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 160,
        child: Stack(
          children: [
            // ImageView scaleType fitXY
            Positioned.fill(
              child: Image.asset(imageAsset, fit: BoxFit.fill),
            ),
            // TextView: alignParentBottom + centerHorizontal + paddingBottom 10dp
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
