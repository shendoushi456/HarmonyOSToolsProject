import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/countdown_models.dart';

/// 倒数日数据访问层 - 对齐 Android CountdownRepository（Room 软删除）。
class CountdownRepository {
  static const _storageKey = 'toolbox_countdown_v1';

  Future<List<CountdownItem>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List;
      // 对齐 DAO：isActive=1 按 isPinned DESC, createdAt ASC 排序。
      final items = list
          .map((value) => CountdownItem.fromJson(value as Map<String, dynamic>))
          .where((item) => item.isActive)
          .toList()
        ..sort((a, b) {
          if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
          return a.createdAt.compareTo(b.createdAt);
        });
      return items;
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<CountdownItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(items.map((e) => e.toJson()).toList()));
  }
}
