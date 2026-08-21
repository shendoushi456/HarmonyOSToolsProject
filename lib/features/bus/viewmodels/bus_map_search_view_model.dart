// 首页周边地点地图搜索 ViewModel - 对齐 Android bus/viewmodel/BusMapSearchViewModel.kt
// 首页周边地点地图搜索的状态与真实 SDK 调用
//
// 鸿蒙端差异：
// - Android: AndroidViewModel + MutableStateFlow → Flutter: Riverpod Notifier + State
// - Android: PoiSearch.newInstance() + OnGetPoiSearchResultListener 单监听器
// - 鸿蒙端: 每次搜索创建新 BMFPoiNearbySearch 实例避免回调冲突
// - Android: LatLng → 鸿蒙端 BMFCoordinate
// - Android: BaiduMapUtils.calculateDistance 同步 → 鸿蒙端 BaiduMapUtils.calculateDistance 异步
// - Android: SearchResult / SearchResultData 自定义类
// - 鸿蒙端: 复用 models/baidu_search_result.dart 中的 BaiduSearchResult / BaiduSearchResultData
import 'package:flutter/foundation.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';
import 'package:flutter_baidu_mapapi_search/flutter_baidu_mapapi_search.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/baidu_search_result.dart' show BaiduSearchResult, BaiduSearchResultData;
import '../repositories/baidu_location_repository.dart';
import '../utils/baidu_map_utils.dart';

/// 首页周边地点地图搜索 UI 状态 - 对齐 Android BusMapSearchUiState data class
class BusMapSearchUiState {
  const BusMapSearchUiState({
    this.searchKeyword = '',
    this.currentLocation,
    this.locationName = '',
    this.searchResults = const [],
    this.isLoading = false,
    this.errorMessage = '',
  });

  /// 搜索关键字
  final String searchKeyword;

  /// 当前定位坐标（对齐 Android currentLocation: LatLng?）
  final BMFCoordinate? currentLocation;

  /// 当前位置名称
  final String locationName;

  /// 搜索结果列表（复用 BaiduSearchResult，对齐 Android searchResults: List<SearchResult>）
  final List<BaiduSearchResult> searchResults;

  /// 是否正在加载
  final bool isLoading;

  /// 错误信息
  final String errorMessage;

  BusMapSearchUiState copyWith({
    String? searchKeyword,
    BMFCoordinate? currentLocation,
    String? locationName,
    List<BaiduSearchResult>? searchResults,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool clearResults = false,
  }) {
    return BusMapSearchUiState(
      searchKeyword: searchKeyword ?? this.searchKeyword,
      currentLocation: currentLocation ?? this.currentLocation,
      locationName: locationName ?? this.locationName,
      searchResults: clearResults ? const [] : (searchResults ?? this.searchResults),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? '' : (errorMessage ?? this.errorMessage),
    );
  }
}

/// 首页周边地点地图搜索 ViewModel - 对齐 Android BusMapSearchViewModel
class BusMapSearchViewModel extends Notifier<BusMapSearchUiState> {
  /// 统一复用项目的单例定位管理器（对齐 Android 注释：避免不同页面同时创建 LocationClient）
  late final BaiduLocationRepository _locationRepository;

  @override
  BusMapSearchUiState build() {
    _locationRepository = BaiduLocationRepository();
    return const BusMapSearchUiState();
  }

