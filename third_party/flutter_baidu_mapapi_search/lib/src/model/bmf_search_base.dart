import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';

/// 搜索结果基类
class BMFSearch implements BMFModel {
  /// search 唯一标识id
  late String _id;

  BMFSearch() {
    var timeStamp = DateTime.now().millisecondsSinceEpoch;
    _id = '$timeStamp' '_' '$hashCode';
  }

  BMFSearch.fromMap(Map map) {
    if (null != map['id']) {
      this._id = map['id'];
    }
  }

  /// getter方法 用于区分不同搜索结果
  String get id => _id;

  @override
  fromMap(Map map) {
    BMFSearch.fromMap(map);
  }

  @override
  Map<String, Object?> toMap() {
    return {
      'id': this.id,
    };
  }
}
