import 'package:flutter/services.dart';
import 'package:flutter_baidu_mapapi_search/flutter_baidu_mapapi_search.dart';
import 'package:flutter_baidu_mapapi_search/src/private/bmf_aoisearch_dispatcher.dart';
import 'package:flutter_baidu_mapapi_search/src/private/bmf_buildingsearch_dispatcher.dart';
import 'package:flutter_baidu_mapapi_search/src/private/bmf_buslinesearch_dispatcher.dart';
import 'package:flutter_baidu_mapapi_search/src/private/bmf_districtsearch_dispatcher.dart';
import 'package:flutter_baidu_mapapi_search/src/private/bmf_geocodesearch_dispatcher.dart';
import 'package:flutter_baidu_mapapi_search/src/private/bmf_method_id.dart';
import 'package:flutter_baidu_mapapi_search/src/private/bmf_poisearch_dispatcher.dart';
import 'package:flutter_baidu_mapapi_search/src/private/bmf_recommendstop_dispatcher.dart';
import 'package:flutter_baidu_mapapi_search/src/private/bmf_routesearch_dispatcher.dart';
import 'package:flutter_baidu_mapapi_search/src/private/bmf_search_channel_factory.dart';
import 'package:flutter_baidu_mapapi_search/src/private/bmf_suggestionsearch_dispatcher.dart';
import 'package:flutter_baidu_mapapi_search/src/private/bmf_weathersearch_dispatcher.dart';

class BMFSearchCallbackHandler {
  static final BMFSearchCallbackHandler _instance =
      BMFSearchCallbackHandler._internal();

  BMFSearchCallbackHandler._internal();

  factory BMFSearchCallbackHandler() => _instance;

  /// sug检索回调闭包
  BMFOnGetSuggestionSearchResultCallback? _suggestionCallback;

  /// 路线规划回调闭包集合（按methodId区分）
  final Map<String, dynamic> _routeCallbacks = {
    BMFRouteSearchMethodID.kTransitRoutePlan: null,
    BMFRouteSearchMethodID.kMassTransitRoutePlan: null,
    BMFRouteSearchMethodID.kDrivingRoutePlan: null,
    BMFRouteSearchMethodID.kWalkingRoutePlan: null,
    BMFRouteSearchMethodID.kRidingRoutePlan: null,
    BMFRouteSearchMethodID.kIndoorRoutePlanSearch: null,
  };

  /// 推荐上车点闭包
  BMFOnGetRecommendStopSearchResultCallback? _recommendStopCallback;

  /// 地图AOI检索回调
  BMFOnGetAOIResultCallback? _onGetAOIResultCallback;

  /// 地图建筑物检索回调
  BMFOnGetBuildingResultCallback? _onGetBuildingResultCallback;

  /// 公交检索回调
  BMFOnGetBuslineResultCallback? _onGetBusLineResultCallback;

  /// 结果回调闭包
  BMFOnGetDistrictResultCallback? _onGetDistrictCallback;

  /// 地理编码回调结果闭包
  BMFOnGetGeoCodeResultCallback? _onGetGeoCodeCallback;

  /// 逆地理编码回调结果闭包
  BMFOnGetReverseGeoCodeResultCallback? _onGetReverseGeoCodeCallback;

  /// 天气查询回调闭包
  BMFOnGetWeatherSearchResultCallback? _onGetWeatherSearchCallback;

  /// 短串分享检索回调集合（按methodId区分）
  final Map<String, dynamic> _shareUrlCallbacks = {
    BMFShareURLSearchMethodID.kRequestPoiDetailShareURL: null,
    BMFShareURLSearchMethodID.kRequestLocationShareURL: null,
    BMFShareURLSearchMethodID.kRequestRoutePlanShareURL: null,
  };

  /// poi检索回调集合（按methodId区分）
  final Map<String, dynamic> _poiCallbacks = {
    BMFPoiSearchMethodID.kPoiSearchInCity: null,
    BMFPoiSearchMethodID.kPoiSearchNearBy: null,
    BMFPoiSearchMethodID.kPoiSearchInbounds: null,
    BMFPoiSearchMethodID.kPoiDetailSearch: null,
    BMFPoiSearchMethodID.kPoiIndoorSearch: null,
  };

  /// 初始化标识
  static bool _isInitialized = false;

