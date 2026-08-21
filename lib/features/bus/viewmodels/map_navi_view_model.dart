// 地图导航 ViewModel - 对齐 Android bus/viewmodel/MapNaviViewModel.kt
// 导航引擎初始化、路线引导、驾车/骑行/步行导航生命周期管理
//
// 鸿蒙端差异：
// - Android: ViewModel + MutableStateFlow → Flutter: Riverpod Notifier + State
// - Android: BikeNavigateHelper / WalkNavigateHelper / BaiduNaviManagerFactory 导航 SDK
// - 鸿蒙端: 上述导航 SDK 可用性未验证，全部用 try-catch 兜底，不可用时记录日志但不崩溃
// - Android: 导航视图通过 View 返回，由 Activity setContentView 展示
// - 鸿蒙端: Flutter 无对应 View 概念，导航视图展示由 Page 层处理
// - Android: 导航事件通过 IBNaviListener / IBNaviViewListener / IBRouteGuidanceListener / IWRouteGuidanceListener 回调
// - 鸿蒙端: SDK 不可用，回调无法注册，状态保持初始值，由 Page 层兜底显示
// - Android: Activity 生命周期方法（onStart/onStop/onPause/onResume/onDestroy/onBackPressed/onKeyDown/onConfigurationChanged/onRequestPermissionsResult/onActivityResult）
// - 鸿蒙端: Flutter 用 WidgetsBindingObserver 监听 AppLifecycleState，由 Page 层调用对应方法
import 'package:flutter/foundation.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';
import 'package:flutter_baidu_mapapi_search/flutter_baidu_mapapi_search.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/navi_plan_manager.dart';
import '../utils/route_data_manager.dart';

/// 地图导航数据状态 - 对齐 Android MapNaviState data class
class MapNaviState {
  const MapNaviState({
    this.naviStartType = NaviStartType.drive,
    this.navigationStatus = '准备导航',
    this.remainDistance = '',
    this.remainTime = '',
    this.currentGuideText = '',
    this.gpsStatus = 'GPS信号良好',
    this.isEngineInitialized = false,
    this.isRoutePlanSuccess = false,
    this.errorMessage = '',
    this.startName = '',
    this.endName = '',
  });

  /// 导航类型（对齐 Android naviStartType: NaviStartType = NaviStartType.Drive）
  final NaviStartType naviStartType;

  /// 导航状态描述
  final String navigationStatus;

  /// 剩余距离
  final String remainDistance;

  /// 剩余时间
  final String remainTime;

  /// 当前引导文本
  final String currentGuideText;

  /// GPS 状态
  final String gpsStatus;

  /// 引擎是否已初始化
  final bool isEngineInitialized;

  /// 路线规划是否成功
  final bool isRoutePlanSuccess;

  /// 错误信息
  final String errorMessage;

  /// 起点名称
  final String startName;

  /// 终点名称
  final String endName;

  MapNaviState copyWith({
    NaviStartType? naviStartType,
    String? navigationStatus,
    String? remainDistance,
    String? remainTime,
    String? currentGuideText,
    String? gpsStatus,
    bool? isEngineInitialized,
    bool? isRoutePlanSuccess,
    String? errorMessage,
    String? startName,
    String? endName,
    bool clearError = false,
  }) {
    return MapNaviState(
      naviStartType: naviStartType ?? this.naviStartType,
      navigationStatus: navigationStatus ?? this.navigationStatus,
      remainDistance: remainDistance ?? this.remainDistance,
      remainTime: remainTime ?? this.remainTime,
      currentGuideText: currentGuideText ?? this.currentGuideText,
      gpsStatus: gpsStatus ?? this.gpsStatus,
      isEngineInitialized: isEngineInitialized ?? this.isEngineInitialized,
      isRoutePlanSuccess: isRoutePlanSuccess ?? this.isRoutePlanSuccess,
      errorMessage: clearError ? '' : (errorMessage ?? this.errorMessage),
      startName: startName ?? this.startName,
      endName: endName ?? this.endName,
    );
  }
}

