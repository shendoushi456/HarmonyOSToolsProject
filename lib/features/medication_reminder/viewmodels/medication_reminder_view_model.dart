import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/medication_models.dart';
import '../repositories/medication_reminder_repository.dart';
import '../services/medication_reminder_scheduler.dart';
import 'medication_reminder_state.dart';

final medicationReminderRepositoryProvider =
    Provider<MedicationReminderRepository>(
  (ref) => MedicationReminderRepository(),
);

final medicationReminderSchedulerProvider =
    Provider<MedicationReminderScheduler>(
  (ref) => const OhosMedicationReminderScheduler(),
);

final medicationReminderViewModelProvider =
    NotifierProvider<MedicationReminderViewModel, MedicationReminderState>(
  MedicationReminderViewModel.new,
);

/// 还原 Android MedicationReminderFragment 的日期筛选、排期和记录规则。
class MedicationReminderViewModel extends Notifier<MedicationReminderState> {
  late final MedicationReminderRepository _repository;
  late final MedicationReminderScheduler _scheduler;

  @override
  MedicationReminderState build() {
    _repository = ref.read(medicationReminderRepositoryProvider);
    _scheduler = ref.read(medicationReminderSchedulerProvider);
    Future.microtask(_load);
    return MedicationReminderState.initial();
  }

  Future<void> _load() async {
    final data = await _repository.load();
    state = state.copyWith(
      loading: false,
      medications: data.medications,
      records: data.records,
    );
    await _scheduler.restore(data.medications);
  }

  void selectDate(DateTime date) =>
      state = state.copyWith(selectedDate: dateOnly(date));

  List<Medication> get asNeededMedications => state.medications
      .where((item) => item.scheduleType == '按需' && item.isActive)
      .toList();

  List<MedicationRecord> get selectedRecords => state.records
      .where((item) => dateKey(item.date) == dateKey(state.selectedDate))
      .toList()
    ..sort((left, right) => left.scheduledTime.compareTo(right.scheduledTime));

  List<MedicationScheduleEntry> get scheduledEntries {
    final recorded = <String>{
      for (final item in selectedRecords)
        '${item.medicationId}:${item.scheduledTime}',
    };
    final result = <MedicationScheduleEntry>[];
    for (final medication in state.medications) {
      if (!medication.isActive || medication.scheduleType == '按需') continue;
      if (!takesOn(medication, state.selectedDate)) continue;
      for (final time in medication.times) {
        if (!recorded.contains('${medication.id}:${time.time}')) {
          result
              .add(MedicationScheduleEntry(medication: medication, time: time));
        }
      }
    }
    result.sort((left, right) => left.time.time.compareTo(right.time.time));
    return result;
  }

  bool get hasScheduledMedication => state.medications.any(
        (item) =>
            item.isActive &&
            item.scheduleType != '按需' &&
            takesOn(item, state.selectedDate),
      );

  bool isAsNeededRecorded(Medication medication) => selectedRecords.any(
        (item) =>
            item.medicationId == medication.id && item.scheduledTime == '按需服用',
      );

  Future<void> saveMedication({
    Medication? original,
    required String name,
    required String type,
    required String scheduleType,
    required List<MedicationTime> times,
    required DateTime startDate,
    DateTime? endDate,
    String remarks = '',
    int useDays = 0,
    int pauseDays = 0,
    List<int> selectedWeekdays = const [],
    int intervalDays = 0,
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty || type.isEmpty) return;
    if (scheduleType != '按需' && times.isEmpty) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final normalizedTimes = [...times]
      ..sort((left, right) => left.time.compareTo(right.time));
    final medication = original == null
        ? Medication(
            id: now,
            name: cleanName,
            type: type,
            scheduleType: scheduleType,
            times: normalizedTimes,
            startDate: dateOnly(startDate),
            endDate: endDate == null ? null : dateOnly(endDate),
            remarks: remarks.trim(),
            useDays: useDays,
            pauseDays: pauseDays,
            selectedWeekdays: selectedWeekdays,
            intervalDays: intervalDays,
            createdAt: now,
            updatedAt: now,
          )
        : original.copyWith(
            name: cleanName,
            type: type,
            scheduleType: scheduleType,
            times: normalizedTimes,
            startDate: dateOnly(startDate),
            endDate: endDate == null ? original.endDate : dateOnly(endDate),
            clearEndDate: endDate == null,
            remarks: remarks.trim(),
            useDays: useDays,
            pauseDays: pauseDays,
            selectedWeekdays: selectedWeekdays,
            intervalDays: intervalDays,
            updatedAt: now,
          );
    final medications = original == null
        ? [medication, ...state.medications]
        : state.medications
            .map((item) => item.id == medication.id ? medication : item)
            .toList();
    state = state.copyWith(medications: medications);
    await _persist();
    await _scheduler.cancel(medication.id);
    if (medication.isActive && medication.scheduleType != '按需') {
      await _scheduler.schedule(medication);
    }
  }

