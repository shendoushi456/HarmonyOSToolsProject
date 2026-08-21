// 公交搜索 ViewModel - 对齐 Android bus/viewmodel/BusSearchViewModel.kt
// 含搜索框文本、搜索历史、POI 搜索、输入联想、公交路线规划
//
// 鸿蒙端差异：
// - Android: AndroidViewModel + mutableStateOf → Flutter: Riverpod Notifier + State
// - Android: PoiSearch/RoutePlanSearch/SuggestionSearch 单监听器复用
// - 鸿蒙端: 每次搜索创建新实例避免回调冲突
// - Android: viewModelScope.launch + delay(DEBOUNCE_DELAY) 实现防抖动
// - 鸿蒙端: Timer 实现防抖动
// - Android: LatLng → 鸿蒙端 BMFCoordinate
// - Android: TransitRouteResult → 鸿蒙端 BMFTransitRouteResult
// - Android: PoiInfo → 鸿蒙端 BMFPoiInfo
// - Android: SuggestionResult.SuggestionInfo → 鸿蒙端 BMFSuggestionInfo
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';
import 'package:flutter_baidu_mapapi_search/flutter_baidu_mapapi_search.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/baidu_location_repository.dart';

/// 公交搜索 UI 状态 - 对齐 Android BusSearchUiState data class
class BusSearchUiState {
  const BusSearchUiState({
    this.searchText = '',
    this.searchHistory = const [],
    this.poiResults = const [],
    this.inputSuggestions = const [],
    this.transitRouteResult,
    this.isLoading = false,
    this.isLoadingSuggestions = false,
    this.errorMessage,
    this.selectedStartPoint,
    this.selectedEndPoint,
    this.currentLocation,
    this.showSuggestions = false,
    this.currentCity = '北京',
    this.isLocating = false,
    this.showLocationPermissionDialog = false,
  });

  /// 搜索文本
  final String searchText;

  /// 搜索历史
  final List<String> searchHistory;

  /// POI 搜索结果（对齐 Android poiResults: List<PoiInfo>）
  final List<BMFPoiInfo> poiResults;

  /// 输入联想建议（对齐 Android inputSuggestions: List<SuggestionInfo>）
  final List<BMFSuggestionInfo> inputSuggestions;

  /// 公交路线结果（对齐 Android transitRouteResult: TransitRouteResult?）
  final BMFTransitRouteResult? transitRouteResult;

  /// 是否正在加载
  final bool isLoading;

  /// 是否正在加载联想
  final bool isLoadingSuggestions;

  /// 错误信息
  final String? errorMessage;

  /// 已选起点（对齐 Android selectedStartPoint: LatLng?）
  final BMFCoordinate? selectedStartPoint;

  /// 已选终点
  final BMFCoordinate? selectedEndPoint;

  /// 当前定位
  final BMFCoordinate? currentLocation;

  /// 是否显示联想建议
  final bool showSuggestions;

  /// 当前定位城市
  final String currentCity;

  /// 是否正在定位
  final bool isLocating;

  /// 是否显示定位权限弹窗
  final bool showLocationPermissionDialog;

  BusSearchUiState copyWith({
    String? searchText,
    List<String>? searchHistory,
    List<BMFPoiInfo>? poiResults,
    List<BMFSuggestionInfo>? inputSuggestions,
    BMFTransitRouteResult? transitRouteResult,
    bool? isLoading,
    bool? isLoadingSuggestions,
    String? errorMessage,
    BMFCoordinate? selectedStartPoint,
    BMFCoordinate? selectedEndPoint,
    BMFCoordinate? currentLocation,
    bool? showSuggestions,
    String? currentCity,
    bool? isLocating,
    bool? showLocationPermissionDialog,
    bool clearError = false,
    bool clearTransitResult = false,
    bool clearSelectedStart = false,
    bool clearSelectedEnd = false,
    bool clearSuggestions = false,
  }) {
    return BusSearchUiState(
      searchText: searchText ?? this.searchText,
      searchHistory: searchHistory ?? this.searchHistory,
      poiResults: poiResults ?? this.poiResults,
      inputSuggestions: clearSuggestions
          ? const []
          : (inputSuggestions ?? this.inputSuggestions),
      transitRouteResult: clearTransitResult
          ? null
          : (transitRouteResult ?? this.transitRouteResult),
      isLoading: isLoading ?? this.isLoading,
      isLoadingSuggestions: isLoadingSuggestions ?? this.isLoadingSuggestions,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedStartPoint: clearSelectedStart
          ? null
          : (selectedStartPoint ?? this.selectedStartPoint),
      selectedEndPoint:
          clearSelectedEnd ? null : (selectedEndPoint ?? this.selectedEndPoint),
      currentLocation: currentLocation ?? this.currentLocation,
      showSuggestions: showSuggestions ?? this.showSuggestions,
      currentCity: currentCity ?? this.currentCity,
      isLocating: isLocating ?? this.isLocating,
      showLocationPermissionDialog:
          showLocationPermissionDialog ?? this.showLocationPermissionDialog,
    );
  }
}

