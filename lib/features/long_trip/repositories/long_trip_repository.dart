import 'dart:convert';
import '../../../core/storage/prefs_storage.dart';
import '../models/long_trip_models.dart';

class LongTripRepository {
  static const _key = 'long_trip_plans';

  List<LongTripPlan> loadAll() {
    final raw = PrefsStorage.getString(_key);
    if (raw == null) return const [];
    try {
      return (jsonDecode(raw) as List)
          .whereType<Map<String, dynamic>>()
          .map(LongTripPlan.fromJson)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      return const [];
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
}
