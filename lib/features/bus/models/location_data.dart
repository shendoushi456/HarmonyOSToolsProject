// 定位数据模型 - 对齐 Android bus/repository/LocationRepository.kt
// 含 LocationData 数据类
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';

/// 定位数据模型 - 对齐 Android LocationData data class
class LocationData {
  const LocationData({
    required this.latitude,
    required this.longitude,
    required this.city,
    this.address = '',
    this.district = '',
  });

  /// 纬度
  final double latitude;

  /// 经度
  final double longitude;

  /// 城市（已去除"市"后缀，对齐 Android BaiduLocationManager: city?.removeSuffix("市") ?: "北京"）
  final String city;

  /// 地址描述
  final String address;

  /// 区县
  final String district;

  /// 转换为百度 LatLng - 对齐 Android LocationData.toLatLng()
  BMFCoordinate toLatLng() => BMFCoordinate(latitude, longitude);

  @override
  String toString() =>
      'LocationData(lat=$latitude, lng=$longitude, city=$city, district=$district, address=$address)';
}
