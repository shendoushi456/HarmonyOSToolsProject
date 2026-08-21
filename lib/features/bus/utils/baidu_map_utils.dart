// 百度地图工具类 - 对齐 Android bus/utils/BaiduMapUtils.kt
// 含距离计算、坐标转换、中国境内校验
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';
import 'package:flutter_baidu_mapapi_utils/flutter_baidu_mapapi_utils.dart';

/// 百度地图工具类 - 对齐 Android BaiduMapUtils（单例语义）
class BaiduMapUtils {
  BaiduMapUtils._();

  /// 计算两点间距离（米）- 对齐 Android calculateDistance(DistanceUtil.getDistance)
  /// 鸿蒙端用 BMFCalculateUtils.getLocationDistance（异步）
  static Future<double> calculateDistance(
      double lat1, double lng1, double lat2, double lng2) async {
    final p1 = BMFCoordinate(lat1, lng1);
    final p2 = BMFCoordinate(lat2, lng2);
    final distance = await BMFCalculateUtils.getLocationDistance(p1, p2);
    return distance ?? 0.0;
  }

  /// 格式化距离显示 - 对齐 Android formatDistance
  static String formatDistance(double distance) {
    if (distance < 1000) {
      return '${distance.round()}m';
    }
    return '${(distance / 1000).toStringAsFixed(1)}km';
  }

  /// 判断坐标是否在中国境内 - 对齐 Android isValidChineseCoordinate
  /// 经度范围 73.66-135.05，纬度范围 3.86-53.55
  static bool isValidChineseCoordinate(double latitude, double longitude) {
    return latitude >= 3.86 &&
        latitude <= 53.55 &&
        longitude >= 73.66 &&
        longitude <= 135.05;
  }
}
