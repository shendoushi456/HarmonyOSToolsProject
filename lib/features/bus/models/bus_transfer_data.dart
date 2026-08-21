// 公交换乘数据模型 - 对齐 Android bus/model/BusTransferData.kt
// 含 TransferType、TransferStep、BusTransferRoute、BusTransferUiState
// 含 BMFTransitRouteLine.toBusTransferRoute 扩展（替代 Android TransitRouteLine.toBusTransferRoute 扩展函数）
import 'package:flutter/foundation.dart';
import 'package:flutter_baidu_mapapi_search/flutter_baidu_mapapi_search.dart';

/// 换乘步骤类型 - 对齐 Android TransferType
enum TransferType {
  /// 出发
  start,
  /// 步行
  walk,
  /// 公交
  bus,
  /// 地铁
  subway,
  /// 出租车
  taxi,
  /// 到达终点
  end,
}

/// 换乘路线步骤数据类 - 对齐 Android TransferStep
@immutable
class TransferStep {
  const TransferStep({
    required this.type,
    required this.description,
    this.stations = '',
    this.distance = '',
    this.duration = '',
    this.expandable = false,
    this.stationsList = const [],
  });

  /// 步骤类型
  final TransferType type;

  /// 描述
  final String description;

  /// 站数（如 "5站"）
  final String stations;

  /// 距离（如 "100米"）
  final String distance;

  /// 耗时（如 "5分钟"）
  final String duration;

  /// 是否可展开
  final bool expandable;

  /// 站点名称列表
  final List<String> stationsList;

  /// 复制并修改部分字段（对齐 Kotlin data class copy）
  TransferStep copyWith({
    TransferType? type,
    String? description,
    String? stations,
    String? distance,
    String? duration,
    bool? expandable,
    List<String>? stationsList,
  }) {
    return TransferStep(
      type: type ?? this.type,
      description: description ?? this.description,
      stations: stations ?? this.stations,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      expandable: expandable ?? this.expandable,
      stationsList: stationsList ?? this.stationsList,
    );
  }

  @override
  String toString() =>
      'TransferStep(type=$type, description=$description, stations=$stations, distance=$distance, duration=$duration)';
}

/// 公交换乘路线详情数据类 - 对齐 Android BusTransferRoute
@immutable
class BusTransferRoute {
  const BusTransferRoute({
    this.routeId = '',
    this.totalDuration = '',
    this.totalDistance = '',
    this.walkingDistance = '',
    this.taxiCost = '',
    this.startPoint = '',
    this.endPoint = '',
    this.transferSteps = const [],
  });

  /// 路线唯一标识
  final String routeId;

  /// 总耗时
  final String totalDuration;

  /// 总距离
  final String totalDistance;

  /// 步行距离
  final String walkingDistance;

  /// 出租车费用
  final String taxiCost;

  /// 起点名称
  final String startPoint;

  /// 终点名称
  final String endPoint;

  /// 换乘步骤列表
  final List<TransferStep> transferSteps;

  /// 复制并修改部分字段（对齐 Kotlin data class copy）
  BusTransferRoute copyWith({
    String? routeId,
    String? totalDuration,
    String? totalDistance,
    String? walkingDistance,
    String? taxiCost,
    String? startPoint,
    String? endPoint,
    List<TransferStep>? transferSteps,
  }) {
    return BusTransferRoute(
      routeId: routeId ?? this.routeId,
      totalDuration: totalDuration ?? this.totalDuration,
      totalDistance: totalDistance ?? this.totalDistance,
      walkingDistance: walkingDistance ?? this.walkingDistance,
      taxiCost: taxiCost ?? this.taxiCost,
      startPoint: startPoint ?? this.startPoint,
      endPoint: endPoint ?? this.endPoint,
      transferSteps: transferSteps ?? this.transferSteps,
    );
  }

  @override
  String toString() =>
      'BusTransferRoute(routeId=$routeId, totalDuration=$totalDuration, totalDistance=$totalDistance, startPoint=$startPoint, endPoint=$endPoint, steps=${transferSteps.length})';
}

/// 换乘路线UI状态数据类 - 对齐 Android BusTransferUiState
@immutable
class BusTransferUiState {
  const BusTransferUiState({
    this.isLoading = false,
    this.transferRoute,
    this.error,
  });

  /// 是否正在加载
  final bool isLoading;

  /// 换乘路线（对齐 Android transferRoute: BusTransferRoute?）
  final BusTransferRoute? transferRoute;

  /// 错误信息（null 表示无错误）
  final String? error;

