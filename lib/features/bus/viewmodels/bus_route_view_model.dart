// 公交路线规划 ViewModel - 对齐 Android bus/viewmodel/BusRouteViewModel.kt
// 含公交/驾车/骑行/步行路线规划、输入联想、定位、路线点击导航跳转
//
// 鸿蒙端差异：
// - Android: AndroidViewModel + mutableStateOf → Flutter: Riverpod Notifier + State
// - Android: RoutePlanSearch + OnGetRoutePlanResultListener 单监听器
// - 鸿蒙端: 4 个独立搜索类（BMFTransitRouteSearch/BMFDrivingRouteSearch/BMFRidingRouteSearch/BMFWalkingRouteSearch）+ 各自回调
// - Android: TransitRouteLine.duration(long 秒) → 鸿蒙端 BMFTransitRouteLine.duration(BMFTime?)
// - Android: DrivingRouteLine.allStep → 鸿蒙端 BMFDrivingRouteLine.steps
// - Android: BikingRouteLine → 鸿蒙端 BMFRidingRouteLine
// - Android: DrivingPolicy.ECAR_AVOID_JAM → 鸿蒙端 BMFDrivingPolicy.BLK_FIRST（躲避拥堵）
// - Android: TransitPolicy.EBUS_TIME_FIRST → 鸿蒙端 BMFTransitPolicy.TIME_FIRST
// - Android: ViewModel 中通过 Intent 跳转 MapNaviActivity/BusSearchActivity/BusRouteLineDetailActivity
// - 鸿蒙端: 暴露 pendingXxx 状态由 Page 层处理跳转（go_router）
// - Android: TransportModeConverter.toUiInt(addressRepository.getDefaultTransportMode()) 同步
// - 鸿蒙端: AddressRepository.getDefaultTransportMode() 异步
// - Android: checkNetworkAndShowError 用 ConnectivityManager
// - 鸿蒙端: 无对应 API，乐观返回 true（实际网络错误由搜索回调兜底）
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';
import 'package:flutter_baidu_mapapi_search/flutter_baidu_mapapi_search.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/address_info.dart';
import '../repositories/address_repository.dart';
import '../repositories/baidu_location_repository.dart';
import '../utils/navi_plan_manager.dart';
import '../utils/route_data_manager.dart';

/// 公交路线列表项数据类 - 对齐 Android BusRouteItem
@immutable
class BusRouteItem {
  const BusRouteItem({
    required this.duration,
    required this.routeNumber,
    this.distance = '',
    this.walkDistance = '',
    this.price = '',
    this.pathId = -1,
    this.transitRouteLine,
    this.transitRouteResult,
  });

  /// 总耗时
  final String duration;

  /// 路线编号（如 "617路→地铁5号线"）
  final String routeNumber;

  /// 总距离
  final String distance;

  /// 步行距离
  final String walkDistance;

  /// 票价
  final String price;

  /// 路线索引（对齐 Android pathId: Int）
  final int pathId;

  /// 公交路线对象（对齐 Android transitRouteLine: TransitRouteLine?）
  final BMFTransitRouteLine? transitRouteLine;

  /// 公交路线结果（对齐 Android transitRouteResult: TransitRouteResult?）
  final BMFTransitRouteResult? transitRouteResult;

  @override
  String toString() =>
      'BusRouteItem(routeNumber=$routeNumber, duration=$duration, distance=$distance)';
}

/// 驾车路线列表项数据类 - 对齐 Android DriveRouteItem
@immutable
class DriveRouteItem {
  const DriveRouteItem({
    required this.duration,
    this.distance = '',
    this.trafficLights = '',
    this.tollCost = '',
    this.pathId = -1,
    this.drivingRouteLine,
  });

  final String duration;
  final String distance;
  final String trafficLights;
  final String tollCost;
  final int pathId;

  /// 驾车路线对象（对齐 Android drivingRouteLine: DrivingRouteLine?）
  final BMFDrivingRouteLine? drivingRouteLine;

  @override
  String toString() =>
      'DriveRouteItem(duration=$duration, distance=$distance, trafficLights=$trafficLights)';
}

/// 骑行路线列表项数据类 - 对齐 Android RideRouteItem
@immutable
class RideRouteItem {
  const RideRouteItem({
    required this.duration,
    this.distance = '',
    this.pathId = -1,
    this.bikingRouteLine,
  });

  final String duration;
  final String distance;
  final int pathId;

  /// 骑行路线对象（对齐 Android bikingRouteLine: BikingRouteLine?）
  /// 鸿蒙端用 BMFRidingRouteLine
  final BMFRidingRouteLine? bikingRouteLine;

  @override
  String toString() => 'RideRouteItem(duration=$duration, distance=$distance)';
}

/// 步行路线列表项数据类 - 对齐 Android WalkRouteItem
@immutable
class WalkRouteItem {
  const WalkRouteItem({
    required this.duration,
    this.distance = '',
    this.pathId = -1,
    this.walkingRouteLine,
  });

  final String duration;
  final String distance;
  final int pathId;

  /// 步行路线对象（对齐 Android walkingRouteLine: WalkingRouteLine?）
  final BMFWalkingRouteLine? walkingRouteLine;

  @override
  String toString() => 'WalkRouteItem(duration=$duration, distance=$distance)';
}

/// 待处理的导航动作 - 用于 Page 层观察并执行页面跳转
/// 替代 Android 中直接调用 MapNaviActivity.start / BusRouteLineDetailActivity.start
@immutable
class PendingNaviAction {
  const PendingNaviAction({
    required this.type,
    required this.startPoint,
    required this.endPoint,
    required this.startName,
    required this.endName,
    required this.naviStartType,
    this.transitRouteLines,
    this.transitRouteResult,
  });

  /// 动作类型：导航 / 路线详情
  final NaviActionType type;

  /// 起点坐标
  final BMFCoordinate startPoint;

  /// 终点坐标
  final BMFCoordinate endPoint;

  /// 起点名称
  final String startName;

  /// 终点名称
  final String endName;

  /// 导航类型
  final NaviStartType naviStartType;

  /// 公交路线列表（仅 type == routeLineDetail 时使用）
  final List<BMFTransitRouteLine>? transitRouteLines;

  /// 公交路线结果（仅 type == routeLineDetail 时使用）
  final BMFTransitRouteResult? transitRouteResult;
}

/// 导航动作类型
enum NaviActionType {
  /// 启动导航
  startNavi,

  /// 查看公交路线详情
  routeLineDetail,
}

