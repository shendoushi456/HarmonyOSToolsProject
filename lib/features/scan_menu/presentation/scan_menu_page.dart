import 'package:flutter/material.dart';

import 'package:harmonyos_flutter_empty/core/theme/app_colors.dart';
import 'package:harmonyos_flutter_empty/features/translation/presentation/pages/article_translation_page.dart';
import 'package:harmonyos_flutter_empty/features/translation/presentation/pages/doc_translation_page.dart';
import 'package:harmonyos_flutter_empty/features/translation/presentation/pages/photo_translation_page.dart';
import 'package:harmonyos_flutter_empty/features/translation/presentation/pages/setting_translation_page.dart';
import 'package:harmonyos_flutter_empty/features/translation/presentation/pages/text_translation_page.dart';
import 'widgets/placeholder_page.dart';

/// 扫描菜单主容器（5 Tab 底部导航）
///
/// 对应原 Android `ScanMenuActivity`，保真还原底部导航 5 个 Tab：
/// 文本翻译 / 拍照翻译 / 文档翻译 / 文章批改 / 工具中心。
///
/// 5 个 Tab 均实现真实页面：文本翻译（Tab1）、拍照翻译（Tab2）、
/// 文档翻译（Tab3）、文章批改（Tab4）、工具中心（Tab5）。
///
/// 保真说明：原项目 `ScanMenuActivity.initView()` 中 tabIndex 索引与 nav_menu
/// 不一致（索引 1 显示图库、索引 2 显示工具中心），属原项目 Bug。
/// Flutter 版本无外部 tabIndex 入口，默认显示 Tab1，该 Bug 不触发。
class ScanMenuPage extends StatefulWidget {
  const ScanMenuPage({super.key});

  @override
  State<ScanMenuPage> createState() => _ScanMenuPageState();
}

class _ScanMenuPageState extends State<ScanMenuPage> {
  int _currentIndex = 0;

  /// 5 个 Tab 的页面列表
  late final List<Widget> _pages = [
    const TextTranslationPage(),
    const PhotoTranslationPage(),
    const DocTranslationPage(),
    const ArticleTranslationPage(),
    const SettingTranslationPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.counterGray,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(
            icon: _TabIcon(selected: false, index: 0),
            activeIcon: _TabIcon(selected: true, index: 0),
            label: '文本翻译',
          ),
          BottomNavigationBarItem(
            icon: _TabIcon(selected: false, index: 1),
            activeIcon: _TabIcon(selected: true, index: 1),
            label: '拍照翻译',
          ),
          BottomNavigationBarItem(
            icon: _TabIcon(selected: false, index: 2),
            activeIcon: _TabIcon(selected: true, index: 2),
            label: '文档翻译',
          ),
          BottomNavigationBarItem(
            icon: _TabIcon(selected: false, index: 3),
            activeIcon: _TabIcon(selected: true, index: 3),
            label: '文章批改',
          ),
          BottomNavigationBarItem(
            icon: _TabIcon(selected: false, index: 4),
            activeIcon: _TabIcon(selected: true, index: 4),
            label: '工具中心',
          ),
        ],
      ),
    );
  }

  void _onTabTapped(int index) {
    // 保真：原 Tab2 拍照翻译会检查相机权限，此处简化为直接显示占位页
    setState(() {
      _currentIndex = index;
    });
  }
}

/// Tab 图标组件
///
/// 根据 selected 状态切换 true/false 图片，对应原 Android drawable selector。
class _TabIcon extends StatelessWidget {
  const _TabIcon({required this.selected, required this.index});

  final bool selected;
  final int index;

  /// Tab 图标资源名（true=选中，false=未选中）
  static const List<String> _iconTrue = [
    'assets/images/app_icon_tab_1_true.png',
    'assets/images/app_icon_tab_2_true.png',
    'assets/images/app_icon_tab_3_true.png',
    'assets/images/app_icon_tab_4_true.png',
    'assets/images/icon_tab_5_true.png',
  ];

  static const List<String> _iconFalse = [
    'assets/images/app_icon_tab_1_false.png',
    'assets/images/app_icon_tab_2_false.png',
    'assets/images/app_icon_tab_3_false.png',
    'assets/images/app_icon_tab_4_false.png',
    'assets/images/icon_tab_5_false.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      selected ? _iconTrue[index] : _iconFalse[index],
      width: 24,
      height: 24,
    );
  }
}
