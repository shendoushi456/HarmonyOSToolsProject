import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/medication_models.dart';

class MedicationReminderRepository {
  static const _storageKey = 'toolbox_medication_reminder_v1';

  Future<MedicationReminderData> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null || raw.isEmpty) return MedicationReminderData.initial();
      return MedicationReminderData.fromJson(
          jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return MedicationReminderData.initial();
    }
  }

  Future<void> save(MedicationReminderData value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(value.toJson()));
  }
}

class MedicationReminderData {
  final List<Medication> medications;
  final List<MedicationRecord> records;

  const MedicationReminderData(
      {required this.medications, required this.records});

  factory MedicationReminderData.initial() => const MedicationReminderData(
        medications: [],
        records: [],
      );

  Map<String, dynamic> toJson() => {
        'medications': medications.map((item) => item.toJson()).toList(),
        'records': records.map((item) => item.toJson()).toList(),
      };

  factory MedicationReminderData.fromJson(Map<String, dynamic> json) {
    List<T> list<T>(String key, T Function(Map<String, dynamic>) factory) {
      final raw = json[key] as List? ?? const [];
      return raw
          .whereType<Map>()
          .map((item) => factory(Map<String, dynamic>.from(item)))
          .toList();
    }

    return MedicationReminderData(
      medications: list('medications', Medication.fromJson),
      records: list('records', MedicationRecord.fromJson),
    );
  }
}
