import 'package:flutter/services.dart';
import 'package:flutter_baidu_mapapi_search/src/model/bmf_routesearch_options.dart';
import 'package:flutter_baidu_mapapi_search/src/model/bmf_routesearch_result.dart';
import 'package:flutter_baidu_mapapi_search/src/private/bmf_method_id.dart';
import 'package:flutter_baidu_mapapi_search/src/private/bmf_search_channel_factory.dart';
import 'package:flutter_baidu_mapapi_search/src/private/bmf_search_dispatcher.dart';
import 'package:flutter_baidu_mapapi_search/src/search/bmf_search_errorcode.dart';

/// 公交检索结果回调闭包
typedef BMFOnGetTransitRouteResultCallback = void Function(
    BMFTransitRouteResult result, BMFSearchErrorCode errorCode);

/// 公共交通路线检索 结果回调闭包
typedef BMFOnGetMassTransitRouteResultCallback = void Function(
    BMFMassTransitRouteResult result, BMFSearchErrorCode errorCode);

/// 驾乘搜索结果回调闭包
typedef BMFOnGetDrivingRouteResultCallback = void Function(
    BMFDrivingRouteResult result, BMFSearchErrorCode errorCode);

/// 步行搜索结果回调闭包
typedef BMFOnGetWalkingRouteResultCallback = void Function(
    BMFWalkingRouteResult result, BMFSearchErrorCode errorCode);

/// 骑行搜索结果回调闭包
typedef BMFOnGetRidingRouteResultCallback = void Function(
    BMFRidingRouteResult result, BMFSearchErrorCode errorCode);

/// 室内路线搜索结果回调闭包
typedef BMFOnGetIndoorRouteResultCallback = void Function(
    BMFIndoorRouteResult result, BMFSearchErrorCode errorCode);

/// 路线规划调度中心
class BMFRouteSearchDisptacher {
  /// 无参构造
  BMFRouteSearchDisptacher() {
    BMFSearchCallbackHandler.initialize();
  }

  /// 公交路线检索（仅支持市内）
  ///
  /// transitRoutePlanOption 公交换乘信息类
  /// 成功返回ture，否则返回false
  Future<bool> transitRouteSearch(
      BMFTransitRoutePlanOption transitRoutePlanOption) async {
    ArgumentError.checkNotNull(
        transitRoutePlanOption, "transitRoutePlanOption");

    bool result = false;
    try {
      Map map = (await BMFSearchChannelFactory.searchChannel.invokeMethod(
          BMFRouteSearchMethodID.kTransitRoutePlan,
          {
            'transitRoutePlanOption': transitRoutePlanOption.toMap(),
          } as dynamic)) as Map;
      result = map['result'] as bool;
    } on PlatformException catch (e) {
      print(e.toString());
    }
    return result;
  }

  /// 公共交通路线检索（new）（支持市内和跨城）
  ///
  /// 注：起终点城市不支持使用cityId
  /// routePlanOption 公共交通检索信息类
  /// 成功返回ture，否则返回false
  Future<bool> massTransitRouteSearch(
      BMFMassTransitRoutePlanOption massTransitRoutePlanOption) async {
    ArgumentError.checkNotNull(
        massTransitRoutePlanOption, "massTransitRoutePlanOption");

    bool result = false;
    try {
      Map map = (await BMFSearchChannelFactory.searchChannel.invokeMethod(
          BMFRouteSearchMethodID.kMassTransitRoutePlan,
          {
            'massTransitRoutePlanOption': massTransitRoutePlanOption.toMap(),
          } as dynamic)) as Map;
      result = map['result'] as bool;
    } on PlatformException catch (e) {
      print(e.toString());
    }
    return result;
  }

  /// 驾乘路线检索
  ///
  /// drivingRoutePlanOption 驾车检索信息类
  /// 成功返回ture，否则返回false
  Future<bool> dringRouteSearch(
      BMFDrivingRoutePlanOption drivingRoutePlanOption) async {
    ArgumentError.checkNotNull(
        drivingRoutePlanOption, "drivingRoutePlanOption");

    bool result = false;
    try {
      Map map = (await BMFSearchChannelFactory.searchChannel.invokeMethod(
          BMFRouteSearchMethodID.kDrivingRoutePlan,
          {
            'drivingRoutePlanOption': drivingRoutePlanOption.toMap(),
          } as dynamic)) as Map;
      result = map['result'] as bool;
    } on PlatformException catch (e) {
      print(e.toString());
    }
    return result;
  }

