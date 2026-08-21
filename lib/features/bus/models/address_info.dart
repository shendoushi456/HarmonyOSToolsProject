// 地址信息数据模型 - 对齐 Android bus/repository/AddressRepository.kt
// 含 AddressInfo + AddressType + TransportMode + TransportModeConverter
import 'dart:convert';

/// 地址信息 - 对齐 Android AddressInfo data class
class AddressInfo {
  AddressInfo({
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.destinationName,
  });

  /// 目的地纬度
  final double destinationLatitude;

  /// 目的地经度
  final double destinationLongitude;

  /// 目的地名称
  final String destinationName;

  /// 从 JSON Map 构造（对齐 Android Gson.fromJson）
  factory AddressInfo.fromJson(Map<String, dynamic> json) {
    return AddressInfo(
      destinationLatitude: (json['destinationLatitude'] as num?)?.toDouble() ?? 0.0,
      destinationLongitude: (json['destinationLongitude'] as num?)?.toDouble() ?? 0.0,
      destinationName: json['destinationName'] as String? ?? '',
    );
  }

  /// 序列化为 JSON Map（对齐 Android Gson.toJson）
  Map<String, dynamic> toJson() {
    return {
      'destinationLatitude': destinationLatitude,
      'destinationLongitude': destinationLongitude,
      'destinationName': destinationName,
    };
  }

  /// 从 JSON 字符串构造（对齐 Android AddressRepository.getAddress 的 gson.fromJson）
  factory AddressInfo.fromJsonString(String json) {
    if (json.isEmpty) {
      throw const FormatException('空 JSON 字符串');
    }
    return AddressInfo.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  /// 序列化为 JSON 字符串（对齐 Android AddressRepository.saveAddress 的 gson.toJson）
  String toJsonString() => jsonEncode(toJson());

  @override
  String toString() =>
      'AddressInfo(lat=$destinationLatitude, lng=$destinationLongitude, name=$destinationName)';
}

/// 地址类型枚举 - 对齐 Android AddressType
enum AddressType {
  /// 公司
  company,
  /// 家庭
  home,
  /// 学校
  school,
}

/// 通勤方式枚举（持久化值）- 对齐 Android bus/repository/TransportMode
/// 注意：与 bus/MapRouteActivity.kt 中的 TransportMode sealed class 不同
/// 此处用于持久化默认交通方式，sealed class 用于 UI 传参
enum TransportMode {
  /// 公共交通
  publicTransport,
  /// 骑行
  cycling,
  /// 步行
  walking,
  /// 驾车
  driving;

  /// 持久化用 name（对齐 Android TransportMode.name）
  String get persistentName => name;

  /// 从持久化字符串解析（对齐 Android TransportMode.valueOf，异常时返回默认 PUBLIC_TRANSPORT）
  static TransportMode fromPersistentName(String? name) {
    if (name == null || name.isEmpty) return TransportMode.publicTransport;
    for (final mode in TransportMode.values) {
      if (mode.name == name) return mode;
    }
    return TransportMode.publicTransport;
  }
}

/// TransportMode 与 UI Int 值的转换工具 - 对齐 Android TransportModeConverter
/// TransportMode: publicTransport(0), cycling(1), walking(2), driving(3)
/// UI Int: 公共交通(0), 驾车(1), 骑行(2), 步行(3)
class TransportModeConverter {
  TransportModeConverter._();

  /// 将 TransportMode 枚举转换为 UI 中使用的 Int 值
  static int toUiInt(TransportMode mode) {
    switch (mode) {
      case TransportMode.publicTransport:
        return 0;
      case TransportMode.driving:
        return 1;
      case TransportMode.cycling:
        return 2;
      case TransportMode.walking:
        return 3;
    }
  }

  /// 将 UI 中使用的 Int 值转换为 TransportMode 枚举
  static TransportMode fromUiInt(int uiInt) {
    switch (uiInt) {
      case 0:
        return TransportMode.publicTransport;
      case 1:
        return TransportMode.driving;
      case 2:
        return TransportMode.cycling;
      case 3:
        return TransportMode.walking;
      default:
        return TransportMode.publicTransport;
    }
  }
}
