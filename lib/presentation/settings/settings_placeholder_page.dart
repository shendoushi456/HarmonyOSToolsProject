import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// 设置页占位
///
/// 对应 Android: com.cln.setting/SettSet2Activity（仅入口跳转，不迁移内部实现）
/// CarHomePage 右上角设置图标跳转到此页。
class SettingsPlaceholderPage extends StatelessWidget {
  const SettingsPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.settings, size: 64, color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              '设置页（待迁移）',
              style: TextStyle(fontSize: 16, color: AppColors.primaryText),
            ),
            SizedBox(height: 8),
            Text(
              '对应 Android SettSet2Activity，功能待后续迁移',
              style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
            ),
          ],
        ),
      ),
    );
  }
}
