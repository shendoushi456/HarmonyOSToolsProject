// 导航规划管理器 - 对齐 Android bus/utils/NaviPlanManager.kt
// 负责在跳转到导航页面之前进行导航初始化和路线规划
//
// 鸿蒙端差异：
// - Android: BikeNavigateHelper / WalkNavigateHelper / BaiduNaviManagerFactory 等导航 SDK
// - 鸿蒙端: 上述导航 SDK 可用性未验证，全部用 try-catch 兜底，不可用时记录日志但不崩溃
// - Android: 通过 Context + Intent 跳转 MapNaviActivity / WalkNaviActivity
// - 鸿蒙端: Flutter 用 go_router 路由，通过 onNaviReady 回调通知调用方进行页面跳转
// - Android: Handler + Looper.getMainLooper() 处理驾车路线规划消息
// - 鸿蒙端: 用 Completer/Stream 替代，本类暂以日志为主
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';

/// 导航起点类型 - 对齐 Android bus/MapNaviActivity.kt 中的 NaviStartType sealed class
/// 注：Android 原为 sealed class，鸿蒙端简化为 enum
enum NaviStartType {
  /// 驾车
  drive,
  /// 骑行
  bike,
  /// 步行
  walk,
}

/// 导航规划就绪回调
/// 当路线规划成功后触发，调用方在此回调中执行页面跳转（替代 Android MapNaviActivity.startAfterPlan）
/// 参数：
/// - startPoint: 起点坐标
/// - endPoint: 终点坐标
/// - startName: 起点名称
/// - endName: 终点名称
/// - naviStartType: 导航类型
typedef NaviReadyCallback = void Function({
  required BMFCoordinate startPoint,
  required BMFCoordinate endPoint,
  required String startName,
  required String endName,
  required NaviStartType naviStartType,
});

/// 导航规划管理器 - 对齐 Android NaviPlanManager（单例）
/// 负责在跳转到导航页面之前进行导航初始化和路线规划
class NaviPlanManager {
  NaviPlanManager._internal() {
    // 对齐 Android 私有构造函数
  }

  static final NaviPlanManager _instance = NaviPlanManager._internal();
  static NaviPlanManager get instance => _instance;

  /// 日志 TAG - 对齐 Android TAG = "NaviPlanManager"
  static const String _tag = 'NaviPlanManager';

  // 当前规划任务信息（对齐 Android currentXxx 字段）
  BMFCoordinate? _currentStartPoint;
  BMFCoordinate? _currentEndPoint;
  String? _currentStartName;
  String? _currentEndName;
  NaviStartType? _currentNaviType;

  /// 导航就绪回调（替代 Android MapNaviActivity.startAfterPlan）
  /// 调用方设置此回调以在路线规划成功后跳转页面
  NaviReadyCallback? onNaviReady;

  /// 启动导航（在路线规划成功后跳转到导航页面）
  /// 对齐 Android startNaviWithPlan
  ///
  /// 鸿蒙端差异：去掉 Context 参数（Flutter 不需要）
  Future<void> startNaviWithPlan({
    required BMFCoordinate startPoint,
    required BMFCoordinate endPoint,
    required String startName,
    required String endName,
    required NaviStartType naviStartType,
  }) async {
    debugPrint('$_tag: 开始导航规划流程: $naviStartType');

    // 保存当前任务信息（对齐 Android currentXxx = xxx）
    _currentStartPoint = startPoint;
    _currentEndPoint = endPoint;
    _currentStartName = startName;
    _currentEndName = endName;
    _currentNaviType = naviStartType;

    switch (naviStartType) {
      case NaviStartType.drive:
        await _startDriveRoutePlan();
        break;
      case NaviStartType.bike:
        await _startBikeRoutePlan();
        break;
      case NaviStartType.walk:
        await _startWalkRoutePlan();
        break;
    }
  }

  /// 启动驾车路线规划 - 对齐 Android startDriveRoutePlan
  Future<void> _startDriveRoutePlan() async {
    try {
      debugPrint('$_tag: 开始驾车路线规划');

      // 对齐 Android: 检查百度导航管理器是否初始化
      // 鸿蒙端差异：BaiduNaviManagerFactory / BaiduNaviManager 鸿蒙端可用性未验证
      // TODO(HarmonyOS): 鸿蒙端导航 SDK 可用后，在此初始化 BaiduNaviManager
      // 暂时直接调用 performDriveRoutePlan，由其内部兜底
      await _performDriveRoutePlan();
    } catch (e, stackTrace) {
      debugPrint('$_tag: 驾车路线规划失败: $e\n$stackTrace');
    }
  }

