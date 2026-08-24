import 'package:flutter/services.dart';

import '../models/location_snapshot.dart';

/// 鸿蒙定位平台通道。
///
/// 仅负责平台调用与 DTO 转换；权限、加载状态和页面展示由上层负责。
class LocationPlatformService {
  const LocationPlatformService();

  static const MethodChannel _channel =
      MethodChannel('com.p.a_b/toolbox_location');

  /// 不触发授权弹窗地获取当前位置，用于页面首次展示。
  Future<LocationSnapshot> getCurrentLocation() => _read('getCurrentLocation');

  /// 由用户主动点击“允许”后调用，原生侧会申请鸿蒙定位权限。
  Future<LocationSnapshot> requestCurrentLocation() =>
      _read('requestCurrentLocation');

  Future<LocationSnapshot> _read(String method) async {
    final data = await _channel.invokeMapMethod<String, dynamic>(method);
    if (data == null) {
      throw PlatformException(
        code: 'location_empty',
        message: '定位服务没有返回位置数据',
      );
    }

    final latitude = _number(data['latitude']);
    final longitude = _number(data['longitude']);
    if (latitude == null || longitude == null) {
      throw PlatformException(
        code: 'location_invalid',
        message: '定位服务返回了无效坐标',
      );
    }

    return LocationSnapshot(
      latitude: latitude,
      longitude: longitude,
      altitude: _number(data['altitude']),
      address: (data['address'] as String?)?.trim() ?? '',
    );
  }

  double? _number(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}
