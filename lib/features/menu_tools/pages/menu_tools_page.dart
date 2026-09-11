// MenuFragment 首页(Compose 版) - 对齐 toolbox_c MenuFragment.kt。
// 顶栏天气(城市可点击换城市,温度不带跳转) + 白色圆角内容区:
// 3 识别卡 + 字体大小 banner(点击进放大镜) + 文档工具 4 卡。
// 按用户要求:不放放大镜 banner 模块。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../router/route_names.dart';
import '../../menu_fragment/models/tool_definition.dart';
import '../../menu_fragment/services/tool_navigation_service.dart';
import '../../weather/models/weather_model.dart';
import '../../weather/repositories/city_repository.dart';
import '../../weather/viewmodels/weather_view_model.dart';
import '../viewmodels/menu_tools_view_model.dart';
import 'scan_details_page.dart';

class MenuToolsPage extends ConsumerStatefulWidget {
  const MenuToolsPage({super.key});

  @override
  ConsumerState<MenuToolsPage> createState() => _MenuToolsPageState();
}

class _MenuToolsPageState extends ConsumerState<MenuToolsPage> {
  @override
  void initState() {
    super.initState();
    // 对齐安卓 onResume 的 viewModel.loadData()
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadWeather());
  }

  /// 加载当前城市天气 - 对齐 WlTravelViewModel.loadData:
  /// 读本地城市缓存(默认北京)后请求天气,城市未变且非首次时跳过。
  Future<void> _loadWeather() async {
    final cities = await ref.read(cityRepositoryProvider).loadCities();
    if (cities.isNotEmpty) {
      await ref.read(weatherViewModelProvider.notifier).loadData(cities.first);
    }
  }

  /// 城市点击 - 对齐 changeCity → WlAddCityActivity(单选),
  /// 返回 true 表示已替换城市,重新加载天气。
  Future<void> _changeCity() async {
    final result = await context.push(RoutePaths.citySelect);
    if (result == true) {
      await _loadWeather();
    }
  }

  @override
  Widget build(BuildContext context) {
    final weather = ref.watch(weatherViewModelProvider);
    final recognitionItems = ref.watch(menuRecognitionItemsProvider);
    final functionItems = ref.watch(menuFunctionItemsProvider);
    final today = weather.today;
    return Scaffold(
      backgroundColor: const Color(0xFFC6EBFF),
      body: Column(
        children: [
          _TopBar(
            cityName: weather.cityName,
            today: today,
            onCityTap: _changeCity,
          ),
          // 白色圆角内容区 - 对齐 RoundedCornerShape(top 16) + verticalScroll
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 23),
                    _RecognizeTools(items: recognitionItems),
                    const SizedBox(height: 20),
                    const _TextSizeBanner(),
                    _SecondToolsSection2(items: functionItems),
                    const SizedBox(height: 26),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 顶栏 - 对齐 MenuFragment.TopAppBar:
/// 背景同页面 0xFFC6EBFF,padding(h20, top 12, bottom 7)。
class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.cityName,
    required this.today,
    required this.onCityTap,
  });

  final String cityName;
  final DailyWeather? today;
  final VoidCallback onCityTap;

  @override
  Widget build(BuildContext context) {
    final today = this.today;
    return Container(
      color: const Color(0xFFC6EBFF),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 20, right: 20, top: 12, bottom: 7),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 城市行 - 对齐 Row(padding bottom 4):
                    // 城市名可点击换城市,温度纯展示(用户要求不带跳转)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          GestureDetector(
                            // 安卓 clickable(indication = null)
                            behavior: HitTestBehavior.opaque,
                            onTap: onCityTap,
                            child: Text(
                              cityName,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (today != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '${today.tempMax}°/${today.tempMin}°',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Image.asset(
                              menuToolsWeatherIcon(today.textDay),
                              width: 24,
                              height: 24,
                              fit: BoxFit.contain,
                            ),
                          ] else
                            const Text(
                              '加载中...',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Text(
                      '文件扫描助手',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      '快速扫描.精准识别.轻松管理',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    // "点击查看"按钮 - 对齐 0xFF97D8FA 圆角 30 胶囊
                    Padding(
                      padding: const EdgeInsets.only(left: 10, top: 8),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => ScanDetailsPage.push(context),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF97D8FA),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 2),
                          child: const Text(
                            '点击查看',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 右侧装饰图 150x130 - 对齐 top_bg
              Image.asset(
                AppAssets.menuToolsTopBg,
                width: 150,
                height: 130,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 3 张识别卡 - 对齐 RecognizeTools:水平 20,间距 18。
class _RecognizeTools extends StatelessWidget {
  const _RecognizeTools({required this.items});

  final List<MenuRecognitionItem> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(width: 18),
            Expanded(
              child: _RecognizeToolCard(item: items[i]),
            ),
          ],
        ],
      ),
    );
  }
}

/// 识别卡 - 对齐 RecognizeToolCard:
/// 圆角 10 + padding(top 18, bottom 10) + 40dp 图标 + 12sp 标题。
class _RecognizeToolCard extends StatelessWidget {
  const _RecognizeToolCard({required this.item});

  final MenuRecognitionItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 安卓 clickable(indication = null),无水波纹
      behavior: HitTestBehavior.opaque,
      onTap: () =>
          ToolNavigationService.openDestination(context, item.destination),
      child: Container(
        decoration: BoxDecoration(
          color: item.backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.only(top: 18, bottom: 10),
        child: Column(
          children: [
            Image.asset(
              item.iconAsset,
              width: 40,
              height: 40,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 13),
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E1E1E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 字体大小 banner - 对齐 s_ztdx 图(水平 20,高 188,FillBounds)。
/// 用户指定:点击进入放大镜(安卓原版跳 TextSizeSettingsActivity,按需求改为放大镜)。
class _TextSizeBanner extends StatelessWidget {
  const _TextSizeBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => ToolNavigationService.openDestination(
          context,
          ToolDestination.magnifier,
        ),
        child: Image.asset(
          AppAssets.menuToolsTextSizeBanner,
          height: 188,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}

/// 文档工具区 - 对齐 SecondToolsSection2:padding(top 22, h20),间距 12。
class _SecondToolsSection2 extends StatelessWidget {
  const _SecondToolsSection2({required this.items});

  final List<MenuFunctionItem> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '文档工具',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _FunctionCard(item: items[i]),
          ],
        ],
      ),
    );
  }
}

/// 纵向功能卡 - 对齐 FunctionCard:
/// 白底圆角 8 阴影 3,padding(h16, v12),38dp 图标 + 16sp 标题 + 12sp 描述。
/// 注意:安卓 iconBackgroundColor 参数未参与渲染,保真不渲染图标背景。
class _FunctionCard extends StatelessWidget {
  const _FunctionCard({required this.item});

  final MenuFunctionItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 3,
      borderRadius: BorderRadius.circular(8),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () =>
            ToolNavigationService.openDestination(context, item.destination),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Image.asset(
                item.iconAsset,
                width: 38,
                height: 38,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
