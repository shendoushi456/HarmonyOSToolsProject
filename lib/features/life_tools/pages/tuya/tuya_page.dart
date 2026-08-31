// TuyaActivity Flutter 迁移版 - 涂鸦分流页
// 对齐 Android activity_tuya.xml + TuyaActivity.kt
// 单页双区：mFltyLL(4 分类按钮→OffLineTypeActivity) + mLxtyLL(6 分类按钮→CategoryItemsActivity)
// 保真 Bug：mode=category 隐藏 mFltyLL 显示 mLxtyLL(6 按钮)；mode=offline 反之
import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../color_more/category_items_page.dart';
import '../color_more/offline_category_page.dart';

class TuyaPage extends StatelessWidget {
  const TuyaPage({super.key, required this.mode, required this.title});

  final String mode;
  final String title;

  static Future<void> push(
    BuildContext context, {
    required String mode,
    required String title,
  }) =>
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TuyaPage(mode: mode, title: title),
        ),
      );

  @override
  Widget build(BuildContext context) {
    // 保真 Bug：mode=category 隐藏 mFltyLL 显示 mLxtyLL；mode=offline 反之
    final showFlty = mode != 'category'; // offline 或其他 → 显示 mFltyLL
    final showLxty = mode != 'offline'; // category 或其他 → 显示 mLxtyLL
    return Scaffold(
      backgroundColor: AppColors.homeBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (showFlty) _buildFltyArea(context),
                    if (showLxty) _buildLxtyArea(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 顶栏（对齐 activity_tuya.xml:22-54 mRv）
  Widget _buildTopBar(BuildContext context) {
    return Container(
      height: 50,
      color: AppColors.homeBg,
      child: Row(
        children: [
          // 返回按钮（对齐 iv_back，黑色 tint，padding 10dp）
          SizedBox(
            width: 56,
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                padding: const EdgeInsets.all(10),
                icon: ColorFiltered(
                  colorFilter:
                      const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                  child: Image.asset(AppAssets.tuyaBack, width: 24, height: 24),
                ),
                onPressed: () => Navigator.maybePop(context),
              ),
            ),
          ),
          // 标题（对齐 tv_title 22sp 黑色）
          Expanded(
            child: Center(
              child: Text(
                title,
                style: const TextStyle(fontSize: 22, color: Colors.black),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          // 右侧占位，确保标题相对整个顶栏居中且不会挤到返回按钮。
          const SizedBox(width: 56),
        ],
      ),
    );
  }

  /// mFltyLL 区 - 4 分类按钮 2×2（对齐 :67-214）
  /// 水果/字母/数字/曼茶罗 → OfflineCategoryPage
  Widget _buildFltyArea(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 13),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: _buildCategoryButton(
                context,
                AppAssets.tuyaFruit,
                '水果',
                () => OfflineCategoryPage.push(context, classify: '水果'),
              )),
              const SizedBox(width: 8),
              Expanded(
                  child: _buildCategoryButton(
                context,
                AppAssets.tuyaLetter,
                '字母',
                () => OfflineCategoryPage.push(context, classify: '字母'),
              )),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _buildCategoryButton(
                context,
                AppAssets.tuyaNumber,
                '数字',
                () => OfflineCategoryPage.push(context, classify: '数字'),
              )),
              const SizedBox(width: 8),
              Expanded(
                  child: _buildCategoryButton(
                context,
                AppAssets.tuyaMandala,
                '曼茶罗',
                () => OfflineCategoryPage.push(context, classify: '曼茶罗'),
              )),
            ],
          ),
        ],
      ),
    );
  }

  /// mLxtyLL 区 - 6 分类按钮 3×2（对齐 :217-444）
  /// 卡通/动物/食物/交通/自然/鲜花 → CategoryItemsPage
  Widget _buildLxtyArea(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 13, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: _buildCategoryButton(
                context,
                AppAssets.tuyaCartoon,
                '卡通',
                () => CategoryItemsPage.push(context, code: 2),
              )),
              const SizedBox(width: 8),
              Expanded(
                  child: _buildCategoryButton(
                context,
                AppAssets.tuyaAnimal,
                '动物',
                () => CategoryItemsPage.push(context, code: 3),
              )),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _buildCategoryButton(
                context,
                AppAssets.tuyaFood,
                '食物',
                () => CategoryItemsPage.push(context, code: 4),
              )),
              const SizedBox(width: 8),
              Expanded(
                  child: _buildCategoryButton(
                context,
                AppAssets.tuyaTraffic,
                '交通',
                () => CategoryItemsPage.push(context, code: 5),
              )),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _buildCategoryButton(
                context,
                AppAssets.tuyaNature,
                '自然',
                () => CategoryItemsPage.push(context, code: 6),
              )),
              const SizedBox(width: 8),
              Expanded(
                  child: _buildCategoryButton(
                context,
                AppAssets.tuyaFlower,
                '鲜花',
                () => CategoryItemsPage.push(context, code: 1),
              )),
            ],
          ),
        ],
      ),
    );
  }

  /// 分类按钮（对齐 activity_tuya.xml 各 ShapeLinearLayout）
  /// #4DFFFFFF 圆角 20dp，图标 70dp + 文字 18sp，paddingLeft 12 paddingV 12
  Widget _buildCategoryButton(
    BuildContext context,
    String icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          color: AppColors.homeRecognitionCard,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Image.asset(icon, width: 60, height: 60, fit: BoxFit.fill),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(fontSize: 18, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
