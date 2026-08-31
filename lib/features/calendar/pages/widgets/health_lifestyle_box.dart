// 健康生活方式卡 - 对齐 Android CalendarFragment 行 92-125 的 Box
// Container margin start20 top0 end20 bottom20 + padding v10 + bg 0xFF333D60 + RoundedCorner 6 →
//   Column(padding v10) → Text("健康生活方式", 16sp White Medium, padding l20 b10) + NewFunctionRow1 + Spacer10 + NewFunctionRow2
import 'package:flutter/material.dart';
import 'health_function_row.dart';

class HealthLifestyleBox extends StatelessWidget {
  const HealthLifestyleBox({super.key});

  @override
  Widget build(BuildContext context) {
    // 整个 widget 树都是常量，用 const 包裹
    return Container(
      margin: const EdgeInsets.only(left: 20, top: 0, right: 20, bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF333D60), // 对齐 bg 0xFF333D60
        borderRadius: BorderRadius.circular(6), // 对齐 RoundedCorner 6dp
      ),
      // 对齐 Android Column padding vertical 10dp
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // "健康生活方式" - 对齐 Android Text("健康生活方式", 16sp White Medium, padding start20 bottom10)
            Padding(
              padding: EdgeInsets.only(left: 20, bottom: 10),
              child: Text(
                '健康生活方式',
                style: TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 16,
                  fontWeight: FontWeight.w500, // Medium
                ),
              ),
            ),
            // 第一行：营养 / 如何缓解压力 - 对齐 Android NewFunctionRow1()
            HealthFunctionRow1(),
            // Spacer 10dp - 对齐 Android Spacer(height 10dp)
            SizedBox(height: 10),
            // 第二行：24节气 / 历史上的今天 - 对齐 Android NewFunctionRow2()
            HealthFunctionRow2(),
          ],
        ),
      ),
    );
  }
}
