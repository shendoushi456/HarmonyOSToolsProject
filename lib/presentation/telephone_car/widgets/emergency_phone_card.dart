import 'package:flutter/material.dart';

/// 紧急电话卡片
///
/// 对应 Android: TelephoneCarFragment.kt:251-292 EmergencyCard
/// 彩色卡片 + 号码 + 标题，点击拨号。
class EmergencyPhoneCard extends StatelessWidget {
  final String number;
  final String title;
  final Color backgroundColor;
  final VoidCallback onTap;

  const EmergencyPhoneCard({
    super.key,
    required this.number,
    required this.title,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
