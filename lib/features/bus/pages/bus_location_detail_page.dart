// 地点详情页 - 对齐 Android bus/BusLocationDetailActivity.kt
// 显示特定地点的详细信息和地图
//
// 迁移说明：
// - Android ComponentActivity + Compose → Flutter ConsumerStatefulWidget
// - Android by viewModels() → ref.watch(busLocationDetailViewModelProvider)
// - Android Intent.getSerializableExtra("search_result") → GoRoute extra['search_result']
// - Android BusRouteActivity.start(context, lat, lng, name, use_my_location=true) → GoRoute push
// - Android NearbyActivity.start(context) → 跳转 BusSearch（鸿蒙端复用搜索页）
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../router/route_names.dart';
import '../models/baidu_search_result.dart';
import '../utils/bus_theme_colors.dart';
import '../viewmodels/bus_location_detail_view_model.dart';
import '../widgets/map_compose.dart';

/// 地点详情页 - 对齐 Android BusLocationDetailActivity
/// 显示特定地点的详细信息和地图
class BusLocationDetailPage extends ConsumerStatefulWidget {
  const BusLocationDetailPage({super.key, this.extra});

  /// 路由参数。由 GoRoute builder 注入，避免在 initState 中通过
  /// GoRouterState.of(context) 访问 InheritedWidget。
  final Map<String, dynamic>? extra;

  @override
  ConsumerState<BusLocationDetailPage> createState() =>
      _BusLocationDetailPageState();
}

