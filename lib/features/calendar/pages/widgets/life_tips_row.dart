// 生活小窍门 Row - 对齐 Android NearbyFragment Row(padding 30dp)
// Image shenghxts 106dp(fillMaxWidth, clickable→xiaoqiaomen.html H5 "生活小贴士")
// + Column("生活小窍门" 18sp White Medium lineHeight 25sp + 描述 12sp White Medium lineHeight 17sp)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../router/route_names.dart';

class LifeTipsRow extends StatelessWidget {
  const LifeTipsRow({super.key});

  @override
  Widget build(BuildContext context) {
    // 对齐 Android Row(modifier = Modifier.padding(30.dp))
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Row(
        children: [
          // 对齐 Android Image(shenghxts, size 106dp, fillMaxWidth, clickable→H5)
          GestureDetector(
            onTap: () => context.push(RoutePaths.lifeTips),
            behavior: HitTestBehavior.opaque,
            child: Image.asset(
              AppAssets.lifeTipsIcon,
              width: 106,
              height: 106,
              fit: BoxFit.fill,
            ),
          ),
          // 对齐 Android Column
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // "生活小窍门" 18sp White Medium lineHeight 25sp
                  Text(
                    '生活小窍门',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      height: 25 / 18,
                    ),
                  ),
                  // 描述 12sp White Medium
                  Text(
                    '若有小面积皮肤损伤或烧伤、烫伤，抹上少许牙膏，可立即止血止痛，也可防止感染，疗效颇佳。',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
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