/// 地图导航 ViewModel - 对齐 Android MapNaviViewModel
///
/// 鸿蒙端差异：百度导航 SDK（BikeNavigateHelper/WalkNavigateHelper/BaiduNaviManagerFactory）
/// 鸿蒙端可用性未验证，所有 SDK 调用用 try-catch 兜底 + TODO 标注
class MapNaviViewModel extends Notifier<MapNaviState> {
  /// 日志 TAG - 对齐 Android TAG = "MapNaviViewModel"
  static const String _tag = 'MapNaviViewModel';

  /// 导航数据（对齐 Android drivingRouteLine / bikingRouteLine / walkingRouteLine）
  /// 注：鸿蒙端导航 SDK 不可用时这些字段仅存储不读取，待 SDK 可用后供导航逻辑使用
  // ignore: unused_field
  BMFDrivingRouteLine? _drivingRouteLine;
  // ignore: unused_field
  BMFRidingRouteLine? _bikingRouteLine;
  // ignore: unused_field
  BMFWalkingRouteLine? _walkingRouteLine;

  /// 坐标数据（对齐 Android startPoint / endPoint）
  /// 注：鸿蒙端导航 SDK 不可用时这些字段仅存储不读取，待 SDK 可用后供导航逻辑使用
  // ignore: unused_field
  BMFCoordinate? _startPoint;
  // ignore: unused_field
  BMFCoordinate? _endPoint;

  @override
  MapNaviState build() {
    return const MapNaviState();
  }

  /// 初始化导航参数 - 对齐 Android initNaviParams
  void initNaviParams({
    required NaviStartType naviStartType,
    BMFCoordinate? startPoint,
    BMFCoordinate? endPoint,
    String? startName,
    String? endName,
  }) {
    _startPoint = startPoint;
    _endPoint = endPoint;

    state = state.copyWith(
      naviStartType: naviStartType,
      startName: startName ?? '',
      endName: endName ?? '',
    );

    // 对齐 Android: 从 RouteDataManager 获取路线数据
    _drivingRouteLine = RouteDataManager.instance.getDrivingRouteLine();
    _bikingRouteLine = RouteDataManager.instance.getBikingRouteLine();
    _walkingRouteLine = RouteDataManager.instance.getWalkingRouteLine();

    debugPrint('$_tag: 导航参数初始化完成: $naviStartType, 起点: $startName, 终点: $endName');
  }

  /// 路线规划完成后准备导航UI展示 - 对齐 Android prepareNaviAfterPlan
  ///
  /// 鸿蒙端差异：Android 接收 ComponentActivity 参数用于创建导航视图
  /// 鸿蒙端: Flutter 无 ComponentActivity，去掉该参数，由 Page 层处理视图创建
  Future<void> prepareNaviAfterPlan(NaviStartType naviStartType) async {
    try {
      debugPrint('$_tag: 路线规划完成，准备导航UI: $naviStartType');

      // 对齐 Android: 设置路线规划成功状态
      state = state.copyWith(
        naviStartType: naviStartType,
        isRoutePlanSuccess: true,
        navigationStatus: '路线规划完成，准备导航',
      );

      switch (naviStartType) {
        case NaviStartType.drive:
          // 对齐 Android: setupDriveNaviView(activity)
          await _setupDriveNaviView();
          break;
        case NaviStartType.bike:
          // 对齐 Android: initBikeNavigation(activity)
          await _initBikeNavigation();
          break;
        case NaviStartType.walk:
          // 对齐 Android: initWalkNavigation(activity)
          await _initWalkNavigation();
          break;
      }
    } catch (e, stackTrace) {
      debugPrint('$_tag: 准备导航UI失败: $e\n$stackTrace');
      state = state.copyWith(errorMessage: '准备导航UI失败: $e');
    }
  }

