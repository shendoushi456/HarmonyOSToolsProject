import 'package:flutter/services.dart';
import 'package:flutter_baidu_mapapi_search/src/model/bmf_suggestionsearch_options.dart';
import 'package:flutter_baidu_mapapi_search/src/model/bmf_suggestionsearch_result.dart';
import 'package:flutter_baidu_mapapi_search/src/private/bmf_method_id.dart';
import 'package:flutter_baidu_mapapi_search/src/private/bmf_search_channel_factory.dart';
import 'package:flutter_baidu_mapapi_search/src/private/bmf_search_dispatcher.dart';
import 'package:flutter_baidu_mapapi_search/src/search/bmf_search_errorcode.dart';

/// sug检索回调闭包
typedef BMFOnGetSuggestionSearchResultCallback = void Function(
    BMFSuggestionSearchResult result, BMFSearchErrorCode errorCode);

/// sug检索调度中心
class BMFSuggestionSearchDispatcher {

  /// 无参构造
  BMFSuggestionSearchDispatcher() {
    BMFSearchCallbackHandler.initialize();
  }

  /// 搜索建议检索
  ///
  /// suggestionSearchOption       sug检索信息类
  /// 成功返回ture，否则返回false
  Future<bool> suggestionSearch(
      BMFSuggestionSearchOption suggestionSearchOption) async {
    ArgumentError.checkNotNull(
        suggestionSearchOption, "suggestionSearchOption");

    bool result = false;
    try {
      Map map = (await BMFSearchChannelFactory.searchChannel.invokeMethod(
          BMFSuggestionSearchMethodID.kSuggestionSearch,
          {
            'suggestionSearchOption': suggestionSearchOption.toMap(),
          } as dynamic)) as Map;
      result = map['result'] as bool;
    } on PlatformException catch (e) {
      print(e.toString());
    }
    return result;
  }

  /// sug检索异步回调结果
  void onGetSuggestionSearchCallback(
      BMFOnGetSuggestionSearchResultCallback block) {
    ArgumentError.checkNotNull(block, "block");
    BMFSearchCallbackHandler().registerSuggestionCallback(block);
  }
}
