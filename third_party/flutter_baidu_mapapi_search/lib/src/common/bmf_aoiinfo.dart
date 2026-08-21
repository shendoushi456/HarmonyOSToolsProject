import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';

/// 搜索结果aoi类型
enum BMFAOIType {
  AOITypeUnknown,

  ///< 未知类型
  AOITypeAirport,

  ///< 机场
  AOITypeAirportRailwayStation,

  ///< 火车站
  AOITypeMall,

  ///< 商场
  AOITypeGasStation,

  ///< 加油站
  AOITypeSchool,

  ///< 学校
  AOITypeHospital,

  ///< 医院
  AOITypeResidentialDistrict,

  ///< 住宅区
  AOITypeScenicArea,

  ///< 风景区
  AOITypePark,

  ///< 公园
  AOITypeFreeWayService,

  ///< 服务区
  AOITypeWater

  ///< 水域
}

/// aoi信息类
class BMFAOIInfo implements BMFModel {
  /// 对应输入点顺序，用来区分是哪个点返回的aoi。
  /// 注意：该字段从1开始计数
  int? order;

  /// aoid的uid
  String? uid;

  /// aoi的名称
  String? name;

  /// aoi的类型
  BMFAOIType? type;

  /// aoi的加密面数据
  String? paths;

  /// 点距离aoi边界最近距离，单位：米
  int? nearestDistance;

  /// 对应输入点与aoi的关系
  /// 0（aoi内），1（aoi外），2（未找到）
  int? relation;

  BMFAOIInfo({
    this.order,
    this.uid,
    this.name,
    this.type,
    this.paths,
    this.nearestDistance,
    this.relation,
  });

  BMFAOIInfo.fromMap(Map map) {
    order = map['order'];
    uid = map['uid'];
    name = map['name'];
    type = BMFAOIType.values[map['type']];
    paths = map['paths'];
    nearestDistance = map['nearestDistance'];
    relation = map['relation'];
  }

  @override
  fromMap(Map map) {
    return BMFAOIInfo.fromMap(map);
  }

  @override
  Map<String, Object?> toMap() {
    return {
      'order': this.order,
      'uid': this.uid,
      'name': this.name,
      'type': this.type?.index,
      'paths': this.paths,
      'nearestDistance': this.nearestDistance,
      'relation': this.relation
    };
  }
}
