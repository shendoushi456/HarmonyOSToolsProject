// 路线数据传递管理器 - 对齐 Android bus/utils/RouteDataManager.kt
// 用于页面间传递百度路线对象（因百度对象不可序列化，用单例传递引用）
// 鸿蒙端差异：Android 用 Parcelable，Flutter 直接用对象引用
import 'package:flutter_baidu_mapapi_search/flutter_baidu_mapapi_search.dart';

/// 路线数据管理器 - 对齐 Android RouteDataManager（单例）
/// 用于 Activity 间传递百度路线对象（因百度对象不可序列化）
class RouteDataManager {
  RouteDataManager._internal();

  static final RouteDataManager _instance = RouteDataManager._internal();
  static RouteDataManager get instance => _instance;

  /// 驾车路线（对齐 Android DrivingRouteLine）
  BMFDrivingRouteLine? _drivingRouteLine;

  /// 骑行路线（对齐 Android BikingRouteLine）
  BMFRidingRouteLine? _bikingRouteLine;

  /// 步行路线（对齐 Android WalkingRouteLine）
  BMFWalkingRouteLine? _walkingRouteLine;

  /// 公交路线列表（对齐 Android BusRouteLineDetailActivity.temporaryTransitRouteLines）
  List<BMFTransitRouteLine>? _transitRouteLines;

  /// 公交路线结果（对齐 Android TransitRouteResult）
  BMFTransitRouteResult? _transitRouteResult;

  /// 设置驾车路线 - 对齐 Android setDrivingRouteLine
  void setDrivingRouteLine(BMFDrivingRouteLine? line) {
    _drivingRouteLine = line;
  }

  /// 获取驾车路线 - 对齐 Android getDrivingRouteLine
  BMFDrivingRouteLine? getDrivingRouteLine() => _drivingRouteLine;

  /// 设置骑行路线 - 对齐 Android setBikingRouteLine
  void setBikingRouteLine(BMFRidingRouteLine? line) {
    _bikingRouteLine = line;
  }

  /// 获取骑行路线 - 对齐 Android getBikingRouteLine
  BMFRidingRouteLine? getBikingRouteLine() => _bikingRouteLine;

  /// 设置步行路线 - 对齐 Android setWalkingRouteLine
  void setWalkingRouteLine(BMFWalkingRouteLine? line) {
    _walkingRouteLine = line;
  }

  /// 获取步行路线 - 对齐 Android getWalkingRouteLine
  BMFWalkingRouteLine? getWalkingRouteLine() => _walkingRouteLine;

  /// 设置公交路线列表 - 对齐 Android BusRouteLineDetailActivity.temporaryTransitRouteLines
  void setTransitRouteLines(List<BMFTransitRouteLine>? lines) {
    _transitRouteLines = lines;
  }

  /// 获取公交路线列表
  List<BMFTransitRouteLine>? getTransitRouteLines() => _transitRouteLines;

  /// 设置公交路线结果 - 对齐 Android TransitRouteResult
  void setTransitRouteResult(BMFTransitRouteResult? result) {
    _transitRouteResult = result;
  }

  /// 获取公交路线结果
  BMFTransitRouteResult? getTransitRouteResult() => _transitRouteResult;

  /// 清除所有路线数据 - 对齐 Android clear
  void clearAll() {
    _drivingRouteLine = null;
    _bikingRouteLine = null;
    _walkingRouteLine = null;
    _transitRouteLines = null;
    _transitRouteResult = null;
  }
}
