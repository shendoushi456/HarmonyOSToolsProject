// 通用定位 ViewModel - 对齐 Android bus/viewmodel/CommonLocationViewModel.kt
// 管理定位权限和当前位置信息
// 鸿蒙端差异：Android 用 AndroidViewModel + StateFlow，Flutter 用 Riverpod Notifier + State
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';
import '../models/common_location_ui_state.dart';
import '../models/location_data.dart';
import '../repositories/baidu_location_repository.dart';

/// 通用定位 ViewModel - 对齐 Android CommonLocationViewModel
class CommonLocationViewModel extends Notifier<CommonLocationUiState> {
  /// 定位 Repository（对齐 Android locationRepository = BaiduLocationRepository(application)）
  late final BaiduLocationRepository _locationRepository;

  @override
  CommonLocationUiState build() {
    _locationRepository = BaiduLocationRepository();
    return const CommonLocationUiState();
  }

  /// 检查定位权限 - 对齐 Android checkLocationPermission
  /// 鸿蒙端通过 ArkTS 权限桥接检查。
  Future<void> checkLocationPermission() async {
    final hasPermission =
        await _locationRepository.hasLocationPermissionAsync();
    state = state.copyWith(hasLocationPermission: hasPermission);
  }

  /// 获取当前位置 - 对齐 Android getCurrentLocation
  Future<void> getCurrentLocation() async {
    final hasPermission =
        await _locationRepository.hasLocationPermissionAsync();
    state = state.copyWith(hasLocationPermission: hasPermission);
    if (!hasPermission) return;

    state = state.copyWith(isLocating: true);

    try {
      final LocationData? locationData =
          await _locationRepository.getCurrentLocation();
      if (locationData != null) {
        state = state.copyWith(
          currentLocation:
              BMFCoordinate(locationData.latitude, locationData.longitude),
          currentCity: locationData.city,
          currentAddress: locationData.address,
          latitude: locationData.latitude,
          longitude: locationData.longitude,
          district: locationData.district,
          isLocating: false,
          errorMessage: '',
        );
      } else {
        state = state.copyWith(
          isLocating: false,
          errorMessage: '获取位置失败',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLocating: false,
        errorMessage: '定位异常: $e',
      );
    }
  }

  /// 重新定位 - 对齐 Android requestLocation
  void requestLocation() {
    _locationRepository.requestLocation();
    getCurrentLocation();
  }

  /// 清除错误信息 - 对齐 Android clearError
  void clearError() {
    state = state.copyWith(errorMessage: '');
  }

  /// 清除缓存 - 对齐 Android clearCache
  void clearCache() {
    _locationRepository.clearCache();
  }

  /// 停止定位 - 对齐 Android onCleared 中 locationRepository.stopLocation()
  void stopLocation() {
    _locationRepository.stopLocation();
  }
}

/// 通用定位 ViewModel Provider
final commonLocationViewModelProvider =
    NotifierProvider<CommonLocationViewModel, CommonLocationUiState>(
  CommonLocationViewModel.new,
);
