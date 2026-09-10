// 天气网络服务 - 对齐 Android WeatherUtils + WeatherHttpManager
// 封装和风天气 4 个接口,返回 DTO
import 'dart:convert';

import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_config.dart';
import '../models/weather_dto.dart';
import '../models/hourly_weather.dart';
import '../models/weather_city_dto.dart';
import '../models/weather_warning.dart';

/// 天气异常 - 错误分类
class WeatherException implements Exception {
  final String message;
  final int? code;
  WeatherException(this.message, {this.code});

  @override
  String toString() => 'WeatherException($code): $message';
}

class WeatherService {
  final Dio _dio;

  WeatherService({Dio? dio}) : _dio = dio ?? DioClient.instance;

  /// 城市定位查询 - GET /geo/v2/city/lookup
  /// 返回第一个匹配城市的 location ID
  Future<CityLocationDTO> lookupCity(String cityName) async {
    try {
      final response = await _dio.get(
        ApiConfig.pathCityLookup,
        queryParameters: {'location': cityName},
      );
      final dto = WeatherCityBeanDTO.fromJsonString(response.toString());
      if (dto == null || dto.location.isEmpty) {
        throw WeatherException('未找到城市: $cityName');
      }
      return dto.location.first;
    } on DioException catch (e) {
      throw WeatherException(
        '城市查询失败: ${e.message}',
        code: e.response?.statusCode,
      );
    }
  }

  /// 15天预报 - GET /v7/weather/15d
  Future<WeatherBeanInfoDTO> getWeather15d(String cityId) async {
    return _getWeather(ApiConfig.pathWeather15d, cityId);
  }

  /// 7天预报 - GET /v7/weather/7d
  Future<WeatherBeanInfoDTO> getWeather7d(String cityId) async {
    return _getWeather(ApiConfig.pathWeather7d, cityId);
  }

  /// 实时天气 - GET /v7/weather/now
  Future<WeatherBeanInfoDTO> getWeatherNow(String cityId) async {
    return _getWeather(ApiConfig.pathWeatherNow, cityId);
  }

  /// 24 小时天气预报，对齐 Android getWeather24H。
  Future<List<HourlyWeather>> getWeather24h(String cityId) async {
    try {
      final response = await _dio.get(
        ApiConfig.pathWeather24h,
        queryParameters: {'location': cityId},
      );
      final payload = hourlyWeatherResponseFromJson(response.data);
      if (payload == null) {
        throw WeatherException('24小时天气数据解析失败');
      }
      if (payload.code != ApiConfig.codeSuccess) {
        throw WeatherException('24小时天气接口返回异常: ${payload.code}');
      }
      return payload.hourly;
    } on DioException catch (e) {
      throw WeatherException('24小时天气查询失败: ${e.message}',
          code: e.response?.statusCode);
    }
  }

  /// 生活指数(1天) - GET /v7/indices/1d
  /// 对齐 Android QxAirRepository.requestWeather("v7/indices/1d", type=3,6,16,5,13,15)
  Future<Map<String, dynamic>> getLifeIndices(String cityId) async {
    try {
      final response = await _dio.get(
        ApiConfig.pathIndices1d,
        queryParameters: {
          'location': cityId,
          'type': '3,6,16,5,13,15',
        },
      );
      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      if (data is String) {
        return jsonDecode(data) as Map<String, dynamic>;
      }
      throw WeatherException('生活指数数据解析失败');
    } on DioException catch (e) {
      throw WeatherException(
        '生活指数查询失败: ${e.message}',
        code: e.response?.statusCode,
      );
    }
  }

  /// 实时空气质量 - GET /v7/air/now
  Future<WeatherBeanInfoDTO> getAirNow(String cityId) async {
    try {
      final response = await _dio.get(
        ApiConfig.pathAirNow,
        queryParameters: {'location': cityId},
      );
      final dto = WeatherBeanInfoDTO.fromJsonString(response.toString());
      if (dto == null) {
        throw WeatherException('空气质量解析失败');
      }
      return dto;
    } on DioException catch (e) {
      throw WeatherException(
        '空气质量查询失败: ${e.message}',
        code: e.response?.statusCode,
      );
    }
  }

  /// 获取指定经纬度的生效预警，对齐 Android doWeatherAlertGet。
  Future<List<WeatherWarning>> getWeatherAlerts({
    required String latitude,
    required String longitude,
  }) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.pathWeatherAlert}/$latitude/$longitude',
      );
      return WeatherWarningResponse.fromJsonString(response.toString())
          .activeWarnings;
    } on DioException catch (e) {
      throw WeatherException('预警查询失败: ${e.message}',
          code: e.response?.statusCode);
    }
  }

  /// 通用天气查询(7d/15d)
  Future<WeatherBeanInfoDTO> _getWeather(String path, String cityId) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: {'location': cityId},
      );
      final dto = WeatherBeanInfoDTO.fromJsonString(response.toString());
      if (dto == null) {
        throw WeatherException('天气数据解析失败');
      }
      return dto;
    } on DioException catch (e) {
      throw WeatherException(
        '天气查询失败: ${e.message}',
        code: e.response?.statusCode,
      );
    }
  }
}
