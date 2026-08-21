
import 'package:flutter/services.dart';
import 'package:flutter_baidu_mapapi_search/src/model/bmf_aoisearch_options.dart';
import 'package:flutter_baidu_mapapi_search/src/model/bmf_aoisearch_result.dart';
import 'package:flutter_baidu_mapapi_search/src/private/bmf_method_id.dart';
import 'package:flutter_baidu_mapapi_search/src/private/bmf_search_channel_factory.dart';
import 'package:flutter_baidu_mapapi_search/src/private/bmf_search_dispatcher.dart';
import 'package:flutter_baidu_mapapi_search/src/search/bmf_search_errorcode.dart';

/// 地图AOI检索回调
typedef BMFOnGetAOIResultCallback = void Function(
    BMFAOISearchResult result, BMFSearchErrorCode errorCode);

/// AOIsearch调度中心
class BMFAOISearchDispatcher {

  /// 无参构造
  BMFAOISearchDispatcher() {
    BMFSearchCallbackHandler.initialize();
  }

  /// 地图aoi检索
  ///
  /// AOISearchOption 地图aoi检索信息类
  /// bool 成功返回true，否则返回false
  Future<bool> AOISearch(
      BMFAOISearchOption AOISearchOption) async {
    ArgumentError.checkNotNull(AOISearchOption, "AOISearchOption");

    bool result = false;
    try {
      Map map = (await BMFSearchChannelFactory.searchChannel.invokeMethod(
          BMFAOISearchMethodID.kAOISearch,
          {
            'AOISearchOption': AOISearchOption.toMap(),
          } as dynamic)) as Map;
      result = map['result'] as bool;
    } on PlatformException catch (e) {
      print(e.toString());
    }
    return result;
  }

  /// 地图AOI检索异步回调结果
  void onGetAOISearchResultCallback(BMFOnGetAOIResultCallback block) {
    ArgumentError.checkNotNull(block, "block");
    BMFSearchCallbackHandler().registerAOICallback(block);
  }
}