/// 待处理的搜索页跳转 - 用于 Page 层观察并执行页面跳转
/// 替代 Android 中直接调用 BusSearchActivity.startForResult
@immutable
class PendingSearchRequest {
  const PendingSearchRequest({
    required this.isFromLocation,
    required this.currentCity,
    required this.requestCode,
  });

  /// true 为选择出发地，false 为选择目的地
  final bool isFromLocation;

  /// 当前城市
  final String currentCity;

  /// 请求码（对齐 Android requestCode: 1001/1002）
  final int requestCode;
}

/// 公交路线规划 UI 状态 - 对齐 Android BusRouteUiState data class
class BusRouteUiState {
  const BusRouteUiState({
    this.fromLocation = '我的位置',
    this.toLocation = '地点名称',
    this.selectedTransportMode = 0,
    this.transportModes = const ['公共交通', '驾车', '骑行', '步行'],
    this.busRoutes = const [],
    this.driveRoutes = const [],
    this.rideRoutes = const [],
    this.walkRoutes = const [],
    this.transitRouteResult,
    this.driveRouteResult,
    this.rideRouteResult,
    this.walkRouteResult,
    this.selectedStartPoint,
    this.selectedEndPoint,
    this.currentLocation,
    this.currentCity = '北京',
    this.isLoading = false,
    this.errorMessage,
    this.inputSuggestions = const [],
    this.showFromSuggestions = false,
    this.showToSuggestions = false,
    this.showLocationPermissionDialog = false,
    this.isSearchMode = false,
    this.isLocationSwapped = false,
    this.pendingNaviAction,
    this.pendingSearchRequest,
  });

  /// 出发地名称
  final String fromLocation;

  /// 目的地名称
  final String toLocation;

  /// 已选交通方式索引（0 公共交通 / 1 驾车 / 2 骑行 / 3 步行）
  final int selectedTransportMode;

  /// 交通方式列表
  final List<String> transportModes;

  /// 公交路线列表
  final List<BusRouteItem> busRoutes;

  /// 驾车路线列表
  final List<DriveRouteItem> driveRoutes;

  /// 骑行路线列表
  final List<RideRouteItem> rideRoutes;

  /// 步行路线列表
  final List<WalkRouteItem> walkRoutes;

  /// 公交路线结果（对齐 Android transitRouteResult: TransitRouteResult?）
  final BMFTransitRouteResult? transitRouteResult;

  /// 驾车路线结果
  final BMFDrivingRouteResult? driveRouteResult;

  /// 骑行路线结果
  final BMFRidingRouteResult? rideRouteResult;

  /// 步行路线结果
  final BMFWalkingRouteResult? walkRouteResult;

  /// 已选起点
  final BMFCoordinate? selectedStartPoint;

  /// 已选终点
  final BMFCoordinate? selectedEndPoint;

  /// 当前定位
  final BMFCoordinate? currentLocation;

  /// 当前城市
  final String currentCity;

  /// 是否正在加载
  final bool isLoading;

  /// 错误信息
  final String? errorMessage;

  /// 输入联想建议
  final List<BMFSuggestionInfo> inputSuggestions;

  /// 是否显示出发地联想
  final bool showFromSuggestions;

  /// 是否显示目的地联想
  final bool showToSuggestions;

  /// 是否显示定位权限弹窗
  final bool showLocationPermissionDialog;

  /// 是否为搜索模式
  final bool isSearchMode;

  /// 位置是否已交换
  final bool isLocationSwapped;

  /// 待处理的导航动作（Page 层观察此字段并执行跳转，处理后清除）
  final PendingNaviAction? pendingNaviAction;

  /// 待处理的搜索页跳转请求（Page 层观察此字段并执行跳转，处理后清除）
  final PendingSearchRequest? pendingSearchRequest;

  BusRouteUiState copyWith({
    String? fromLocation,
    String? toLocation,
    int? selectedTransportMode,
    List<String>? transportModes,
    List<BusRouteItem>? busRoutes,
    List<DriveRouteItem>? driveRoutes,
    List<RideRouteItem>? rideRoutes,
    List<WalkRouteItem>? walkRoutes,
    BMFTransitRouteResult? transitRouteResult,
    BMFDrivingRouteResult? driveRouteResult,
    BMFRidingRouteResult? rideRouteResult,
    BMFWalkingRouteResult? walkRouteResult,
    BMFCoordinate? selectedStartPoint,
    BMFCoordinate? selectedEndPoint,
    BMFCoordinate? currentLocation,
    String? currentCity,
    bool? isLoading,
    String? errorMessage,
    List<BMFSuggestionInfo>? inputSuggestions,
    bool? showFromSuggestions,
    bool? showToSuggestions,
    bool? showLocationPermissionDialog,
    bool? isSearchMode,
    bool? isLocationSwapped,
    PendingNaviAction? pendingNaviAction,
    PendingSearchRequest? pendingSearchRequest,
    bool clearError = false,
    bool clearTransitResult = false,
    bool clearDriveResult = false,
    bool clearRideResult = false,
    bool clearWalkResult = false,
    bool clearSelectedStart = false,
    bool clearSelectedEnd = false,
    bool clearSuggestions = false,
    bool clearFromSuggestions = false,
    bool clearToSuggestions = false,
    bool clearPendingNavi = false,
    bool clearPendingSearch = false,
    bool clearBusRoutes = false,
    bool clearDriveRoutes = false,
    bool clearRideRoutes = false,
    bool clearWalkRoutes = false,
  }) {
    return BusRouteUiState(
      fromLocation: fromLocation ?? this.fromLocation,
      toLocation: toLocation ?? this.toLocation,
      selectedTransportMode:
          selectedTransportMode ?? this.selectedTransportMode,
      transportModes: transportModes ?? this.transportModes,
      busRoutes: clearBusRoutes ? const [] : (busRoutes ?? this.busRoutes),
      driveRoutes:
          clearDriveRoutes ? const [] : (driveRoutes ?? this.driveRoutes),
      rideRoutes: clearRideRoutes ? const [] : (rideRoutes ?? this.rideRoutes),
      walkRoutes: clearWalkRoutes ? const [] : (walkRoutes ?? this.walkRoutes),
      transitRouteResult: clearTransitResult
          ? null
          : (transitRouteResult ?? this.transitRouteResult),
      driveRouteResult:
          clearDriveResult ? null : (driveRouteResult ?? this.driveRouteResult),
      rideRouteResult:
          clearRideResult ? null : (rideRouteResult ?? this.rideRouteResult),
      walkRouteResult:
          clearWalkResult ? null : (walkRouteResult ?? this.walkRouteResult),
      selectedStartPoint: clearSelectedStart
          ? null
          : (selectedStartPoint ?? this.selectedStartPoint),
      selectedEndPoint:
          clearSelectedEnd ? null : (selectedEndPoint ?? this.selectedEndPoint),
      currentLocation: currentLocation ?? this.currentLocation,
      currentCity: currentCity ?? this.currentCity,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      inputSuggestions: clearSuggestions
          ? const []
          : (inputSuggestions ?? this.inputSuggestions),
      showFromSuggestions: clearFromSuggestions
          ? false
          : (showFromSuggestions ?? this.showFromSuggestions),
      showToSuggestions: clearToSuggestions
          ? false
          : (showToSuggestions ?? this.showToSuggestions),
      showLocationPermissionDialog:
          showLocationPermissionDialog ?? this.showLocationPermissionDialog,
      isSearchMode: isSearchMode ?? this.isSearchMode,
      isLocationSwapped: isLocationSwapped ?? this.isLocationSwapped,
      pendingNaviAction: clearPendingNavi
          ? null
          : (pendingNaviAction ?? this.pendingNaviAction),
      pendingSearchRequest: clearPendingSearch
          ? null
          : (pendingSearchRequest ?? this.pendingSearchRequest),
    );
  }
}