  Future<void> setMedicationActive(Medication medication, bool active) async {
    final updated = medication.copyWith(
      isActive: active,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    state = state.copyWith(
      medications: state.medications
          .map((item) => item.id == updated.id ? updated : item)
          .toList(),
    );
    await _persist();
    await _scheduler.cancel(updated.id);
    if (active && updated.scheduleType != '按需') {
      await _scheduler.schedule(updated);
    }
  }

  Future<void> deleteMedication(Medication medication) async {
    state = state.copyWith(
      medications:
          state.medications.where((item) => item.id != medication.id).toList(),
      records: state.records
          .where((item) => item.medicationId != medication.id)
          .toList(),
    );
    await _persist();
    await _scheduler.cancel(medication.id);
  }

  Future<void> recordScheduled(MedicationScheduleEntry entry,
          {String notes = ''}) =>
      _record(
        medication: entry.medication,
        scheduledTime: entry.time.time,
        dosage: entry.time.dosage,
        notes: notes,
      );

  Future<void> recordAsNeeded(Medication medication,
          {String? dosage, String notes = ''}) =>
      _record(
        medication: medication,
        scheduledTime: '按需服用',
        dosage: dosage ??
            (medication.times.isEmpty
                ? defaultDosage(medication.type)
                : medication.times.first.dosage),
        notes: notes,
      );

  Future<void> _record({
    required Medication medication,
    required String scheduledTime,
    required String dosage,
    required String notes,
  }) async {
    final exists = selectedRecords.any(
      (item) =>
          item.medicationId == medication.id &&
          item.scheduledTime == scheduledTime,
    );
    if (exists) return;
    final now = DateTime.now();
    final record = MedicationRecord(
      id: now.microsecondsSinceEpoch,
      medicationId: medication.id,
      medicationName: medication.name,
      medicationType: medication.type,
      scheduledTime: scheduledTime,
      actualTime:
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      dosage: dosage,
      date: state.selectedDate,
      notes: notes.trim(),
      createdAt: now.millisecondsSinceEpoch,
    );
    state = state.copyWith(records: [...state.records, record]);
    await _persist();
  }

  bool takesOn(Medication medication, DateTime date) {
    final target = dateOnly(date);
    if (target.isBefore(dateOnly(medication.startDate)) ||
        (medication.endDate != null &&
            target.isAfter(dateOnly(medication.endDate!)))) {
      return false;
    }
    final days = target.difference(dateOnly(medication.startDate)).inDays;
    switch (medication.scheduleType) {
      case '每天':
        return true;
      case '每隔几天':
        return days == 0 ||
            (medication.intervalDays > 0 &&
                days % (medication.intervalDays + 1) == 0);
      case '每周特定日期':
        return medication.selectedWeekdays.contains(target.weekday);
      case '循环定时':
        final total = medication.useDays + medication.pauseDays;
        if (medication.useDays <= 0 || total <= 0) return false;
        final position = (days + 1) % total;
        return position > 0 && position <= medication.useDays;
      default:
        return false;
    }
  }

  Future<void> _persist() => _repository.save(
        MedicationReminderData(
            medications: state.medications, records: state.records),
      );
}

class MedicationScheduleEntry {
  final Medication medication;
  final MedicationTime time;

  const MedicationScheduleEntry({required this.medication, required this.time});
}

String defaultDosage(String type) {
  switch (type) {
    case '胶囊':
      return '1粒';
    case '药片':
    case '贴剂':
      return '1片';
    case '液体':
      return '1毫升';
    case '滴剂':
      return '1滴';
    case '粉末':
      return '1勺';
    case '吸入剂':
      return '1次吸入';
    case '喷剂':
      return '1次喷剂';
    case '注射':
      return '1次注射';
    default:
      return '1次';
  }
}
