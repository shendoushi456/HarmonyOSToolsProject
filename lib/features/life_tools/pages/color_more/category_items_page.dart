// CategoryItemsPage - 分类涂鸦列表页
// 对齐 Android CategoryItemsActivity.java + activity_category_items.xml
// GridView 2 列，根据 code (1-6) 加载 6 张 gp 线稿
// 点击 item → CategoryDrawPage（对应 MainActivityTwo）
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/tool_top_bar.dart';
import 'category_draw_page.dart';

/// 分类涂鸦列表页 - 对齐 CategoryItemsActivity
/// code: 1=鲜花 2=卡通 3=动物 4=食物 5=交通 6=自然
class CategoryItemsPage extends ConsumerWidget {
  const CategoryItemsPage({super.key, required this.code});

  final int code;

  static Future<void> push(
    BuildContext context, {
    required int code,
  }) =>
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CategoryItemsPage(code: code),
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = _categoryData(code);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4FF),
      appBar: ToolTopBar(title: category.title),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1,
        ),
        itemCount: category.assets.length,
        itemBuilder: (context, index) {
          // 对齐 CategoryItemsActivity:112 selectedPosition = position + 1
          final selectedPosition = index + 1;
          return Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            elevation: 1,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => CategoryDrawPage.push(
                context,
                code: code,
                position: selectedPosition,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  category.assets[index],
                  fit: BoxFit.contain,
                  // Android 跟图素材为白线透明图，errorBuilder 兜底
                  errorBuilder: (_, error, __) => const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 根据 code 返回分类数据 - 对齐 CategoryItemsActivity.setCategoryResources
  /// Thumbnails1-6 数组（strings.xml:123-176）引用 @drawable/gp{code}_{1-6}
  _CategoryInfo _categoryData(int code) {
    switch (code) {
      case 1:
        return const _CategoryInfo(
          title: '鲜花',
          assets: [
            'assets/images/coloring_book/flowers/gp1_1.webp',
            'assets/images/coloring_book/flowers/gp1_2.png',
            'assets/images/coloring_book/flowers/gp1_3.webp',
            'assets/images/coloring_book/flowers/gp1_4.png',
            'assets/images/coloring_book/flowers/gp1_5.webp',
            'assets/images/coloring_book/flowers/gp1_6.png',
          ],
        );
      case 2:
        return const _CategoryInfo(
          title: '卡通',
          assets: [
            'assets/images/coloring_book/cartoons/gp2_1.webp',
            'assets/images/coloring_book/cartoons/gp2_2.png',
            'assets/images/coloring_book/cartoons/gp2_3.png',
            'assets/images/coloring_book/cartoons/gp2_4.png',
            'assets/images/coloring_book/cartoons/gp2_5.png',
            'assets/images/coloring_book/cartoons/gp2_6.png',
          ],
        );
      case 3:
        return const _CategoryInfo(
          title: '动物',
          assets: [
            'assets/images/coloring_book/animals/gp3_1.png',
            'assets/images/coloring_book/animals/gp3_2.webp',
            'assets/images/coloring_book/animals/gp3_3.webp',
            'assets/images/coloring_book/animals/gp3_4.png',
            'assets/images/coloring_book/animals/gp3_5.png',
            'assets/images/coloring_book/animals/gp3_6.png',
          ],
        );
      case 4:
        return const _CategoryInfo(
          title: '食物',
          assets: [
            'assets/images/coloring_book/foods/gp4_1.webp',
            'assets/images/coloring_book/foods/gp4_2.webp',
            'assets/images/coloring_book/foods/gp4_3.webp',
            'assets/images/coloring_book/foods/gp4_4.webp',
            'assets/images/coloring_book/foods/gp4_5.webp',
            'assets/images/coloring_book/foods/gp4_6.png',
          ],
        );
      case 5:
        return const _CategoryInfo(
          title: '交通',
          assets: [
            'assets/images/coloring_book/transport/gp5_1.webp',
            'assets/images/coloring_book/transport/gp5_2.webp',
            'assets/images/coloring_book/transport/gp5_3.png',
            'assets/images/coloring_book/transport/gp5_4.png',
            'assets/images/coloring_book/transport/gp5_5.webp',
            'assets/images/coloring_book/transport/gp5_6.png',
          ],
        );
      case 6:
      default:
        return const _CategoryInfo(
          title: '自然',
          assets: [
            'assets/images/coloring_book/nature/gp6_1.png',
            'assets/images/coloring_book/nature/gp6_2.png',
            'assets/images/coloring_book/nature/gp6_3.png',
            'assets/images/coloring_book/nature/gp6_4.png',
            'assets/images/coloring_book/nature/gp6_5.webp',
            'assets/images/coloring_book/nature/gp6_6.webp',
          ],
        );
    }
  }
}

class _CategoryInfo {
  const _CategoryInfo({required this.title, required this.assets});
  final String title;
  final List<String> assets;
}
