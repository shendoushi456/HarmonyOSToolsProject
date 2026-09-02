// 城市查询 DTO - 对应 Android WeatherCityBean.kt
import 'dart:convert';

/// 城市定位查询响应 DTO
class WeatherCityBeanDTO {
  final int code;
  final List<CityLocationDTO> location;

  const WeatherCityBeanDTO({
    required this.code,
    required this.location,
  });

  factory WeatherCityBeanDTO.fromJson(Map<String, dynamic> json) {
    return WeatherCityBeanDTO(
      code: json['code'] is int
          ? json['code'] as int
          : int.tryParse(json['code']?.toString() ?? '') ?? 0,
      location: (json['location'] as List?)
              ?.map((e) => CityLocationDTO.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  static WeatherCityBeanDTO? fromJsonString(String jsonString) {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return WeatherCityBeanDTO.fromJson(json);
    } catch (_) {
      return null;
    }
  }
}

/// 城市位置 DTO
class CityLocationDTO {
  final String name;
  final String id;
  final String fxLink;
  final String latitude;
  final String longitude;

  const CityLocationDTO({
    required this.name,
    required this.id,
    required this.fxLink,
    required this.latitude,
    required this.longitude,
  });

  factory CityLocationDTO.fromJson(Map<String, dynamic> json) {
    return CityLocationDTO(
      name: json['name']?.toString() ?? '',
      id: json['id']?.toString() ?? '',
      fxLink: json['fxLink']?.toString() ?? '',
      latitude: json['lat']?.toString() ?? '',
      longitude: json['lon']?.toString() ?? '',
    );
  }
}