/// 公交搜索 ViewModel - 对齐 Android BusSearchViewModel
class BusSearchViewModel extends Notifier<BusSearchUiState> {
  /// 定位 Repository（对齐 Android locationRepository: LocationRepository = BaiduLocationRepository(application)）
  late final BaiduLocationRepository _locationRepository;

  /// 防抖动定时器（对齐 Android suggestionsJob: Job?）
  Timer? _suggestionsTimer;

  /// 百度搜索原生回调的超时保护。部分云真机环境中原生 SDK 请求已受理但不回调，
  /// 没有该保护会使页面永久停留在“搜索中”。
  Timer? _suggestionResultTimeout;
  Timer? _poiResultTimeout;

  /// 原生搜索插件按类型只保留一个全局回调，通过请求序号忽略过期响应。
  int _suggestionRequestId = 0;
  int _poiRequestId = 0;

  /// 防抖动延迟 - 对齐 Android DEBOUNCE_DELAY = 300L
  static const Duration _debounceDelay = Duration(milliseconds: 300);

  /// 原生百度搜索 SDK 未回调时的最大等待时长。
  static const Duration _searchResultTimeout = Duration(seconds: 10);

  /// 定位尚未完成时首页会传入“定位中”，这不是百度检索可识别的城市名。
  static const String _defaultSearchCity = '北京';

  @override
  BusSearchUiState build() {
    _locationRepository = BaiduLocationRepository();
    ref.onDispose(_disposeResources);
    // 对齐 Android init { initSearch(); checkLocationPermissionOnInit() }
    // 鸿蒙端: 搜索实例按需创建，无需 initSearch；权限检查异步进行
    Future.microtask(() => _checkLocationPermissionOnInit());
    return const BusSearchUiState();
  }

  /// 初始化时检查位置权限 - 对齐 Android checkLocationPermissionOnInit
  Future<void> _checkLocationPermissionOnInit() async {
    final hasPermission =
        await _locationRepository.hasLocationPermissionAsync();
    if (!hasPermission) {
      // 对齐 Android: 显示权限请求弹窗
      state = state.copyWith(showLocationPermissionDialog: true);
    } else {
      // 对齐 Android: 有权限，开始智能初始化定位
      await _initLocationWithPermission();
    }
  }

  /// 有权限时的智能初始化定位策略 - 对齐 Android initLocationWithPermission
  Future<void> _initLocationWithPermission() async {
    try {
      await _startSilentLocation();
    } catch (e) {
      // 对齐 Android: 初始化定位异常，使用默认设置
      state = state.copyWith(currentCity: '北京');
    }
  }

  /// 处理权限请求结果 - 对齐 Android onLocationPermissionResult
  Future<void> onLocationPermissionResult(bool granted) async {
    state = state.copyWith(showLocationPermissionDialog: false);

    if (granted) {
      // 对齐 Android: 权限获取成功，开始定位
      await _initLocationWithPermission();
    } else {
      // 对齐 Android: 权限被拒绝，使用默认城市
      state = state.copyWith(
        currentCity: '北京',
        errorMessage: '需要位置权限才能获取当前位置，将使用默认城市进行搜索',
      );
    }
  }

  /// 关闭权限弹窗 - 对齐 Android dismissLocationPermissionDialog
  void dismissLocationPermissionDialog() {
    state = state.copyWith(
      showLocationPermissionDialog: false,
      currentCity: '北京',
    );
  }

