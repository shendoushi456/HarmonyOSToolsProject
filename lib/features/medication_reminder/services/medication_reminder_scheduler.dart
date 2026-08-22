import 'package:flutter/services.dart';

import '../models/medication_models.dart';

/// 鸿蒙提醒系统的边界。排期判断仍归 ViewModel 所有，原生层只负责发布通知。
abstract class MedicationReminderScheduler {
  Future<void> schedule(Medication medication);
  Future<void> cancel(int medicationId);
  Future<void> restore(Iterable<Medication> medications);
}

class OhosMedicationReminderScheduler implements MedicationReminderScheduler {
  const OhosMedicationReminderScheduler();

  static const _channel = MethodChannel('com.p.a_b/toolbox_reminder');

  @override
  Future<void> schedule(Medication medication) => _channel.invokeMethod<void>(
        'scheduleMedication',
        {
          'id': medication.id,
          'name': medication.name,
          'type': medication.type,
          'scheduleType': medication.scheduleType,
          'times': medication.times.map((time) => time.time).toList(),
          'startDate': medication.startDate.millisecondsSinceEpoch,
          'endDate': medication.endDate?.millisecondsSinceEpoch,
          'useDays': medication.useDays,
          'pauseDays': medication.pauseDays,
          'selectedWeekdays': medication.selectedWeekdays,
          'intervalDays': medication.intervalDays,
          'isActive': medication.isActive,
        },
      );

  @override
  Future<void> cancel(int medicationId) =>
      _channel.invokeMethod<void>('cancelMedication', {'id': medicationId});

  @override
  Future<void> restore(Iterable<Medication> medications) async {
    for (final medication in medications) {
      if (medication.isActive && medication.scheduleType != '按需') {
        await schedule(medication);
      }
    }
  }
}
