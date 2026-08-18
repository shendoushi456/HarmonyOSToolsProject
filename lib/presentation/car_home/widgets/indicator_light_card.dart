import 'package:flutter/material.dart';

/// 单个指示灯卡片（首页横向列表用）
///
/// 对应 Android: CarFragment.kt:521-578 IndicatorLightCardFromData
/// 宽 166dp，高 68dp，白底卡片，左侧图标 + 右侧名称与描述（超 30 字截断加"……"）。
class IndicatorLightCard extends StatelessWidget {
  final String name;
  final String description;
  final String iconAsset;
  final VoidCallback? onTap;

  const IndicatorLightCard({
    super.key,
    required this.name,
    required this.description,
    required this.iconAsset,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final truncatedDescription = description.length > 30
        ? '${description.substring(0, 30)}……'
        : description;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 166,
        height: 68,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 24,
                height: 25,
                child: Image.asset(iconAsset),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF404040),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      truncatedDescription,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF777777),
                        height: 11 / 8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
