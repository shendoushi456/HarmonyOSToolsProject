import 'package:flutter/services.dart';
import 'package:flutter_baidu_mapapi_search/src/model/bmf_recommendstopsearch_options.dart';
import 'package:flutter_baidu_mapapi_search/src/model/bmf_recommendstopsearch_reslut.dart';
import 'package:flutter_baidu_mapapi_search/src/private/bmf_method_id.dart';
import 'package:flutter_baidu_mapapi_search/src/private/bmf_search_channel_factory.dart';
import 'package:flutter_baidu_mapapi_search/src/private/bmf_search_dispatcher.dart';
import 'package:flutter_baidu_mapapi_search/src/search/bmf_search_errorcode.dart';

/// 推荐上车点回调闭包
typedef BMFOnGetRecommendStopSearchResultCallback = void Function(
    BMFRecommendStopSearchResult result, BMFSearchErrorCode errorCode);

class BMFRecommendStopSearchDispatcher {

  BMFRecommendStopSearchDispatcher() {
    BMFSearchCallbackHandler.initialize();
  }

  Future<bool> recommendStopSearch(
      BMFRecommendStopSearchOption recommendStopSearchOption) async {
    ArgumentError.checkNotNull(
        recommendStopSearchOption, "recommendStopSearchOption");

    bool result = false;
    try {
      Map map = (await BMFSearchChannelFactory.searchChannel.invokeMethod(
          BMFRecommendStopSearchMethodID.kRecommendStopSearch,
          {
            'recommendStopSearchOption': recommendStopSearchOption.toMap(),
          } as dynamic)) as Map;
      result = map['result'] as bool;
    } on PlatformException catch (e) {
      print(e.toString());
    }
    return result;
  }

  /// 推荐上车点检索异步回调结果
  void onGetRecommendStopSearchCallback(
      BMFOnGetRecommendStopSearchResultCallback block) {
    ArgumentError.checkNotNull(block, "block");
    BMFSearchCallbackHandler().registerRecommendStopCallback(block);
  }
}
