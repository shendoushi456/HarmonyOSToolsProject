// 天气指标组件 - 风速/气压/湿度单项
// 对齐 Android WeatherChildFragment.WeatherMetric
import 'package:flutter/material.dart';

class WeatherMetric extends StatelessWidget {
  final String label;
  final String value;
  final String icon;

  const WeatherMetric({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 85,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(icon, width: 28, height: 28),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
