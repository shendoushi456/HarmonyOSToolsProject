import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart'
    show BMFModel;
import 'package:flutter_baidu_mapapi_search/src/model/bmf_search_base.dart';

/// 地图AOI搜索参数
class BMFAOISearchOption extends BMFSearch implements BMFModel {
  /// 经纬度数组字符串 (必选)
  /// 注意以下两点：
  /// 多个经纬度之间以 ; 号分割
  /// 经纬度类型必须为 bd09ll
  /// eg: 116.31380,40.07445;116.31087,40.07361
  late String locations;

  /// 有参构造
  BMFAOISearchOption({required this.locations});

  /// map => BMFAOISearchOption
  BMFAOISearchOption.fromMap(Map map)
      : assert(
            map != null, // ignore: unnecessary_null_comparison
            'Construct a BMFAOISearchOption，The parameter map cannot be null !'),
        super.fromMap(map) {
    locations = map['locations'];
  }

  @override
  fromMap(Map map) {
    return BMFAOISearchOption.fromMap(map);
  }

  @override
  Map<String, Object?> toMap() {
    return Map.from(super.toMap())..addAll({'locations': this.locations});
  }
}
