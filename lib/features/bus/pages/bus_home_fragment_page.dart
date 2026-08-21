// 畅行首页 - 对齐 Android HomeFragment.kt
// 替换原鸿蒙 Flutter 项目的日历页（tab[1]）
// 含头部+搜索栏+路线规划卡片+常用地址区域+权限引导页
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../router/route_names.dart';
import '../models/address_info.dart';
import '../models/route_choice.dart';
import '../repositories/baidu_location_repository.dart';
import '../viewmodels/address_view_model.dart';
import '../viewmodels/common_location_view_model.dart';
import '../widgets/address_section.dart';
import '../widgets/location_permission_content.dart';

/// 畅行首页主题色（对齐 Android HomeFragment.kt 顶部私有常量）
const Color _jbcxAccent = AppColors.jbcxAccent;
const Color _jbcxText = AppColors.jbcxText;

/// 畅行首页 - 对齐 Android HomeFragment
/// 替换原鸿蒙 Flutter 项目的日历页（tab[1]）
class BusHomeFragmentPage extends ConsumerStatefulWidget {
  const BusHomeFragmentPage({super.key});

  @override
  ConsumerState<BusHomeFragmentPage> createState() =>
      _BusHomeFragmentPageState();
}

class _BusHomeFragmentPageState extends ConsumerState<BusHomeFragmentPage> {
  @override
  void initState() {
    super.initState();
    // 对齐 Android HomeFragment.onResume: 检查权限 + 刷新地址
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(commonLocationViewModelProvider.notifier)
          .checkLocationPermission();
      ref.read(addressViewModelProvider.notifier).reload();
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(commonLocationViewModelProvider);

    // 对齐 Android HomeFragment.ScreenContent
    // LaunchedEffect(uiState.hasLocationPermission) { if (hasLocationPermission) getCurrentLocation() }
    if (locationState.hasLocationPermission) {
      // 有权限，触发定位（对齐 Android LaunchedEffect）
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!locationState.isLocating && locationState.currentCity == '定位中') {
          ref
              .read(commonLocationViewModelProvider.notifier)
              .getCurrentLocation();
        }
      });
      // 对齐 Android HomeContent(uiState.currentCity.ifBlank { "北京" })
      // 修复：定位中时显示"定位中"，不掩盖真实状态；空字符串时显示"北京"
      return _HomeContent(
        currentCity: locationState.currentCity.isEmpty
            ? '北京'
            : locationState.currentCity,
      );
    } else {
      // 对齐 Android LocationPermissionContent(subtitle = "用于查看附近功能信息及使用\n路线规划等功能")
      return LocationPermissionContent(
        subtitle: '用于查看附近功能信息及使用\n路线规划等功能',
        onRequestPermission: () => _requestLocationPermission(),
      );
    }
  }

  /// 请求定位权限 - 对齐 Android HomeFragment.requestLocationPermission
  /// 鸿蒙端通过 ArkTS 权限桥接请求系统权限。
  Future<void> _requestLocationPermission() async {
    // 通过统一 Repository 请求定位权限（对齐 Android PermissionX）。
    final repository = BaiduLocationRepository();
    final granted = await repository.requestLocationPermission();
    if (granted) {
      // 权限授予，重新检查权限状态并触发定位
      await ref
          .read(commonLocationViewModelProvider.notifier)
          .checkLocationPermission();
      await ref
          .read(commonLocationViewModelProvider.notifier)
          .getCurrentLocation();
    }
    // 权限被拒绝时，LocationPermissionContent 仍然显示，用户可再次点击"去开启"
  }
}

/// 首页内容 - 对齐 Android HomeFragment.HomeContent
class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.currentCity});

  final String currentCity;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HomeHeader(),
            _HomeSearch(currentCity: currentCity),
            _RoutePlanningCard(currentCity: currentCity),
            // 对齐 Android Text(text = "常用地址", fontSize = 18.sp, fontWeight = FontWeight.Medium)
            const Padding(
              padding: EdgeInsets.only(left: 20, top: 26, bottom: 13),
              child: Text(
                '常用地址',
                style: TextStyle(
                  color: _jbcxText,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 34),
              child: AddressSection(currentCity: currentCity),
            ),
          ],
        ),
      ),
    );
  }
}

