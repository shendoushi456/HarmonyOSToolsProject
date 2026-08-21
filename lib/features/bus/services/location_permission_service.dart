import 'package:flutter/services.dart';

/// 当前安装 HAP 的签名身份，用于核对百度鸿蒙 AK 的应用配置。
class RuntimeAppIdentity {
  const RuntimeAppIdentity({
    required this.bundleName,
    required this.appId,
    required this.fingerprint,
    required this.appIdentifier,
  });

  final String? bundleName;
  final String? appId;
  final String? fingerprint;
  final String? appIdentifier;

  static String? _nonEmpty(Object? value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }

  factory RuntimeAppIdentity.fromMap(Map<Object?, Object?> map) {
    return RuntimeAppIdentity(
      bundleName: _nonEmpty(map['bundleName']),
      appId: _nonEmpty(map['appId']),
      fingerprint: _nonEmpty(map['fingerprint']),
      appIdentifier: _nonEmpty(map['appIdentifier']),
    );
  }
}

/// OpenHarmony foreground-location permission bridge.
class LocationPermissionService {
  const LocationPermissionService();

  static const MethodChannel _channel =
      MethodChannel('bus/location_permission');

  Future<bool> hasLocationPermission() =>
      _invokePermissionMethod('checkLocationPermission');

  Future<bool> requestLocationPermission() =>
      _invokePermissionMethod('requestLocationPermission');

  /// 获取当前安装 HAP 的完整运行时签名身份。
  Future<RuntimeAppIdentity?> getRuntimeIdentity() async {
    try {
      final identity = await _channel.invokeMapMethod<Object?, Object?>(
        'getRuntimeIdentity',
      );
      return identity == null ? null : RuntimeAppIdentity.fromMap(identity);
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  /// 获取设备从当前安装 HAP 签名解析出的运行时 AppID，用于排查百度鸿蒙 AK 505。
  Future<String?> getAppIdentifier() async {
    try {
      return (await getRuntimeIdentity())?.appIdentifier;
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  Future<bool> _invokePermissionMethod(String method) async {
    try {
      return await _channel.invokeMethod<bool>(method) ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}
