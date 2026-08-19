import 'package:flutter/material.dart';

import '../../../domain/models/indicator_light.dart';

/// 单个汽车指示灯的详情页。
class IndicatorLightDetailPage extends StatelessWidget {
  final IndicatorLight light;

  const IndicatorLightDetailPage({super.key, required this.light});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(light.name)),
      body: ColoredBox(
        color: const Color(0xFFF5F5F5),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  light.iconAsset,
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                light.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF404040),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                light.description,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF555555),
                  height: 1.7,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