/// 首页头部 - 对齐 Android HomeFragment.HomeHeader
/// 渐变背景 + 标题图 + 副标题 + hero图
class _HomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 234,
      // 对齐 Android Brush.verticalGradient(listOf(Color(0xFFBCFFFF), Color.White))
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.jbcxHeaderGradientStart, Colors.white],
        ),
      ),
      child: Stack(
        children: [
          // 左上角标题区 - 对齐 Android Column(align = Alignment.TopStart, padding = start=30, top=61)
          Positioned(
            left: 30,
            top: 61 + MediaQuery.of(context).padding.top,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 对齐 Android AsyncImage(R.mipmap.jbcx_home_title, width = 128.dp)
                Image.asset(
                  AppAssets.jbcxHomeTitle,
                  width: 128,
                  fit: BoxFit.fitWidth,
                ),
                const SizedBox(height: 8),
                // 对齐 Android Text("轻松搞定全程出行", fontSize = 16.sp, fontWeight = FontWeight.Medium)
                const Text(
                  '轻松搞定全程出行',
                  style: TextStyle(
                    color: _jbcxText,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                // 对齐 Android Text("·规划路线    ·查询交通", fontSize = 12.sp, color = 0xFF626262)
                const Text(
                  '·规划路线    ·查询交通',
                  style: TextStyle(
                    color: AppColors.jbcxSubText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // 右下角 hero 图 - 对齐 Android AsyncImage(R.mipmap.jbcx_home_hero, size = 178.dp, align = BottomEnd)
          Positioned(
            right: 12,
            bottom: 0,
            child: Image.asset(
              AppAssets.jbcxHomeHero,
              width: 178,
              height: 178,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

/// 搜索栏 - 对齐 Android HomeFragment.HomeSearch
class _HomeSearch extends StatelessWidget {
  const _HomeSearch({required this.currentCity});

  final String currentCity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _jbcxAccent, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.only(left: 12, right: 16),
        child: Row(
          children: [
            // 对齐 Android AsyncImage(R.mipmap.jbcx_search, size = 19.dp)
            Image.asset(AppAssets.jbcxSearch, width: 19, height: 19),
            const SizedBox(width: 14),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _onSearchTapped(context),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '搜线路、站点、目的地',
                    style: TextStyle(
                      color: AppColors.jbcxInputText,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            // 对齐 Android Box(width=46, height=24, background=JbcxAccent, clickable)
            GestureDetector(
              onTap: () => _onSearchTapped(context),
              child: Container(
                width: 46,
                height: 24,
                decoration: BoxDecoration(
                  color: _jbcxAccent,
                  borderRadius: BorderRadius.circular(23),
                ),
                alignment: Alignment.center,
                child: const Text(
                  '搜索',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 搜索按钮点击 - 对齐 Android RoutenquiryFragment.SearchSection onSearchClick
  /// 直接跳转搜索页，不传 keyword（搜索页自己处理输入）
  void _onSearchTapped(BuildContext context) {
    GoRouter.of(context).push(
      RoutePaths.busSearch,
      extra: {'current_city': currentCity},
    );
  }
}

/// 路线规划卡片 - 对齐 Android HomeFragment.RoutePlanningCard
class _RoutePlanningCard extends StatefulWidget {
  const _RoutePlanningCard({required this.currentCity});

  final String currentCity;

  @override
  State<_RoutePlanningCard> createState() => _RoutePlanningCardState();
}

class _RoutePlanningCardState extends State<_RoutePlanningCard> {
  /// 4 种交通方式 - 对齐 Android routeModes
  final List<RouteChoice> _routeModes = const [
    RouteChoice(
        mode: TransportMode.walking,
        title: '步行路线',
        icon: AppAssets.jbcxRouteWalk),
    RouteChoice(
        mode: TransportMode.cycling,
        title: '骑行路线',
        icon: AppAssets.jbcxRouteCycle),
    RouteChoice(
        mode: TransportMode.driving,
        title: '驾车路线',
        icon: AppAssets.jbcxRouteDrive),
    RouteChoice(
        mode: TransportMode.publicTransport,
        title: '公交路线',
        icon: AppAssets.jbcxRouteBus),
  ];

  /// 当前选中的交通方式值 - 对齐 Android selectedMode by rememberSaveable { mutableStateOf(TransportMode.Walking.value) }
  int _selectedMode = TransportMode.walking.index;

  /// 出发地/目的地 - 对齐 Android fromName/toName/fromLat/fromLng/toLat/toLng
  String _fromName = '';
  double? _fromLat;
  double? _fromLng;
  String _toName = '';
  double? _toLat;
  double? _toLng;

  /// 是否正在编辑出发地 - 对齐 Android editingFrom
  bool _editingFrom = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
      child: Container(
        width: double.infinity,
        height: 186,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // 起终点输入区 - 对齐 Android RoutenquiryFragment.RouteInputPanel
            // 整个面板 clickable，点击后根据 selectedMode 跳转 MapRoutePage（只传 transport_mode）
            GestureDetector(
              onTap: () => _onRoutePanelTapped(context),
              child: SizedBox(
                height: 84,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // 起终点指示器
                      SizedBox(
                        width: 10,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.jbcxRouteStart,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 17,
                              color: AppColors.jbcxDivider,
                            ),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.jbcxRouteEnd,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 起终点输入框 - 对齐 Android RouteInputPanel 中的文字
                      Expanded(
                        child: Column(
                          children: [
                            _LocationLine(
                              text: _fromName.isEmpty ? '请选择出发地' : _fromName,
                              placeholder: _fromName.isEmpty,
                              onTap: () => _onRoutePanelTapped(context),
                            ),
                            Divider(color: AppColors.jbcxDivider, height: 1),
                            _LocationLine(
                              text: _toName.isEmpty ? '请选择目的地' : _toName,
                              placeholder: _toName.isEmpty,
                              onTap: () => _onRoutePanelTapped(context),
                            ),
                          ],
                        ),
                      ),
                      // 交换按钮 - 对齐 Android Box(size=38, clickable)
                      GestureDetector(
                        onTap: _swapLocations,
                        child: SizedBox(
                          width: 38,
                          height: 38,
                          child: Center(
                            child: Text(
                              '⇅',
                              style: TextStyle(
                                color: AppColors.jbcxSwapIcon,
                                fontSize: 27,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // 4 种交通方式 - 对齐 Android LazyRow(height=102, SpaceBetween)
            SizedBox(
              height: 102,
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _routeModes.map((choice) {
                    final selected = _selectedMode == choice.mode.index;
                    return _RouteModeItem(
                      choice: choice,
                      selected: selected,
                      onTap: () => _onModeSelected(choice),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 交换起终点 - 对齐 Android HomeFragment.RoutePlanningCard 交换按钮
  void _swapLocations() {
    setState(() {
      final oldName = _fromName;
      final oldLat = _fromLat;
      final oldLng = _fromLng;
      _fromName = _toName;
      _fromLat = _toLat;
      _fromLng = _toLng;
      _toName = oldName;
      _toLat = oldLat;
      _toLng = oldLng;
    });
  }

  /// 路线输入面板点击 - 对齐 Android RoutenquiryFragment.RouteInputPanel clickable
  /// 整个面板点击后根据 selectedMode 跳转 MapRoutePage（只传 transport_mode，不传起终点）
  /// 让 MapRoutePage 自己处理定位和选址
  void _onRoutePanelTapped(BuildContext context) {
    // 对齐 Android: selectedRouteType?.let { when(routeType) { ... MapRouteActivity.start(context, TransportMode.Xxx) } } ?: run { Toast "请先选择出行方式" }
    final selectedMode = TransportMode.values.firstWhere(
      (m) => m.index == _selectedMode,
      orElse: () => TransportMode.walking,
    );
    GoRouter.of(context).push(
      RoutePaths.mapRoute,
      extra: {
        // MapRoutePage 使用 UI 顺序：公交0、驾车1、骑行2、步行3。
        'transport_mode': TransportModeConverter.toUiInt(selectedMode),
        // 从“请选择出发地/目的地”入口进入时，等待用户主动选择，不自动定位。
        'skip_initial_location': true,
      },
    );
  }

  /// 选择交通方式 - 对齐 Android RoutenquiryFragment.RouteTypeSelector onRouteTypeSelected
  void _onModeSelected(RouteChoice choice) {
    setState(() {
      _selectedMode = choice.mode.index;
    });
  }

  /// 开始路线规划 - 对齐 Android HomeFragment.startRoute（保留原有逻辑，起终点都选了时直接算路）
  void _startRoute(TransportMode mode) {
    if (_fromName.isEmpty ||
        _toName.isEmpty ||
        _fromLat == null ||
        _fromLng == null ||
        _toLat == null ||
        _toLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择出发地和目的地')),
      );
      return;
    }
    GoRouter.of(context).push(
      RoutePaths.mapRoute,
      extra: {
        'transport_mode': TransportModeConverter.toUiInt(mode),
        'start_name': _fromName,
        'start_latitude': _fromLat,
        'start_longitude': _fromLng,
        'end_name': _toName,
        'end_latitude': _toLat,
        'end_longitude': _toLng,
      },
    );
  }
}

/// 路线位置输入行 - 对齐 Android HomeFragment.LocationLine
class _LocationLine extends StatelessWidget {
  const _LocationLine({
    required this.text,
    required this.placeholder,
    required this.onTap,
  });

  final String text;
  final bool placeholder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 36,
        width: double.infinity,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            style: TextStyle(
              color: placeholder
                  ? AppColors.jbcxInputText
                  : const Color(0xFF333333),
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

/// 交通方式项 - 对齐 Android HomeFragment.RoutePlanningCard 中的 Column(74x98)
class _RouteModeItem extends StatelessWidget {
  const _RouteModeItem({
    required this.choice,
    required this.selected,
    required this.onTap,
  });

  final RouteChoice choice;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 74,
        height: 98,
        decoration: BoxDecoration(
          color: selected ? _jbcxAccent : AppColors.jbcxRouteBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 对齐 Android Image(painterResource(choice.icon), size=44, colorFilter=tint)
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                selected ? Colors.white : _jbcxAccent,
                BlendMode.srcIn,
              ),
              child: Image.asset(
                choice.icon,
                width: 44,
                height: 44,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              choice.title,
              style: TextStyle(
                color: selected ? Colors.white : _jbcxText,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
