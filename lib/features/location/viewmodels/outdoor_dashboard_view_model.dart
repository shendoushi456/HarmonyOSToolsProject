import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../weather/repositories/city_repository.dart';
import '../../weather/repositories/weather_repository.dart';
import '../../weather/models/weather_model.dart';
import '../repositories/location_repository.dart';
import '../services/heading_platform_service.dart';
import 'outdoor_dashboard_state.dart';

/// 海拔/指南针的共享 ViewModel。
///
/// 对齐 Android 中两个 Fragment 各自收集 LocationViewModel 与 TravelViewModel，
/// 但集中成一个可复用状态源，避免重复发起定位和天气请求。
class OutdoorDashboardViewModel extends Notifier<OutdoorDashboardState> {
  final LocationRepository _locationRepository = LocationRepository();
  final CityRepository _cityRepository = CityRepository();
  final WeatherRepository _weatherRepository = WeatherRepository();
  final HeadingPlatformService _headingService = const HeadingPlatformService();
  StreamSubscription<double>? _headingSubscription;
  Future<void> _headingTransition = Future<void>.value();
  bool _isHeadingEnabled = false;

  @override
  OutdoorDashboardState build() {
    ref.onDispose(() {
      _isHeadingEnabled = false;
      _headingTransition = _headingTransition.then((_) async {
        await _headingSubscription?.cancel();
        _headingSubscription = null;
      });
    });
    Future<void>.microtask(load);
    return const OutdoorDashboardState();
  }

  /// 指南针在应用前台时启用方向传感器；底部 Tab 切换不会停止它。
  ///
  /// 操作串行化，确保旧订阅的 stopHeading 完成后才建立新订阅，避免
  /// 快速前后台切换时旧订阅意外停止新的原生传感器监听。
  void setHeadingEnabled(bool enabled) {
    if (_isHeadingEnabled == enabled) return;
    _isHeadingEnabled = enabled;
    _headingTransition = _headingTransition.then((_) async {
      await _headingSubscription?.cancel();
      _headingSubscription = null;
      if (!_isHeadingEnabled) return;
      _headingSubscription = _headingService.headingStream.listen(
        (heading) => state = state.copyWith(heading: heading),
        onError: (_) => state = state.copyWith(isHeadingUnavailable: true),
      );
    });
  }

  Future<void> load() async {
    await Future.wait(
        [_loadWeather(), _loadLocation(requestPermission: false)]);
  }

  /// 用户明确点击授权后调用，避免首次进入页面即弹出系统定位权限框。
  Future<void> requestLocation() => _loadLocation(requestPermission: true);

  Future<void> _loadLocation({required bool requestPermission}) async {
    state = state.copyWith(
      isLocationLoading: true,
      needsLocationPermission: false,
      clearLocationError: true,
    );
    try {
      final location = requestPermission
          ? await _locationRepository.requestAndLocate()
          : await _locationRepository.locate();
      state = state.copyWith(
        location: location,
        isLocationLoading: false,
        needsLocationPermission: false,
        clearLocationError: true,
      );
    } on PlatformException catch (error) {
      state = state.copyWith(
        isLocationLoading: false,
        needsLocationPermission: error.code == 'location_permission_denied',
        locationError: error.message ?? '暂时无法获取当前位置',
      );
    } catch (_) {
      state = state.copyWith(
        isLocationLoading: false,
        locationError: '暂时无法获取当前位置',
      );
    }
  }

  Future<void> _loadWeather() async {
    state = state.copyWith(isWeatherLoading: true);
    try {
      final cities = await _cityRepository.loadCities();
      final city =
          cities.isEmpty ? _cityRepository.defaultCity() : cities.first;
      final cityId = await _weatherRepository.resolveCityId(city.cityName);
      final results = await Future.wait([
        _weatherRepository.loadDailyWeather(cityId),
        _weatherRepository.loadAirQuality(cityId),
      ]);
      final weather = results[0] as WeatherInfo;
      state = state.copyWith(
        cityName: city.cityName,
        weather: weather.daily.isEmpty ? null : weather.daily.first,
        airQuality: results[1] as AirQuality?,
        isWeatherLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isWeatherLoading: false);
    }
  }
}

final outdoorDashboardViewModelProvider =
    NotifierProvider<OutdoorDashboardViewModel, OutdoorDashboardState>(
  OutdoorDashboardViewModel.new,
);
