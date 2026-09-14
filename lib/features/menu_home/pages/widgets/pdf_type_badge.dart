import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

/// 空态占位图 - 显示 "PDF→IMG" / "IMG→PDF" 等类型标识
class PdfTypeBadge extends StatelessWidget {
  final String text;

  const PdfTypeBadge({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.toolsTopBarBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.qmtqBlue,
          ),
        ),
      ),
    );
  }
}
