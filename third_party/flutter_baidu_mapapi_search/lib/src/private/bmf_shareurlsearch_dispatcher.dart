import 'package:flutter/services.dart';
import 'package:flutter_baidu_mapapi_search/src/model/bmf_shareurlsearch_options.dart';
import 'package:flutter_baidu_mapapi_search/src/model/bmf_shareurlsearch_result.dart';
import 'package:flutter_baidu_mapapi_search/src/private/bmf_method_id.dart';
import 'package:flutter_baidu_mapapi_search/src/private/bmf_search_channel_factory.dart';
import 'package:flutter_baidu_mapapi_search/src/private/bmf_search_dispatcher.dart';
import 'package:flutter_baidu_mapapi_search/src/search/bmf_search_errorcode.dart';

/// 短串分享回调结果闭包
typedef BMFOnGetShareURLResultCallback = void Function(
    BMFShareURLResult result, BMFSearchErrorCode errorCode);

/// 短串检索调度中心
class BMFShareurlSearchDispatcher {

  /// 无参构造
  BMFShareurlSearchDispatcher() {
    BMFSearchCallbackHandler.initialize();
  }

  /// 获取poi详情短串分享url
  ///
  /// poiDetailShareUrlSearchOption poi详情短串分享检索信息类
  /// 请求发送成功返回true，否则返回false
  Future<bool> poiDetailShareUrlSearchDispatcher(
      BMFPoiDetailShareURLOption poiDetailShareURLOption) async {
    ArgumentError.checkNotNull(
        poiDetailShareURLOption, "poiDetailShareURLOption");

    bool result = false;
    try {
      Map map = (await BMFSearchChannelFactory.searchChannel.invokeMethod(
          BMFShareURLSearchMethodID.kRequestPoiDetailShareURL,
          {
            'poiDetailShareURLOption': poiDetailShareURLOption.toMap(),
          } as dynamic)) as Map;
      result = map['result'];
    } on PlatformException catch (e) {
      print(e.toString());
    }
    return result;
  }

  /// 获取反geo短串分享url
  ///
  /// reverseGeoShareUrlSearchOption 反geo短串分享检索信息类
  /// 请求发送成功返回true，否则返回false
  Future<bool> reverseGeoShareUrlSearchDispatcher(
      BMFReverseGeoShareURLOption reverseGeoShareURLOption) async {
    ArgumentError.checkNotNull(
        reverseGeoShareURLOption, "reverseGeoShareURLOption");

    bool result = false;
    try {
      Map map = (await BMFSearchChannelFactory.searchChannel.invokeMethod(
          BMFShareURLSearchMethodID.kRequestLocationShareURL,
          {
            'reverseGeoShareURLOption': reverseGeoShareURLOption.toMap(),
          } as dynamic)) as Map;
      result = map['result'];
    } on PlatformException catch (e) {
      print(e.toString());
    }
    return result;
  }

  /// 获取路线规划短串分享url
  ///
  /// routePlanShareUrlSearchOption 取路线规划短串分享检索信息类
  /// 请求发送成功返回true，否则返回false
  Future<bool> routePlanShareUrlSearchDispatcher(
      BMFRoutePlanShareURLOption routePlanShareURLOption) async {
    ArgumentError.checkNotNull(
        routePlanShareURLOption, "routePlanShareURLOption");

    bool result = false;
    try {
      Map map = (await BMFSearchChannelFactory.searchChannel.invokeMethod(
          BMFShareURLSearchMethodID.kRequestRoutePlanShareURL,
          {
            'routePlanShareURLOption': routePlanShareURLOption.toMap(),
          } as dynamic)) as Map;
      result = map['result'];
    } on PlatformException catch (e) {
      print(e.toString());
    }
    return result;
  }

  /// poi详情短串分享url回调结果
  void onGetPoiDetailShareURLResultCallback(
      BMFOnGetShareURLResultCallback block) {
    ArgumentError.checkNotNull(block, "block");
    BMFSearchCallbackHandler().registerShareUrlCallback(
        BMFShareURLSearchMethodID.kRequestPoiDetailShareURL, block);
  }

  /// 反geo短串分享url回调结果
  void onGetReverseGeoShareURLResultCallback(
      BMFOnGetShareURLResultCallback block) {
    ArgumentError.checkNotNull(block, "block");
    BMFSearchCallbackHandler().registerShareUrlCallback(
        BMFShareURLSearchMethodID.kRequestLocationShareURL, block);
  }

  /// 路线规划短串分享url回调结果闭包
  void onGetRoutePlanShareURLResultCallback(
      BMFOnGetShareURLResultCallback block) {
    ArgumentError.checkNotNull(block, "block");
    BMFSearchCallbackHandler().registerShareUrlCallback(
        BMFShareURLSearchMethodID.kRequestRoutePlanShareURL, block);
  }
}
