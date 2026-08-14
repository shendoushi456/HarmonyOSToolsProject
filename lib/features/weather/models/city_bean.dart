// 城市领域模型 - 对应 Android CityBean.kt
// 用于本地存储和 UI 展示
import 'dart:convert';

class CityBean {
  final String areaCode;
  final String cityName;
  final bool isLocal;
  final String lonlat;

  const CityBean({
    required this.areaCode,
    required this.cityName,
    this.isLocal = false,
    this.lonlat = '',
  });

  /// 默认城市(北京) - 对齐 Android 默认值
  factory CityBean.defaultCity() {
    return const CityBean(areaCode: '1', cityName: '北京', isLocal: false);
  }

  Map<String, dynamic> toJson() => {
        'areaCode': areaCode,
        'cityName': cityName,
        'isLocal': isLocal,
        'lonlat': lonlat,
      };

  factory CityBean.fromJson(Map<String, dynamic> json) {
    return CityBean(
      areaCode: json['areaCode']?.toString() ?? '',
      cityName: json['cityName']?.toString() ?? '',
      isLocal: json['isLocal'] as bool? ?? false,
      lonlat: json['lonlat']?.toString() ?? '',
    );
  }

  CityBean copyWith({
    String? areaCode,
    String? cityName,
    bool? isLocal,
    String? lonlat,
  }) {
    return CityBean(
      areaCode: areaCode ?? this.areaCode,
      cityName: cityName ?? this.cityName,
      isLocal: isLocal ?? this.isLocal,
      lonlat: lonlat ?? this.lonlat,
    );
  }
}

/// 城市列表的 JSON 序列化/反序列化辅助函数
String cityListToJson(List<CityBean> cities) {
  return jsonEncode(cities.map((e) => e.toJson()).toList());
}

List<CityBean> cityListFromJson(String jsonString) {
  try {
    final list = jsonDecode(jsonString) as List;
    return list
        .map((e) => CityBean.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (_) {
    return [];
  }
}