/// 公交路线规划 ViewModel - 对齐 Android BusRouteViewModel
class BusRouteViewModel extends Notifier<BusRouteUiState> {
  /// 定位 Repository（对齐 Android locationRepository = LocationRepositoryProvider.getLocationRepository(application)）
  late final BaiduLocationRepository _locationRepository;

  /// 地址 Repository（对齐 Android addressRepository = AddressRepository.getInstance(application)）
  late final AddressRepository _addressRepository;

  /// 防抖动定时器（对齐 Android suggestionsJob: Job?）
  Timer? _suggestionsTimer;

  /// 防抖动延迟 - 对齐 Android DEBOUNCE_DELAY = 300L
  // 注：Android 原代码中 triggerLocationSearch 已注释，此常量保留以对齐原项目结构
  // ignore: unused_field
  static const Duration _debounceDelay = Duration(milliseconds: 300);

  @override
  BusRouteUiState build() {
    _locationRepository = BaiduLocationRepository();
    _addressRepository = AddressRepository.instance;
    // 对齐 Android init { initRouteSearch(); checkLocationPermissionOnInit(); }
    // 鸿蒙端: 搜索实例按需创建，无需 initSearch；权限检查异步进行
    Future.microtask(() => _checkLocationPermissionOnInit());
    return const BusRouteUiState();
  }

  /// 初始化时检查位置权限 - 对齐 Android checkLocationPermissionOnInit
  Future<void> _checkLocationPermissionOnInit() async {
    final hasPermission =
        await _locationRepository.hasLocationPermissionAsync();
    if (!hasPermission) {
      // 对齐 Android: 显示权限请求弹窗
      state = state.copyWith(showLocationPermissionDialog: true);
    }
  }

  /// 处理权限请求结果 - 对齐 Android onLocationPermissionResult
  void onLocationPermissionResult(bool granted) {
    state = state.copyWith(showLocationPermissionDialog: false);

    if (granted) {
      // 对齐 Android: 权限获取成功，可以开始定位相关操作
      state = state.copyWith(clearError: true);
    } else {
      // 对齐 Android: 权限被拒绝
      state = state.copyWith(errorMessage: '需要位置权限才能提供准确的路线规划服务');
    }
  }

  /// 关闭权限弹窗 - 对齐 Android dismissLocationPermissionDialog
  void dismissLocationPermissionDialog() {
    state = state.copyWith(showLocationPermissionDialog: false);
  }

  /// 解析公交路线搜索结果 - 对齐 Android parseTransitRouteResult
  List<BusRouteItem> _parseTransitRouteResult(BMFTransitRouteResult result) {
    final routes = <BusRouteItem>[];

    // 对齐 Android: result.routeLines?.forEachIndexed
    final routeLines = result.routes ?? const <BMFTransitRouteLine>[];
    for (var index = 0; index < routeLines.length; index++) {
      final transitRouteLine = routeLines[index];

      // 对齐 Android: formatDuration(transitRouteLine.duration)
      // 鸿蒙端: BMFTransitRouteLine.duration 类型为 BMFTime?，需折算为秒
      final durationSeconds = _durationToSeconds(transitRouteLine.duration);
      final duration = _formatDuration(durationSeconds);

      // 对齐 Android: transitRouteLine.allStep?.mapNotNull { ... }
      // 鸿蒙端: BMFTransitRouteLine.steps
      final steps = transitRouteLine.steps ?? const <BMFTransitStep>[];
      final routeNumbers = steps
          .map((step) {
            // 对齐 Android: BUSLINE/SUBWAY -> step.vehicleInfo?.title
            if (step.stepType == BMFTransitStepType.BUSLINE ||
                step.stepType == BMFTransitStepType.SUBWAY) {
              return step.vehicleInfo?.title;
            }
            return null;
          })
          .whereType<String>()
          .join('→');

      // 对齐 Android: String.format("%.1fkm", transitRouteLine.distance / 1000f)
      final distanceMeters = transitRouteLine.distance ?? 0;
      final distance = '${(distanceMeters / 1000).toStringAsFixed(1)}km';

      // 对齐 Android: 步行距离汇总
      final walkDistance = steps
          .where((s) => s.stepType == BMFTransitStepType.WAKLING)
          .fold<double>(0.0, (sum, s) => sum + (s.distance ?? 0));
      final walkDistanceStr = '${walkDistance.round()}m';

      // 对齐 Android: "2元" - 百度地图不直接提供票价信息
      const price = '2元';

      debugPrint('BusRouteViewModel: 公交路线信息: 路线编号:$routeNumbers, '
          '路线距离:$distance, 步行距离:$walkDistanceStr, 路线时间:$duration, 路线价格:$price');

      routes.add(BusRouteItem(
        duration: duration,
        routeNumber: routeNumbers.isEmpty ? '公交路线' : routeNumbers,
        distance: distance,
        walkDistance: '步行$walkDistanceStr',
        price: price,
        pathId: index,
        transitRouteLine: transitRouteLine,
        transitRouteResult: result,
      ));
    }

    // 对齐 Android: 依据时间排序 - 按 duration 从短到长排序
    routes.sort((a, b) {
      final aDuration = _durationToSeconds(a.transitRouteLine?.duration);
      final bDuration = _durationToSeconds(b.transitRouteLine?.duration);
      return aDuration.compareTo(bDuration);
    });
    return routes;
  }