  /// 统一处理器
  static Future<dynamic> _unifiedHandler(MethodCall call) async {
    final instance = BMFSearchCallbackHandler();
    final methodId = call.method;

    /// sug搜索类型
    if (methodId == BMFSuggestionSearchMethodID.kSuggestionSearch) {
      return instance._handleSuggestionResult(call);
    }

    /// 路线规划类型
    if (instance._routeCallbacks.containsKey(methodId)) {
      return instance._handleRouteResult(call, methodId);
    }

    /// 推荐上车点
    if (methodId == BMFRecommendStopSearchMethodID.kRecommendStopSearch) {
      return instance._handleRecommendStopResult(call);
    }

    /// 地图AOI检索
    if (methodId == BMFAOISearchMethodID.kAOISearch) {
      return instance._handleAOIResult(call);
    }

    /// 地图建筑物检索
    if (methodId == BMFBuildingSearchMethodID.kBuildingSearch) {
      return instance._handleBuildingResult(call);
    }

    /// 公交检索
    if (methodId == BMFBusLineSearchMethodID.kBusLineSearch) {
      return instance._handleBusLineResult(call);
    }

    /// 行政区划检索
    if (methodId == BMFDistrictSearchMethodID.kDistrictSearch) {
      return instance._handleDistrictResult(call);
    }

    /// 地理编码
    if (methodId == BMFGeoAndReverseGeoMethodID.kGeoCode) {
      return instance._handleGeoCodeResult(call);
    }

    /// 逆地理编码
    if (methodId == BMFGeoAndReverseGeoMethodID.kReverseGeoCode) {
      return instance._handleReverseGeoCodeResult(call);
    }

    /// 天气查询
    if (methodId == BMFWeatherSearchMethodID.kWeatherSearch) {
      return instance._handleWeatherResult(call);
    }

    /// 短串分享
    if (instance._shareUrlCallbacks.containsKey(methodId)) {
      return instance._handleShareUrlResult(call, methodId);
    }

    /// poi检索
    if (instance._poiCallbacks.containsKey(methodId)) {
      return instance._handlePoiResult(call, methodId);
    }
    return null;
  }

  Future<dynamic> _handlePoiResult(MethodCall call, String methodId) async {
    final callback = _poiCallbacks[methodId];
    if (callback == null) return null;

    final resultMap = call.arguments['result'];
    final errorCode =
        BMFSearchErrorCode.values[call.arguments['errorCode'] as int];

    if (methodId == BMFPoiSearchMethodID.kPoiSearchInCity &&
        callback is BMFOnGetPoiSearchResultCallback) {
      callback(BMFPoiSearchResult.fromMap(resultMap), errorCode);
    } else if (methodId == BMFPoiSearchMethodID.kPoiSearchNearBy &&
        callback is BMFOnGetPoiSearchResultCallback) {
      callback(BMFPoiSearchResult.fromMap(resultMap), errorCode);
    } else if (methodId == BMFPoiSearchMethodID.kPoiSearchInbounds &&
        callback is BMFOnGetPoiSearchResultCallback) {
      callback(BMFPoiSearchResult.fromMap(resultMap), errorCode);
    } else if (methodId == BMFPoiSearchMethodID.kPoiDetailSearch &&
        callback is BMFOnGetPOIDetailSearchResultCallback) {
      callback(BMFPoiDetailSearchResult.fromMap(resultMap), errorCode);
    } else if (methodId == BMFPoiSearchMethodID.kPoiIndoorSearch &&
        callback is BMFOnGetPOIIndoorSearchResultCallback) {
      callback(BMFPoiIndoorSearchResult.fromMap(resultMap), errorCode);
    }
    return Future.value(null);
  }

  Future<dynamic> _handleShareUrlResult(
      MethodCall call, String methodId) async {
    final callback = _shareUrlCallbacks[methodId];
    if (callback == null) return null;

    final resultMap = call.arguments['result'];
    final errorCode =
        BMFSearchErrorCode.values[call.arguments['errorCode'] as int];

    /// 目前分享都使用的同一个回调闭包，根据methodId区分具体类型，没有多个回调类型
    if (methodId == BMFShareURLSearchMethodID.kRequestPoiDetailShareURL) {
      callback(BMFShareURLResult.fromMap(resultMap), errorCode);
    } else if (methodId == BMFShareURLSearchMethodID.kRequestLocationShareURL) {
      callback(BMFShareURLResult.fromMap(resultMap), errorCode);
    } else if (methodId ==
        BMFShareURLSearchMethodID.kRequestRoutePlanShareURL) {
      callback(BMFShareURLResult.fromMap(resultMap), errorCode);
    }
    return Future.value(null);
  }

