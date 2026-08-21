// 首页（附近） - 对齐 Android NearbyFragment.kt
// 替换原鸿蒙 Flutter 项目的首页（tab[0]，原 WeatherPage）
// 含顶部标题栏 + 功能卡片网格 + 百度地图
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../router/route_names.dart';
import '../../bus/models/common_location_ui_state.dart';
import '../../bus/repositories/baidu_location_repository.dart';
import '../../bus/viewmodels/common_location_view_model.dart';
import '../../bus/widgets/location_permission_content.dart';
import '../../bus/widgets/map_compose.dart';

/// 首页（附近） - 对齐 Android NearbyFragment
/// 替换原 WeatherPage（tab[0]）
class NearbyFragmentPage extends ConsumerStatefulWidget {
  const NearbyFragmentPage({super.key});

  @override
  ConsumerState<NearbyFragmentPage> createState() => _NearbyFragmentPageState();
}

class _NearbyFragmentPageState extends ConsumerState<NearbyFragmentPage> {
  // 颜色常量 - 对齐 Android NearbyFragment
  static const Color _primaryColor = Color(0xFF0FC459);

  /// 大卡片功能项 - 对齐 Android createMockFunctions() → List<NearbyFunction2>
  static const List<_NearbyFunction2> _largeCards = [
    _NearbyFunction2(
      name: '美食',
      description: '点击查看附近美食',
      icon: AppAssets.nearbyFood,
      backgroundColor: Color(0xFFD4DCFF),
    ),
    _NearbyFunction2(
      name: '超市购物',
      description: '点击查看购物超市',
      icon: AppAssets.nearbyMarket,
      backgroundColor: Color(0xFFEFFABE),
    ),
  ];

  /// 小图标功能项 - 对齐 Android createMockFunctions2() → List<NearbyFunction>
  static const List<_NearbyFunction> _smallIcons = [
    _NearbyFunction(
        name: '休闲娱乐',
        icon: AppAssets.nearbyEntertainment,
        backgroundColor: Color(0xFFFFEBC4)),
    _NearbyFunction(
        name: '酒店',
        icon: AppAssets.nearbyHotel,
        backgroundColor: Color(0xFFFED5D9)),
    _NearbyFunction(
        name: '景点',
        icon: AppAssets.nearbyScenic,
        backgroundColor: Color(0xFFDCF2F4)),
    _NearbyFunction(
        name: '卫生间',
        icon: AppAssets.nearbyToilet,
        backgroundColor: Color(0xFFEFFABE)),
    _NearbyFunction(
        name: '地铁站',
        icon: AppAssets.nearbySubway,
        backgroundColor: Color(0xFFC4F9F3)),
    _NearbyFunction(
        name: '公交站',
        icon: AppAssets.nearbyBus,
        backgroundColor: Color(0xFFFFF0B7)),
    _NearbyFunction(
        name: '加油站',
        icon: AppAssets.nearbyGas,
        backgroundColor: Color(0xFFDFE1FF)),
    _NearbyFunction(
        name: '停车场',
        icon: AppAssets.nearbyParking,
        backgroundColor: Color(0xFFDAF3C1)),
  ];

  @override
  void initState() {
    super.initState();
    // 对齐 Android onResume: 检查权限
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(commonLocationViewModelProvider.notifier)
          .checkLocationPermission();
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(commonLocationViewModelProvider);

    // 对齐 Android LaunchedEffect: 有权限则触发定位
    if (locationState.hasLocationPermission &&
        !locationState.isLocating &&
        locationState.currentCity == '定位中') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(commonLocationViewModelProvider.notifier).getCurrentLocation();
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 顶部标题栏 - 对齐 Android TopStatusBar
          _TopStatusBar(),
          // 内容区域
          if (locationState.hasLocationPermission)
            Expanded(child: _NearbyMapContent(locationState: locationState))
          else
            Expanded(
              child: LocationPermissionContent(
                subtitle: '用于查看附近功能信息及使用\n路线规划等功能',
                onRequestPermission: () => _requestLocationPermission(),
              ),
            ),
        ],
      ),
    );
  }

  /// 请求定位权限 - 对齐 Android NearbyFragment.requestLocationPermission
  Future<void> _requestLocationPermission() async {
    final repo = BaiduLocationRepository();
    final granted = await repo.requestLocationPermission();
    if (granted) {
      await ref
          .read(commonLocationViewModelProvider.notifier)
          .checkLocationPermission();
      await ref
          .read(commonLocationViewModelProvider.notifier)
          .getCurrentLocation();
    }
  }
}

