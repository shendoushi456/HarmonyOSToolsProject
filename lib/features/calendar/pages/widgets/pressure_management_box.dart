// 压力管理卡片 - 对齐 Android NearbyFragment.PressureManagementBox
// Box(fillMaxWidth, height 165dp, padding horizontal 30dp)
//   Image llifehjyl_bg 315x165dp 背景
//   Row(padding 16dp, Top align):
//     Column(weight 1f, padding end 16dp, CenterVertically):
//       Text "压力管理与放松技巧" 18sp Black Bold (padding bottom 8dp)
//       Text 描述 12sp #464646 lineHeight 18sp
//     Image llifehjyl 90dp (padding end 9dp, Bottom align, contentScale Fit)
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';

class PressureManagementBox extends StatelessWidget {
  const PressureManagementBox({super.key});

  @override
  Widget build(BuildContext context) {
    // 对齐 Android Box(fillMaxWidth, height 165dp, padding horizontal 30dp)
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: SizedBox(
        height: 165,
        width: double.infinity,
        child: Stack(
          children: [
            // 背景图片 - 对齐 Android Image(llifehjyl_bg, size 315x165dp)
            Positioned.fill(
              child: Image.asset(
                AppAssets.pressureCardBg,
                width: 315,
                height: 165,
                fit: BoxFit.fill,
              ),
            ),
            // 内容层 - 对齐 Android Row(padding 16dp, Top align)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 左侧文字 Column - 对齐 Android Column(weight 1f, padding end 16dp, CenterVertically)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // "压力管理与放松技巧" 18sp Black Bold (padding bottom 8dp)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Text(
                                '压力管理与放松技巧',
                                style: TextStyle(
                                  color: Color(0xFF000000),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // 描述 12sp #464646 lineHeight 18sp
                            const Text(
                              '压力是正常反应，不必对抗，允许自己感受情绪写下烦恼（“情绪日记”），有助于客观看待问题，减轻心理负担',
                              style: TextStyle(
                                color: Color(0xFF464646),
                                fontSize: 12,
                                height: 18 / 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // 右侧插图 - 对齐 Android Image(llifehjyl, size 90dp, padding end 9dp, Bottom align, Fit)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 9),
                      child: Image.asset(
                        AppAssets.pressureCardIllustration,
                        width: 90,
                        height: 90,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