  /// 处理天气检索结果
  Future<dynamic> _handleWeatherResult(MethodCall call) async {
    if (_onGetWeatherSearchCallback == null) return null;
    Map map = call.arguments;
    BMFWeatherSearchResult result =
        BMFWeatherSearchResult.fromMap(map['result']);
    BMFSearchErrorCode errorCode =
        BMFSearchErrorCode.values[map['errorCode'] as int];
    _onGetWeatherSearchCallback!(result, errorCode);
    return Future.value(null);
  }

  /// 处理re geo结果
  Future<dynamic> _handleReverseGeoCodeResult(MethodCall call) async {
    if (_onGetReverseGeoCodeCallback == null) return null;
    Map map = call.arguments;
    BMFReverseGeoCodeSearchResult result =
        BMFReverseGeoCodeSearchResult.fromMap(map['result']);
    BMFSearchErrorCode errorCode =
        BMFSearchErrorCode.values[map['errorCode'] as int];
    _onGetReverseGeoCodeCallback!(result, errorCode);
    return Future.value(null);
  }

  /// 处理geo结果
  Future<dynamic> _handleGeoCodeResult(MethodCall call) async {
    if (_onGetGeoCodeCallback == null) return null;

    Map map = call.arguments;
    BMFGeoCodeSearchResult result =
        BMFGeoCodeSearchResult.fromMap(map['result']);
    BMFSearchErrorCode errorCode =
        BMFSearchErrorCode.values[map['errorCode'] as int];

    _onGetGeoCodeCallback!(result, errorCode);
    return Future.value(null);
  }

  /// 处理行政规划检索结果
  Future<dynamic> _handleDistrictResult(MethodCall call) async {
    if (_onGetDistrictCallback == null) return null;

    Map map = call.arguments;
    BMFDistrictSearchResult result =
        BMFDistrictSearchResult.fromMap(map['result']);
    BMFSearchErrorCode errorCode =
        BMFSearchErrorCode.values[map['errorCode'] as int];

    _onGetDistrictCallback!(result, errorCode);
    return Future.value(null);
  }

  /// 处理公交检索结果
  Future<dynamic> _handleBusLineResult(MethodCall call) async {
    if (_onGetBusLineResultCallback == null) return null;

    Map map = call.arguments;
    BMFBusLineResult result = BMFBusLineResult.fromMap(map['result']);
    BMFSearchErrorCode errorCode =
        BMFSearchErrorCode.values[map['errorCode'] as int];

    _onGetBusLineResultCallback!(result, errorCode);
    return Future.value(null);
  }

  /// 处理建筑物检索结果
  Future<dynamic> _handleBuildingResult(MethodCall call) async {
    if (_onGetBuildingResultCallback == null) return null;

    Map map = call.arguments;
    BMFBuildingSearchResult result =
        BMFBuildingSearchResult.fromMap(map['result']);
    BMFSearchErrorCode errorCode =
        BMFSearchErrorCode.values[map['errorCode'] as int];

    _onGetBuildingResultCallback!(result, errorCode);
    return Future.value(null);
  }

  /// 处理AOI检索结果
  Future<dynamic> _handleAOIResult(MethodCall call) async {
    if (_onGetAOIResultCallback == null) return null;

    Map map = call.arguments;
    BMFAOISearchResult result = BMFAOISearchResult.fromMap(map['result']);
    BMFSearchErrorCode errorCode =
        BMFSearchErrorCode.values[map['errorCode'] as int];

    _onGetAOIResultCallback!(result, errorCode);
    return Future.value(null);
  }

  /// 处理推荐上车点结果
  Future<dynamic> _handleRecommendStopResult(MethodCall call) async {
    if (_recommendStopCallback == null) return null;

    Map map = call.arguments;
    BMFRecommendStopSearchResult result =
        BMFRecommendStopSearchResult.fromMap(map['result']);
    BMFSearchErrorCode errorCode =
        BMFSearchErrorCode.values[map['errorCode'] as int];

    _recommendStopCallback!(result, errorCode);
    return Future.value(null);
  }

  /// 处理建议搜索结果
  Future<dynamic> _handleSuggestionResult(MethodCall call) async {
    if (_suggestionCallback == null) return null;

    Map map = call.arguments;
    BMFSuggestionSearchResult result =
        BMFSuggestionSearchResult.fromMap(map['result']);
    BMFSearchErrorCode errorCode =
        BMFSearchErrorCode.values[map['errorCode'] as int];

    _suggestionCallback!(result, errorCode);
    return Future.value(null);
  }