  /// 初始化地图搜索 - 对齐 Android initMapSearch
  Future<void> initMapSearch(String searchKeyword) async {
    state = state.copyWith(
      searchKeyword: searchKeyword,
      clearResults: true,
      isLoading: true,
      clearError: true,
    );

    // 对齐 Android: if (!locationRepository.hasLocationPermission())
    final hasPermission = await _locationRepository.hasLocationPermissionAsync();
    if (!hasPermission) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '未授予定位权限，请在系统设置中开启定位权限',
      );
      return;
    }

    // 对齐 Android: requestCurrentLocation()
    await _requestCurrentLocation();
  }

  /// 请求当前位置 - 对齐 Android requestCurrentLocation
  Future<void> _requestCurrentLocation() async {
    try {
      // 对齐 Android: locationRepository.getCurrentLocation().fold(...)
      final location = await _locationRepository.getCurrentLocation();
      if (location != null) {
        final currentLocation = BMFCoordinate(location.latitude, location.longitude);
        debugPrint('BusMapSearchViewModel: 定位成功：${currentLocation.latitude}, ${currentLocation.longitude}');
        state = state.copyWith(
          currentLocation: currentLocation,
          // 对齐 Android: location.address.ifBlank { "当前位置" }
          locationName: location.address.isEmpty ? '当前位置' : location.address,
        );
        await _searchNearbyPOI();
      } else {
        debugPrint('BusMapSearchViewModel: 定位失败');
        state = state.copyWith(
          isLoading: false,
          errorMessage: '定位失败，请稍后重试',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('BusMapSearchViewModel: 定位异常: $e\n$stackTrace');
      state = state.copyWith(
        isLoading: false,
        errorMessage: '定位失败：$e',
      );
    }
  }

  /// 搜索附近 POI - 对齐 Android searchNearbyPOI
  Future<void> _searchNearbyPOI() async {
    final currentState = state;
    final currentLocation = currentState.currentLocation;
    if (currentLocation == null) {
      state = currentState.copyWith(
        isLoading: false,
        errorMessage: '无法获取当前位置',
      );
      return;
    }

    try {
      // 对齐 Android: PoiNearbySearchOption().location().radius(20000).keyword().pageNum(0).pageCapacity(20)
      final option = BMFPoiNearbySearchOption(
        keywords: [currentState.searchKeyword],
        location: currentLocation,
        radius: 20000,
        pageIndex: 0,
        pageSize: 20,
      );

      // 对齐 Android: poiSearch.searchNearby(option) + onGetPoiResult 回调
      // 鸿蒙端: 每次创建新 BMFPoiNearbySearch 实例避免回调冲突
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
              isLoading: false,
              searchResults: searchResults,
              clearError: true,
            );
          } else {
            // 对齐 Android: when (result?.error) { KEY_ERROR/PERMISSION_UNFINISHED/NETWORK_ERROR/... }
            final error = _nearbyErrorMessage(errorCode);
            debugPrint('BusMapSearchViewModel: $error');
            state = state.copyWith(
              isLoading: false,
              clearResults: true,
              errorMessage: error,
            );
          }
        },
      );

      // 对齐 Android: val started = search.searchNearby(option)
      final ok = await poiSearch.poiNearbySearch(option);
      if (!ok) {
        state = currentState.copyWith(
          isLoading: false,
          errorMessage: '地点搜索请求未发送；请检查百度地图 API Key 是否已启用',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('BusMapSearchViewModel: 附近地点搜索异常: $e\n$stackTrace');
      state = currentState.copyWith(
        isLoading: false,
        errorMessage: '地点搜索失败：$e',
      );
    }
  }

  /// POI 信息转换为 SearchResult - 对齐 Android PoiInfo.toSearchResultOrNull()
  Future<BaiduSearchResult?> _poiInfoToSearchResultOrNull(BMFPoiInfo poiInfo) async {
    // 对齐 Android: val poiLocation = this.location ?: return null
    final poiLocation = poiInfo.pt;
    if (poiLocation == null) return null;

    // 对齐 Android: if (poiLocation.latitude == 0.0 && poiLocation.longitude == 0.0) return null
    if (poiLocation.latitude == 0.0 && poiLocation.longitude == 0.0) return null;

    // 对齐 Android: if (!BaiduMapUtils.isValidChineseCoordinate(...)) return null
    if (!BaiduMapUtils.isValidChineseCoordinate(poiLocation.latitude, poiLocation.longitude)) {
      debugPrint('BusMapSearchViewModel: 跳过范围异常的 POI：${poiInfo.name} (${poiLocation.latitude}, ${poiLocation.longitude})');
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
    // 对齐 Android: val currentLocation = _uiState.value.currentLocation ?: return ""
    final currentLocation = state.currentLocation;
    if (currentLocation == null) return '';

    final distance = await BaiduMapUtils.calculateDistance(
      currentLocation.latitude,
      currentLocation.longitude,
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

/// 首页周边地点地图搜索 ViewModel Provider
final busMapSearchViewModelProvider =
    NotifierProvider<BusMapSearchViewModel, BusMapSearchUiState>(
  BusMapSearchViewModel.new,
);

/// SearchResult 类型别名 - 对齐 Android SearchResult
/// 鸿蒙端: 直接复用 models/baidu_search_result.dart 中的 BaiduSearchResult
typedef SearchResult = BaiduSearchResult;

/// SearchResultData 类型别名 - 对齐 Android SearchResultData
/// 鸿蒙端: 直接复用 models/baidu_search_result.dart 中的 BaiduSearchResultData
typedef SearchResultData = BaiduSearchResultData;
