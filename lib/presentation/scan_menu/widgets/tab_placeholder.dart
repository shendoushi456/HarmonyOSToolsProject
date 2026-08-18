import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Tab 占位页面
///
/// 用于 ScanMenuActivity 的第二、三个页面（违章查询、应急电话）入口预留。
/// 对应 Android: SearchCarInfoFragment、TelephoneCarFragment（暂未迁移，仅预留入口）。
class TabPlaceholder extends StatelessWidget {
  final String title;

  const TabPlaceholder({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: AppColors.primary.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              '$title（待迁移）',
              style: const TextStyle(fontSize: 16, color: AppColors.secondaryText),
            ),
            const SizedBox(height: 8),
            const Text(
              '该页面入口已预留，功能待后续迁移',
              style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
            ),
          ],
        ),
      ),
    );
  }
}
