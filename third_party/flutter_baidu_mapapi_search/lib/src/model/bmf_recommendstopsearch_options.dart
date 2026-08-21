import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart'
    show BMFModel, BMFCoordinate;
import 'package:flutter_baidu_mapapi_search/src/model/bmf_search_base.dart';

///  推荐上车点参数信息类
class BMFRecommendStopSearchOption extends BMFSearch implements BMFModel {
  /// 推荐上车点经纬度 （必选）
  BMFCoordinate? location;

  /// 是否需要场站上车点推荐（可选），默认：NO，设置为YES时，location位置在场站附近时返回对应的场站推荐上车点信息
  /// since 3.4.0
  bool? isNeedStationInfo;

  /// 有参构造
  BMFRecommendStopSearchOption(
      {required this.location, this.isNeedStationInfo = false});

  /// map => BMFRecommendStopSearchOption
  BMFRecommendStopSearchOption.fromMap(Map map)
      : assert(
            map != null, // ignore: unnecessary_null_comparison
            'Construct a BMFRecommendStopSearchOption，The parameter map cannot be null !'),
        super.fromMap(map) {
    location =
        map['location'] == null ? null : BMFCoordinate.fromMap(map['location']);
    isNeedStationInfo = map['isNeedStationInfo'] as bool;
  }

  @override
  fromMap(Map map) {
    return BMFRecommendStopSearchOption.fromMap(map);
  }

  @override
  Map<String, Object?> toMap() {
    return Map.from(super.toMap())
      ..addAll({
        'location': this.location?.toMap(),
        'isNeedStationInfo': this.isNeedStationInfo as bool,
      });
  }
}
