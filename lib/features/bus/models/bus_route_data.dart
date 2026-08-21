// 公交路线数据模型 - 对齐 Android bus/model/BusRouteData.kt
// 含 BusStation、BusRouteDetail、BusRouteUiState 数据类
import 'package:flutter/foundation.dart';

/// 公交站点数据类 - 对齐 Android BusStation
@immutable
class BusStation {
  const BusStation({
    this.id = '',
    this.name = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.address = '',
  });

  /// 站点唯一标识
  final String id;

  /// 站点名称
  final String name;

  /// 纬度
  final double latitude;

  /// 经度
  final double longitude;

  /// 地址描述
  final String address;

  /// 复制并修改部分字段（对齐 Kotlin data class copy）
  BusStation copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    String? address,
  }) {
    return BusStation(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
    );
  }

  @override
  String toString() =>
      'BusStation(id=$id, name=$name, lat=$latitude, lng=$longitude, address=$address)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BusStation &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          address == other.address;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ latitude.hashCode ^ longitude.hashCode ^ address.hashCode;
}

/// 公交路线详情数据类 - 对齐 Android BusRouteDetail
@immutable
class BusRouteDetail {
  const BusRouteDetail({
    this.routeName = '',
    this.routeId = '',
    this.startStation = '',
    this.endStation = '',
    this.firstTime = '',
    this.lastTime = '',
    this.price = '',
    this.company = '',
    this.distance = '',
    this.totalStations = 0,
    this.stations = const [],
  });

  /// 路线名称
  final String routeName;

  /// 路线唯一标识
  final String routeId;

  /// 起点站
  final String startStation;

  /// 终点站
  final String endStation;

  /// 首班车时间
  final String firstTime;

  /// 末班车时间
  final String lastTime;

  /// 票价信息
  final String price;

  /// 所属公司
  final String company;

  /// 全程距离
  final String distance;

  /// 总站点数
  final int totalStations;

  /// 站点列表
  final List<BusStation> stations;

  /// 复制并修改部分字段（对齐 Kotlin data class copy）
  BusRouteDetail copyWith({
    String? routeName,
    String? routeId,
    String? startStation,
    String? endStation,
    String? firstTime,
    String? lastTime,
    String? price,
    String? company,
    String? distance,
    int? totalStations,
    List<BusStation>? stations,
  }) {
    return BusRouteDetail(
      routeName: routeName ?? this.routeName,
      routeId: routeId ?? this.routeId,
      startStation: startStation ?? this.startStation,
      endStation: endStation ?? this.endStation,
      firstTime: firstTime ?? this.firstTime,
      lastTime: lastTime ?? this.lastTime,
      price: price ?? this.price,
      company: company ?? this.company,
      distance: distance ?? this.distance,
      totalStations: totalStations ?? this.totalStations,
      stations: stations ?? this.stations,
    );
  }

  @override
  String toString() =>
      'BusRouteDetail(routeName=$routeName, routeId=$routeId, start=$startStation, end=$endStation, totalStations=$totalStations)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BusRouteDetail &&
          runtimeType == other.runtimeType &&
          routeName == other.routeName &&
          routeId == other.routeId &&
          startStation == other.startStation &&
          endStation == other.endStation &&
          firstTime == other.firstTime &&
          lastTime == other.lastTime &&
          price == other.price &&
          company == other.company &&
          distance == other.distance &&
          totalStations == other.totalStations &&
          listEquals(stations, other.stations);

  @override
  int get hashCode =>
      routeName.hashCode ^
      routeId.hashCode ^
      startStation.hashCode ^
      endStation.hashCode ^
      firstTime.hashCode ^
      lastTime.hashCode ^
      price.hashCode ^
      company.hashCode ^
      distance.hashCode ^
      totalStations.hashCode ^
      stations.hashCode;
}

/// UI状态数据类 - 对齐 Android BusRouteUiState
@immutable
class BusRouteUiState {
  const BusRouteUiState({
    this.isLoading = false,
    this.routeDetail,
    this.error,
    this.isReversed = false,
  });

  /// 是否正在加载
  final bool isLoading;

  /// 路线详情（null 表示无数据）
  final BusRouteDetail? routeDetail;

  /// 错误信息（null 表示无错误）
  final String? error;

  /// 是否为反向路线
  final bool isReversed;

  /// 复制并修改部分字段（对齐 Kotlin data class copy）
  BusRouteUiState copyWith({
    bool? isLoading,
    BusRouteDetail? routeDetail,
    String? error,
    bool? isReversed,
    bool clearError = false,
    bool clearRouteDetail = false,
  }) {
    return BusRouteUiState(
      isLoading: isLoading ?? this.isLoading,
      routeDetail: clearRouteDetail ? null : (routeDetail ?? this.routeDetail),
      error: clearError ? null : (error ?? this.error),
      isReversed: isReversed ?? this.isReversed,
    );
  }

  @override
  String toString() =>
      'BusRouteUiState(isLoading=$isLoading, routeDetail=$routeDetail, error=$error, isReversed=$isReversed)';
}

/// 时间格式化函数 - 对齐 Android BusRouteData.kt 中的 formatBusTime
/// 将 DateTime 对象转换为 HH:mm 格式字符串
String formatBusTime(DateTime? date) {
  if (date == null) {
    return '';
  }
  // 对齐 Kotlin SimpleDateFormat("HH:mm", Locale.getDefault())
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
