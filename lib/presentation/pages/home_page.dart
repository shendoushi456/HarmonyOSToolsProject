import 'package:flutter/material.dart';

import '../../features/bootstrap/app_view_model.dart';
import '../../features/health_tips/health_tips_view_model.dart';
import '../../features/home_tools/home_tools_view_model.dart';
import '../widgets/android_vector_icon.dart';
import '../widgets/recipe_grid.dart';
import 'health_tips_page.dart';
import 'home_tools_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.viewModel});
  final AppViewModel viewModel;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  /// 首页/减脂 Tab 对应 Android RecipesToolsMainActivity 的
  /// HomeToolsTwoFragment / JianKangMiaoZhaoFragment（label：首页/减脂）。
  /// “我的”Tab 对应 SettingToolFragment3（原版第 5 个 Tab），
  /// “最近浏览”为鸿蒙侧临时 Tab，按要求移除。
  final _homeToolsViewModel = const HomeToolsViewModel();
  final _healthTipsViewModel = const HealthTipsViewModel();

  // 底部导航配色（bottomnavitemcolor.xml + colorPrimary）：
  // 背景绿 #9FDE6E，选中 #B4F3F3，未选中白。
  static const _navBackground = Color(0xFF9FDE6E);
  static const _navSelected = Color(0xFFB4F3F3);

  @override
  Widget build(BuildContext context) {
    final catalog = widget.viewModel.catalog;
    if (catalog == null) return const SizedBox.shrink();
    const titles = ['菜谱', '减脂', '食谱', '收藏', '我的'];
    return Scaffold(
      // 首页与“我的”还原安卓：无 AppBar（各自页面自带头部结构），
      // 其余 Tab 沿用绿色标题栏（原版 colorPrimary）。
      appBar: (_currentIndex == 0 || _currentIndex == 4)
          ? null
          : AppBar(
              title: Text(titles[_currentIndex]),
              backgroundColor: _navBackground,
            ),
      body: AnimatedBuilder(
        animation: widget.viewModel,
        builder: (context, _) => IndexedStack(
          index: _currentIndex,
          children: [
            HomeToolsPage(
              viewModel: _homeToolsViewModel,
              appViewModel: widget.viewModel,
            ),
            HealthTipsPage(viewModel: _healthTipsViewModel),
            RecipeGrid(
              recipes: widget.viewModel.allRecipes,
              viewModel: widget.viewModel,
              emptyMessage: '暂无食谱',
              emptyIcon: Icons.menu_book_outlined,
            ),
            RecipeGrid(
              recipes: widget.viewModel.favoriteRecipes,
              viewModel: widget.viewModel,
              emptyMessage: '暂无收藏食谱',
              emptyIcon: Icons.favorite_border,
            ),
            SettingsPage(viewModel: widget.viewModel),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: _navBackground,
        selectedItemColor: _navSelected,
        unselectedItemColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          // home.xml：白色四宫格
          _item(0, _vectorIcon(ToolboxVectorIcons.home, 33, 33), '菜谱'),
          // jianzhi_white.png：减脂 Tab 图标（66x69 白色 png，着色处理）
          _item(1, _pngIcon(1, 'jianzhi_white.png'), '减脂'),
          // recent.xml：火焰
          _item(2, _vectorIcon(ToolboxVectorIcons.recent, 512, 512), '食谱'),
          // favorite.xml：心形
          _item(3, _vectorIcon(ToolboxVectorIcons.favorite, 485, 485), '收藏'),
          // wode_bai.png：我的 Tab 图标（白色 png，着色处理）
          _item(4, _pngIcon(4, 'wode_bai.png'), '我的'),
        ],
      ),
    );
  }

  BottomNavigationBarItem _item(int index, Widget icon, String label) {
    final selected = _currentIndex == index;
    return BottomNavigationBarItem(
      icon: IconTheme(
        data: IconThemeData(color: selected ? _navSelected : Colors.white),
        child: icon,
      ),
      label: label,
    );
  }

  /// 按选中状态着色的安卓矢量图标。
  Widget _vectorIcon(String pathData, double vw, double vh) {
    final color =
        _currentIndex == _indexOf(pathData) ? _navSelected : Colors.white;
    return AndroidVectorIcon(
      pathData: pathData,
      viewportWidth: vw,
      viewportHeight: vh,
      color: color,
      size: 26,
    );
  }

  int _indexOf(String pathData) {
    switch (pathData) {
      case ToolboxVectorIcons.home:
        return 0;
      case ToolboxVectorIcons.recent:
        return 2;
      case ToolboxVectorIcons.favorite:
        return 3;
      default:
        return -1;
    }
  }

  /// 白色 png Tab 图标（减脂 jianzhi_white / 我的 wode_bai），
  /// 按选中状态用 srcIn 染色。
  Widget _pngIcon(int index, String assetName) {
    final selected = _currentIndex == index;
    return Image.asset(
      'assets/images/recipes_tools/$assetName',
      width: 26,
      height: 26,
      color: selected ? _navSelected : Colors.white,
      colorBlendMode: BlendMode.srcIn,
    );
  }
}
