import 'package:flutter/material.dart';

import '../../data/models/recipes_tools_models.dart';
import '../../features/health_tips/health_tips_view_model.dart';
import '../widgets/tool_title_bar.dart';
import 'recipes_web_page.dart';

/// 卡路里查询页 —— 对应 calculatorlibrary CalorieSearchListActivity +
/// activity_calor_search_list.xml：title_bar_tool 标题栏（"食物热量卡路里查询"）
/// + 8 个食物分类入口图（竖排，间距 20dp、1dp #D9D9D9 分隔线）。
/// 点击携带 "shipu"（"1"~"8"）进入 RecipesWebPage（SPuActivity 逻辑）。
class CalorieSearchListPage extends StatelessWidget {
  const CalorieSearchListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = const HealthTipsViewModel().calorieCategories;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const ToolTitleBar(title: '食物热量卡路里查询'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 30, 16, 0),
              child: Column(
                children: [
                  for (var i = 0; i < categories.length; i++) ...[
                    if (i > 0) const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => _openSpu(context, categories[i]),
                      child: Image.asset(
                        categories[i].imagePath,
                        fit: BoxFit.contain,
                      ),
                    ),
                    // 每个入口图片下方的 1dp 分隔线（#D9D9D9）
                    Container(height: 1, color: const Color(0xFFD9D9D9)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 入口点击 —— 原版跳 SPuActivity（extra "shipu"="1"~"8" → 远程 H5）。
  void _openSpu(BuildContext context, CalorieCategoryItem item) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => RecipesWebPage(spuExtra: item.shipuExtra),
    ));
  }
}
