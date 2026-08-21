// 地图搜索页 - 对齐 Android bus/BusMapSearchActivity.kt
// 显示"超市购物"等关键字搜索结果的地图页面
//
// 迁移说明：
// - Android ComponentActivity + Compose → Flutter ConsumerStatefulWidget
// - Android by viewModels() → ref.watch(busMapSearchViewModelProvider)
// - Android ImmersionBar.fullScreen(true).statusBarDarkFont(false) → SafeArea
// - Android Intent.getStringExtra("search_keyword") → GoRoute extra['search_keyword']
// - Android finish() → GoRouter.of(context).pop()
// - Android MapCompose(...) → 复用鸿蒙端 MapCompose Widget
// - Android LazyColumn → ListView.builder
// - Android PermissionX → ArkTS 定位权限桥接
import 'package:flutter/material.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../router/route_names.dart';
import '../models/baidu_search_result.dart';
import '../repositories/baidu_location_repository.dart';
import '../utils/bus_theme_colors.dart';
import '../viewmodels/bus_map_search_view_model.dart';
import '../widgets/map_compose.dart';

/// 地图搜索页 - 对齐 Android BusMapSearchActivity
/// 显示"超市购物"搜索结果的地图页面
class BusMapSearchPage extends ConsumerStatefulWidget {
  const BusMapSearchPage({
    super.key,
    this.extra = const {},
  });

  /// 路由参数，由 GoRoute 构建页面时传入，避免在 initState 中读取 context。
  final Map<String, dynamic> extra;

  @override
  ConsumerState<BusMapSearchPage> createState() => _BusMapSearchPageState();
}

class _BusMapSearchPageState extends ConsumerState<BusMapSearchPage> {
  /// 搜索关键字 - 对齐 Android intent.getStringExtra("search_keyword") ?: "超市购物"
  late final String _searchKeyword;

  /// 是否有定位权限 - 对齐 Android hasLocationPermission()
  bool _hasLocationPermission = false;

  /// 权限检查完成
  bool _permissionChecked = false;

  late final BaiduLocationRepository _locationRepository;

  @override
  void initState() {
    super.initState();
    _locationRepository = BaiduLocationRepository();
    // 对齐 Android onCreate: 从 Intent 获取 search_keyword
    // 鸿蒙端通过 GoRoute extra 传递。
    _searchKeyword = (widget.extra['search_keyword'] as String?) ?? '超市购物';

    // 对齐 Android onCreate: hasLocationPermission() / requestLocationPermission()
    _checkLocationPermission();
  }

  /// 检查定位权限 - 对齐 Android hasLocationPermission()
  Future<void> _checkLocationPermission() async {
    final granted = await _locationRepository.hasLocationPermissionAsync();
    if (!mounted) return;
    setState(() {
      _hasLocationPermission = granted;
      _permissionChecked = true;
    });

    // 对齐 Android: if (hasLocationPermission()) showMapSearch() else requestLocationPermission()
    if (granted) {
      _initMapSearch();
    } else {
      // 对齐 Android: requestLocationPermission()
      _requestLocationPermission();
    }
  }

  /// 请求定位权限 - 对齐 Android locationPermissionLauncher.launch(...)
  Future<void> _requestLocationPermission() async {
    final granted = await _locationRepository.requestLocationPermission();
    if (!mounted) return;
    setState(() {
      _hasLocationPermission = granted;
    });
    if (granted) {
      _initMapSearch();
    }
    // 权限被拒绝时，显示"重新授权"按钮（对齐 Android showPermissionDeniedContent）
  }

