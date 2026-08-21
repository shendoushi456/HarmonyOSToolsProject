import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart'
    show BMFModel;
import 'package:flutter_baidu_mapapi_search/src/common/bmf_aoiinfo.dart';
import 'package:flutter_baidu_mapapi_search/src/model/bmf_search_base.dart';

/// 地图AOI返回结果类
class BMFAOISearchResult extends BMFSearch implements BMFModel {
  /// aoi信息数组
  List<BMFAOIInfo>? aoiInfoList;

  /// 有参构造
  BMFAOISearchResult({this.aoiInfoList});

  /// map => BMFAOISearchOption
  BMFAOISearchResult.fromMap(Map map) : super.fromMap(map) {
    if (map['aoiInfoList'] != null) {
      List<BMFAOIInfo> tempAoiInfoList = [];

      for (var item in map['aoiInfoList']) {
        BMFAOIInfo info = BMFAOIInfo.fromMap(item as Map);
        tempAoiInfoList.add(info);
      }
      aoiInfoList = tempAoiInfoList;
    }
  }

  @override
  fromMap(Map map) {
    return BMFAOISearchResult.fromMap(map);
  }

  @override
  Map<String, Object?> toMap() {
    return Map.from(super.toMap())..addAll({'aoiInfoList': this.aoiInfoList});
  }
}