  /// 复制并修改部分字段（对齐 Kotlin data class copy）
  BusTransferUiState copyWith({
    bool? isLoading,
    BusTransferRoute? transferRoute,
    String? error,
    bool clearError = false,
    bool clearRoute = false,
  }) {
    return BusTransferUiState(
      isLoading: isLoading ?? this.isLoading,
      transferRoute: clearRoute ? null : (transferRoute ?? this.transferRoute),
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  String toString() =>
      'BusTransferUiState(isLoading=$isLoading, transferRoute=$transferRoute, error=$error)';
}

/// 扩展方法：将百度SDK的 BMFTransitRouteLine 转换为我们的数据模型
/// 对齐 Android TransitRouteLine.toBusTransferRoute(startPoint, endPoint) 扩展函数
/// 鸿蒙端差异：Android 用 TransitRouteLine + TransitStep；鸿蒙端用 BMFTransitRouteLine + BMFTransitStep
extension BMFTransitRouteLineExt on BMFTransitRouteLine {
  /// 转换为 BusTransferRoute
  ///
  /// [startPoint] 起点名称
  /// [endPoint] 终点名称
  BusTransferRoute toBusTransferRoute({
    required String startPoint,
    required String endPoint,
  }) {
    final transferSteps = <TransferStep>[];

    // 添加起始点
    transferSteps.add(const TransferStep(
      type: TransferType.start,
      description: '出发',
      stations: '',
      distance: '',
    ));

    // 处理每个换乘步骤
    // 对齐 Android this.allStep?.forEach；鸿蒙端 BMFTransitRouteLine 用 steps 字段
    final steps = this.steps;
    if (steps != null) {
      for (final transitStep in steps) {
        final stepType = transitStep.stepType;
        // 路段距离/耗时：对齐 Android transitStep.distance / transitStep.duration
        // BMFTransitStep.distance 单位：米；duration 单位：秒
        final stepDistance = transitStep.distance ?? 0;
        final stepDuration = transitStep.duration ?? 0;

        // 对齐 Android TransitRouteStepType.WAKLING / BUSLINE / SUBWAY
        // 鸿蒙端枚举：BMFTransitStepType.WAKLING / BUSLINE / SUBWAY
        if (stepType == BMFTransitStepType.WAKLING) {
          // 步行
          if (stepDistance > 0) {
            transferSteps.add(TransferStep(
              type: TransferType.walk,
              description: '步行$stepDistance米',
              distance: '$stepDistance米',
              // 对齐 Android ${(transitStep.duration / 60)}分钟（duration 单位秒，除以 60 转分钟）
              duration: '${(stepDuration / 60).floor()}分钟',
            ));
          }
        } else if (stepType == BMFTransitStepType.BUSLINE) {
          // 公交
          final vehicleInfo = transitStep.vehicleInfo;
          // 对齐 Android vehicleInfo?.passStationNum ?: 0
          final stationNum = vehicleInfo?.passStationNum ?? 0;

          transferSteps.add(TransferStep(
            type: TransferType.bus,
            description: vehicleInfo?.title ?? '公交',
            stations: '$stationNum站',
            expandable: true,
            // 对齐 Android：百度SDK不直接提供站点列表
            stationsList: const [],
          ));
        } else if (stepType == BMFTransitStepType.SUBWAY) {
          // 地铁
          final vehicleInfo = transitStep.vehicleInfo;
          final stationNum = vehicleInfo?.passStationNum ?? 0;

          transferSteps.add(TransferStep(
            type: TransferType.subway,
            description: vehicleInfo?.title ?? '地铁',
            stations: '$stationNum站',
            expandable: true,
            stationsList: const [],
          ));
        }
        // 其他类型（如出租车等）对齐 Android else 分支：忽略
      }
    }

    // 添加终点
    transferSteps.add(const TransferStep(
      type: TransferType.end,
      description: '到达终点',
      stations: '',
      distance: '',
    ));

    // 对齐 Android：routeId = this.hashCode().toString()
    // 鸿蒙端：Dart 的 hashCode 是运行时值，行为对齐
    // 总耗时：对齐 Android ${(this.duration / 60)}分钟
    // 注：Android this.duration 单位秒，鸿蒙端 BMFTransitRouteLine.duration 类型为 BMFTime?
    // BMFTime 包含 days/hours/minutes/seconds 字段，统一折算为秒
    final time = duration;
    final totalSeconds = ((time?.dates ?? 0) * 86400) +
        ((time?.hours ?? 0) * 3600) +
        ((time?.minutes ?? 0) * 60) +
        (time?.seconds ?? 0);
    // 总距离：对齐 Android String.format("%.1fkm", this.distance / 1000f)
    final distanceMeters = distance ?? 0;
    final distanceKm = (distanceMeters / 1000).toStringAsFixed(1);

    return BusTransferRoute(
      routeId: hashCode.toString(),
      totalDuration: '${(totalSeconds / 60).floor()}分钟',
      totalDistance: '${distanceKm}km',
      // 对齐 Android "步行距离暂无"
      walkingDistance: '步行距离暂无',
      taxiCost: '',
      startPoint: startPoint,
      endPoint: endPoint,
      transferSteps: transferSteps,
    );
  }
}