  /// 格式化时间（秒转换为分钟）- 对齐 Android formatDuration
  ///
  /// 增加实时路况系数，使其更接近导航时间
  String _formatDuration(int seconds, {bool includeTrafficFactor = true}) {
    var adjustedSeconds = seconds;

    // 对齐 Android: 根据交通模式调整时间
    if (includeTrafficFactor) {
      // 对齐 Android: 各模式调整系数已被注释为 1，保持原时间
      // 这里直接保留原时间，与 Android 当前行为一致
      switch (state.selectedTransportMode) {
        case 1: // 驾车
          // adjustedSeconds = (seconds * 1).toInt();
          break;
        case 2: // 骑行
          // adjustedSeconds = (seconds * 1).toInt();
          break;
        case 3: // 步行
          // adjustedSeconds = seconds;
          break;
        default: // 公共交通
          // adjustedSeconds = (seconds * 1).toInt();
          break;
      }
    }

    final minutes = adjustedSeconds ~/ 60;
    if (minutes < 60) {
      return '$minutes分钟';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '$hours小时';
    }
    return '$hours小时$remainingMinutes分钟';
  }

  /// 解析驾车路线搜索结果 - 对齐 Android parseDrivingRouteResult
  List<DriveRouteItem> _parseDrivingRouteResult(BMFDrivingRouteResult result) {
    final routes = <DriveRouteItem>[];

    // 对齐 Android: result.routeLines?.forEachIndexed
    final routeLines = result.routes ?? const <BMFDrivingRouteLine>[];
    for (var index = 0; index < routeLines.length; index++) {
      final drivingRouteLine = routeLines[index];

      // 对齐 Android: formatDuration(drivingRouteLine.duration)
      final durationSeconds = _durationToSeconds(drivingRouteLine.duration);
      final duration = _formatDuration(durationSeconds);

      // 对齐 Android: String.format("%.1fkm", drivingRouteLine.distance / 1000f)
      final distanceMeters = drivingRouteLine.distance ?? 0;
      final distance = '${(distanceMeters / 1000).toStringAsFixed(1)}km';

      // 对齐 Android: drivingRouteLine.allStep?.sumOf { it.trafficList?.size ?: 0 }
      // 鸿蒙端: BMFDrivingRouteLine.steps 中 BMFDrivingStep.traffics (List<int>?)
      final steps = drivingRouteLine.steps ?? const <BMFDrivingStep>[];
      final trafficLights = steps.fold<int>(
        0,
        (sum, s) => sum + (s.traffics?.length ?? 0),
      );
      final trafficLightsStr =
          trafficLights > 0 ? '$trafficLights个红绿灯' : '无红绿灯';

      // 对齐 Android: "无过路费" - 百度地图不直接提供过路费信息
      const tollCost = '无过路费';

      debugPrint('BusRouteViewModel: 驾车路线信息: 路线距离:$distance, 路线时间:$duration, '
          '红绿灯数:$trafficLightsStr, 过路费:$tollCost');

      routes.add(DriveRouteItem(
        duration: duration,
        distance: distance,
        trafficLights: trafficLightsStr,
        tollCost: tollCost,
        pathId: index,
        drivingRouteLine: drivingRouteLine,
      ));
    }

    // 对齐 Android: 按 duration 排序
    routes.sort((a, b) {
      final aDuration = _durationToSeconds(a.drivingRouteLine?.duration);
      final bDuration = _durationToSeconds(b.drivingRouteLine?.duration);
      return aDuration.compareTo(bDuration);
    });
    return routes;
  }

  /// 解析骑行路线搜索结果 - 对齐 Android parseBikingRouteResult
  List<RideRouteItem> _parseBikingRouteResult(BMFRidingRouteResult result) {
    final routes = <RideRouteItem>[];

    final routeLines = result.routes ?? const <BMFRidingRouteLine>[];
    for (var index = 0; index < routeLines.length; index++) {
      final bikingRouteLine = routeLines[index];

      final durationSeconds = _durationToSeconds(bikingRouteLine.duration);
      final duration = _formatDuration(durationSeconds);

      final distanceMeters = bikingRouteLine.distance ?? 0;
      final distance = '${(distanceMeters / 1000).toStringAsFixed(1)}km';

      debugPrint('BusRouteViewModel: 骑行路线信息: 路线距离:$distance, 路线时间:$duration');

      routes.add(RideRouteItem(
        duration: duration,
        distance: distance,
        pathId: index,
        bikingRouteLine: bikingRouteLine,
      ));
    }

    routes.sort((a, b) {
      final aDuration = _durationToSeconds(a.bikingRouteLine?.duration);
      final bDuration = _durationToSeconds(b.bikingRouteLine?.duration);
      return aDuration.compareTo(bDuration);
    });
    return routes;
  }

  /// 解析步行路线搜索结果 - 对齐 Android parseWalkingRouteResult
  List<WalkRouteItem> _parseWalkingRouteResult(BMFWalkingRouteResult result) {
    final routes = <WalkRouteItem>[];

    final routeLines = result.routes ?? const <BMFWalkingRouteLine>[];
    for (var index = 0; index < routeLines.length; index++) {
      final walkingRouteLine = routeLines[index];

      final durationSeconds = _durationToSeconds(walkingRouteLine.duration);
      final duration = _formatDuration(durationSeconds);

      final distanceMeters = walkingRouteLine.distance ?? 0;
      final distance = '${(distanceMeters / 1000).toStringAsFixed(1)}km';

      debugPrint('BusRouteViewModel: 步行路线信息: 路线距离:$distance, 路线时间:$duration');

      routes.add(WalkRouteItem(
        duration: duration,
        distance: distance,
        pathId: index,
        walkingRouteLine: walkingRouteLine,
      ));
    }

    routes.sort((a, b) {
      final aDuration = _durationToSeconds(a.walkingRouteLine?.duration);
      final bDuration = _durationToSeconds(b.walkingRouteLine?.duration);
      return aDuration.compareTo(bDuration);
    });
    return routes;
  }

  /// 将 BMFTime 折算为总秒数 - 鸿蒙端工具方法
  /// Android duration 是 long（秒），鸿蒙端 duration 是 BMFTime?（含 dates/hours/minutes/seconds）
  int _durationToSeconds(BMFTime? time) {
    if (time == null) return 0;
    return ((time.dates ?? 0) * 86400) +
        ((time.hours ?? 0) * 3600) +
        ((time.minutes ?? 0) * 60) +
        (time.seconds ?? 0);
  }

