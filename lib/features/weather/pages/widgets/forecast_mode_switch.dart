// 趋势/列表切换组件 - 对齐 Android ForecastModeSwitch
// 156x32dp 圆角胶囊,选中段 QmtqBlue 底白字
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ForecastModeSwitch extends StatelessWidget {
  final bool showTrend;
  final ValueChanged<bool> onChanged;

  const ForecastModeSwitch({
    super.key,
    required this.showTrend,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 156,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.switchBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _buildSegment('趋势', showTrend, () => onChanged(true)),
          _buildSegment('列表', !showTrend, () => onChanged(false)),
        ],
      ),
    );
  }

  Widget _buildSegment(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: double.infinity,
          decoration: isSelected
              ? BoxDecoration(
                  color: AppColors.qmtqBlue,
                  borderRadius: BorderRadius.circular(18),
                )
              : null,
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isSelected ? Colors.white : AppColors.qmtqText,
              height: 20 / 14,
            ),
          ),
        ),
      ),
    );
  }
}