/// 顶部标题栏 - 对齐 Android NearbyFragment.TopStatusBar
/// 绿色背景，"首页"标题，50dp 高
class _TopStatusBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _NearbyFragmentPageState._primaryColor,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      height: MediaQuery.of(context).padding.top + 50,
      alignment: Alignment.center,
      child: const Text('首页',
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
    );
  }
}

/// 地图模式内容 - 对齐 Android NearbyMapContent
class _NearbyMapContent extends ConsumerWidget {
  const _NearbyMapContent({required this.locationState});

  final CommonLocationUiState locationState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 大卡片网格 - 对齐 Android ListModeFunctionGrid
          _ListModeFunctionGrid(),
          // 小图标网格 - 对齐 Android HorizontalFunctionScroll
          _HorizontalFunctionScroll(),
          // 地图卡片 - 对齐 Android Card(border=PRIMARY_COLOR)
          Padding(
            padding:
                const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 16),
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(
                    color: _NearbyFragmentPageState._primaryColor, width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: MapCompose(
                  currentLocation: locationState.currentLocation,
                  onLocationButtonClick: () {
                    if (locationState.hasLocationPermission) {
                      ref
                          .read(commonLocationViewModelProvider.notifier)
                          .getCurrentLocation();
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 大卡片网格 - 对齐 Android ListModeFunctionGrid
class _ListModeFunctionGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 16, left: 20, right: 20),
      child: Column(
        spacing: 12,
        children: _NearbyFragmentPageState._largeCards
            .map((func) => _ListModeFunctionCard(
                func: func,
                onTap: () => _handleFunctionClick(context, func.name)))
            .toList(),
      ),
    );
  }
}

/// 大卡片 - 对齐 Android ListModeFunctionCard
class _ListModeFunctionCard extends StatelessWidget {
  const _ListModeFunctionCard({required this.func, required this.onTap});
  final _NearbyFunction2 func;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 3,
                offset: const Offset(0, 1))
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                    color: Color(0xFFFDC844), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Image.asset(func.icon,
                    width: 40, height: 40, fit: BoxFit.contain),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(func.name,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1E1E1E)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(func.description,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF757575)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Image.asset(AppAssets.carrowIcon, width: 18, height: 18),
            ],
          ),
        ),
      ),
    );
  }
}

/// 小图标网格 - 对齐 Android HorizontalFunctionScroll
class _HorizontalFunctionScroll extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final functions = _NearbyFragmentPageState._smallIcons;
    final rows = <List<_NearbyFunction>>[];
    for (var i = 0; i < functions.length; i += 4) {
      rows.add(functions.sublist(
          i, i + 4 > functions.length ? functions.length : i + 4));
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        spacing: 6,
        children: rows
            .map((rowItems) => Row(
                  spacing: 12,
                  children: [
                    ...rowItems.map((func) => Expanded(
                        child: _HorizontalFunctionCard(
                            func: func,
                            onTap: () =>
                                _handleFunctionClick(context, func.name)))),
                    ...List.generate(4 - rowItems.length,
                        (_) => const Expanded(child: SizedBox())),
                  ],
                ))
            .toList(),
      ),
    );
  }
}

/// 小图标卡片 - 对齐 Android HorizontalFunctionCard
class _HorizontalFunctionCard extends StatelessWidget {
  const _HorizontalFunctionCard({required this.func, required this.onTap});
  final _NearbyFunction func;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 3,
                    offset: const Offset(0, 1))
              ],
            ),
            alignment: Alignment.center,
            child: Image.asset(func.icon,
                width: 36, height: 36, fit: BoxFit.contain),
          ),
          const SizedBox(height: 8),
          Text(func.name,
              style: const TextStyle(fontSize: 12, color: Color(0xFF333333)),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

/// 功能点击 - 对齐 Android NearbyFragment.handleFunctionClick
void _handleFunctionClick(BuildContext context, String functionName) {
  GoRouter.of(context)
      .push(RoutePaths.busMapSearch, extra: {'search_keyword': functionName});
}

/// 小图标功能项 - 对齐 Android NearbyFunction
class _NearbyFunction {
  final String name;
  final String icon;
  final Color backgroundColor;
  const _NearbyFunction(
      {required this.name, required this.icon, required this.backgroundColor});
}

/// 大卡片功能项 - 对齐 Android NearbyFunction2
class _NearbyFunction2 {
  final String name;
  final String description;
  final String icon;
  final Color backgroundColor;
  const _NearbyFunction2(
      {required this.name,
      required this.description,
      required this.icon,
      required this.backgroundColor});
}
