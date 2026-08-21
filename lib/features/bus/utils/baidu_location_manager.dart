// 百度定位管理单例 - 对齐 Android bus/utils/BaiduLocationManager.kt
// 鸿蒙端差异：
// - Android: LocationClient + BDAbstractLocationListener + BDLocation
// - 鸿蒙 Flutter: LocationFlutterPlugin + BaiduLocationOhosOption + BaiduLocation + 回调
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bmflocation/flutter_bmflocation.dart';
import '../models/location_data.dart';
import '../services/location_permission_service.dart';
import 'baidu_sdk_initializer.dart';
import 'baidu_location_error_mapper.dart';

/// 定位结果回调接口 - 对齐 Android BaiduLocationManager.LocationCallback
typedef LocationCallback = void Function(
    LocationData? locationData, Exception? error);

/// 定位失败时携带 SDK 的可读错误信息，避免上层退化为笼统的“定位失败”。
class LocationException implements Exception {
  const LocationException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// 百度定位管理单例类 - 对齐 Android BaiduLocationManager
/// 负责百度定位 SDK 的初始化、生命周期管理、定位状态控制
class BaiduLocationManager {
  BaiduLocationManager._internal() {
    _initLocationClient();
  }

  static final BaiduLocationManager _instance =
      BaiduLocationManager._internal();
  static BaiduLocationManager get instance => _instance;

  /// 缓存过期时间（对齐 Android CACHE_EXPIRE_TIME = 10 * 60 * 1000L）
  static const Duration _cacheExpireTime = Duration(minutes: 10);

  /// 定位插件（对齐 Android LocationClient）
  LocationFlutterPlugin get _locationPlugin =>
      BaiduSdkInitializer.locationPlugin;

  // 定位状态管理（对齐 Android isLocationInProgress）
  bool _isLocationInProgress = false;

  // 缓存管理（对齐 Android cachedLocationData / cacheTime）
  LocationData? _cachedLocationData;
  DateTime? _cacheTime;

  // 多回调支持（对齐 Android locationCallbacks）
  final Set<LocationCallback> _locationCallbacks = {};

  // 定位结果流控制器（用于 Future 化的回调）
  Completer<LocationData?>? _currentCompleter;

  /// 当前安装 HAP 签名中的 appId 和 appIdentifier，用于排查百度 505。
  String? _runtimeAppId;
  String? _runtimeAppIdentifier;

  /// 初始化百度定位客户端 - 对齐 Android initLocationClient
  void _initLocationClient() {
    // 鸿蒙端无需显式 initLocationClient，LocationFlutterPlugin 已封装
    // 定位参数在 requestLocation 时通过 prepareLoc 设置
  }