  /// 静默定位（后台获取，不影响UI）- 对齐 Android startSilentLocation
  Future<void> _startSilentLocation() async {
    try {
      // 对齐 Android: locationRepository.getCurrentLocation()
      final locationData = await _locationRepository.getCurrentLocation();
      if (locationData != null) {
        // 对齐 Android: 静默更新位置和城市信息，不设置 isLocating 状态
        state = state.copyWith(
          currentLocation:
              BMFCoordinate(locationData.latitude, locationData.longitude),
          currentCity: locationData.city,
        );
      } else {
        // 对齐 Android: 静默失败，使用默认城市，不显示错误
        state = state.copyWith(currentCity: '北京');
      }
    } catch (e) {
      // 对齐 Android: 静默处理异常，使用默认城市
      state = state.copyWith(currentCity: '北京');
    }
  }

  /// 开始定位获取当前位置和城市（用户主动触发）- 对齐 Android startLocationAndUpdateCity
  Future<void> startLocationAndUpdateCity() async {
    if (state.isLocating) return;

    state = state.copyWith(isLocating: true, clearError: true);

    try {
      final location = await _locationRepository.getCurrentLocation();
      if (location != null) {
        state = state.copyWith(
          currentLocation: BMFCoordinate(location.latitude, location.longitude),
          currentCity: location.city,
          isLocating: false,
          clearError: true,
        );
      } else {
        state = state.copyWith(
          isLocating: false,
          errorMessage: '定位失败，请稍后重试',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLocating: false,
        errorMessage: '定位失败：$e',
      );
    }
  }

  /// 智能定位 - 根据当前状态决定最佳定位时机 - 对齐 Android smartLocation
  Future<void> smartLocation() async {
    // 对齐 Android: 如果已经有位置信息且不是默认城市，无需重新定位
    if (state.currentLocation != null && state.currentCity != '北京') {
      return;
    }
    // 对齐 Android: 如果正在定位中，不重复触发
    if (state.isLocating) {
      return;
    }
    // 对齐 Android: 如果没有权限，提示用户
    final hasPermission =
        await _locationRepository.hasLocationPermissionAsync();
    if (!hasPermission) {
      state = state.copyWith(errorMessage: '需要位置权限才能获取当前位置');
      return;
    }
    // 对齐 Android: 其他情况启动定位
    await startLocationAndUpdateCity();
  }

  /// 检查定位权限 - 对齐 Android checkLocationPermission
  Future<bool> checkLocationPermission() async {
    return _locationRepository.hasLocationPermissionAsync();
  }

  /// 检查是否需要定位 - 对齐 Android shouldRequestLocation
  bool shouldRequestLocation() {
    return state.currentLocation == null;
  }

  /// 更新搜索文本并触发输入联想 - 对齐 Android updateSearchText
  void updateSearchText(String text) {
    final requestId = ++_suggestionRequestId;
    _suggestionResultTimeout?.cancel();
    state = state.copyWith(
      searchText: text,
      showSuggestions: false,
      isLoadingSuggestions: false,
      // 对齐 Android: 清除POI搜索结果
      poiResults: const [],
    );

    // 对齐 Android: 触发输入联想搜索（带防抖动）
    final trimmed = text.trim();
    if (trimmed.isNotEmpty) {
      _triggerInputSuggestions(trimmed, requestId);
    } else {
      // 对齐 Android: 文本为空时清除联想建议
      state = state.copyWith(
        clearSuggestions: true,
        showSuggestions: false,
      );
    }
  }

  /// 带防抖动的输入联想搜索 - 对齐 Android triggerInputSuggestions
  void _triggerInputSuggestions(String keyword, int requestId) {
    // 对齐 Android: 取消之前的搜索任务
    _suggestionsTimer?.cancel();
    // 对齐 Android: delay(DEBOUNCE_DELAY) 后执行
    _suggestionsTimer = Timer(_debounceDelay, () {
      _searchInputSuggestions(keyword, requestId);
    });
  }

  /// 执行输入联想搜索 - 对齐 Android searchInputSuggestions
  Future<void> _searchInputSuggestions(String keyword, int requestId) async {
    if (keyword.trim().isEmpty || requestId != _suggestionRequestId) return;

    state = state.copyWith(isLoadingSuggestions: true);
    final city = _searchCity;
    debugPrint(
      '[BaiduSearch] suggestion request: id=$requestId, keyword=$keyword, city=$city',
    );

    _suggestionResultTimeout?.cancel();
    _suggestionResultTimeout = Timer(_searchResultTimeout, () {
      if (requestId != _suggestionRequestId) return;
      debugPrint('[BaiduSearch] suggestion timeout: id=$requestId');
      state = state.copyWith(
        isLoadingSuggestions: false,
        errorMessage: '地点联想请求超时，请检查云真机网络和百度地图服务配置',
        clearSuggestions: true,
        showSuggestions: false,
      );
    });

    try {
      // 对齐 Android: SuggestionSearchOption().keyword(keyword).city(currentCity)
      final option = BMFSuggestionSearchOption(
        keyword: keyword,
        cityname: city,
      );

      // 鸿蒙端: 每次创建新 BMFSuggestionSearch 实例避免回调冲突
      final suggestionSearch = BMFSuggestionSearch();
      suggestionSearch.onGetSuggestSearchResult(
        callback: (result, errorCode) {
          if (requestId != _suggestionRequestId) return;
          _suggestionResultTimeout?.cancel();
          debugPrint(
            '[BaiduSearch] suggestion callback: id=$requestId, error=$errorCode, count=${result.suggestionList?.length ?? 0}',
          );
          // 对齐 Android: if (result?.error == NO_ERROR && !allSuggestions.isNullOrEmpty())
          if (errorCode == BMFSearchErrorCode.NO_ERROR) {
            final suggestions =
                result.suggestionList ?? const <BMFSuggestionInfo>[];
            if (suggestions.isNotEmpty) {
              state = state.copyWith(
                isLoadingSuggestions: false,
                inputSuggestions: suggestions,
                showSuggestions: true,
                clearError: true,
              );
            } else {
              state = state.copyWith(
                isLoadingSuggestions: false,
                clearSuggestions: true,
                showSuggestions: false,
              );
            }
          } else {
            state = state.copyWith(
              isLoadingSuggestions: false,
              errorMessage: '地点联想失败：$errorCode',
              clearSuggestions: true,
              showSuggestions: false,
            );
          }
        },
      );

      // 对齐 Android: suggestionSearch?.requestSuggestion(option)
      final accepted = await suggestionSearch.suggestionSearch(option);
      if (requestId != _suggestionRequestId) return;
      debugPrint(
        '[BaiduSearch] suggestion accepted: id=$requestId, accepted=$accepted',
      );
      if (!accepted) {
        _suggestionResultTimeout?.cancel();
        state = state.copyWith(
          isLoadingSuggestions: false,
          errorMessage: '联想搜索请求未被百度地图服务受理',
          clearSuggestions: true,
          showSuggestions: false,
        );
      }
    } catch (e) {
      if (requestId != _suggestionRequestId) return;
      _suggestionResultTimeout?.cancel();
      debugPrint('[BaiduSearch] suggestion exception: id=$requestId, error=$e');
      state = state.copyWith(
        isLoadingSuggestions: false,
        errorMessage: '联想搜索异常：$e',
        clearSuggestions: true,
        showSuggestions: false,
      );
    }
  }

  /// 搜索POI地点 - 对齐 Android searchPoi
  Future<void> searchPoi(String keyword) async {
    if (keyword.trim().isEmpty) return;
    final requestId = ++_poiRequestId;
    _poiResultTimeout?.cancel();

    // 对齐 Android：定位只用于刷新后续请求的城市，不能阻塞本次手动搜索。
    // 鸿蒙定位鉴权失败时若在这里等待，会让用户误以为搜索按钮无效。
    if (shouldRequestLocation()) {
      unawaited(smartLocation());
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      poiResults: const [],
    );
    final city = _searchCity;
    debugPrint(
      '[BaiduSearch] POI request: id=$requestId, keyword=${keyword.trim()}, city=$city',
    );

    _poiResultTimeout = Timer(_searchResultTimeout, () {
      if (requestId != _poiRequestId) return;
      debugPrint('[BaiduSearch] POI timeout: id=$requestId');
      state = state.copyWith(
        isLoading: false,
        errorMessage: '地点搜索请求超时，请检查云真机网络和百度地图服务配置',
      );
    });

    try {
      // 对齐 Android: PoiCitySearchOption().city(currentCity).keyword(keyword).pageNum(0).pageCapacity(20)
      final option = BMFPoiCitySearchOption(
        keyword: keyword,
        city: city,
        pageIndex: 0,
        pageSize: 20,
      );

      // 鸿蒙端: 每次创建新 BMFPoiCitySearch 实例避免回调冲突
      final poiSearch = BMFPoiCitySearch();
      poiSearch.onGetPoiCitySearchResult(
        callback: (result, errorCode) {
          if (requestId != _poiRequestId) return;
          _poiResultTimeout?.cancel();
          debugPrint(
            '[BaiduSearch] POI callback: id=$requestId, error=$errorCode, count=${result.poiInfoList?.length ?? 0}',
          );
          state = state.copyWith(isLoading: false);

          if (errorCode == BMFSearchErrorCode.NO_ERROR) {
            // 对齐 Android: result.allPoi?.let { pois -> ... }
            final pois = result.poiInfoList ?? const <BMFPoiInfo>[];
            state = state.copyWith(
              poiResults: pois,
              clearError: true,
            );
          } else {
            state = state.copyWith(
              errorMessage: '地点搜索失败：$errorCode',
              poiResults: const [],
            );
          }
        },
      );

      // 对齐 Android: poiSearch?.searchInCity(option)
      final accepted = await poiSearch.poiCitySearch(option);
      if (requestId != _poiRequestId) return;
      debugPrint(
          '[BaiduSearch] POI accepted: id=$requestId, accepted=$accepted');
      if (!accepted) {
        _poiResultTimeout?.cancel();
        state = state.copyWith(
          isLoading: false,
          errorMessage: '搜索请求未被百度地图服务受理',
        );
        return;
      }

      // 对齐 Android: addToSearchHistory(keyword)
      _addToSearchHistory(keyword);
    } catch (e) {
      if (requestId != _poiRequestId) return;
      _poiResultTimeout?.cancel();
      debugPrint('[BaiduSearch] POI exception: id=$requestId, error=$e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: '搜索异常：$e',
      );
    }
  }

  /// 搜索公交路线 - 对齐 Android searchBusRoute
  Future<void> searchBusRoute({
    required BMFCoordinate startPoint,
    required BMFCoordinate endPoint,
    String? city,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      selectedStartPoint: startPoint,
      selectedEndPoint: endPoint,
    );

    try {
      // 对齐 Android: PlanNode.withLocation(startPoint); TransitRoutePlanOption().from().to().city().policy(EBUS_TIME_FIRST)
      // 鸿蒙端: BMFPlanNode(pt:) + BMFTransitRoutePlanOption(from:, to:, city:, transitPolicy:)
      final stNode = BMFPlanNode(pt: startPoint);
      final enNode = BMFPlanNode(pt: endPoint);
      final option = BMFTransitRoutePlanOption(
        from: stNode,
        to: enNode,
        city: city ?? state.currentCity,
        // 对齐 Android: TransitPolicy.EBUS_TIME_FIRST → 鸿蒙端 BMFTransitPolicy.TIME_FIRST
        transitPolicy: BMFTransitPolicy.TIME_FIRST,
      );

      // 鸿蒙端: 每次创建新 BMFTransitRouteSearch 实例避免回调冲突
      final routeSearch = BMFTransitRouteSearch();
      routeSearch.onGetTransitRouteSearchResult(
        callback: (result, errorCode) {
          state = state.copyWith(isLoading: false);

          if (errorCode == BMFSearchErrorCode.NO_ERROR) {
            state = state.copyWith(
              transitRouteResult: result,
              clearError: true,
            );
          } else {
            state = state.copyWith(
              errorMessage: '路线规划失败，请重试',
              clearTransitResult: true,
            );
          }
        },
      );

      // 对齐 Android: routeSearch?.transitSearch(option)
      await routeSearch.transitRouteSearch(option);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '路线规划异常：$e',
      );
    }
  }

