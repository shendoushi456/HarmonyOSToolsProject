import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart'
    show BMFModel, BMFCoordinate;
import 'package:flutter_baidu_mapapi_search/src/model/bmf_search_base.dart';

/// 推荐上车点返回结果类
class BMFRecommendStopSearchResult extends BMFSearch implements BMFModel {
  /// 推荐上车点返回结果列表
  List<BMFRecommendStopInfo>? recommendStopInfoList;

  /// 场站推荐上车点返回结果列表，当isNeedStationInfo为YES时返回
  List<BMFStationRecommendStopInfo>? stationInfoList;

  /// 有参构造
  BMFRecommendStopSearchResult(
      {this.recommendStopInfoList, this.stationInfoList});

  /// map => BMFRecommendStopSearchResult
  BMFRecommendStopSearchResult.fromMap(Map map)
      : assert(
            map != null, // ignore: unnecessary_null_comparison
            'Construct a BMFRecommendStopSearchResult，The parameter map cannot be null !'),
        super.fromMap(map) {
    if (map['recommendStopInfoList'] != null) {
      List<BMFRecommendStopInfo> tmpRecommendStopInfoList = [];
      map['recommendStopInfoList'].forEach((v) {
        tmpRecommendStopInfoList.add(BMFRecommendStopInfo.fromMap(v as Map));
      });
      recommendStopInfoList = tmpRecommendStopInfoList;
    }
    ;
    if (map['stationInfoList'] != null) {
      List<BMFStationRecommendStopInfo> tmpStationRecommendStopInfoList = [];
      map['stationInfoList'].forEach((v) {
        tmpStationRecommendStopInfoList
            .add(BMFStationRecommendStopInfo.fromMap(v as Map));
      });
      stationInfoList = tmpStationRecommendStopInfoList;
    }
  }

  @override
  fromMap(Map map) {
    return BMFRecommendStopSearchResult.fromMap(map);
  }

  @override
  Map<String, Object?> toMap() {
    return Map.from(super.toMap())
      ..addAll({
        'recommendStopInfoList':
            this.recommendStopInfoList?.map((e) => e.toMap()).toList(),
        'stationInfoList': this.stationInfoList?.map((e) => e.toMap()).toList(),
      });
  }
}

class BMFStationRecommendStopInfo implements BMFModel {
  /// 场站分层名称信息，逗号隔开，如:(北京首都国际机场,T1航站楼,停车场)，无场站分层信息时为空字符串
  String? stationName;

  /// 推荐上车点返回结果列表，无场站分层信息时为普通推荐上车点
  List<BMFRecommendStopInfo>? recommendStopsInfoList;

  BMFStationRecommendStopInfo({this.stationName, this.recommendStopsInfoList});

  BMFStationRecommendStopInfo.fromMap(Map map)
      : assert(
            map != null, // ignore: unnecessary_null_comparison
            'Construct a BMFStationRecommendStopInfo parameter map cannot be null !') {
    stationName = map['stationName'];
    if (map['recommendStopsInfoList'] != null) {
      List<BMFRecommendStopInfo> tmpRecommendStopInfoList = [];
      map['recommendStopsInfoList'].forEach((v) {
        tmpRecommendStopInfoList.add(BMFRecommendStopInfo.fromMap(v as Map));
      });
      recommendStopsInfoList = tmpRecommendStopInfoList;
    }
  }

  @override
  fromMap(Map map) {
    return BMFStationRecommendStopInfo.fromMap(map);
  }

  @override
  Map<String, Object?> toMap() {
    return {
      'stationName': this.stationName,
      'recommendStopsInfoList':
          this.recommendStopsInfoList?.map((e) => e.toMap()).toList(),
    };
  }
}

/// 推荐上车点信息类
class BMFRecommendStopInfo implements BMFModel {
  /// 推荐上车点名称
  String? name;

  /// 推荐上车点地址
  String? address;

  /// 推荐上车点经纬度
  BMFCoordinate? location;

  /// 推荐点poi的uid
  String? uid;

  /// 距查找点的距离，单位米
  double? distance;

  /// 有参构造
  BMFRecommendStopInfo(
      {this.name, this.address, this.location, this.uid, this.distance});

  /// map => BMFRecommendStopInfo
  BMFRecommendStopInfo.fromMap(Map map)
      : assert(
            map != null, // ignore: unnecessary_null_comparison
            'Construct a BMFRecommendStopInfo，The parameter map cannot be null !') {
    name = map['name'];
    address = map['address'];
    location =
        map['location'] == null ? null : BMFCoordinate.fromMap(map['location']);
    uid = map['uid'];
    if (map['distance'] != null) {
      distance = double.parse(map['distance'].toString());
    }
  }

  @override
  fromMap(Map map) {
    return BMFRecommendStopInfo.fromMap(map);
  }

  @override
  Map<String, Object?> toMap() {
    return {
      'name': this.name,
      'address': this.address,
      'location': this.location?.toMap(),
      'uid': this.uid,
      'distance': this.distance
    };
  }
}
