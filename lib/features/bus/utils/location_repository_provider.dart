// 定位 Repository 提供器 - 对齐 Android bus/di/LocationRepositoryProvider.kt
// 简单的依赖注入实现，提供 LocationRepository 单例
//
// 鸿蒙端差异：
// - Android: 通过 Context 获取 applicationContext 创建 BaiduLocationRepository
// - 鸿蒙端: Flutter 无需 Context，BaiduLocationRepository 不依赖 Context
import '../repositories/baidu_location_repository.dart';
import '../repositories/location_repository.dart';

/// 定位 Repository 提供器 - 对齐 Android LocationRepositoryProvider（object 单例）
class LocationRepositoryProvider {
  // 私有构造（对齐 Android object，无构造）
  LocationRepositoryProvider._();

  static final LocationRepositoryProvider _instance = LocationRepositoryProvider._();
  static LocationRepositoryProvider get instance => _instance;

  /// 单例 LocationRepository 实例（对齐 Android @Volatile locationRepository）
  LocationRepository? _locationRepository;

  /// 获取 LocationRepository 实例 - 对齐 Android getLocationRepository(context)
  /// 鸿蒙端差异：去掉 Context 参数（Flutter 不需要）
  LocationRepository getLocationRepository() {
    final existing = _locationRepository;
    if (existing != null) {
      return existing;
    }
    // 双重检查锁定模式 - Dart 单线程模型下同步访问足够，但保留对齐语义
    final newInstance = BaiduLocationRepository();
    _locationRepository = newInstance;
    return newInstance;
  }

  /// 清除实例（用于测试或重置）- 对齐 Android clearInstance
  void clearInstance() {
    final repo = _locationRepository;
    if (repo is BaiduLocationRepository) {
      repo.destroy();
    }
    _locationRepository = null;
  }
}