  /// 设置当前位置 - 对齐 Android setCurrentLocation
  void setCurrentLocation(BMFCoordinate location) {
    state = state.copyWith(currentLocation: location);
  }

  /// 选择POI作为起点或终点 - 对齐 Android selectPoi
  Future<void> selectPoi(BMFPoiInfo poi, {required bool isStartPoint}) async {
    final latLng = poi.pt;
    if (latLng == null) return;

    if (isStartPoint) {
      state = state.copyWith(selectedStartPoint: latLng);
    } else {
      state = state.copyWith(selectedEndPoint: latLng);
    }

    // 对齐 Android: 如果起点和终点都选择了，自动搜索路线
    final startPoint = isStartPoint ? latLng : state.selectedStartPoint;
    final endPoint = isStartPoint ? state.selectedEndPoint : latLng;

    if (startPoint != null && endPoint != null) {
      await searchBusRoute(startPoint: startPoint, endPoint: endPoint);
    }
  }

  /// 选择输入联想建议 - 对齐 Android selectSuggestion
  Future<void> selectSuggestion(BMFSuggestionInfo suggestion) async {
    final selectedText = suggestion.key ?? '';
    state = state.copyWith(
      searchText: selectedText,
      showSuggestions: false,
      clearSuggestions: true,
    );

    // 对齐 Android: 执行POI搜索
    if (selectedText.isNotEmpty) {
      await searchPoi(selectedText);
    }
  }

