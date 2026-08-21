// 公交换乘路线数据仓库 - 对齐 Android bus/repository/BusTransferRepository.kt
//
// 鸿蒙端差异：
// - Android: RoutePlanSearch.newInstance() + OnGetRoutePlanResultListener 单监听器
// - 鸿蒙端: BMFTransitRouteSearch + onGetTransitRouteSearchResult 回调
// - Android: SearchResult.ERRORNO 判断错误
// - 鸿蒙端: BMFSearchErrorCode 枚举判断错误
// - Android: PlanNode.withLocation(LatLng) → TransitRoutePlanOption().from().to().city().policy()
// - 鸿蒙端: BMFPlanNode(pt: BMFCoordinate) → BMFTransitRoutePlanOption(from:, to:, city:, transitPolicy:)
// - Android: 回调同步 → 鸿蒙端用 Completer 包装为 Future
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';
import 'package:flutter_baidu_mapapi_search/flutter_baidu_mapapi_search.dart';

import '../models/bus_transfer_data.dart';

/// 公交换乘路线数据仓库 - 对齐 Android BusTransferRepository
class BusTransferRepository {
  BusTransferRepository();

  /// 规划公交换乘路线 - 对齐 Android planBusTransferRoute
  ///
  /// [startPoint] 起点坐标
  /// [endPoint] 终点坐标
  /// [startName] 起点名称
  /// [endName] 终点名称
  /// [city] 城市，默认"北京"
  Future<Result<List<BusTransferRoute>>> planBusTransferRoute({
    required BMFCoordinate startPoint,
    required BMFCoordinate endPoint,
    String startName = '起点',
    String endName = '终点',
    String city = '北京',
  }) async {
    return _planTransitRoute(
      startPoint: startPoint,
      endPoint: endPoint,
      startName: startName,
      endName: endName,
      city: city,
    );
  }

  /// 根据坐标规划公交换乘路线 - 对齐 Android planBusTransferRouteByCoordinates
  Future<Result<List<BusTransferRoute>>> planBusTransferRouteByCoordinates({
    required BMFCoordinate startLatLng,
    required BMFCoordinate endLatLng,
    String startAddress = '出发地',
    String endAddress = '目的地',
    String city = '北京',
  }) async {
    return _planTransitRoute(
      startPoint: startLatLng,
      endPoint: endLatLng,
      startName: startAddress,
      endName: endAddress,
      city: city,
    );
  }

  /// 根据地址名称规划公交换乘路线 - 对齐 Android planBusTransferRouteByAddress
  ///
  /// 注：Android 原代码使用临时坐标 LatLng(39.908692, 116.397477) 简化处理。
  /// 鸿蒙端保持相同行为以对齐原项目（迁移保真原则）。
  Future<Result<List<BusTransferRoute>>> planBusTransferRouteByAddress({
    required String startAddress,
    required String endAddress,
    String city = '北京',
  }) async {
    // 对齐 Android: 使用地址搜索需要先转换为坐标，这里简化处理使用临时坐标
    // 注：原项目使用北京天安门坐标作为临时占位
    // 鸿蒙端差异：BMFCoordinate 不是 const 构造函数，故不能用 const 修饰
    final tempCoord = BMFCoordinate(39.908692, 116.397477);
    return _planTransitRoute(
      startPoint: tempCoord,
      endPoint: tempCoord,
      startName: startAddress,
      endName: endAddress,
      city: city,
    );
  }

  /// 处理已有的公交路线数据 - 对齐 Android processBusRouteData
  ///
  /// [transitRouteLines] 公交路径列表
  /// [transitRouteResult] 公交路线结果（未使用，对齐原项目签名）
  Result<List<BusTransferRoute>> processBusRouteData(
    List<BMFTransitRouteLine> transitRouteLines, {
    BMFTransitRouteResult? transitRouteResult,
  }) {
    try {
      if (transitRouteLines.isNotEmpty) {
        final transferRoutes = transitRouteLines.map((transitRouteLine) {
          // 对齐 Android: 从transitRouteResult中提取起终点信息
          // 百度SDK的TransitRouteResult不直接提供起终点信息，使用默认值
          const startPoint = '起点';
          const endPoint = '终点';

          // 对齐 Android: transitRouteLine.toBusTransferRoute(startPoint, endPoint)
          // 鸿蒙端: 使用 BMFTransitRouteLineExt 扩展方法
          final route = transitRouteLine.toBusTransferRoute(
            startPoint: startPoint,
            endPoint: endPoint,
          );

          // 对齐 Android 注释: 百度地图不直接提供出租车费用信息，可以根据距离估算
          return route;
        }).toList();
        return Result.success(transferRoutes);
      } else {
        return Result.failure(Exception('公交路径列表为空'));
      }
    } catch (e) {
      return Result.failure(e is Exception ? e : Exception('$e'));
    }
  }