  /// 获取当前位置（支持缓存）- 对齐 Android suspend fun getCurrentLocation(): Result<LocationData>
  Future<LocationData?> getCurrentLocation() async {
    // 检查缓存是否有效
    if (_cachedLocationData != null && _cacheTime != null) {
      if (DateTime.now().difference(_cacheTime!) < _cacheExpireTime) {
        return _cachedLocationData;
      }
    }

    // 必须等待隐私协议和 AK 完成设置。此前初始化是 fire-and-forget，首次打开
    // 路线页会与 SDK 初始化竞争，从而随机得到“定位失败”。
    final sdkReady = await BaiduSdkInitializer.ensureInitialized();
    if (!sdkReady) {
      throw StateError('百度定位 SDK 初始化失败');
    }

    final runtimeIdentity =
        await const LocationPermissionService().getRuntimeIdentity();
    _runtimeAppId ??= runtimeIdentity?.appId;
    _runtimeAppIdentifier ??= runtimeIdentity?.appIdentifier;
    debugPrint(
      '[BaiduLocation] runtime identity before location: '
      'bundleName=${runtimeIdentity?.bundleName ?? '未获取到'}, '
      'appId=${runtimeIdentity?.appId ?? '未获取到'}, '
      'appIdentifier=${runtimeIdentity?.appIdentifier ?? '未获取到'}, '
      'fingerprint=${runtimeIdentity?.fingerprint ?? '未获取到'}',
    );

    // 多个调用同时等待 SDK 初始化后会在这里串行复用同一轮定位。
    if (_isLocationInProgress) {
      if (_cachedLocationData != null) return _cachedLocationData;
      if (_currentCompleter != null) return _currentCompleter!.future;
    }

    // 检查权限（鸿蒙端权限检查由调用方处理）
    _isLocationInProgress = true;

    _currentCompleter = Completer<LocationData?>();

    // 设置定位结果回调
    _locationPlugin.seriesLocationCallback(callback: _onLocationResult);

    // 配置鸿蒙端定位参数（对齐 Android LocationClientOption）
    final ohosOption = BaiduLocationOhosOption(
      coordType: BMFLocationCoordType.bd09ll, // bd09ll 坐标系
      isNeedAddress: true, // 需要地址信息
      isNeedLocationDescribe: true, // 需要地址描述
      isNeedLocationPoiList: true, // 需要 POI 结果
      locationMode: BMFLocationMode.hightAccuracy, // 高精度模式
      scanspan: 3000, // 定位间隔 3s（对齐 Android setScanSpan(3000)）
    );

    // 设置定位参数（对齐 Android LocationClientOption + setLocOption）
    // 关键：prepareLoc 仅设置配置，不启动定位
    final prepared =
        await _locationPlugin.prepareLoc({}, {}, ohosOption.getMap());
    if (!prepared) {
      _isLocationInProgress = false;
      throw StateError('百度定位参数设置失败');
    }

    // 启动定位（对齐 Android client.start()）
    // 关键：必须调用 startLocation() 才能真正开始定位，否则回调永不触发
    final started = await _locationPlugin.startLocation();
    if (!started) {
      _isLocationInProgress = false;
      throw StateError('百度定位服务启动失败');
    }

    // 添加超时保护（10 秒），避免权限拒绝或信号弱时 Future 永久挂起
    return _currentCompleter!.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        _isLocationInProgress = false;
        stopLocation();
        throw const LocationException('定位请求超时');
      },
    );
  }

  /// 定位结果回调 - 对齐 Android onReceiveLocation
  void _onLocationResult(BaiduLocation result) {
    _isLocationInProgress = false;

    // 处理定位结果（对齐 Android handleLocationResult）
    final locationData = _handleLocationResult(result);
    if (locationData != null) {
      // 更新缓存
      _cachedLocationData = locationData;
      _cacheTime = DateTime.now();

      // 完成当前 Future
      if (_currentCompleter != null && !_currentCompleter!.isCompleted) {
        _currentCompleter!.complete(locationData);
      }

      // 通知所有回调
      final callbacks = Set<LocationCallback>.from(_locationCallbacks);
      _locationCallbacks.clear();
      for (final callback in callbacks) {
        try {
          callback(locationData, null);
        } catch (e) {
          print('回调执行失败: $e');
        }
      }

      // 单次定位成功后停止定位（对齐 Android stopLocationInternal）
      stopLocation();
    } else {
      // 定位失败
      var message = BaiduLocationErrorMapper.messageFor(result);
      if (result.errorCode == 505) {
        final locationAk = BaiduSdkInitializer.harmonyLocationAkForDiagnostics;
        debugPrint(
          '[BaiduLocation] 505 diagnostic: '
          'appId=${_runtimeAppId ?? '未获取到'}, '
          'appIdentifier=${_runtimeAppIdentifier ?? '未获取到'}, '
          'locationAK=$locationAk',
        );
        // message = '$message\n运行时 appId：${_runtimeAppId ?? '未获取到'}'
        //     '\n运行时 appIdentifier：${_runtimeAppIdentifier ?? '未获取到'}'
        //     '\n百度定位 AK：$locationAk';
      }
      final error = LocationException(message);
      if (_currentCompleter != null && !_currentCompleter!.isCompleted) {
        _currentCompleter!.completeError(error);
      }
      _notifyLocationFailure(error);
      stopLocation();
    }
  }

  /// 处理定位结果 - 对齐 Android handleLocationResult
  LocationData? _handleLocationResult(BaiduLocation location) {
    // 鸿蒙端 BaiduLocation.locType != null 表示定位成功
    // 对齐 Android BDLocation.TypeGpsLocation/TypeNetWorkLocation/TypeOffLineLocation/TypeCacheLocation
    if (location.locType == null) return null;

    // 鸿蒙端成功状态码：61(GPS)/66(网络离线)/161(网络)/62(缓存)
    // 对齐 Android BDLocation.TypeGpsLocation(61)/TypeNetWorkLocation(161)/TypeOffLineLocation(66)/TypeCacheLocation(62)
    final locType = location.locType!;
    final successCodes = [61, 66, 161, 62];
    if (!successCodes.contains(locType)) return null;

    // 城市名去除"市"后缀，对齐 Android city?.removeSuffix("市") ?: "北京"
    String city = location.city ?? '北京';
    if (city.endsWith('市')) {
      city = city.substring(0, city.length - 1);
    }

    return LocationData(
      latitude: location.latitude ?? 0.0,
      longitude: location.longitude ?? 0.0,
      city: city,
      address: location.address ?? '',
      district: location.district ?? '',
    );
  }

  /// 通知定位失败 - 对齐 Android notifyLocationFailure
  void _notifyLocationFailure(Exception error) {
    final callbacks = Set<LocationCallback>.from(_locationCallbacks);
    _locationCallbacks.clear();
    for (final callback in callbacks) {
      try {
        callback(null, error);
      } catch (e) {
        print('错误回调执行失败: $e');
      }
    }
  }

  /// 重新请求定位 - 对齐 Android requestLocation
  /// 鸿蒙端 LocationFlutterPlugin 无 requestLocation 方法，用 startLocation 替代
  void requestLocation() {
    try {
      _locationPlugin.startLocation();
    } catch (e) {
      debugPrint('重新定位请求失败: $e');
    }
  }

  /// 停止定位 - 对齐 Android stopLocation
  void stopLocation() {
    try {
      _isLocationInProgress = false;
      _locationPlugin.stopLocation();
    } catch (e) {
      debugPrint('停止定位失败: $e');
    }
  }

  /// 清除缓存 - 对齐 Android clearCache
  void clearCache() {
    _cachedLocationData = null;
    _cacheTime = null;
  }

  /// 释放资源 - 对齐 Android destroy
  void destroy() {
    try {
      stopLocation();
      _locationCallbacks.clear();
      _cachedLocationData = null;
      _cacheTime = null;
    } catch (e) {
      debugPrint('释放定位资源失败: $e');
    }
  }
}
