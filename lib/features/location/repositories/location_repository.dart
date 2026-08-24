import '../models/location_snapshot.dart';
import '../services/location_platform_service.dart';

/// 位置数据仓库，对齐 Android SimpleLocationHelper 的单次定位职责。
class LocationRepository {
  final LocationPlatformService _platformService;

  LocationRepository({LocationPlatformService? platformService})
      : _platformService = platformService ?? const LocationPlatformService();

  Future<LocationSnapshot> locate() => _platformService.getCurrentLocation();

  Future<LocationSnapshot> requestAndLocate() =>
      _platformService.requestCurrentLocation();
}
