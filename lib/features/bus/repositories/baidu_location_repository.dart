// 百度定位 Repository 实现 - 对齐 Android bus/repository/BaiduLocationRepository.kt
// 轻量级数据访问层，依赖 BaiduLocationManager 单例进行实际的定位操作
import '../models/location_data.dart';
import '../services/location_permission_service.dart';
import '../utils/baidu_location_manager.dart';
import 'location_repository.dart';

/// 百度定位 Repository 实现 - 对齐 Android BaiduLocationRepository
/// 轻量级数据访问层，依赖 BaiduLocationManager 单例进行实际的定位操作
class BaiduLocationRepository implements LocationRepository {
  BaiduLocationRepository({LocationPermissionService? permissionService})
      : _permissionService =
            permissionService ?? const LocationPermissionService();

  final LocationPermissionService _permissionService;

  /// 定位管理器单例（对齐 Android BaiduLocationManager.getInstance(context)）
  BaiduLocationManager get _locationManager => BaiduLocationManager.instance;

  @override
  bool hasLocationPermission() {
    // 鸿蒙权限检查是异步的，调用方应使用 hasLocationPermissionAsync。
    return false;
  }

  /// 通过 ArkTS 权限桥接检查鸿蒙定位权限。
  Future<bool> hasLocationPermissionAsync() =>
      _permissionService.hasLocationPermission();

  /// 请求鸿蒙前台定位权限。
  Future<bool> requestLocationPermission() =>
      _permissionService.requestLocationPermission();

  @override
  Future<LocationData?> getCurrentLocation() async {
    return _locationManager.getCurrentLocation();
  }

  @override
  bool isLocating() {
    return false;
  }

  @override
  void stopLocation() {
    _locationManager.stopLocation();
  }

  /// 重新定位 - 对齐 Android requestLocation
  void requestLocation() {
    _locationManager.requestLocation();
  }

  /// 清除缓存 - 对齐 Android clearCache
  void clearCache() {
    _locationManager.clearCache();
  }

  /// 释放资源 - 对齐 Android destroy
  void destroy() {
    // 不需要销毁单例，只是清理本地引用
  }
}