class _BusLocationDetailPageState extends ConsumerState<BusLocationDetailPage> {
  @override
  void initState() {
    super.initState();
    // 对齐 Android onCreate: 从 Intent 获取 SearchResultData 并重新组装为 SearchResult
    final extra = widget.extra;
    BaiduSearchResultData? searchResultData;
    BaiduSearchResult? directSearchResult;
    if (extra is Map<String, dynamic>) {
      final raw = extra['search_result'];
      if (raw is BaiduSearchResult) {
        directSearchResult = raw;
      } else if (raw is BaiduSearchResultData) {
        searchResultData = raw;
      } else if (raw is Map<String, dynamic>) {
        searchResultData = BaiduSearchResultData(
          id: (raw['id'] as String?) ?? '',
          name: (raw['name'] as String?) ?? '',
          description: (raw['description'] as String?) ?? '',
          address: (raw['address'] as String?) ?? '',
          latitude: _toDouble(raw['latitude']) ?? 0.0,
          longitude: _toDouble(raw['longitude']) ?? 0.0,
          distance: (raw['distance'] as String?) ?? '',
          iconUrl: (raw['iconUrl'] as String?) ?? '',
        );
      } else if (extra.containsKey('id') || extra.containsKey('name')) {
        // 兼容旧版 BusSearchPage 直接传递字段的格式。
        searchResultData = BaiduSearchResultData(
          id: (extra['id'] as String?) ?? '',
          name: (extra['name'] as String?) ?? '',
          description: (extra['description'] as String?) ?? '',
          address: (extra['address'] as String?) ?? '',
          latitude: _toDouble(extra['latitude']) ?? 0.0,
          longitude: _toDouble(extra['longitude']) ?? 0.0,
          distance: (extra['distance'] as String?) ?? '',
          iconUrl: (extra['iconUrl'] as String?) ?? '',
        );
      }
    }

    // 对齐 Android: val searchResult = searchResultData?.let { SearchResult(it) }
    final searchResult =
        directSearchResult ?? searchResultData?.toSearchResult();

    // 对齐 Android: 提取需要的数据，设置默认值
    final locationName = searchResult?.name ?? '天安门';
    final locationDescription = _resolveDescription(searchResult);
    final latitude = searchResult?.latLng.latitude ?? 39.908692;
    final longitude = searchResult?.latLng.longitude ?? 116.397477;

    // 对齐 Android: viewModel.initLocationDetail(...)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(busLocationDetailViewModelProvider.notifier).initLocationDetail(
            searchResult: searchResult,
            locationName: locationName,
            locationDescription: locationDescription,
            latitude: latitude,
            longitude: longitude,
          );
    });
  }

  /// 解析地点描述 - 对齐 Android when { description.isNotEmpty() ...; address.isNotEmpty() ...; else 默认 }
  String _resolveDescription(BaiduSearchResult? result) {
    if (result == null) return '北京市中轴线和长安街的交汇点';
    if (result.description.isNotEmpty) return result.description;
    if (result.address.isNotEmpty) return result.address;
    return '北京市中轴线和长安街的交汇点';
  }

  /// 兼容 num / int / double 的转换
  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // 对齐 Android LocationDetailScreenContent(uiState, onSearchNearbyClick, onRelocateClick)
    final uiState = ref.watch(busLocationDetailViewModelProvider);

    return Scaffold(
      // 对齐 Android topBar = { AppBar(uiState.locationName) }
      appBar: _LocationDetailAppBar(title: uiState.locationName),
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            // 地图区域 - 对齐 Android MapArea(padding bottom 176)
            Positioned.fill(
              bottom: 176,
              child: _MapArea(
                uiState: uiState,
                onRelocateClick: () {
                  // 对齐 Android: viewModel.relocate()
                  ref
                      .read(busLocationDetailViewModelProvider.notifier)
                      .relocate();
                },
              ),
            ),
            // 底部信息面板 - 对齐 Android LocationInfoPanel(align BottomCenter, height 176)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 176,
              child: _LocationInfoPanel(
                locationName: uiState.locationName,
                locationDescription: uiState.locationDescription,
                onSearchNearbyClick: () {
                  // 对齐 Android: NearbyActivity.start(this)
                  // 鸿蒙端复用搜索页作为 Nearby 入口
                  context.push(RoutePaths.busSearch);
                },
                onNavigateClick: () {
                  // 对齐 Android: BusRouteActivity.start(this, lat, lng, name, use_my_location=true)
                  final target = uiState.targetLocation;
                  context.push(
                    RoutePaths.busRoute,
                    extra: {
                      'destination_latitude': target?.latitude ?? 39.908692,
                      'destination_longitude': target?.longitude ?? 116.397477,
                      'destination_name': uiState.locationName,
                      'use_my_location': true,
                    },
                  );
                },
              ),
            ),
            // 加载指示器 - 对齐 Android if (isLoading) CircularProgressIndicator(center, PRIMARY_COLOR)
            if (uiState.isLoading)
              const Center(
                child: CircularProgressIndicator(
                  color: BusThemeColors.primaryColor,
                ),
              ),
            // 错误提示 - 对齐 Android if (errorMessage.isNotEmpty) Card(...)
            if (uiState.errorMessage.isNotEmpty)
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Card(
                  color: const Color(0xFFFFEBEE),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      uiState.errorMessage,
                      style: const TextStyle(color: Color(0xFFD32F2F)),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 顶部导航栏 - 对齐 Android AppBar(title)
class _LocationDetailAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _LocationDetailAppBar({required this.title});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(50);

  @override
  Widget build(BuildContext context) {
    // 对齐 Android Box(背景 PRIMARY_COLOR, statusBarsPadding, height 50)
    return Container(
      color: BusThemeColors.primaryColor,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 50,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 返回按钮 - 对齐 Android Box(start 18dp, clickable, padding 12)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 18),
                  child: IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.arrow_back,
                      size: 18,
                      color: BusThemeColors.onPrimaryColor,
                    ),
                  ),
                ),
              ),
              // 标题 - 对齐 Android Text(title, padding horizontal 50, center, color ON_PRIMARY, 22sp, SemiBold, maxLines 1, Ellipsis)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: BusThemeColors.onPrimaryColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 地图区域 - 对齐 Android MapArea
