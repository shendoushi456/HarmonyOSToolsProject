// 百度地图扩展函数 - 对齐 Android bus/model/BaiduExtensions.kt
// 含 BMFBusLineResult.toBusRouteDetailBaidu 扩展、Location 数据类、BMFCoordinate.toLocation 扩展
// 鸿蒙端差异：
// - Android BusLineResult → 鸿蒙端 BMFBusLineResult
// - Android LatLng → 鸿蒙端 BMFCoordinate
// - Android BusLineResult.stations (List<BusStationItem>) → 鸿蒙端 BMFBusLineResult.busStations (List<BMFBusStation>)
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';
import 'package:flutter_baidu_mapapi_search/flutter_baidu_mapapi_search.dart';

import 'bus_route_data.dart';

/// 简单位置信息数据类 - 对齐 Android BaiduExtensions.kt 中的 Location
class Location {
  const Location({
    required this.latitude,
    required this.longitude,
  });

  /// 纬度
  final double latitude;

  /// 经度
  final double longitude;

  @override
  String toString() => 'Location(lat=$latitude, lng=$longitude)';
}

/// 扩展方法集合 - 对齐 Android BaiduExtensions.kt 中的扩展函数
extension BaiduMapExtensions on BMFCoordinate {
  /// 百度 BMFCoordinate 转换为简单的位置信息
  /// 对齐 Android LatLng.toLocation(): Location
  Location toLocation() {
    return Location(latitude: latitude, longitude: longitude);
  }
}

/// BMFBusLineResult 扩展 - 对齐 Android BusLineResult.toBusRouteDetailBaidu(): BusRouteDetail?
extension BMFBusLineResultExt on BMFBusLineResult {
  /// 将百度 SDK 的 BMFBusLineResult 转换为 BusRouteDetail
  /// 对齐 Android BusLineResult.toBusRouteDetailBaidu()
  ///
  /// 鸿蒙端差异：
  /// - Android: busLineName / startTime / endTime / stations / uid 字段直接可空访问
  /// - 鸿蒙端: 字段均为可空，访问时需 null 安全处理
  /// - Android BusLineResult.stations 元素类型为 BusStationItem（含 uid/title/location）
  /// - 鸿蒙端 BMFBusLineResult.busStations 元素类型为 BMFBusStation（继承 BMFRouteNode，含 uid/title/location）
  BusRouteDetail? toBusRouteDetailBaidu() {
    try {
      final busLineName = this.busLineName;
      if (busLineName == null || busLineName.isEmpty) {
        // 对齐 Android busLineName 为空时返回 null
        return null;
      }

      // 首末班车时间：对齐 Android startTime?.toString() ?: "06:00"
      final startTime = (this.startTime != null && this.startTime!.isNotEmpty)
          ? this.startTime!
          : '06:00';
      final endTime = (this.endTime != null && this.endTime!.isNotEmpty)
          ? this.endTime!
          : '23:00';

      // 提取站点信息
      // 对齐 Android val stationList = this.stations ?: emptyList()
      final stationList = busStations ?? const <BMFBusStation>[];
      final stations = <BusStation>[];

      // 对齐 Android stationList.forEachIndexed
      for (final station in stationList) {
        // 对齐 Android station.uid ?: ""
        // 鸿蒙端 BMFBusStation 继承 BMFRouteNode，含 uid/title/location 字段
        final location = station.location;
        stations.add(BusStation(
          id: station.uid ?? '',
          name: station.title ?? '未知站点',
          latitude: location?.latitude ?? 0.0,
          longitude: location?.longitude ?? 0.0,
          address: '',
        ));
      }

      return BusRouteDetail(
        // 对齐 Android this.uid ?: ""
        routeId: uid ?? '',
        routeName: busLineName,
        // 对齐 Android stations.firstOrNull()?.name ?: ""
        startStation: stations.isNotEmpty ? stations.first.name : '',
        endStation: stations.isNotEmpty ? stations.last.name : '',
        firstTime: startTime,
        lastTime: endTime,
        // 对齐 Android "2元" - 百度SDK不直接提供票价信息
        price: '2元',
        // 对齐 Android "未知公司" - 百度SDK不直接提供公司信息
        company: '未知公司',
        // 对齐 Android "约${stations.size * 0.5}公里" - 估算距离
        distance: '约${stations.length * 0.5}公里',
        totalStations: stations.length,
        stations: stations,
      );
    } catch (e) {
      // 对齐 Android catch (e: Exception) { null }
      return null;
    }
  }
}
