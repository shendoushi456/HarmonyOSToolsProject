// 通用定位 UI 状态 - 对齐 Android bus/viewmodel/CommonLocationViewModel.kt 中的 CommonLocationUiState
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';

/// 通用定位 UI 状态 - 对齐 Android CommonLocationUiState data class
class CommonLocationUiState {
  const CommonLocationUiState({
    this.hasLocationPermission = false,
    this.isLocating = false,
    this.currentLocation,
    this.currentCity = '定位中',
    this.currentAddress = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.district = '',
    this.errorMessage = '',
  });

  /// 是否已授予定位权限
  final bool hasLocationPermission;

  /// 是否正在定位
  final bool isLocating;

  /// 当前位置（百度 LatLng，对齐 Android currentLocation: LatLng?）
  final BMFCoordinate? currentLocation;

  /// 当前城市（默认"定位中"，对齐 Android currentCity: String = "定位中"）
  final String currentCity;

  /// 当前地址
  final String currentAddress;

  /// 纬度
  final double latitude;

  /// 经度
  final double longitude;

  /// 区县
  final String district;

  /// 错误信息
  final String errorMessage;

  /// 不可变拷贝（对齐 Android data class copy）
  CommonLocationUiState copyWith({
    bool? hasLocationPermission,
    bool? isLocating,
    BMFCoordinate? currentLocation,
    String? currentCity,
    String? currentAddress,
    double? latitude,
    double? longitude,
    String? district,
    String? errorMessage,
  }) {
    return CommonLocationUiState(
      hasLocationPermission: hasLocationPermission ?? this.hasLocationPermission,
      isLocating: isLocating ?? this.isLocating,
      currentLocation: currentLocation ?? this.currentLocation,
      currentCity: currentCity ?? this.currentCity,
      currentAddress: currentAddress ?? this.currentAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      district: district ?? this.district,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