  /// 步行路线检索
  ///
  /// walkingRoutePlanOption 步行检索信息类
  /// 成功返回ture，否则返回false
  Future<bool> walkingRouteSearch(
      BMFWalkingRoutePlanOption walkingRoutePlanOption) async {
    ArgumentError.checkNotNull(
        walkingRoutePlanOption, "walkingRoutePlanOption");

    bool result = false;
    try {
      Map map = (await BMFSearchChannelFactory.searchChannel.invokeMethod(
          BMFRouteSearchMethodID.kWalkingRoutePlan,
          {
            'walkingRoutePlanOption': walkingRoutePlanOption.toMap(),
          } as dynamic)) as Map;
      result = map['result'] as bool;
    } on PlatformException catch (e) {
      print(e.toString());
    }
    return result;
  }

  /// 骑行路线检索
  ///
  /// ridingRoutePlanOption 骑行检索信息类
  /// 成功返回ture，否则返回false
  Future<bool> ridingRouteSearch(
      BMFRidingRoutePlanOption ridingRoutePlanOption) async {
    ArgumentError.checkNotNull(ridingRoutePlanOption, "ridingRoutePlanOption");

    bool result = false;
    try {
      Map map = (await BMFSearchChannelFactory.searchChannel.invokeMethod(
          BMFRouteSearchMethodID.kRidingRoutePlan,
          {
            'ridingRoutePlanOption': ridingRoutePlanOption.toMap(),
          } as dynamic)) as Map;
      result = map['result'] as bool;
    } on PlatformException catch (e) {
      print(e.toString());
    }
    return result;
  }

  /// 室内路线检索
  ///
  /// indoorRoutePlanOption 室内路线检索信息类
  /// 成功返回ture，否则返回false
  Future<bool> indoorRouteSearch(
      BMFIndoorRoutePlanOption indoorRoutePlanOption) async {
    ArgumentError.checkNotNull(indoorRoutePlanOption, "indoorRoutePlanOption");

    bool result = false;
    try {
      Map map = (await BMFSearchChannelFactory.searchChannel.invokeMethod(
          BMFRouteSearchMethodID.kIndoorRoutePlanSearch,
          {
            'indoorRoutePlanOption': indoorRoutePlanOption.toMap(),
          } as dynamic)) as Map;
      result = map['result'] as bool;
    } on PlatformException catch (e) {
      print(e.toString());
    }
    return result;
  }

  /// 公交检索结果回调
  void onGetTransitRouteResultCallback(
      BMFOnGetTransitRouteResultCallback block) {
    ArgumentError.checkNotNull(block, "block");
    BMFSearchCallbackHandler()
        .registerRouteCallback(BMFRouteSearchMethodID.kTransitRoutePlan, block);
  }

  /// 公共交通路线检索结果回调
  void onGetMassTransitRouteResultCallback(
      BMFOnGetMassTransitRouteResultCallback block) {
    ArgumentError.checkNotNull(block, "block");
    BMFSearchCallbackHandler().registerRouteCallback(
        BMFRouteSearchMethodID.kMassTransitRoutePlan, block);
  }

  /// 驾乘搜索结果回调
  void onGetDrivingRouteResultCallback(
      BMFOnGetDrivingRouteResultCallback block) {
    ArgumentError.checkNotNull(block, "block");
    BMFSearchCallbackHandler()
        .registerRouteCallback(BMFRouteSearchMethodID.kDrivingRoutePlan, block);
  }

  /// 步行搜索结果回调
  void onGetWalkingRouteResultCallback(
      BMFOnGetWalkingRouteResultCallback block) {
    ArgumentError.checkNotNull(block, "block");
    BMFSearchCallbackHandler()
        .registerRouteCallback(BMFRouteSearchMethodID.kWalkingRoutePlan, block);
  }

  /// 骑行搜索结果回调
  void onGetRidingRouteResultCallback(BMFOnGetRidingRouteResultCallback block) {
    ArgumentError.checkNotNull(block, "block");
    BMFSearchCallbackHandler()
        .registerRouteCallback(BMFRouteSearchMethodID.kRidingRoutePlan, block);
  }

  /// 室内路线搜索结果回调
  void onGetIndoorRouteResultCallback(BMFOnGetIndoorRouteResultCallback block) {
    ArgumentError.checkNotNull(block, "block");
    BMFSearchCallbackHandler().registerRouteCallback(
        BMFRouteSearchMethodID.kIndoorRoutePlanSearch, block);
  }
}