  /// 更新出发地 - 对齐 Android updateFromLocation
  void updateFromLocation(String location) {
    state = state.copyWith(
      fromLocation: location,
      clearFromSuggestions: true,
    );
  }

  /// 使用坐标更新出发地位置 - 对齐 Android updateFromLocationWithCoordinate
  Future<void> updateFromLocationWithCoordinate({
    required String locationName,
    required double latitude,
    required double longitude,
  }) async {
    final startPoint = BMFCoordinate(latitude, longitude);
    state = state.copyWith(
      fromLocation: locationName,
      selectedStartPoint: startPoint,
      clearFromSuggestions: true,
    );
  }

  /// 更新目的地 - 对齐 Android updateToLocation
  void updateToLocation(String location) {
    state = state.copyWith(
      toLocation: location,
      clearToSuggestions: true,
    );
  }

  /// 设置目的地信息（经纬度和名称）- 对齐 Android setDestination
  void setDestination({
    required double latitude,
    required double longitude,
    required String name,
  }) {
    final destinationPoint = BMFCoordinate(latitude, longitude);
    state = state.copyWith(
      toLocation: name,
      selectedEndPoint: destinationPoint,
      clearToSuggestions: true,
    );
  }

  /// 交换出发地和目的地 - 对齐 Android swapLocations
  ///
  /// 交换 fromLocation 和 toLocation 的值，同时交换对应的坐标点
  void swapLocations() {
    // 对齐 Android: 交换 fromLocation 和 toLocation
    final temp = state.fromLocation;
    state = state.copyWith(
      fromLocation: state.toLocation,
      toLocation: temp,
      isLocationSwapped: !state.isLocationSwapped,
    );

    // 对齐 Android: 同时交换坐标点
    final tempPoint = state.selectedStartPoint;
    state = state.copyWith(
      selectedStartPoint: state.selectedEndPoint,
      selectedEndPoint: tempPoint,
    );
  }

  /// 选择交通方式 - 对齐 Android selectTransportMode
  ///
  /// [transportMode] 0 公共交通 / 1 驾车 / 2 骑行 / 3 步行；-1 表示从 AddressRepository 获取默认值
  Future<void> selectTransportMode(int transportMode) async {
    // 对齐 Android: 如果 transportMode 为 -1，则从 AddressRepository 获取默认导航方式
    int finalMode;
    if (transportMode == -1) {
      // 鸿蒙端差异: getDefaultTransportMode 异步
      final transport = await _addressRepository.getDefaultTransportMode();
      finalMode = TransportModeConverter.toUiInt(transport);
    } else {
      finalMode = transportMode;
    }

    state = state.copyWith(selectedTransportMode: finalMode);
  }

  /// 根据交通方式搜索路线 - 对齐 Android searchRouteByMode
  Future<void> _searchRouteByMode(int modeIndex) async {
    final startPoint = state.selectedStartPoint;
    final endPoint = state.selectedEndPoint;

    // 对齐 Android: if (startPoint == null || endPoint == null) { return }
    if (startPoint == null || endPoint == null) {
      debugPrint(
          'BusRouteViewModel: startPoint=$startPoint endPoint=$endPoint');
      return;
    }

    // 对齐 Android: 检查网络
    if (!_checkNetworkAndShowError()) return;

    state = state.copyWith(isLoading: true, clearError: true);
    debugPrint('BusRouteViewModel: 开始搜索路线，模式: $modeIndex');

    try {
      // 对齐 Android: PlanNode.withLocation(startPoint)
      final stNode = BMFPlanNode(pt: startPoint);
      final enNode = BMFPlanNode(pt: endPoint);

      switch (modeIndex) {
        case 0: // 公共交通
          await _searchTransitRoute(stNode, enNode);
          break;
        case 1: // 驾车
          await _searchDrivingRoute(stNode, enNode);
          break;
        case 2: // 骑行
          await _searchBikingRoute(stNode, enNode);
          break;
        case 3: // 步行
          await _searchWalkingRoute(stNode, enNode);
          break;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '路线规划异常：$e',
      );
    }
  }

  /// 搜索公交路线 - 对齐 Android modeIndex == 0
  Future<void> _searchTransitRoute(
      BMFPlanNode stNode, BMFPlanNode enNode) async {
    // 对齐 Android: TransitRoutePlanOption().from().to().city().policy(EBUS_TIME_FIRST)
    final option = BMFTransitRoutePlanOption(
      from: stNode,
      to: enNode,
      city: state.currentCity,
      // 对齐 Android: TransitPolicy.EBUS_TIME_FIRST → 鸿蒙端 BMFTransitPolicy.TIME_FIRST
      transitPolicy: BMFTransitPolicy.TIME_FIRST,
    );

    // 鸿蒙端: 每次创建新 BMFTransitRouteSearch 实例避免回调冲突
    final routeSearch = BMFTransitRouteSearch();
    routeSearch.onGetTransitRouteSearchResult(
      callback: (result, errorCode) {
        state = state.copyWith(isLoading: false);

        // 对齐 Android: if (result?.error == NO_ERROR && result.routeLines != null)
        if (errorCode == BMFSearchErrorCode.NO_ERROR && result.routes != null) {
          final routes = _parseTransitRouteResult(result);
          if (routes.isEmpty) {
            state = state.copyWith(
              errorMessage: '没有找到公交路线，请检查起点和终点',
              clearBusRoutes: true,
            );
          } else {
            state = state.copyWith(
              transitRouteResult: result,
              busRoutes: routes,
              clearError: true,
            );
            debugPrint('BusRouteViewModel: 成功获取到${routes.length}条公交路线');
          }
        } else {
          final errorMsg = _getErrorMessage(errorCode);
          debugPrint('BusRouteViewModel: 公交路线规划失败: $errorCode, $errorMsg');
          state = state.copyWith(
            errorMessage: errorMsg,
            clearBusRoutes: true,
          );
        }
      },
    );

    // 对齐 Android: routePlanSearch?.transitSearch(option)
    await routeSearch.transitRouteSearch(option);
  }