  /// 内部方法：实际执行公交换乘搜索
  /// 对齐 Android 三个 planBusTransferRoute* 方法的公共逻辑
  Future<Result<List<BusTransferRoute>>> _planTransitRoute({
    required BMFCoordinate startPoint,
    required BMFCoordinate endPoint,
    required String startName,
    required String endName,
    required String city,
  }) async {
    final completer = Completer<Result<List<BusTransferRoute>>>();

    try {
      final routePlanSearch = BMFTransitRouteSearch();

      // 对齐 Android: routePlanSearch.setOnGetRoutePlanResultListener + onGetTransitRouteResult
      routePlanSearch.onGetTransitRouteSearchResult(
        callback: (result, errorCode) {
          if (errorCode == BMFSearchErrorCode.NO_ERROR) {
            final routes = result.routes;
            if (routes != null && routes.isNotEmpty) {
              // 对齐 Android: result.routeLines.map { transitRouteLine.toBusTransferRoute(startName, endName) }
              final transferRoutes = routes
                  .map((line) => line.toBusTransferRoute(
                        startPoint: startName,
                        endPoint: endName,
                      ))
                  .toList();
              if (!completer.isCompleted) {
                completer.complete(Result.success(transferRoutes));
              }
            } else {
              if (!completer.isCompleted) {
                completer.complete(Result.failure(Exception('未找到换乘路线')));
              }
            }
          } else {
            // 对齐 Android: when (result?.error) { NETWORK_ERROR/KEY_ERROR/PERMISSION_UNFINISHED/else }
            final errorMsg = _transitErrorMessage(errorCode);
            if (!completer.isCompleted) {
              completer.complete(Result.failure(Exception(errorMsg)));
            }
          }
        },
      );

      // 对齐 Android: val stNode = PlanNode.withLocation(startPoint); val enNode = PlanNode.withLocation(endPoint)
      // 鸿蒙端: BMFPlanNode(pt: BMFCoordinate)
      final stNode = BMFPlanNode(pt: startPoint);
      final enNode = BMFPlanNode(pt: endPoint);

      // 对齐 Android: TransitRoutePlanOption().from(stNode).to(enNode).city(city).policy(TransitPolicy.EBUS_TIME_FIRST)
      // 鸿蒙端: BMFTransitRoutePlanOption(from:, to:, city:, transitPolicy:)
      // 注：Android 用 EBUS_TIME_FIRST，鸿蒙端对应 BMFTransitPolicy.TIME_FIRST（枚举名不同）
      final option = BMFTransitRoutePlanOption(
        from: stNode,
        to: enNode,
        city: city,
        transitPolicy: BMFTransitPolicy.TIME_FIRST,
      );

      // 对齐 Android: routePlanSearch.transitSearch(option)
      final ok = await routePlanSearch.transitRouteSearch(option);
      if (!ok) {
        if (!completer.isCompleted) {
          completer.complete(Result.failure(Exception('路线规划请求失败')));
        }
      }
    } catch (e, stackTrace) {
      debugPrint('BusTransferRepository: 公交换乘规划异常: $e\n$stackTrace');
      if (!completer.isCompleted) {
        completer.complete(Result.failure(e is Exception ? e : Exception('$e')));
      }
    }

    return completer.future;
  }

  /// 错误码转消息 - 对齐 Android when (result?.error) { ... }
  String _transitErrorMessage(BMFSearchErrorCode errorCode) {
    switch (errorCode) {
      case BMFSearchErrorCode.NETWOKR_ERROR:
        return '网络异常，请检查网络连接';
      case BMFSearchErrorCode.KEY_ERROR:
        return 'Key验证失败';
      case BMFSearchErrorCode.PERMISSION_UNFINISHED:
        return '权限未开启';
      default:
        return '路线规划失败';
    }
  }
}

/// 简单的 Result 类型 - 对齐 Kotlin Result<T>
/// 注：与 bus_route_repository.dart 中的 Result 重复，后续可考虑抽到公共模块
class Result<T> {
  Result._({this.value, this.error});

  factory Result.success(T value) => Result._(value: value);

  factory Result.failure(Exception error) => Result._(error: error);

  final T? value;
  final Exception? error;

  bool get isSuccess => error == null;

  bool get isFailure => error != null;

  T getOrNull() => value as T;

  Exception? exceptionOrNull() => error;
}
