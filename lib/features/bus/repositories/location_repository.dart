// 定位 Repository 抽象接口 - 对齐 Android bus/repository/LocationRepository.kt
// 抽象定位数据获取，不依赖具体实现
import '../models/location_data.dart';

/// 定位 Repository 接口 - 对齐 Android LocationRepository
abstract class LocationRepository {
  /// 获取当前位置信息 - 对齐 Android suspend fun getCurrentLocation(): Result<LocationData>
  /// 鸿蒙端用 Future 替代 Kotlin Result
  Future<LocationData?> getCurrentLocation();

  /// 检查定位权限 - 对齐 Android fun hasLocationPermission(): Boolean
  bool hasLocationPermission();

  /// 是否正在定位 - 对齐 Android fun isLocating(): Boolean
  bool isLocating();

  /// 停止定位 - 对齐 Android fun stopLocation()
  void stopLocation();
}