  /// 处理路线搜索结果
  Future<dynamic> _handleRouteResult(MethodCall call, String methodId) async {
    final callback = _routeCallbacks[methodId];
    if (callback == null) return null;

    final resultMap = call.arguments['result'];
    final errorCode =
        BMFSearchErrorCode.values[call.arguments['errorCode'] as int];

    if (methodId == BMFRouteSearchMethodID.kTransitRoutePlan &&
        callback is BMFOnGetTransitRouteResultCallback) {
      callback(BMFTransitRouteResult.fromMap(resultMap), errorCode);
    } else if (methodId == BMFRouteSearchMethodID.kMassTransitRoutePlan &&
        callback is BMFOnGetMassTransitRouteResultCallback) {
      callback(BMFMassTransitRouteResult.fromMap(resultMap), errorCode);
    } else if (methodId == BMFRouteSearchMethodID.kDrivingRoutePlan &&
        callback is BMFOnGetDrivingRouteResultCallback) {
      callback(BMFDrivingRouteResult.fromMap(resultMap), errorCode);
    } else if (methodId == BMFRouteSearchMethodID.kWalkingRoutePlan &&
        callback is BMFOnGetWalkingRouteResultCallback) {
      callback(BMFWalkingRouteResult.fromMap(resultMap), errorCode);
    } else if (methodId == BMFRouteSearchMethodID.kRidingRoutePlan &&
        callback is BMFOnGetRidingRouteResultCallback) {
      callback(BMFRidingRouteResult.fromMap(resultMap), errorCode);
    } else if (methodId == BMFRouteSearchMethodID.kIndoorRoutePlanSearch &&
        callback is BMFOnGetIndoorRouteResultCallback) {
      callback(BMFIndoorRouteResult.fromMap(resultMap), errorCode);
    }

    return Future.value(null);
  }

  /// 注册sug搜索回调
  void registerSuggestionCallback(
      BMFOnGetSuggestionSearchResultCallback callback) {
    _suggestionCallback = callback;
  }

  /// 注册路线规划回调
  void registerRouteCallback(String methodId, dynamic callback) {
    if (_routeCallbacks.containsKey(methodId)) {
      _routeCallbacks[methodId] = callback;
    }
  }

  /// 注册推荐上车点回调
  void registerRecommendStopCallback(
      BMFOnGetRecommendStopSearchResultCallback callback) {
    _recommendStopCallback = callback;
  }

  /// 注册地图AOI检索回调
  void registerAOICallback(BMFOnGetAOIResultCallback callback) {
    _onGetAOIResultCallback = callback;
  }

  /// 注册地图建筑物检索回调
  void registerBuildingCallback(BMFOnGetBuildingResultCallback callback) {
    _onGetBuildingResultCallback = callback;
  }

  /// 注册公交检索回调
  void registerBusLineCallback(BMFOnGetBuslineResultCallback callback) {
    _onGetBusLineResultCallback = callback;
  }

  /// 注册行政检索回调
  void registerDistrictCallback(BMFOnGetDistrictResultCallback callback) {
    _onGetDistrictCallback = callback;
  }

  /// 注册geo回调
  void registerGeoCodeCallback(BMFOnGetGeoCodeResultCallback callback) {
    _onGetGeoCodeCallback = callback;
  }

  /// 注册re geo回调
  void registerReverseGeoCodeCallback(
      BMFOnGetReverseGeoCodeResultCallback callback) {
    _onGetReverseGeoCodeCallback = callback;
  }

  /// 注册天气回调
  void registerWeatherCallback(BMFOnGetWeatherSearchResultCallback callback) {
    _onGetWeatherSearchCallback = callback;
  }

  /// 注册短串分享回调
  void registerShareUrlCallback(String methodId, dynamic callback) {
    if (_shareUrlCallbacks.containsKey(methodId)) {
      _shareUrlCallbacks[methodId] = callback;
    }
  }

  /// 注册poi检索回调
  void registerPoiCallback(String methodId, dynamic callback) {
    if (_poiCallbacks.containsKey(methodId)) {
      _poiCallbacks[methodId] = callback;
    }
  }

  /// 初始化方法通道
  static void initialize() {
    if (!_isInitialized) {
      BMFSearchChannelFactory.searchChannel
          .setMethodCallHandler(_unifiedHandler);
      _isInitialized = true;
    }
  }
}
