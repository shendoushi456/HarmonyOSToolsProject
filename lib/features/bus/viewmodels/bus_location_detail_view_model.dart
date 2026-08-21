// 地点详情 ViewModel - 对齐 Android bus/viewmodel/BusLocationDetailViewModel.kt
// POI 详情页状态管理：展示目标地点 + 周边搜索 + 主动重定位
//
// 鸿蒙端差异：
// - Android: AndroidViewModel + MutableStateFlow → Flutter: Riverpod Notifier + State
// - Android: PoiSearch.newInstance() + OnGetPoiSearchResultListener 单监听器
// - 鸿蒙端: 每次搜索创建新 BMFPoiNearbySearch 实例避免回调冲突
// - Android: LatLng → 鸿蒙端 BMFCoordinate
// - Android: BaiduMapUtils.calculateDistance 同步 → 鸿蒙端 BaiduMapUtils.calculateDistance 异步
import 'package:flutter/foundation.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';
import 'package:flutter_baidu_mapapi_search/flutter_baidu_mapapi_search.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/baidu_search_result.dart' show BaiduSearchResult, BaiduSearchResultData;
import '../repositories/baidu_location_repository.dart';
import '../utils/baidu_map_utils.dart';

/// 地点详情 UI 状态 - 对齐 Android BusLocationDetailUiState data class
class BusLocationDetailUiState {
  const BusLocationDetailUiState({
    this.searchResult,
    this.locationName = '',
    this.locationDescription = '',
    this.targetLocation,
    this.currentLocation,
    this.currentLocationName = '',
    this.nearbyPOIs = const [],
    this.isLoading = false,
    this.isSearching = false,
    this.errorMessage = '',
    this.shouldResetDrag = false,
    this.shouldResetLocation = false,
  });

  /// 当前展示的搜索结果（对齐 Android searchResult: SearchResult?）
  final BaiduSearchResult? searchResult;

  /// 位置名称
  final String locationName;

  /// 位置描述
  final String locationDescription;

  /// 目标地点坐标（对齐 Android targetLocation: LatLng?）
  final BMFCoordinate? targetLocation;

  /// 当前定位坐标
  final BMFCoordinate? currentLocation;

  /// 当前定位名称
  final String currentLocationName;

  /// 周边 POI 列表
  final List<BaiduSearchResult> nearbyPOIs;

  /// 是否正在加载（定位中）
  final bool isLoading;

  /// 是否正在搜索周边
  final bool isSearching;

  /// 错误信息
  final String errorMessage;

  /// 是否应重置拖拽状态（一次性标记）
  final bool shouldResetDrag;

  /// 是否应重置定位（一次性标记）
  final bool shouldResetLocation;

  BusLocationDetailUiState copyWith({
    BaiduSearchResult? searchResult,
    String? locationName,
    String? locationDescription,
    BMFCoordinate? targetLocation,
    BMFCoordinate? currentLocation,
    String? currentLocationName,
    List<BaiduSearchResult>? nearbyPOIs,
    bool? isLoading,
    bool? isSearching,
    String? errorMessage,
    bool? shouldResetDrag,
    bool? shouldResetLocation,
    bool clearError = false,
    bool clearResetDrag = false,
    bool clearResetLocation = false,
  }) {
    return BusLocationDetailUiState(
      searchResult: searchResult ?? this.searchResult,
      locationName: locationName ?? this.locationName,
      locationDescription: locationDescription ?? this.locationDescription,
      targetLocation: targetLocation ?? this.targetLocation,
      currentLocation: currentLocation ?? this.currentLocation,
      currentLocationName: currentLocationName ?? this.currentLocationName,
      nearbyPOIs: nearbyPOIs ?? this.nearbyPOIs,
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      errorMessage: clearError ? '' : (errorMessage ?? this.errorMessage),
      shouldResetDrag: clearResetDrag ? false : (shouldResetDrag ?? this.shouldResetDrag),
      shouldResetLocation: clearResetLocation ? false : (shouldResetLocation ?? this.shouldResetLocation),
    );
  }
}

/// 地点详情 ViewModel - 对齐 Android BusLocationDetailViewModel
class BusLocationDetailViewModel extends Notifier<BusLocationDetailUiState> {
  /// 定位 Repository（对齐 Android locationRepository = BaiduLocationRepository(application)）
  late final BaiduLocationRepository _locationRepository;