  /// 隐藏联想建议 - 对齐 Android hideSuggestions
  void hideSuggestions() {
    state = state.copyWith(
      showSuggestions: false,
      clearSuggestions: true,
    );
  }

  /// 添加到搜索历史 - 对齐 Android addToSearchHistory
  void _addToSearchHistory(String keyword) {
    final history = List<String>.from(state.searchHistory);
    if (!history.contains(keyword)) {
      history.insert(0, keyword);
      // 对齐 Android: 最多保存10条历史
      if (history.length > 10) {
        history.removeLast();
      }
      state = state.copyWith(searchHistory: history);
    }
  }

  /// 清除搜索历史 - 对齐 Android clearSearchHistory
  void clearSearchHistory() {
    state = state.copyWith(searchHistory: const []);
  }

  /// 清除错误信息 - 对齐 Android clearError
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// 重置搜索结果 - 对齐 Android resetSearchResults
  void resetSearchResults() {
    state = state.copyWith(
      poiResults: const [],
      clearTransitResult: true,
      clearSelectedStart: true,
      clearSelectedEnd: true,
      clearError: true,
    );
  }

  /// 手动设置城市 - 对齐 Android setCurrentCity
  void setCurrentCity(String city) {
    state = state.copyWith(currentCity: _normalizeSearchCity(city));
  }