class _MapArea extends StatelessWidget {
  const _MapArea({
    required this.uiState,
    required this.onRelocateClick,
  });

  final BusLocationDetailUiState uiState;
  final VoidCallback onRelocateClick;

  @override
  Widget build(BuildContext context) {
    // 对齐 Android: MapCompose(currentLocation, searchResults = nearbyPOIs, resetLocation, resetUserDrag, onLocationButtonClick)
    return MapCompose(
      currentLocation: uiState.currentLocation,
      searchResults: uiState.nearbyPOIs
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
      resetLocation: uiState.shouldResetLocation,
      resetUserDrag: uiState.shouldResetDrag,
      // 详情页进入时以搜索结果作为地图目标，而不是等待设备当前位置。
      isSearchTargetLocation: true,
      targetLocation: uiState.targetLocation,
      onLocationButtonClick: onRelocateClick,
    );
  }
}

/// 底部地点信息面板 - 对齐 Android LocationInfoPanel
class _LocationInfoPanel extends StatelessWidget {
  const _LocationInfoPanel({
    required this.locationName,
    required this.locationDescription,
    required this.onSearchNearbyClick,
    required this.onNavigateClick,
  });

  final String locationName;
  final String locationDescription;
  final VoidCallback onSearchNearbyClick;
  final VoidCallback onNavigateClick;

  @override
  Widget build(BuildContext context) {
    // 对齐 Android Box(shadow 4dp, 圆角 top 20, 白底, padding start 20 end 35 top 20 bottom 41)
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
      padding: const EdgeInsets.only(
        left: 20,
        right: 35,
        top: 20,
        bottom: 41,
      ),
      child: Column(
        children: [
          // 地点信息区域 - 对齐 Android LocationInfoSection
          _LocationInfoSection(
            locationName: locationName,
            locationDescription: locationDescription,
          ),
          const SizedBox(height: 30),
          // 按钮区域 - 对齐 Android ActionButtonsSection
          _ActionButtonsSection(
            onSearchNearbyClick: onSearchNearbyClick,
            onNavigateClick: onNavigateClick,
          ),
        ],
      ),
    );
  }
}

/// 地点信息区域 - 对齐 Android LocationInfoSection
class _LocationInfoSection extends StatelessWidget {
  const _LocationInfoSection({
    required this.locationName,
    required this.locationDescription,
  });

  final String locationName;
  final String locationDescription;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 对齐 Android Text(locationName, color 0xFF454545, 16sp, Medium, maxLines 1, Ellipsis)
        Text(
          locationName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF454545),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        // 对齐 Android Text(locationDescription, color 0xFF8A8A8A, 12sp, maxLines 1, Ellipsis)
        Text(
          locationDescription,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF8A8A8A),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

/// 操作按钮区域 - 对齐 Android ActionButtonsSection
class _ActionButtonsSection extends StatelessWidget {
  const _ActionButtonsSection({
    required this.onSearchNearbyClick,
    required this.onNavigateClick,
  });

  final VoidCallback onSearchNearbyClick;
  final VoidCallback onNavigateClick;

  @override
  Widget build(BuildContext context) {
    return Row(
      // 对齐 Android Row(padding horizontal 16, spacedBy 16)
      children: [
        // 搜周边按钮 - 对齐 Android Box(weight 1, shadow 4dp, 圆角 6, 白底, padding vertical 8)
        Expanded(
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            elevation: 4,
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: onSearchNearbyClick,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                child: const Text(
                  '搜周边',
                  style: TextStyle(
                    color: Color(0xFF454545),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // 到这去按钮 - 对齐 Android Box(weight 1, 背景 PRIMARY_COLOR, 圆角 6, padding vertical 8)
        Expanded(
          child: Material(
            color: BusThemeColors.primaryColor,
            borderRadius: BorderRadius.circular(6),
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: onNavigateClick,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                child: const Text(
                  '到这去',
                  style: TextStyle(
                    color: BusThemeColors.onPrimaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
