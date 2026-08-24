import 'package:flutter/foundation.dart';

import '../../weather/models/weather_model.dart';
import '../models/location_snapshot.dart';

/// 海拔与指南针共用的页面状态。
@immutable
class OutdoorDashboardState {
  final LocationSnapshot? location;
  final DailyWeather? weather;
  final AirQuality? airQuality;
  final String cityName;
  final bool isLocationLoading;
  final bool isWeatherLoading;
  final bool needsLocationPermission;
  final double heading;
  final bool isHeadingUnavailable;
  final String? locationError;

  const OutdoorDashboardState({
    this.location,
    this.weather,
    this.airQuality,
    this.cityName = '北京',
    this.isLocationLoading = false,
    this.isWeatherLoading = false,
    this.needsLocationPermission = false,
    this.heading = 0,
    this.isHeadingUnavailable = false,
    this.locationError,
  });

  OutdoorDashboardState copyWith({
    LocationSnapshot? location,
    DailyWeather? weather,
    AirQuality? airQuality,
    String? cityName,
    bool? isLocationLoading,
    bool? isWeatherLoading,
    bool? needsLocationPermission,
    double? heading,
    bool? isHeadingUnavailable,
    String? locationError,
    bool clearLocationError = false,
  }) {
    return OutdoorDashboardState(
      location: location ?? this.location,
      weather: weather ?? this.weather,
      airQuality: airQuality ?? this.airQuality,
      cityName: cityName ?? this.cityName,
      isLocationLoading: isLocationLoading ?? this.isLocationLoading,
      isWeatherLoading: isWeatherLoading ?? this.isWeatherLoading,
      needsLocationPermission:
          needsLocationPermission ?? this.needsLocationPermission,
      heading: heading ?? this.heading,
      isHeadingUnavailable: isHeadingUnavailable ?? this.isHeadingUnavailable,
      locationError:
          clearLocationError ? null : (locationError ?? this.locationError),
    );
  }
}