  /// 初始化地图搜索 - 对齐 Android showMapSearch() → viewModel.initMapSearch(searchKeyword)
  void _initMapSearch() {
    // 对齐 Android: viewModel.initMapSearch(searchKeyword)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(busMapSearchViewModelProvider.notifier)
          .initMapSearch(_searchKeyword);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 权限未检查完成时显示加载状态，避免无反馈白屏。
    if (!_permissionChecked) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 对齐 Android showPermissionDeniedContent(): 无权限显示提示
    if (!_hasLocationPermission) {
      return Scaffold(
        appBar: _MapSearchAppBar(searchKeyword: _searchKeyword),
        body: Container(
          color: Colors.white,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 对齐 Android Text("需要定位权限才能显示附近地点", color = 0xFF666666)
              const Text(
                '需要定位权限才能显示附近地点',
                style: TextStyle(color: Color(0xFF666666)),
              ),
              const SizedBox(height: 12),
              // 对齐 Android Button(onClick = ::requestLocationPermission) { Text("重新授权") }
              ElevatedButton(
                onPressed: _requestLocationPermission,
                child: const Text('重新授权'),
              ),
            ],
          ),
        ),
      );
    }

    // 对齐 Android MapSearchScreenContent(searchKeyword)
    final uiState = ref.watch(busMapSearchViewModelProvider);

    return Scaffold(
      // 对齐 Android topBar = { AppBar(searchKeyword) }
      appBar: _MapSearchAppBar(searchKeyword: _searchKeyword),
      body: Container(
        color: const Color(0xFFF3F2F2),
        child: Stack(
          children: [
            // 地图区域 - 对齐 Android MapArea(modifier.padding(bottom = 228.dp))
            Positioned.fill(
              bottom: 228,
              child: _MapArea(
                currentLocation: uiState.currentLocation,
                searchResults: uiState.searchResults,
                onLocationButtonClick: () {
                  // 对齐 Android: viewModel.initMapSearch(viewModel.uiState.value.searchKeyword)
                  ref
                      .read(busMapSearchViewModelProvider.notifier)
                      .initMapSearch(uiState.searchKeyword);
                },
              ),
            ),
            // 底部搜索结果面板 - 对齐 Android SearchResultsPanel(align BottomCenter, height 228)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 228,
              child: _SearchResultsPanel(
                searchResults: uiState.searchResults,
                isLoading: uiState.isLoading,
                onItemClick: (result) {
                  // 对齐 Android: BusLocationDetailActivity.start(context, searchResult)
                  context.push(
                    RoutePaths.busLocationDetail,
                    extra: {
                      'search_result': result.toSerializableData(),
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 顶部搜索栏 - 对齐 Android AppBar(searchKeyword)
class _MapSearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _MapSearchAppBar({required this.searchKeyword});

  final String searchKeyword;

  @override
  Size get preferredSize => const Size.fromHeight(76);

  @override
  Widget build(BuildContext context) {
    // 对齐 Android Box(背景 PRIMARY_COLOR, statusBarsPadding, height 76dp)
    return Container(
      color: BusThemeColors.primaryColor,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 76,
          child: Padding(
            // 对齐 Android padding(horizontal = 19.dp, vertical = 17.dp)
            padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 17),
            child: Row(
              children: [
                // 返回按钮 - 对齐 Android Icon(Icons.Default.ArrowBack, tint ON_PRIMARY, size 22)
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 22,
                    color: BusThemeColors.onPrimaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                // 搜索输入框 - 对齐 Android Box(weight 1, 背景白, 圆角 21, padding vertical 9)
                Expanded(
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(21),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(21),
                      onTap: () {
                        // 对齐 Android: BusSearchActivity.start(context)
                        context.push(RoutePaths.busSearch);
                      },
                      child: Container(
                        height: 42,
                        padding: const EdgeInsets.only(
                            left: 18, right: 10, top: 9, bottom: 9),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            // 提示文字 - 对齐 Android Text(searchKeyword, color 0xFF4B4B4B, fontSize 14)
                            Expanded(
                              child: Text(
                                searchKeyword,
                                style: const TextStyle(
                                  color: Color(0xFF4B4B4B),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            // 搜索按钮 - 对齐 Android Box(height 24, 背景 PRIMARY_COLOR, 圆角 12, padding horizontal 10)
                            Container(
                              height: 24,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: BusThemeColors.primaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '搜索',
                                style: TextStyle(
                                  color: BusThemeColors.onPrimaryColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
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
    );
  }
}

/// 地图区域 - 对齐 Android MapArea
class _MapArea extends StatelessWidget {
  const _MapArea({
    required this.currentLocation,
    required this.searchResults,
    required this.onLocationButtonClick,
  });

  /// 当前位置 - 对齐 Android currentLocation: LatLng?
  final BMFCoordinate? currentLocation;

  /// 搜索结果 - 对齐 Android searchResults: List<SearchResult>
  final List<BaiduSearchResult> searchResults;

  /// 定位按钮点击回调
  final VoidCallback onLocationButtonClick;

  @override
  Widget build(BuildContext context) {
    // 对齐 Android: MapCompose(modifier, currentLocation, searchResults, isSearchTargetLocation = false)
    return MapCompose(
      currentLocation: currentLocation,
      // 将 BaiduSearchResult 转换为 MapCompose 接受的 MapSearchResult
      searchResults: searchResults
          .map((r) => MapSearchResult(
                id: r.id,
                name: r.name,
                latLng: r.latLng,
                address: r.address,
                description: r.description,
                distance: r.distance,
                iconUrl: r.iconUrl,
              ))
          .toList(),
      isSearchTargetLocation: false,
      onLocationButtonClick: onLocationButtonClick,
    );
  }
}

/// 底部搜索结果面板 - 对齐 Android SearchResultsPanel
class _SearchResultsPanel extends StatelessWidget {
  const _SearchResultsPanel({
    required this.searchResults,
    required this.isLoading,
    required this.onItemClick,
  });

  final List<BaiduSearchResult> searchResults;
  final bool isLoading;
  final void Function(BaiduSearchResult) onItemClick;

  @override
  Widget build(BuildContext context) {
    // 对齐 Android Box(shadow 4dp, 圆角 top 20, 白底, padding 20/22)
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    // 对齐 Android when { isLoading -> ...; empty -> ...; else -> LazyColumn }
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 对齐 Android CircularProgressIndicator(size 32, color PRIMARY_COLOR)
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                color: BusThemeColors.primaryColor,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 8),
            // 对齐 Android Text("搜索中...", color 0xFF8A8A8A, fontSize 14)
            const Text(
              '搜索中...',
              style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (searchResults.isEmpty) {
      return Center(
        child: Text(
          '未找到相关地点',
          style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 14),
        ),
      );
    }

    // 对齐 Android LazyColumn(verticalArrangement spacedBy 18)
    return ListView.separated(
      itemCount: searchResults.length,
      separatorBuilder: (_, __) => const SizedBox(height: 18),
      itemBuilder: (context, index) {
        final result = searchResults[index];
        return _SearchResultItem(
          result: result,
          onClick: () => onItemClick(result),
        );
      },
    );
  }
}

/// 单条搜索结果 - 对齐 Android SearchResultItem
class _SearchResultItem extends StatelessWidget {
  const _SearchResultItem({required this.result, required this.onClick});

  final BaiduSearchResult result;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    // 对齐 Android Row(fillMaxWidth, clickable, spacedBy 12)
    return InkWell(
      onTap: onClick,
      child: Row(
        children: [
          // 图标占位 - 对齐 Android Box(size 44) { Box(size 18, 圆形, PRIMARY_COLOR) }
          SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: BusThemeColors.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 文本信息 - 对齐 Android Column(weight 1)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 对齐 Android Text(result.name, color 0xFF454545, fontSize 14, Medium, maxLines 1, Ellipsis)
                Text(
                  result.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF454545),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                // 对齐 Android Text(if (address.isNotEmpty) address else description, color 0xFF8A8A8A, fontSize 10)
                Text(
                  result.address.isNotEmpty
                      ? result.address
                      : result.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF8A8A8A),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          // 距离信息 - 对齐 Android if (distance.isNotEmpty) Text(distance, color PRIMARY_COLOR, 12, Medium)
          if (result.distance.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                result.distance,
                style: const TextStyle(
                  color: BusThemeColors.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
