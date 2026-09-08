import 'package:flutter/material.dart';

import '../../data/models/recipes_tools_models.dart';
import '../../features/bootstrap/app_view_model.dart';
import '../../features/home_tools/home_tools_view_model.dart';
import 'calorie_search_list_page.dart';
import 'recipes_list_page.dart';
import 'recipes_web_page.dart';

/// 首页（HomeToolsTwoFragment）—— 对应 fragment_home_tools_two.xml：
/// 顶部绿色标题块（162dp，"首页"白字 22sp 居中偏上）+
/// 食物卡路里查询卡片（beijing_ic 背景 170dp）+
/// 低卡食品推荐横向列表（item：yinying_bg 卡片 192dp）+
/// 菜谱分类横向列表（item：70dp 图标 + 文案）。
class HomeToolsPage extends StatelessWidget {
  const HomeToolsPage({
    super.key,
    required this.viewModel,
    required this.appViewModel,
  });

  final HomeToolsViewModel viewModel;

  /// 菜谱分类点击进入 RecipesListPage 时复用的应用级数据源。
  final AppViewModel appViewModel;

  static const _green = Color(0xFF9FDE6E); // shape_lv_jianbian

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Stack(
        children: [
          // 绿色背景块（162dp，圆角 5dp），"首页"白字 22sp：
          // 原版 FrameLayout gravity=center + marginTop=-40dp
          Container(
            height: 162,
            decoration: BoxDecoration(
              color: _green,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: Transform.translate(
                offset: const Offset(0, -40),
                child: const Text(
                  '首页',
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
              ),
            ),
          ),
          // 内容列：原布局中未约束的 LinearLayout 覆盖在绿色块之上
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80), // kaluli_ll marginTop 80dp
              _CalorieCard(onTap: () => _openCalorieSearch(context)),
              // _CalorieCard(onTap: () => _openCalorieSearch(context)),
              const Padding(
                padding: EdgeInsets.only(top: 30, left: 20),
                child: Text('低卡食品推荐',
                    style: TextStyle(color: Color(0xFF464646), fontSize: 18)),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 21, left: 20, right: 20),
                child: _DiKaList(items: viewModel.diKaTuiJianList),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 30, left: 20),
                child: Text('菜谱分类',
                    style: TextStyle(color: Color(0xFF464646), fontSize: 18)),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 21, left: 20, right: 20),
                child: _CaiPinList(
                  items: viewModel.caiPinFenLeiList,
                  appViewModel: appViewModel,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ],
      ),
    );
  }

  /// 卡路里查询卡片点击 —— 原版跳 CalorieSearchListActivity（extra "shipu"="食物热量"）。
  void _openCalorieSearch(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => const CalorieSearchListPage(),
    ));
  }
}

/// 食物卡路里查询卡片 —— kaluli_ll：beijing_ic 背景、高 170dp、
/// 左 margin 20 / padding 20，三行文案（白 22sp / #C4C4C4 12sp / 绿底白 20sp）。
class _CalorieCard extends StatelessWidget {
  const _CalorieCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=>{},
      child: Container(
        width: double.infinity,
        height: 170,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.only(left: 20),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/recipes_tools/beijing_ic.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 26),
            // const Text('食物卡路里查询',
            //     style: TextStyle(color: Colors.white, fontSize: 22)),
            const SizedBox(height: 4),
            const Text('科学搭配,轻松减脂',
                style: TextStyle(color: Colors.white, fontSize: 22)),
                // style: TextStyle(color: Color(0xFFC4C4C4), fontSize: 22)),
            const SizedBox(height: 10),
            // "点击查看"：shape_lv_jianbian 绿底圆角 5dp，背景紧贴文字（原版无 padding）
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 6),
            //   decoration: BoxDecoration(
            //     color: const Color(0xFF9FDE6E),
            //     borderRadius: BorderRadius.circular(5),
            //   ),
            //   child: const Text('点击查看',
            //       style: TextStyle(color: Colors.white, fontSize: 20)),
            // ),
          ],
        ),
      ),
    );
  }
}

/// 低卡食品推荐横向列表 —— diKaRv：LinearLayoutManager HORIZONTAL，item 间无间距。
class _DiKaList extends StatelessWidget {
  const _DiKaList({required this.items});

  final List<DiKaTuiJianItem> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 202, // item_dika_dapter.xml 固定高
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) => _DiKaItem(item: items[index]),
      ),
    );
  }
}

/// 低卡推荐 item —— item_dika_dapter.xml：yinying_bg.png 卡片背景（150x192dp），
/// 顶部菜品图（150x120dp）、名称 16sp #464646（padding 10）、
/// 卡路里 12sp #969696、右下角"低卡"角标（dika_lv_ic 背景 44x20dp）。
class _DiKaItem extends StatelessWidget {
  const _DiKaItem({required this.item});

  final DiKaTuiJianItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openShiPu(context),
      child: Container(
        width: 150,
        height: 192,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/recipes_tools/yinying_bg.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              item.imagePath,
              width: 150,
              height: 120,
              fit: BoxFit.fill,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(item.name,
                  style:
                      const TextStyle(color: Color(0xFF464646), fontSize: 16)),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 2),
              child: Text(item.kaluli,
                  style:
                      const TextStyle(color: Color(0xFF969696), fontSize: 12)),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                margin: const EdgeInsets.only(right: 10, bottom: 10),
                width: 44,
                height: 20,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                        'assets/images/recipes_tools/dika_lv_ic.png'),
                    fit: BoxFit.fill,
                  ),
                ),
                alignment: Alignment.center,
                child: const Text('低卡',
                    style: TextStyle(color: Color(0xFF5A972C), fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// item 点击 —— 原版跳 ShiPuActivity（extra "shipu"=菜名 → 本地 jianzhi HTML）。
  void _openShiPu(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => RecipesWebPage(shipuTitle: item.name),
    ));
  }
}

/// 菜谱分类横向列表 —— caipinRv。
class _CaiPinList extends StatelessWidget {
  const _CaiPinList({required this.items, required this.appViewModel});

  final List<CaiPinFenLeiItem> items;

  /// 传递给 RecipesListPage 的应用级数据源。
  final AppViewModel appViewModel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 95, // 70dp 图标 + 5dp 间距 + 文字
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final item in items)
            GestureDetector(
              onTap: () => _openList(context, item),
              child: Padding(
                // item_caipu_fen_lei.xml：marginLeft 20 / marginRight 30
                padding: const EdgeInsets.only(left: 20, right: 30),
                child: Column(
                  children: [
                    Image.asset(item.imagePath, width: 70, height: 70),
                    const SizedBox(height: 5),
                    Text(item.name,
                        style: const TextStyle(
                            color: Color(0xFF464646), fontSize: 14)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 分类点击 —— 原版跳 RecipesListActivity（extra p=分类id、title=名称）。
  void _openList(BuildContext context, CaiPinFenLeiItem item) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => RecipesListPage(
        categoryId: item.id,
        title: item.name,
        viewModel: appViewModel,
      ),
    ));
  }
}