  /// 执行驾车路线规划 - 对齐 Android performDriveRoutePlan
  Future<void> _performDriveRoutePlan() async {
    try {
      final startPoint = _currentStartPoint;
      final endPoint = _currentEndPoint;
      if (startPoint == null || endPoint == null) {
        return;
      }

      debugPrint('$_tag: 执行驾车路线规划');
      debugPrint('$_tag: 起点坐标: 纬度=${startPoint.latitude}, 经度=${startPoint.longitude}');
      debugPrint('$_tag: 终点坐标: 纬度=${endPoint.latitude}, 经度=${endPoint.longitude}');

      // 对齐 Android: 构建起终点参数 BNRoutePlanNode
      // 鸿蒙端差异：鸿蒙端导航 SDK 可用性未验证，使用 try-catch 兜底
      // TODO(HarmonyOS): 鸿蒙端导航 SDK 可用后，替换以下 stub 为真实路线规划调用
      try {
        // 模拟 Android: BaiduNaviManagerFactory.getRoutePlanManager().routePlan(...)
        // 由于鸿蒙端 SDK 不可用，直接进入"规划成功"流程，触发回调让调用方决定如何跳转
        debugPrint('$_tag: 鸿蒙端百度导航 SDK 未验证，跳过实际驾车路线规划请求');
        _onDriveRoutePlanSuccess();
      } catch (e) {
        // 对齐 Android: catch (e: Exception) { Log.e(...) }
        debugPrint('$_tag: 驾车路线规划请求异常: $e');
      }
    } catch (e, stackTrace) {
      debugPrint('$_tag: 执行驾车路线规划异常: $e\n$stackTrace');
    }
  }

  /// 驾车路线规划成功处理 - 对齐 Android onDriveRoutePlanSuccess
  void _onDriveRoutePlanSuccess() {
    final startPoint = _currentStartPoint;
    final endPoint = _currentEndPoint;
    final startName = _currentStartName ?? '';
    final endName = _currentEndName ?? '';
    final naviType = _currentNaviType;
    if (startPoint == null || endPoint == null || naviType == null) {
      return;
    }

    debugPrint('$_tag: 驾车路线规划成功，触发 onNaviReady 回调');

    // 对齐 Android: MapNaviActivity.Companion.startAfterPlan(...)
    // 鸿蒙端差异：通过回调通知调用方跳转，由调用方使用 go_router 完成实际跳转
    final callback = onNaviReady;
    if (callback != null) {
      callback(
        startPoint: startPoint,
        endPoint: endPoint,
        startName: startName,
        endName: endName,
        naviStartType: naviType,
      );
    } else {
      debugPrint('$_tag: onNaviReady 回调未设置，无法跳转导航页面');
    }

    // 清理当前任务信息（对齐 Android clearCurrentTask）
    _clearCurrentTask();
  }

  /// 启动骑行路线规划 - 对齐 Android startBikeRoutePlan
  Future<void> _startBikeRoutePlan() async {
    try {
      debugPrint('$_tag: 开始骑行路线规划');

      // 对齐 Android: 如果步行导航引擎已初始化，先取消
      // 鸿蒙端差异：导航 SDK 可用性未验证，使用 try-catch 兜底
      // TODO(HarmonyOS): 鸿蒙端骑行导航 SDK 可用后，实现 BikeNavigateHelper 初始化与路线规划
      try {
        // 模拟 Android: BikeNavigateHelper.getInstance().initNaviEngine(...)
        debugPrint('$_tag: 鸿蒙端骑行导航 SDK 未验证，跳过引擎初始化');
        // 模拟 Android: engineInitSuccess -> performBikeRoutePlan
        await _performBikeRoutePlan();
      } catch (e) {
        // 对齐 Android: engineInitFail -> bikeNaviHelper?.unInitNaviEngine()
        debugPrint('$_tag: 骑行导航引擎初始化失败: $e');
      }
    } catch (e, stackTrace) {
      debugPrint('$_tag: 骑行路线规划失败: $e\n$stackTrace');
    }
  }

  /// 执行骑行路线规划 - 对齐 Android performBikeRoutePlan
  Future<void> _performBikeRoutePlan() async {
    try {
      final startPoint = _currentStartPoint;
      final endPoint = _currentEndPoint;
      if (startPoint == null || endPoint == null) {
        return;
      }

      debugPrint('$_tag: 执行骑行路线规划');

      // 对齐 Android: 构建 BikeRouteNodeInfo + BikeNaviLaunchParam
      // 鸿蒙端差异：BikeNavigateHelper.routePlanWithRouteNode 鸿蒙端可用性未验证
      // TODO(HarmonyOS): 鸿蒙端骑行导航 SDK 可用后，实现真实路线规划
      try {
        // 模拟 Android: bikeNaviHelper?.routePlanWithRouteNode(launchParam, ...)
        debugPrint('$_tag: 鸿蒙端骑行路线规划 SDK 未验证，直接触发成功回调');
        _onBikeRoutePlanSuccess();
      } catch (e) {
        // 对齐 Android: onRoutePlanFail
        debugPrint('$_tag: 骑行路线规划失败: $e');
      }
    } catch (e, stackTrace) {
      debugPrint('$_tag: 执行骑行路线规划异常: $e\n$stackTrace');
    }
  }

