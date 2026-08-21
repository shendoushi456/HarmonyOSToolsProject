// 百度地图搜索结果数据类 - 对齐 Android bus/model/BaiduMapModels.kt
// 含 BaiduSearchResult、BaiduSearchResultData、BaiduBusLine、BaiduBusStation
// 鸿蒙端差异：Android LatLng → 鸿蒙端 BMFCoordinate
//            Android Parcelable/Serializable → Dart 不可变类（跨页面传递直接用对象引用）
import 'package:flutter/foundation.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';

/// 百度地图搜索结果数据类 - 对齐 Android BaiduSearchResult
/// 鸿蒙端差异：原 Android 实现 Parcelable + Serializable 用于 Intent 传递，
/// Flutter 无需 Parcelable，直接用对象引用传递
@immutable
class BaiduSearchResult {
  const BaiduSearchResult({
    required this.id,
    required this.name,
    required this.description,
    this.address = '',
    required this.latLng,
    this.distance = '',
    this.iconUrl = '',
  });

  /// 唯一标识
  final String id;

  /// 名称
  final String name;

  /// 描述
  final String description;

  /// 地址
  final String address;

  /// 坐标（对齐 Android latLng: LatLng；鸿蒙端用 BMFCoordinate）
  final BMFCoordinate latLng;

  /// 距离描述
  final String distance;

  /// 图标 URL
  final String iconUrl;

  /// 转换为可序列化数据类（对齐 Android toSerializableData）
  /// 鸿蒙端差异：Flutter 无需 Intent 传递，但保留此方法以兼容 Android 原项目调用链
  BaiduSearchResultData toSerializableData() {
    return BaiduSearchResultData(
      id: id,
      name: name,
      description: description,
      address: address,
      latitude: latLng.latitude,
      longitude: latLng.longitude,
      distance: distance,
      iconUrl: iconUrl,
    );
  }

  /// 复制并修改部分字段（对齐 Kotlin data class copy）
  BaiduSearchResult copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    BMFCoordinate? latLng,
    String? distance,
    String? iconUrl,
  }) {
    return BaiduSearchResult(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      latLng: latLng ?? this.latLng,
      distance: distance ?? this.distance,
      iconUrl: iconUrl ?? this.iconUrl,
    );
  }

  @override
  String toString() =>
      'BaiduSearchResult(id=$id, name=$name, latLng=$latLng, distance=$distance)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaiduSearchResult &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          address == other.address &&
          latLng == other.latLng &&
          distance == other.distance &&
          iconUrl == other.iconUrl;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      address.hashCode ^
      latLng.hashCode ^
      distance.hashCode ^
      iconUrl.hashCode;
}

/// 可序列化的搜索结果数据类 - 对齐 Android BaiduSearchResultData
/// 用于序列化场景（鸿蒙端 Flutter 无需 Intent 传递，但保留此类以对齐 Android 调用链）
@immutable
class BaiduSearchResultData {
  const BaiduSearchResultData({
    required this.id,
    required this.name,
    required this.description,
    this.address = '',
    required this.latitude,
    required this.longitude,
    this.distance = '',
    this.iconUrl = '',
  });

  /// 唯一标识
  final String id;

  /// 名称
  final String name;

  /// 描述
  final String description;

  /// 地址
  final String address;

  /// 纬度
  final double latitude;

  /// 经度
  final double longitude;

  /// 距离描述
  final String distance;

  /// 图标 URL
  final String iconUrl;

  /// 从序列化数据构造 SearchResult（对齐 Android toSearchResult）
  BaiduSearchResult toSearchResult() {
    return BaiduSearchResult(
      id: id,
      name: name,
      description: description,
      address: address,
      // 对齐 Android LatLng(latitude, longitude)，鸿蒙端用 BMFCoordinate
      latLng: BMFCoordinate(latitude, longitude),
      distance: distance,
      iconUrl: iconUrl,
    );
  }

