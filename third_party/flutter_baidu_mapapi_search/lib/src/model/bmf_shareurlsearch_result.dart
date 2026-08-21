import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart'
    show BMFModel;
import 'package:flutter_baidu_mapapi_search/src/model/bmf_search_base.dart';

/// 分享URL结果类
class BMFShareURLResult extends BMFSearch implements BMFModel {
  /// 返回结果url
  String? url;

  /// 构造方法
  BMFShareURLResult({this.url});

  /// map => BMFShareURLResult
  BMFShareURLResult.fromMap(Map map)
      : assert(
            map != null, // ignore: unnecessary_null_comparison
            'Construct a BMFShareURLResult，The parameter map cannot be null !'),
        super.fromMap(map) {
    url = map['url'];
  }
  @override
  fromMap(Map map) {
    return BMFShareURLResult.fromMap(map);
  }

  @override
  Map<String, Object?> toMap() {
    return Map.from(super.toMap())..addAll({'url': this.url});
  }
}