  /// 搜索驾车路线 - 对齐 Android modeIndex == 1
  Future<void> _searchDrivingRoute(
      BMFPlanNode stNode, BMFPlanNode enNode) async {
    // 对齐 Android: DrivingRoutePlanOption().from().to().policy(ECAR_AVOID_JAM)
    final option = BMFDrivingRoutePlanOption(
      from: stNode,
      to: enNode,
      // 对齐 Android: ECAR_AVOID_JAM → 鸿蒙端 BMFDrivingPolicy.BLK_FIRST（躲避拥堵）
      drivingPolicy: BMFDrivingPolicy.BLK_FIRST,
    );

    final routeSearch = BMFDrivingRouteSearch();
    routeSearch.onGetDrivingRouteSearchResult(
      callback: (result, errorCode) {
        state = state.copyWith(isLoading: false);

        if (errorCode == BMFSearchErrorCode.NO_ERROR && result.routes != null) {
          final routes = _parseDrivingRouteResult(result);
          if (routes.isEmpty) {
            state = state.copyWith(
              errorMessage: '没有找到驾车路线',
              clearDriveRoutes: true,
            );
          } else {
            state = state.copyWith(
              driveRouteResult: result,
              driveRoutes: routes,
              clearError: true,
            );
          }
        } else {
          final errorMsg = _getErrorMessage(errorCode);
          debugPrint('BusRouteViewModel: 驾车路线规划失败: $errorCode, $errorMsg');
          state = state.copyWith(
            errorMessage: errorMsg,
            clearDriveRoutes: true,
          );
        }
      },
    );

    // 对齐 Android: routePlanSearch?.drivingSearch(option)
    // 鸿蒙端: 方法名为 dringRouteSearch（SDK 拼写）
    await routeSearch.dringRouteSearch(option);
  }

  /// 搜索骑行路线 - 对齐 Android modeIndex == 2
  Future<void> _searchBikingRoute(
      BMFPlanNode stNode, BMFPlanNode enNode) async {
    // 对齐 Android: BikingRoutePlanOption().from().to()
    final option = BMFRidingRoutePlanOption(
      from: stNode,
      to: enNode,
    );

    final routeSearch = BMFRidingRouteSearch();
    routeSearch.onGetRidingRouteSearchResult(
      callback: (result, errorCode) {
        state = state.copyWith(isLoading: false);

        if (errorCode == BMFSearchErrorCode.NO_ERROR && result.routes != null) {
          final routes = _parseBikingRouteResult(result);
          if (routes.isEmpty) {
            state = state.copyWith(
              errorMessage: '没有找到骑行路线',
              clearRideRoutes: true,
            );
          } else {
            state = state.copyWith(
              rideRouteResult: result,
              rideRoutes: routes,
              clearError: true,
            );
          }
        } else {
          final errorMsg = _getErrorMessage(errorCode);
          debugPrint('BusRouteViewModel: 骑行路线规划失败: $errorCode, $errorMsg');
          state = state.copyWith(
            errorMessage: errorMsg,
            clearRideRoutes: true,
          );
        }
      },
    );

    // 对齐 Android: routePlanSearch?.bikingSearch(option)
    // 鸿蒙端: 骑行搜索方法为 ridingRouteSearch
    await routeSearch.ridingRouteSearch(option);
  }

  /// 搜索步行路线 - 对齐 Android modeIndex == 3
  Future<void> _searchWalkingRoute(
      BMFPlanNode stNode, BMFPlanNode enNode) async {
    // 对齐 Android: WalkingRoutePlanOption().from().to()
    final option = BMFWalkingRoutePlanOption(
      from: stNode,
      to: enNode,
    );

    final routeSearch = BMFWalkingRouteSearch();
    routeSearch.onGetWalkingRouteSearchResult(
      callback: (result, errorCode) {
        state = state.copyWith(isLoading: false);

        if (errorCode == BMFSearchErrorCode.NO_ERROR && result.routes != null) {
          final routes = _parseWalkingRouteResult(result);
          if (routes.isEmpty) {
            state = state.copyWith(
              errorMessage: '没有找到步行路线',
              clearWalkRoutes: true,
            );
          } else {
            state = state.copyWith(
              walkRouteResult: result,
              walkRoutes: routes,
              clearError: true,
            );
          }
        } else {
          final errorMsg = _getErrorMessage(errorCode);
          debugPrint('BusRouteViewModel: 步行路线规划失败: $errorCode, $errorMsg');
          state = state.copyWith(
            errorMessage: errorMsg,
            clearWalkRoutes: true,
          );
        }
      },
    );

    // 对齐 Android: routePlanSearch?.walkingSearch(option)
    await routeSearch.walkingRouteSearch(option);
  }

  /// 搜索公交路线 - 对齐 Android searchBusRoute
  Future<void> searchBusRoute() async {
    if (state.selectedStartPoint == null || state.selectedEndPoint == null) {
      state = state.copyWith(errorMessage: '请选择起点和终点');
      return;
    }

    await _searchRouteByMode(state.selectedTransportMode);
  }

  /// 清除错误信息 - 对齐 Android clearError
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// 根据选择的交通方式获取当前路线列表 - 对齐 Android getCurrentRouteList
  List<dynamic> getCurrentRouteList() {
    switch (state.selectedTransportMode) {
      case 0:
        return state.busRoutes; // 公共交通
      case 1:
        return state.driveRoutes; // 驾车
      case 2:
        return state.rideRoutes; // 骑行
      case 3:
        return state.walkRoutes; // 步行
      default:
        return const [];
    }
  }