  /// 复制并修改部分字段（对齐 Kotlin data class copy）
  BaiduSearchResultData copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    String? distance,
    String? iconUrl,
  }) {
    return BaiduSearchResultData(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distance: distance ?? this.distance,
      iconUrl: iconUrl ?? this.iconUrl,
    );
  }

  @override
  String toString() =>
      'BaiduSearchResultData(id=$id, name=$name, lat=$latitude, lng=$longitude, distance=$distance)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaiduSearchResultData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          address == other.address &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          distance == other.distance &&
          iconUrl == other.iconUrl;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      address.hashCode ^
      latitude.hashCode ^
      longitude.hashCode ^
      distance.hashCode ^
      iconUrl.hashCode;
}

/// 公交线路信息 - 对齐 Android BaiduBusLine
@immutable
class BaiduBusLine {
  const BaiduBusLine({
    required this.number,
    required this.direction,
    this.startStation = '',
    this.endStation = '',
    this.fullName = '',
    this.uid = '',
  });

  /// 线路号，如 "617路"
  final String number;

  /// 方向信息，如 "地铁生命科学园站西 → 来广营北"
  final String direction;

  /// 起始站
  final String startStation;

  /// 终点站
  final String endStation;

  /// 完整线路名，如 "617路(地铁生命科学园站西--来广营北)"
  final String fullName;

  /// 百度地图线路唯一标识
  final String uid;

  /// 复制并修改部分字段（对齐 Kotlin data class copy）
  BaiduBusLine copyWith({
    String? number,
    String? direction,
    String? startStation,
    String? endStation,
    String? fullName,
    String? uid,
  }) {
    return BaiduBusLine(
      number: number ?? this.number,
      direction: direction ?? this.direction,
      startStation: startStation ?? this.startStation,
      endStation: endStation ?? this.endStation,
      fullName: fullName ?? this.fullName,
      uid: uid ?? this.uid,
    );
  }

  @override
  String toString() =>
      'BaiduBusLine(number=$number, direction=$direction, uid=$uid)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaiduBusLine &&
          runtimeType == other.runtimeType &&
          number == other.number &&
          direction == other.direction &&
          startStation == other.startStation &&
          endStation == other.endStation &&
          fullName == other.fullName &&
          uid == other.uid;

  @override
  int get hashCode =>
      number.hashCode ^
      direction.hashCode ^
      startStation.hashCode ^
      endStation.hashCode ^
      fullName.hashCode ^
      uid.hashCode;
}

/// 公交站点信息 - 对齐 Android BaiduBusStation
@immutable
class BaiduBusStation {
  const BaiduBusStation({
    required this.id,
    required this.name,
    required this.displayName,
    required this.distance,
    this.latitude = 0.0,
    this.longitude = 0.0,
    required this.busLines,
    this.isExpanded = false,
    this.totalLineCount = 0,
  });

  /// 站点唯一标识
  final String id;

  /// 站点名称
  final String name;

  /// 用于显示的站点名称（去掉 "(公交站)" 后缀）
  final String displayName;

  /// 距离，如 "100米"
  final String distance;

  /// 纬度
  final double latitude;

  /// 经度
  final double longitude;

  /// 公交线路列表
  final List<BaiduBusLine> busLines;

  /// 是否展开显示更多线路
  final bool isExpanded;

  /// 总线路数量
  final int totalLineCount;

  /// 复制并修改部分字段（对齐 Kotlin data class copy）
  BaiduBusStation copyWith({
    String? id,
    String? name,
    String? displayName,
    String? distance,
    double? latitude,
    double? longitude,
    List<BaiduBusLine>? busLines,
    bool? isExpanded,
    int? totalLineCount,
  }) {
    return BaiduBusStation(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      distance: distance ?? this.distance,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      busLines: busLines ?? this.busLines,
      isExpanded: isExpanded ?? this.isExpanded,
      totalLineCount: totalLineCount ?? this.totalLineCount,
    );
  }

  @override
  String toString() =>
      'BaiduBusStation(id=$id, name=$name, displayName=$displayName, distance=$distance, totalLineCount=$totalLineCount)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaiduBusStation &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          displayName == other.displayName &&
          distance == other.distance &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          listEquals(busLines, other.busLines) &&
          isExpanded == other.isExpanded &&
          totalLineCount == other.totalLineCount;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      displayName.hashCode ^
      distance.hashCode ^
      latitude.hashCode ^
      longitude.hashCode ^
      busLines.hashCode ^
      isExpanded.hashCode ^
      totalLineCount.hashCode;
}
