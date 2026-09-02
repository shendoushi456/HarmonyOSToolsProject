import 'dart:convert';
import '../../../core/storage/prefs_storage.dart';
import '../models/agriculture_models.dart';

class CropRecordRepository {
  static const _key = 'agriculture_crop_records';

  List<CropRecord> loadAll() {
    final raw = PrefsStorage.getString(_key);
    if (raw == null) return const [];
    try {
      final value = jsonDecode(raw) as List;
      return value
          .whereType<Map<String, dynamic>>()
          .map(CropRecord.fromJson)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveAll(List<CropRecord> records) => PrefsStorage.setString(
      _key, jsonEncode(records.map((item) => item.toJson()).toList()));
}
