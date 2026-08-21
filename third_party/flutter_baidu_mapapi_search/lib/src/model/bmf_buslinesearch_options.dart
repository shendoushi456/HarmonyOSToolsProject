import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart'
    show BMFModel;
import 'package:flutter_baidu_mapapi_search/src/model/bmf_language_type.dart';
import 'package:flutter_baidu_mapapi_search/src/model/bmf_search_base.dart';

/// 公交线路检索信息类
class BMFBusLineSearchOption extends BMFSearch implements BMFModel {
  /// 城市名（可选）
  String? city;

  /// 公交线路的uid 注：从Sug检索或者POI城市检索中搜索公交线路,得到的结果中获取。
  String? busLineUid;

  /// 可选。起点uid
  String? startUid;

  /// 可选。终点uid
  String? endUid;

  /// 可选。语言类型，默认中文。
  BMFLanguageType? languageType;

  /// 有参构造
  BMFBusLineSearchOption(
      {required this.busLineUid,
      this.city,
      this.startUid,
      this.endUid,
      this.languageType});

  /// map => BMFBusLineSearchOption
  BMFBusLineSearchOption.fromMap(Map map)
      : assert(
            map != null, // ignore: unnecessary_null_comparison
            'Construct a BMFBusLineSearchOption，The parameter map cannot be null !'),
        super.fromMap(map) {
    city = map['city'];
    busLineUid = map['busLineUid'];
    startUid = map['startUid'];
    endUid = map['endUid'];
    languageType = BMFLanguageType.values[map['languageType'] as int];
  }

  @override
  fromMap(Map map) {
    return BMFBusLineSearchOption.fromMap(map);
  }

  @override
  Map<String, Object?> toMap() {
    return Map.from(super.toMap())
      ..addAll({
        'city': this.city,
        'busLineUid': this.busLineUid,
        'startUid': this.startUid,
        'endUid': this.endUid,
        'languageType': this.languageType?.index
      });
  }
}
