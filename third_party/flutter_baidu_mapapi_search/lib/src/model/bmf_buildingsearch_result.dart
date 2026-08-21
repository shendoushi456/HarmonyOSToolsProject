import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart'
    show BMFBuildInfo, BMFModel;
import 'package:flutter_baidu_mapapi_search/src/model/bmf_search_base.dart';

/// 地图建筑物返回结果类
class BMFBuildingSearchResult extends BMFSearch implements BMFModel {
  /// 地图建筑物返回结果列表
  List<BMFBuildInfo>? buildingList;

  /// 有参构造
  BMFBuildingSearchResult({this.buildingList});

  /// map => BMFBuildingSearchResult
  BMFBuildingSearchResult.fromMap(Map map) : super.fromMap(map) {
    if (map['buildingList'] != null) {
      List<BMFBuildInfo> tmpBuildingList = [];
      map['buildingList'].forEach((v) {
        tmpBuildingList.add(BMFBuildInfo.fromMap(v as Map));
      });
      buildingList = tmpBuildingList;
    }
  }

  @override
  fromMap(Map map) {
    return BMFBuildingSearchResult.fromMap(map);
  }

  @override
  Map<String, Object?> toMap() {
    return Map.from(super.toMap())
      ..addAll(
          {'buildingList': this.buildingList?.map((e) => e.toMap()).toList()});
  }
}
