import 'package:flutter/material.dart';

/// 电话列表项
///
/// 对应 Android: TelephoneCarFragment.kt:349-396 PhoneListItem
/// 白底圆角卡片 + 标题/号码 + 电话图标，点击拨号。
class PhoneListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const PhoneListItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
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
        child: SizedBox(
          height: 57,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF0FC093),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 28,
                  height: 28,
                  child: Image.asset('assets/images/che/ic_che_tel_phone.png'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
