import 'package:flutter/material.dart';

/// MoreFragment 中可迁移的工具入口。排除用户指定不迁移的放大镜功能。
class MoreTool {
  final String title;
  final IconData icon;
  final Color color;
  const MoreTool({
    required this.title,
    required this.icon,
    required this.color,
  });
}