  @override
  BusLocationDetailUiState build() {
    _locationRepository = BaiduLocationRepository();
    return const BusLocationDetailUiState();
  }

  /// 初始化地点详情 - 对齐 Android initLocationDetail
  Future<void> initLocationDetail({
    BaiduSearchResult? searchResult,
    required String locationName,
    required String locationDescription,
    required double latitude,
    required double longitude,
  }) async {
    state = state.copyWith(
      searchResult: searchResult,
      nearbyPOIs: searchResult != null ? [searchResult] : const [],
      locationName: locationName,
      locationDescription: locationDescription,
      targetLocation: BMFCoordinate(latitude, longitude),
      // 对齐 Android: 已经有目标 POI 坐标，详情页可直接显示目标地图，不能被当前定位阻塞
      isLoading: false,
      clearError: true,
    );
    // 对齐 Android: ensurePoiSearchInitialized() - 鸿蒙端 POI 搜索实例按需创建，无需显式初始化
  }

  /// 搜索周边 POI - 对齐 Android searchNearby
  Future<void> searchNearby(String searchKeyword) async {
    final currentState = state;
    // 对齐 Android: val searchLocation = currentState.targetLocation ?: currentState.currentLocation
    final searchLocation = currentState.targetLocation ?? currentState.currentLocation;
    if (searchLocation == null) {
      state = currentState.copyWith(errorMessage: '无法获取搜索位置');
      return;
    }

    state = currentState.copyWith(isSearching: true, clearError: true);

    try {
      // 对齐 Android: PoiNearbySearchOption().location().radius(2000).keyword().pageNum(0).pageCapacity(20)
      final option = BMFPoiNearbySearchOption(
        keywords: [searchKeyword],
        location: searchLocation,
        radius: 2000,
        pageIndex: 0,
        pageSize: 20,
      );

      // 对齐 Android: poiSearch.searchNearby(option) + onGetPoiResult 回调
      // 鸿蒙端: 每次创建新 BMFPoiNearbySearch 实例，注册回调后发起搜索
      final poiSearch = BMFPoiNearbySearch();
      poiSearch.onGetPoiNearbySearchResult(
        callback: (result, errorCode) async {
          if (errorCode == BMFSearchErrorCode.NO_ERROR) {
            // 对齐 Android: result.allPoi.orEmpty().mapNotNull { poiInfo.toSearchResultOrNull() }
            final pois = result.poiInfoList ?? const <BMFPoiInfo>[];
            final searchResults = <BaiduSearchResult>[];
            for (final poiInfo in pois) {
              final converted = await _poiInfoToSearchResultOrNull(poiInfo);
              if (converted != null) {
                searchResults.add(converted);
              }
            }
            state = state.copyWith(
              isSearching: false,
              nearbyPOIs: searchResults,
              clearError: true,
            );
          } else {
            // 对齐 Android: when (result?.error) { KEY_ERROR/PERMISSION_UNFINISHED/NETWORK_ERROR/... }
            final error = _nearbyErrorMessage(errorCode);
            debugPrint('BusLocationDetailViewModel: $error');
            state = state.copyWith(
              isSearching: false,
              errorMessage: error,
            );
          }
        },
      );

      // 对齐 Android: search.searchNearby(option) 返回 started: Boolean
      final ok = await poiSearch.poiNearbySearch(option);
      if (!ok) {
        // 对齐 Android: 地点搜索请求未发送；请检查百度地图 API Key 是否已启用
        state = state.copyWith(
          isSearching: false,
          errorMessage: '地点搜索请求未发送；请检查百度地图 API Key 是否已启用',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('BusLocationDetailViewModel: 周边地点搜索异常: $e\n$stackTrace');
      state = state.copyWith(
        isSearching: false,
        errorMessage: '地点搜索失败：$e',
      );
    }
  }

  /// 仅在用户主动请求时才获取当前定位 - 对齐 Android relocate
  Future<void> relocate() async {
    // 对齐 Android: if (!locationRepository.hasLocationPermission())
    // 鸿蒙端: 权限检查为异步，使用乐观返回，实际由定位超时兜底
    final hasPermission = await _locationRepository.hasLocationPermissionAsync();
    if (!hasPermission) {
      state = state.copyWith(
        errorMessage: '未授予定位权限，请在系统设置中开启定位权限',
      );
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // 对齐 Android: locationRepository.getCurrentLocation().fold(...)
      final location = await _locationRepository.getCurrentLocation();
      if (location != null) {
        state = state.copyWith(
          currentLocation: BMFCoordinate(location.latitude, location.longitude),
          // 对齐 Android: location.address.ifBlank { "当前位置" }
          currentLocationName: location.address.isEmpty ? '当前位置' : location.address,
          isLoading: false,
          shouldResetDrag: true,
          shouldResetLocation: true,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: '定位失败，请稍后重试',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('BusLocationDetailViewModel: 定位异常: $e\n$stackTrace');
      state = state.copyWith(
        isLoading: false,
        errorMessage: '定位失败：$e',
      );
    }
  }

  /// POI 信息转换为 SearchResult - 对齐 Android PoiInfo.toSearchResultOrNull()
  Future<BaiduSearchResult?> _poiInfoToSearchResultOrNull(BMFPoiInfo poiInfo) async {
    // 对齐 Android: val poiLocation = location ?: return null
    final poiLocation = poiInfo.pt;
    if (poiLocation == null) return null;

    // 对齐 Android: if (poiLocation.latitude == 0.0 && poiLocation.longitude == 0.0) return null
    if (poiLocation.latitude == 0.0 && poiLocation.longitude == 0.0) return null;

    // 对齐 Android: if (!BaiduMapUtils.isValidChineseCoordinate(...)) return null
    if (!BaiduMapUtils.isValidChineseCoordinate(poiLocation.latitude, poiLocation.longitude)) {
      return null;
    }

    // 对齐 Android: calculateDistance(this)
    final distance = await _calculateDistance(poiLocation);

    // 鸿蒙端: 复用 BaiduSearchResult 数据类（替代 Android 内部 SearchResult）
    return BaiduSearchResult(
      id: poiInfo.uid ?? '',
      name: poiInfo.name ?? '',
      description: poiInfo.address ?? '',
      address: poiInfo.city ?? '',
      latLng: poiLocation,
      distance: distance,
      iconUrl: '',
    );
  }

  /// 计算距离 - 对齐 Android calculateDistance
  ///
  /// 鸿蒙端差异：Android BaiduMapUtils.calculateDistance 同步返回；
  /// 鸿蒙端 BaiduMapUtils.calculateDistance 异步返回 Future<double>
  Future<String> _calculateDistance(BMFCoordinate poiLocation) async {
    // 对齐 Android: val baseLocation = targetLocation ?: currentLocation ?: return ""
    final baseLocation = state.targetLocation ?? state.currentLocation;
    if (baseLocation == null) return '';

    final distance = await BaiduMapUtils.calculateDistance(
      baseLocation.latitude,
      baseLocation.longitude,
      poiLocation.latitude,
      poiLocation.longitude,
    );
    // 对齐 Android: BaiduMapUtils.formatDistance(...)
    return BaiduMapUtils.formatDistance(distance);
  }

  /// 错误码转消息 - 对齐 Android when (result?.error) { ... }
  String _nearbyErrorMessage(BMFSearchErrorCode errorCode) {
    switch (errorCode) {
      case BMFSearchErrorCode.KEY_ERROR:
      case BMFSearchErrorCode.PERMISSION_UNFINISHED:
        return '地图服务鉴权失败，请检查百度地图 API Key、包名和签名';
      case BMFSearchErrorCode.NETWOKR_ERROR:
      case BMFSearchErrorCode.NETWOKR_TIMEOUT:
        return '网络异常，地点搜索失败';
      default:
        return '地点搜索失败：$errorCode';
    }
  }

  /// 停止定位 - 对齐 Android onCleared 中 locationRepository.stopLocation()
  void stopLocation() {
    _locationRepository.stopLocation();
  }
}

/// 地点详情 ViewModel Provider
final busLocationDetailViewModelProvider =
    NotifierProvider<BusLocationDetailViewModel, BusLocationDetailUiState>(
  BusLocationDetailViewModel.new,
);

/// 仅供 BaiduSearchResultData 类型引用兼容的导出（对齐 Android SearchResultData）
/// 鸿蒙端: 直接复用 models/baidu_search_result.dart 中的 BaiduSearchResultData
typedef SearchResultData = BaiduSearchResultData;
