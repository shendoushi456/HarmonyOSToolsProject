import 'dart:convert';
import '../../../core/storage/prefs_storage.dart';
import '../models/long_trip_models.dart';

class LongTripRepository {
  static const _key = 'long_trip_plans';
  static const _commonCitiesKey = 'long_trip_common_cities_v1';
  static const _maxCommonCities = 20;

  List<LongTripPlan> loadAll() {
    final raw = PrefsStorage.getString(_key);
    // 空数据必须返回可增长列表：saveDraft 会直接对结果调用 add，
    // 若返回 const []（不可变），首次保存会抛
    // "Unsupported operation: Cannot add to an unmodifiable list"。
    if (raw == null) return <LongTripPlan>[];
    try {
      return (jsonDecode(raw) as List)
          .whereType<Map<String, dynamic>>()
          .map(LongTripPlan.fromJson)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      return <LongTripPlan>[];
    }
  }

  /// OpenHarmony 偏好存储通过平台通道异步落盘；通道失败必须转换为失败结果，
  /// 不能把异常抛到 UI 回调后静默中断。
  Future<bool> saveAll(List<LongTripPlan> plans) async {
    try {
      return await PrefsStorage.setString(
          _key, jsonEncode(plans.map((item) => item.toJson()).toList()));
    } catch (_) {
      return false;
    }
  }

  /// 写入后从平台刷新缓存再读取，确保不是只命中当前进程内的旧缓存。
  Future<bool> containsPersistedPlan(String id) async {
    try {
      await PrefsStorage.reload();
      return loadAll().any((plan) => plan.id == id);
    } catch (_) {
      return false;
    }
  }

  /// 读取独立的常用沿途城市，不影响天气首页的 city 配置。
  List<LongTripCitySelection> loadCommonCities() {
    final raw = PrefsStorage.getString(_commonCitiesKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      return (jsonDecode(raw) as List)
          .whereType<Map<String, dynamic>>()
          .map(LongTripCitySelection.fromJson)
          .where((city) => city.cityName.trim().isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  /// 以天气 locationId、目录 ID、城市名的顺序去重，最多保留 20 个最近使用城市。
  Future<bool> saveCommonCities(List<LongTripCitySelection> cities) async {
    try {
      final payload = jsonEncode(cities.map((city) => city.toJson()).toList());
      final saved = await PrefsStorage.setString(_commonCitiesKey, payload);
      if (!saved) return false;
      await PrefsStorage.reload();
      return PrefsStorage.getString(_commonCitiesKey) == payload;
    } catch (_) {
      return false;
    }
  }

  Future<bool> addCommonCities(Iterable<LongTripPoint> points) async {
    final existing = loadCommonCities();
    final merged = <LongTripCitySelection>[];
    final seen = <String>{};
    void add(LongTripCitySelection city) {
      final identity = city.locationId.trim().isNotEmpty
          ? 'id:${city.locationId}'
          : city.sourceId.trim().isNotEmpty
              ? 'source:${city.sourceId}'
              : 'name:${city.cityName.trim()}';
      if (city.cityName.trim().isEmpty || !seen.add(identity)) return;
      merged.add(city);
    }

    for (final point in points) {
      add(LongTripCitySelection(
        locationId: point.locationId,
        sourceId: point.sourceId,
        provinceName: point.provinceName,
        adminCityName: point.adminCityName,
        cityName: point.cityName,
        latitude: point.latitude,
        longitude: point.longitude,
      ));
    }
    for (final city in existing) {
      add(city);
    }
    return saveCommonCities(merged.take(_maxCommonCities).toList());
  }
}