  /// 点击路线项目 - 对齐 Android onRouteItemClick
  ///
  /// 鸿蒙端差异：Android 直接调用 MapNaviActivity.start / BusRouteLineDetailActivity.start
  /// 鸿蒙端: 暴露 pendingNaviAction 状态由 Page 层观察并执行跳转
  void onRouteItemClick(dynamic routeItem) {
    if (routeItem is BusRouteItem) {
      // 对齐 Android: 处理公交路线点击 -> BusRouteLineDetailActivity.start
      final transitRouteResult = routeItem.transitRouteResult;
      final transitRouteLine = routeItem.transitRouteLine;
      if (transitRouteResult != null && transitRouteLine != null) {
        final startPoint = state.selectedStartPoint ?? BMFCoordinate(0, 0);
        final endPoint = state.selectedEndPoint ?? BMFCoordinate(0, 0);
        state = state.copyWith(
          pendingNaviAction: PendingNaviAction(
            type: NaviActionType.routeLineDetail,
            startPoint: startPoint,
            endPoint: endPoint,
            startName: state.fromLocation,
            endName: state.toLocation,
            naviStartType: NaviStartType.drive,
            transitRouteLines: [transitRouteLine],
            transitRouteResult: transitRouteResult,
          ),
        );
        debugPrint(
            'BusRouteViewModel: 点击公交路线项目，已设置 pendingNaviAction(routeLineDetail)');
      }
    } else if (routeItem is DriveRouteItem) {
      // 对齐 Android: 处理驾车路线点击 -> startDrivingNavigation
      final routeLine = routeItem.drivingRouteLine;
      if (routeLine != null) {
        _startDrivingNavigation(routeLine);
      } else {
        debugPrint('BusRouteViewModel: 驾车路线数据为空');
        state = state.copyWith(errorMessage: '驾车路线数据不完整');
      }
    } else if (routeItem is RideRouteItem) {
      // 对齐 Android: 处理骑行路线点击 -> startBikingNavigation
      final routeLine = routeItem.bikingRouteLine;
      if (routeLine != null) {
        _startBikingNavigation(routeLine);
      } else {
        debugPrint('BusRouteViewModel: 骑行路线数据为空');
        state = state.copyWith(errorMessage: '骑行路线数据不完整');
      }
    } else if (routeItem is WalkRouteItem) {
      // 对齐 Android: 处理步行路线点击 -> startWalkingNavigation
      final routeLine = routeItem.walkingRouteLine;
      if (routeLine != null) {
        _startWalkingNavigation(routeLine);
      } else {
        debugPrint('BusRouteViewModel: 步行路线数据为空');
        state = state.copyWith(errorMessage: '步行路线数据不完整');
      }
    }
  }

  /// 启动驾车导航 - 对齐 Android startDrivingNavigation
  void _startDrivingNavigation(BMFDrivingRouteLine drivingRouteLine) {
    try {
      final startPoint = state.selectedStartPoint ?? BMFCoordinate(0, 0);
      final endPoint = state.selectedEndPoint ?? BMFCoordinate(0, 0);
      // 对齐 Android: RouteDataManager.setDrivingRouteLine(drivingRouteLine)
      RouteDataManager.instance.setDrivingRouteLine(drivingRouteLine);

      // 对齐 Android: MapNaviActivity.start(context, startPoint, endPoint, fromLocation, toLocation, NaviStartType.Drive)
      // 鸿蒙端: 暴露 pendingNaviAction 由 Page 层跳转
      state = state.copyWith(
        pendingNaviAction: PendingNaviAction(
          type: NaviActionType.startNavi,
          startPoint: startPoint,
          endPoint: endPoint,
          startName: state.fromLocation,
          endName: state.toLocation,
          naviStartType: NaviStartType.drive,
        ),
      );
      debugPrint('BusRouteViewModel: 成功启动驾车导航（pending）');
    } catch (e) {
      debugPrint('BusRouteViewModel: 启动驾车导航失败: $e');
      state = state.copyWith(errorMessage: '启动驾车导航失败: $e');
    }
  }

  /// 启动骑行导航 - 对齐 Android startBikingNavigation
  void _startBikingNavigation(BMFRidingRouteLine bikingRouteLine) {
    try {
      final startPoint = state.selectedStartPoint ?? BMFCoordinate(0, 0);
      final endPoint = state.selectedEndPoint ?? BMFCoordinate(0, 0);
      // 对齐 Android: RouteDataManager.setBikingRouteLine(bikingRouteLine)
      // 鸿蒙端: RouteDataManager 用 setBikingRouteLine(BMFRidingRouteLine)
      RouteDataManager.instance.setBikingRouteLine(bikingRouteLine);

      state = state.copyWith(
        pendingNaviAction: PendingNaviAction(
          type: NaviActionType.startNavi,
          startPoint: startPoint,
          endPoint: endPoint,
          startName: state.fromLocation,
          endName: state.toLocation,
          naviStartType: NaviStartType.bike,
        ),
      );
      debugPrint('BusRouteViewModel: 成功启动骑行导航（pending）');
    } catch (e) {
      debugPrint('BusRouteViewModel: 启动骑行导航失败: $e');
      state = state.copyWith(errorMessage: '启动骑行导航失败: $e');
    }
  }

  /// 启动步行导航 - 对齐 Android startWalkingNavigation
  void _startWalkingNavigation(BMFWalkingRouteLine walkingRouteLine) {
    try {
      final startPoint = state.selectedStartPoint ?? BMFCoordinate(0, 0);
      final endPoint = state.selectedEndPoint ?? BMFCoordinate(0, 0);
      // 对齐 Android: RouteDataManager.setWalkingRouteLine(walkingRouteLine)
      RouteDataManager.instance.setWalkingRouteLine(walkingRouteLine);

      state = state.copyWith(
        pendingNaviAction: PendingNaviAction(
          type: NaviActionType.startNavi,
          startPoint: startPoint,
          endPoint: endPoint,
          startName: state.fromLocation,
          endName: state.toLocation,
          naviStartType: NaviStartType.walk,
        ),
      );
      debugPrint('BusRouteViewModel: 成功启动步行导航（pending）');
    } catch (e) {
      debugPrint('BusRouteViewModel: 启动步行导航失败: $e');
      state = state.copyWith(errorMessage: '启动步行导航失败: $e');
    }
  }

  /// 清除待处理导航动作（Page 层处理跳转后调用）
  void clearPendingNaviAction() {
    state = state.copyWith(clearPendingNavi: true);
  }

  /// 清除待处理搜索请求（Page 层处理跳转后调用）
  void clearPendingSearchRequest() {
    state = state.copyWith(clearPendingSearch: true);
  }

  /// 设置加载状态 - 对齐 Android setLoading
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  /// 开始定位并更新路线起始位置 - 对齐 Android startLocationForRoute
  Future<void> startLocationForRoute() async {
    final hasPermission =
        await _locationRepository.hasLocationPermissionAsync();
    if (!hasPermission) {
      state = state.copyWith(errorMessage: '缺少定位权限');
      return;
    }

    state = state.copyWith(isLoading: true);

    await _startLocationInternal();
  }