  /// 骑行路线规划成功处理 - 对齐 Android onBikeRoutePlanSuccess
  void _onBikeRoutePlanSuccess() {
    final startPoint = _currentStartPoint;
    final endPoint = _currentEndPoint;
    final startName = _currentStartName ?? '';
    final endName = _currentEndName ?? '';
    final naviType = _currentNaviType;
    if (startPoint == null || endPoint == null || naviType == null) {
      return;
    }

    debugPrint('$_tag: 骑行路线规划成功，触发 onNaviReady 回调');

    // 对齐 Android: MapNaviActivity.Companion.startAfterPlan(..., NaviStartType.Bike)
    final callback = onNaviReady;
    if (callback != null) {
      callback(
        startPoint: startPoint,
        endPoint: endPoint,
        startName: startName,
        endName: endName,
        naviStartType: naviType,
      );
    } else {
      debugPrint('$_tag: onNaviReady 回调未设置，无法跳转导航页面');
    }

    _clearCurrentTask();
  }

  /// 启动步行路线规划 - 对齐 Android startWalkRoutePlan
  Future<void> _startWalkRoutePlan() async {
    try {
      debugPrint('$_tag: 开始步行路线规划');

      // 对齐 Android: WalkNavigateHelper.getInstance().initNaviEngine(...)
      // 鸿蒙端差异：WalkNavigateHelper 鸿蒙端可用性未验证
      // TODO(HarmonyOS): 鸿蒙端步行导航 SDK 可用后，实现 WalkNavigateHelper 初始化与路线规划
      try {
        debugPrint('$_tag: 鸿蒙端步行导航 SDK 未验证，跳过引擎初始化');
        // 模拟 Android: engineInitSuccess -> performWalkRoutePlan
        await _performWalkRoutePlan();
      } catch (e) {
        // 对齐 Android: engineInitFail
        debugPrint('$_tag: 步行导航引擎初始化失败: $e');
      }
    } catch (e, stackTrace) {
      debugPrint('$_tag: 步行路线规划失败: $e\n$stackTrace');
    }
  }

  /// 执行步行路线规划 - 对齐 Android performWalkRoutePlan
  Future<void> _performWalkRoutePlan() async {
    try {
      final startPoint = _currentStartPoint;
      final endPoint = _currentEndPoint;
      if (startPoint == null || endPoint == null) {
        return;
      }

      debugPrint('$_tag: 执行步行路线规划');

      // 对齐 Android: 构建 WalkRouteNodeInfo + WalkNaviLaunchParam
      // 鸿蒙端差异：WalkNavigateHelper.routePlanWithRouteNode 鸿蒙端可用性未验证
      // TODO(HarmonyOS): 鸿蒙端步行导航 SDK 可用后，实现真实路线规划
      try {
        // 模拟 Android: walkNaviHelper?.routePlanWithRouteNode(launchParam, ...)
        debugPrint('$_tag: 鸿蒙端步行路线规划 SDK 未验证，直接触发成功回调');
        _onWalkRoutePlanSuccess();
      } catch (e) {
        // 对齐 Android: onRoutePlanFail
        debugPrint('$_tag: 步行路线规划失败: $e');
      }
    } catch (e, stackTrace) {
      debugPrint('$_tag: 执行步行路线规划异常: $e\n$stackTrace');
    }
  }

  /// 步行路线规划成功处理 - 对齐 Android onWalkRoutePlanSuccess
  void _onWalkRoutePlanSuccess() {
    final startPoint = _currentStartPoint;
    final endPoint = _currentEndPoint;
    final startName = _currentStartName ?? '';
    final endName = _currentEndName ?? '';
    final naviType = _currentNaviType;
    if (startPoint == null || endPoint == null || naviType == null) {
      return;
    }

    debugPrint('$_tag: 步行路线规划成功，触发 onNaviReady 回调');

    // 对齐 Android: intent.setClass(context, WalkNaviActivity::class.java); context.startActivity(intent)
    // 鸿蒙端差异：通过回调通知调用方跳转 WalkNaviActivity 对应的 Flutter 页面
    // 注：Android 原代码在此处注释掉了 MapNaviActivity.startAfterPlan 调用，直接跳转 WalkNaviActivity
    // 鸿蒙端统一通过 onNaviReady 回调，由调用方根据 naviStartType 决定跳转目标
    final callback = onNaviReady;
    if (callback != null) {
      callback(
        startPoint: startPoint,
        endPoint: endPoint,
        startName: startName,
        endName: endName,
        naviStartType: naviType,
      );
    } else {
      debugPrint('$_tag: onNaviReady 回调未设置，无法跳转导航页面');
    }

    _clearCurrentTask();
  }

  /// 清理当前任务信息 - 对齐 Android clearCurrentTask
  void _clearCurrentTask() {
    _currentStartPoint = null;
    _currentEndPoint = null;
    _currentStartName = null;
    _currentEndName = null;
    _currentNaviType = null;
  }

  /// 清理资源 - 对齐 Android cleanup
  void cleanup() {
    try {
      // 对齐 Android: bikeNaviHelper?.unInitNaviEngine(); walkNaviHelper?.unInitNaviEngine()
      // 鸿蒙端差异：导航 SDK 可用性未验证，无资源需清理
      _clearCurrentTask();
      debugPrint('$_tag: NaviPlanManager 资源清理完成');
    } catch (e, stackTrace) {
      debugPrint('$_tag: 清理资源异常: $e\n$stackTrace');
    }
  }
}
