
import 'package:flutter_baidu_mapapi_search/flutter_baidu_mapapi_search.dart';
import 'package:flutter_baidu_mapapi_search/src/private/bmf_aoisearch_dispatcher.dart';

/// 地图aoi检索 since 3.6.0
class BMFAOISearch {
  /// 地图aoi搜索服务实例
  late BMFAOISearchDispatcher _aoiSearchDispatcher;

  /// 无参构造
  BMFAOISearch() {
    _aoiSearchDispatcher = BMFAOISearchDispatcher();
  }

  /// 地图aoi检索
  /// onGetAOISearchResult 通知地图aoi检索结果BMFAOISearchResult
  /// AOISearchOption  地图aoi检索信息类
  /// 成功返回true，否则返回false
  Future<bool> aoiSearch(
      BMFAOISearchOption AOISearchOption) async {
    return await _aoiSearchDispatcher.AOISearch(AOISearchOption);
  }

  /// 地图aoi检索异步回调结果
  void onGetAOISearchResult(
      {required void Function(
              BMFAOISearchResult result, BMFSearchErrorCode errorCode)
          callback}) {
    _aoiSearchDispatcher.onGetAOISearchResultCallback(callback);
  }
}