  /// 内部定位逻辑 - 对齐 Android startLocationInternal
  Future<void> _startLocationInternal() async {
    try {
      // 对齐 Android: locationRepository.getCurrentLocation().fold(...)
      final locationData = await _locationRepository.getCurrentLocation();
      if (locationData != null) {
        state = state.copyWith(
          isLoading: false,
          currentCity: locationData.city,
        );
        if (!state.isSearchMode) {
          await updateFromLocationWithCoordinate(
            locationName: '我的位置',
            latitude: locationData.latitude,
            longitude: locationData.longitude,
          );
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: '定位失败',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '定位异常: $e',
      );
    }
  }

  /// 停止定位 - 对齐 Android stopLocation
  void stopLocation() {
    _locationRepository.stopLocation();
  }

  /// 获取错误信息 - 对齐 Android getErrorMessage
  String _getErrorMessage(BMFSearchErrorCode errorCode) {
    switch (errorCode) {
      case BMFSearchErrorCode.AMBIGUOUS_ROURE_ADDR:
        return '起点或终点模糊，请重新选择';
      case BMFSearchErrorCode.NOT_SUPPORT_BUS:
        return '该地区不支持公交路线查询';
      case BMFSearchErrorCode.NOT_SUPPORT_BUS_2CITY:
        return '不支持跨城市公交路线查询';
      case BMFSearchErrorCode.RESULT_NOT_FOUND:
        return '未找到相关路线，请检查起终点';
      case BMFSearchErrorCode.KEY_ERROR:
        return '地图服务密钥错误';
      case BMFSearchErrorCode.NETWOKR_ERROR:
        return '网络连接失败，请检查网络';
      case BMFSearchErrorCode.NETWOKR_TIMEOUT:
        return '网络请求超时，请重试';
      case BMFSearchErrorCode.PERMISSION_UNFINISHED:
        return '权限验证未完成';
      case BMFSearchErrorCode.ST_EN_TOO_NEAR:
        return '距离太近，请选择其他出行方式';
      default:
        return '路线规划失败，请重试';
    }
  }

  /// 检查网络状态 - 对齐 Android checkNetworkAndShowError
  ///
  /// 鸿蒙端差异：Android 用 ConnectivityManager 检查网络
  /// 鸿蒙端: 无对应 API（无 connectivity_plus 依赖），乐观返回 true
  /// 实际网络错误由搜索回调兜底
  bool _checkNetworkAndShowError() {
    // TODO(HarmonyOS): 若需严格网络检查，引入 connectivity_plus 或鸿蒙端网络状态 API
    return true;
  }

  /// 重置所有状态 - 对齐 Android resetState
  void resetState() {
    // 对齐 Android: 保留 currentCity / currentLocation / isSearchMode
    state = BusRouteUiState(
      currentCity: state.currentCity,
      currentLocation: state.currentLocation,
      isSearchMode: state.isSearchMode,
    );
  }

  /// 设置搜索模式 - 对齐 Android setSearchMode
  void setSearchMode(bool searchMode) {
    state = state.copyWith(isSearchMode: searchMode);

    // 对齐 Android: 如果是搜索模式，调整显示文本
    if (searchMode) {
      state = state.copyWith(
        fromLocation: '请选择出发地',
        toLocation: '请选择目的地',
      );
    }
  }

  /// 跳转到搜索页面选择位置 - 对齐 Android navigateToSearch
  ///
  /// 鸿蒙端差异：Android 直接调用 BusSearchActivity.startForResult
  /// 鸿蒙端: 暴露 pendingSearchRequest 状态由 Page 层观察并执行跳转（go_router）
  void navigateToSearch({required bool isFromLocation}) {
    debugPrint(
        'BusRouteViewModel: navigateToSearch 调用 - isFromLocation: $isFromLocation, currentCity: ${state.currentCity}');
    try {
      // 对齐 Android: BusSearchActivity.startForResult(context, isFromLocation, currentCity, requestCode)
      state = state.copyWith(
        pendingSearchRequest: PendingSearchRequest(
          isFromLocation: isFromLocation,
          currentCity: state.currentCity,
          // 对齐 Android: if (isFromLocation) 1001 else 1002
          requestCode: isFromLocation ? 1001 : 1002,
        ),
      );
      debugPrint('BusRouteViewModel: 已设置 pendingSearchRequest');
    } catch (e) {
      debugPrint('BusRouteViewModel: 启动搜索页面失败: $e');
      state = state.copyWith(errorMessage: '启动搜索失败');
    }
  }

  /// 处理搜索页面返回的结果 - 对齐 Android handleSearchResult
  Future<void> handleSearchResult({
    required bool isFromLocation,
    required String locationName,
    required double latitude,
    required double longitude,
  }) async {
    final latLng = BMFCoordinate(latitude, longitude);

    // 对齐 Android: 根据是否交换和点击的输入框来决定更新哪个字段
    if (state.isLocationSwapped) {
      // 交换后：第一个框(fromLocation)是目的地，第二个框(toLocation)是出发地
      if (isFromLocation) {
        // 对齐 Android: 点击第一个框(现在是目的地)
        state = state.copyWith(
          fromLocation: locationName,
          selectedStartPoint: latLng,
        );
      } else {
        // 对齐 Android: 点击第二个框(现在是出发地)
        state = state.copyWith(
          toLocation: locationName,
          selectedEndPoint: latLng,
        );
      }
    } else {
      // 未交换：第一个框(fromLocation)是出发地，第二个框(toLocation)是目的地
      if (isFromLocation) {
        state = state.copyWith(
          fromLocation: locationName,
          selectedStartPoint: latLng,
        );
      } else {
        state = state.copyWith(
          toLocation: locationName,
          selectedEndPoint: latLng,
        );
      }
    }

    // 选点只更新起终点；由用户点击“搜索路线”后再发起路线规划。
  }

  /// 验证输入参数 - 对齐 Android validateRouteParams
  ///
  /// 注：Android 原代码中调用处已注释（// if (!validateRouteParams(...)) return），
  /// 此方法保留以对齐原项目结构，后续若启用参数校验可直接调用
  // ignore: unused_element
  bool _validateRouteParams(
      BMFCoordinate? startPoint, BMFCoordinate? endPoint) {
    if (startPoint == null) {
      state = state.copyWith(errorMessage: '请选择出发地');
      return false;
    }
    if (endPoint == null) {
      state = state.copyWith(errorMessage: '请选择目的地');
      return false;
    }
    if (startPoint.latitude == endPoint.latitude &&
        startPoint.longitude == endPoint.longitude) {
      state = state.copyWith(errorMessage: '出发地和目的地不能相同');
      return false;
    }
    return true;
  }

  /// 释放资源 - 对齐 Android onCleared
  void dispose() {
    _suggestionsTimer?.cancel();
    _suggestionsTimer = null;
    _locationRepository.stopLocation();
    debugPrint('BusRouteViewModel: ViewModel 资源清理完成');
  }
}

/// 公交路线规划 ViewModel Provider
final busRouteViewModelProvider =
    NotifierProvider<BusRouteViewModel, BusRouteUiState>(
  BusRouteViewModel.new,
);
