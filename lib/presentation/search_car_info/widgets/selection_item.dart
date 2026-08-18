import 'package:flutter/material.dart';

/// 单个下拉选择项
///
/// 对应 Android: SearchCarInfoFragment.kt:311-402 SelectionItem
/// 白底圆角卡片 + 标题 + 选中值 + 箭头，点击弹出下拉菜单。
class SelectionItem extends StatelessWidget {
  final String title;
  final String selectedValue;
  final List<String> options;
  final ValueChanged<String> onValueChanged;

  const SelectionItem({
    super.key,
    required this.title,
    required this.selectedValue,
    required this.options,
    required this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: PopupMenuButton<String>(
        onSelected: onValueChanged,
        offset: const Offset(0, 44),
        constraints: const BoxConstraints(maxWidth: 300),
        child: SizedBox(
          height: 38,
          child: Padding(
            padding: const EdgeInsets.only(left: 14, right: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF333333),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      selectedValue,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF999999),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Image.asset(
                      'assets/images/che/ic_che_search_arrow.png',
                      width: 8,
                      height: 8,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        itemBuilder: (context) => options
            .map(
              (option) => PopupMenuItem<String>(
                value: option,
                child: Text(
                  option,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