  /// 设置驾车导航视图 - 对齐 Android setupDriveNaviView
  Future<void> _setupDriveNaviView() async {
    try {
      debugPrint('$_tag: 设置驾车导航视图');

      // 对齐 Android: BaiduNaviManagerFactory.getRouteGuideManager()
      // 鸿蒙端差异：BaiduNaviManagerFactory 鸿蒙端可用性未验证
      // TODO(HarmonyOS): 鸿蒙端导航 SDK 可用后，替换以下 stub 为真实导航视图创建
      try {
        // 模拟 Android: driveRouteGuideManager = BaiduNaviManagerFactory.getRouteGuideManager()
        // 模拟 Android: driveNaviView = driveRouteGuideManager?.onCreate(activity, config)
        debugPrint('$_tag: 鸿蒙端百度导航 SDK 未验证，驾车导航视图创建跳过');
        state = state.copyWith(navigationStatus: '驾车导航准备就绪（stub）');
      } catch (e) {
        debugPrint('$_tag: 创建驾车导航视图失败: $e');
        state = state.copyWith(errorMessage: '创建导航视图失败: $e');
      }
    } catch (e, stackTrace) {
      debugPrint('$_tag: 设置驾车导航视图异常: $e\n$stackTrace');
    }
  }

  /// 初始化骑行导航 - 对齐 Android initBikeNavigation
  Future<void> _initBikeNavigation() async {
    try {
      debugPrint('$_tag: 开始初始化骑行导航');

      state = state.copyWith(navigationStatus: '初始化骑行导航...');

      // 对齐 Android: BikeNavigateHelper.getInstance().initNaviEngine(activity, listener)
      // 鸿蒙端差异：BikeNavigateHelper 鸿蒙端可用性未验证
      // TODO(HarmonyOS): 鸿蒙端骑行导航 SDK 可用后，实现真实初始化
      try {
        // 模拟 Android: bikeNaviHelper = BikeNavigateHelper.getInstance()
        // 模拟 Android: bikeNaviHelper?.initNaviEngine(activity, IBEngineInitListener)
        debugPrint('$_tag: 鸿蒙端骑行导航 SDK 未验证，引擎初始化跳过');
        // 模拟 Android: engineInitSuccess()
        state = state.copyWith(
          isEngineInitialized: false,
          navigationStatus: '骑行导航引擎未初始化（鸿蒙端 SDK 不可用）',
          errorMessage: '鸿蒙端骑行导航 SDK 不可用',
        );
      } catch (e) {
        // 对齐 Android: engineInitFail -> bikeNaviHelper?.unInitNaviEngine()
        debugPrint('$_tag: 骑行导航引擎初始化失败: $e');
        state = state.copyWith(
          isEngineInitialized: false,
          navigationStatus: '导航引擎初始化失败',
          errorMessage: '骑行导航引擎初始化失败: $e',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('$_tag: 初始化骑行导航失败: $e\n$stackTrace');
      state = state.copyWith(errorMessage: '初始化骑行导航异常: $e');
    }
  }

  /// 初始化步行导航 - 对齐 Android initWalkNavigation
  Future<void> _initWalkNavigation() async {
    try {
      debugPrint('$_tag: 开始初始化步行导航');

      state = state.copyWith(navigationStatus: '初始化步行导航...');

      // 对齐 Android: WalkNavigateHelper.getInstance().initNaviEngine(activity, listener)
      // 鸿蒙端差异：WalkNavigateHelper 鸿蒙端可用性未验证
      // TODO(HarmonyOS): 鸿蒙端步行导航 SDK 可用后，实现真实初始化
      try {
        debugPrint('$_tag: 鸿蒙端步行导航 SDK 未验证，引擎初始化跳过');
        state = state.copyWith(
          isEngineInitialized: false,
          navigationStatus: '步行导航引擎未初始化（鸿蒙端 SDK 不可用）',
          errorMessage: '鸿蒙端步行导航 SDK 不可用',
        );
      } catch (e) {
        debugPrint('$_tag: 步行导航引擎初始化失败: $e');
        state = state.copyWith(
          isEngineInitialized: false,
          navigationStatus: '步行导航引擎初始化失败',
          errorMessage: '步行导航引擎初始化失败: $e',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('$_tag: 初始化步行导航失败: $e\n$stackTrace');
      state = state.copyWith(errorMessage: '初始化步行导航异常: $e');
    }
  }

  /// 启动骑行导航 - 对齐 Android startBikeNavi
  Future<void> startBikeNavi() async {
    try {
      // 对齐 Android: bikeNaviHelper?.startBikeNavi(activity)
      // 鸿蒙端: SDK 不可用，仅记录日志
      // TODO(HarmonyOS): 鸿蒙端骑行导航 SDK 可用后，实现真实启动
      debugPrint('$_tag: 鸿蒙端骑行导航 SDK 不可用，无法启动骑行导航');
    } catch (e) {
      debugPrint('$_tag: 启动骑行导航失败: $e');
    }
  }

  /// 启动步行导航 - 对齐 Android startWalkNavi
  Future<void> startWalkNavi() async {
    try {
      // 对齐 Android: walkNaviHelper?.startWalkNavi(activity)
      // 鸿蒙端: SDK 不可用，仅记录日志
      // TODO(HarmonyOS): 鸿蒙端步行导航 SDK 可用后，实现真实启动
      debugPrint('$_tag: 鸿蒙端步行导航 SDK 不可用，无法启动步行导航');
    } catch (e) {
      debugPrint('$_tag: 启动步行导航失败: $e');
    }
  }

  /// 退出导航 - 对齐 Android exitNavigation
  void exitNavigation() {
    try {
      switch (state.naviStartType) {
        case NaviStartType.bike:
          // 对齐 Android: bikeNaviHelper?.quit()
          // TODO(HarmonyOS): 鸿蒙端骑行导航 SDK 可用后，调用 quit()
          debugPrint('$_tag: 鸿蒙端骑行导航 SDK 不可用，退出骑行导航（stub）');
          break;
        case NaviStartType.walk:
          // 对齐 Android: walkNaviHelper?.quit()
          debugPrint('$_tag: 鸿蒙端步行导航 SDK 不可用，退出步行导航（stub）');
          break;
        case NaviStartType.drive:
          // 对齐 Android: driveRouteGuideManager?.onDestroy(false)
          debugPrint('$_tag: 鸿蒙端驾车导航 SDK 不可用，退出驾车导航（stub）');
          break;
      }
    } catch (e) {
      debugPrint('$_tag: 退出导航异常: $e');
    }
  }

  /// 恢复导航 - 对齐 Android resumeNavigation
  void resumeNavigation() {
    try {
      switch (state.naviStartType) {
        case NaviStartType.bike:
          // 对齐 Android: bikeNaviHelper?.resume()
          debugPrint('$_tag: resumeNavigation(bike) stub');
          break;
        case NaviStartType.walk:
          // 对齐 Android: walkNaviHelper?.resume()
          debugPrint('$_tag: resumeNavigation(walk) stub');
          break;
        case NaviStartType.drive:
          // 对齐 Android: driveRouteGuideManager?.onResume()
          debugPrint('$_tag: resumeNavigation(drive) stub');
          break;
      }
    } catch (e) {
      debugPrint('$_tag: 恢复导航异常: $e');
    }
  }

  /// 暂停导航 - 对齐 Android pauseNavigation
  void pauseNavigation() {
    try {
      switch (state.naviStartType) {
        case NaviStartType.bike:
          // 对齐 Android: bikeNaviHelper?.pause()
          debugPrint('$_tag: pauseNavigation(bike) stub');
          break;
        case NaviStartType.walk:
          // 对齐 Android: walkNaviHelper?.pause()
          debugPrint('$_tag: pauseNavigation(walk) stub');
          break;
        case NaviStartType.drive:
          // 对齐 Android: driveRouteGuideManager?.onPause()
          debugPrint('$_tag: pauseNavigation(drive) stub');
          break;
      }
    } catch (e) {
      debugPrint('$_tag: 暂停导航异常: $e');
    }
  }

  /// 开始导航 - 对应 Activity.onStart() - 对齐 Android startNavigation
  void startNavigation() {
    try {
      switch (state.naviStartType) {
        case NaviStartType.drive:
          // 对齐 Android: driveRouteGuideManager?.onStart()
          debugPrint('$_tag: 驾车导航 onStart 调用（stub）');
          break;
        case NaviStartType.bike:
          // 对齐 Android: 骑行导航没有 onStart 方法
          break;
        case NaviStartType.walk:
          // 对齐 Android: 步行导航没有 onStart 方法
          break;
      }
    } catch (e) {
      debugPrint('$_tag: 开始导航异常: $e');
    }
  }

  /// 停止导航 - 对应 Activity.onStop() - 对齐 Android stopNavigation
  void stopNavigation() {
    try {
      switch (state.naviStartType) {
        case NaviStartType.drive:
          // 对齐 Android: driveRouteGuideManager?.onStop()
          debugPrint('$_tag: 驾车导航 onStop 调用（stub）');
          break;
        case NaviStartType.bike:
          // 对齐 Android: 骑行导航没有 onStop 方法
          break;
        case NaviStartType.walk:
          // 对齐 Android: 步行导航没有 onStop 方法
          break;
      }
    } catch (e) {
      debugPrint('$_tag: 停止导航异常: $e');
    }
  }

  /// 销毁导航 - 对齐 Android destroyNavigation
  void destroyNavigation() {
    try {
      switch (state.naviStartType) {
        case NaviStartType.drive:
          // 对齐 Android: driveRouteGuideManager?.onDestroy(true)
          debugPrint('$_tag: 驾车导航 onDestroy 调用（stub）');
          break;
        case NaviStartType.bike:
          // 对齐 Android: NaviPlanManager.getInstance().cleanup()
          NaviPlanManager.instance.cleanup();
          break;
        case NaviStartType.walk:
          // 对齐 Android: NaviPlanManager.getInstance().cleanup()
          NaviPlanManager.instance.cleanup();
          break;
      }
    } catch (e) {
      debugPrint('$_tag: 销毁导航异常: $e');
    }
  }

  /// 处理返回键 - 对应 Activity.onBackPressed() - 对齐 Android handleBackPressed
  bool handleBackPressed() {
    try {
      switch (state.naviStartType) {
        case NaviStartType.drive:
          // 对齐 Android: driveRouteGuideManager?.onBackPressed(false, true)
          debugPrint('$_tag: 驾车导航处理返回键（stub）');
          return true; // SDK 处理了返回键
        case NaviStartType.bike:
          // 对齐 Android: 骑行和步行导航直接退出
          return false;
        case NaviStartType.walk:
          return false;
      }
    } catch (e) {
      debugPrint('$_tag: 处理返回键异常: $e');
      return false;
    }
  }

  /// 释放资源 - 对齐 Android onCleared
  void dispose() {
    try {
      switch (state.naviStartType) {
        case NaviStartType.bike:
          // 对齐 Android: bikeNaviHelper?.quit()
          debugPrint('$_tag: dispose(bike) stub');
          break;
        case NaviStartType.walk:
          // 对齐 Android: walkNaviHelper?.quit()
          debugPrint('$_tag: dispose(walk) stub');
          break;
        case NaviStartType.drive:
          // 对齐 Android: driveRouteGuideManager?.onDestroy(false)
          debugPrint('$_tag: dispose(drive) stub');
          break;
      }
    } catch (e) {
      debugPrint('$_tag: 清理导航资源异常: $e');
    }

    // 对齐 Android: 清理数据
    _startPoint = null;
    _endPoint = null;
    RouteDataManager.instance.clearAll();
  }
}

/// 地图导航 ViewModel Provider
final mapNaviViewModelProvider =
    NotifierProvider<MapNaviViewModel, MapNaviState>(
  MapNaviViewModel.new,
);
