import 'package:flutter/material.dart';

import '../../../features/menu_fragment/models/tool_definition.dart';

/// 工具项数据 - 对应 Android ScanToolsFragment.ToolItemInfo。
class ScanToolItem {
  const ScanToolItem({
    required this.iconAsset,
    required this.title,
    required this.backgroundColor,
    required this.destination,
  });

  final String iconAsset;
  final String title;
  final Color backgroundColor;
  final ToolDestination destination;
}

/// 工具分类数据 - 对应 Android ScanToolsFragment.ToolCategory。
class ScanToolCategory {
  const ScanToolCategory({
    required this.title,
    required this.tools,
  });

  final String title;
  final List<ScanToolItem> tools;
}