  /// 百度检索要求传入有效城市名或 cityCode；页面定位中、空字符串不可直接使用。
  String get _searchCity => _normalizeSearchCity(state.currentCity);

  static String _normalizeSearchCity(String city) {
    final normalized = city.trim();
    return normalized.isEmpty || normalized == '定位中'
        ? _defaultSearchCity
        : normalized;
  }

  /// 获取当前城市 - 对齐 Android getCurrentCity
  String getCurrentCity() {
    return state.currentCity;
  }

  /// 使用当前位置作为起点 - 对齐 Android useCurrentLocationAsStart
  Future<void> useCurrentLocationAsStart() async {
    final location = state.currentLocation;
    if (location == null) return;

    state = state.copyWith(selectedStartPoint: location);

    // 对齐 Android: 如果终点也已选择，自动搜索路线
    final endPoint = state.selectedEndPoint;
    if (endPoint != null) {
      await searchBusRoute(startPoint: location, endPoint: endPoint);
    }
  }

  /// 使用当前位置作为终点 - 对齐 Android useCurrentLocationAsEnd
  Future<void> useCurrentLocationAsEnd() async {
    final location = state.currentLocation;
    if (location == null) return;

    state = state.copyWith(selectedEndPoint: location);

    // 对齐 Android: 如果起点也已选择，自动搜索路线
    final startPoint = state.selectedStartPoint;
    if (startPoint != null) {
      await searchBusRoute(startPoint: startPoint, endPoint: location);
    }
  }

  /// 释放资源 - 对齐 Android onCleared
  void _disposeResources() {
    _suggestionsTimer?.cancel();
    _suggestionsTimer = null;
    _suggestionResultTimeout?.cancel();
    _suggestionResultTimeout = null;
    _poiResultTimeout?.cancel();
    _poiResultTimeout = null;
    _locationRepository.stopLocation();
  }
}

/// 鸿蒙端 BMFSuggestionSearch.onGetSuggestSearchResult 简化命名注释
// 注：鸿蒙端 SDK 中方法名为 onGetSuggestSearchResult（单数），直接使用即可

/// 公交搜索 ViewModel Provider
final busSearchViewModelProvider =
    NotifierProvider<BusSearchViewModel, BusSearchUiState>(
  BusSearchViewModel.new,
);
