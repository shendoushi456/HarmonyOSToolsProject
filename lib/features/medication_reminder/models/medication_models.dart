import 'package:flutter/foundation.dart';

@immutable
class MedicationTime {
  final String time;
  final String dosage;

  const MedicationTime({required this.time, required this.dosage});

  Map<String, dynamic> toJson() => {'time': time, 'dosage': dosage};

  factory MedicationTime.fromJson(Map<String, dynamic> json) => MedicationTime(
        time: json['time']?.toString() ?? '08:00',
        dosage: json['dosage']?.toString() ?? '',
      );
}

/// 对齐 Android MedicationEntity 与 MedicationTimeEntity。
@immutable
class Medication {
  final int id;
  final String name;
  final String type;
  final String scheduleType;
  final List<MedicationTime> times;
  final DateTime startDate;
  final DateTime? endDate;
  final String remarks;
  final int useDays;
  final int pauseDays;
  final List<int> selectedWeekdays;
  final int intervalDays;
  final bool isActive;
  final int createdAt;
  final int updatedAt;

  const Medication({
    required this.id,
    required this.name,
    required this.type,
    required this.scheduleType,
    required this.times,
    required this.startDate,
    this.endDate,
    this.remarks = '',
    this.useDays = 0,
    this.pauseDays = 0,
    this.selectedWeekdays = const [],
    this.intervalDays = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Medication copyWith({
    String? name,
    String? type,
    String? scheduleType,
    List<MedicationTime>? times,
    DateTime? startDate,
    DateTime? endDate,
    bool clearEndDate = false,
    String? remarks,
    int? useDays,
    int? pauseDays,
    List<int>? selectedWeekdays,
    int? intervalDays,
    bool? isActive,
    int? updatedAt,
  }) =>
      Medication(
        id: id,
        name: name ?? this.name,
        type: type ?? this.type,
        scheduleType: scheduleType ?? this.scheduleType,
        times: times ?? this.times,
        startDate: startDate ?? this.startDate,
        endDate: clearEndDate ? null : (endDate ?? this.endDate),
        remarks: remarks ?? this.remarks,
        useDays: useDays ?? this.useDays,
        pauseDays: pauseDays ?? this.pauseDays,
        selectedWeekdays: selectedWeekdays ?? this.selectedWeekdays,
        intervalDays: intervalDays ?? this.intervalDays,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'scheduleType': scheduleType,
        'times': times.map((item) => item.toJson()).toList(),
        'startDate': dateKey(startDate),
        'endDate': endDate == null ? null : dateKey(endDate!),
        'remarks': remarks,
        'useDays': useDays,
        'pauseDays': pauseDays,
        'selectedWeekdays': selectedWeekdays,
        'intervalDays': intervalDays,
        'isActive': isActive,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  factory Medication.fromJson(Map<String, dynamic> json) {
    final rawTimes = json['times'] as List? ?? const [];
    final rawWeekdays = json['selectedWeekdays'] as List? ?? const [];
    return Medication(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '药片',
      scheduleType: json['scheduleType']?.toString() ?? '每天',
      times: rawTimes
          .whereType<Map>()
          .map((item) =>
              MedicationTime.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      startDate: DateTime.tryParse(json['startDate']?.toString() ?? '') ??
          DateTime.now(),
      endDate: DateTime.tryParse(json['endDate']?.toString() ?? ''),
      remarks: json['remarks']?.toString() ?? '',
      useDays: (json['useDays'] as num?)?.toInt() ?? 0,
      pauseDays: (json['pauseDays'] as num?)?.toInt() ?? 0,
      selectedWeekdays: rawWeekdays
          .map((item) => (item as num?)?.toInt() ?? 0)
          .where((item) => item >= 1 && item <= 7)
          .toList(),
      intervalDays: (json['intervalDays'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: (json['createdAt'] as num?)?.toInt() ?? 0,
      updatedAt: (json['updatedAt'] as num?)?.toInt() ?? 0,
    );
  }
}

@immutable
class MedicationRecord {
  final int id;
  final int medicationId;
  final String medicationName;
  final String medicationType;
  final String scheduledTime;
  final String actualTime;
  final String dosage;
  final DateTime date;
  final String notes;
  final int createdAt;

  const MedicationRecord({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.medicationType,
    required this.scheduledTime,
    required this.actualTime,
    required this.dosage,
    required this.date,
    this.notes = '',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'medicationId': medicationId,
        'medicationName': medicationName,
        'medicationType': medicationType,
        'scheduledTime': scheduledTime,
        'actualTime': actualTime,
        'dosage': dosage,
        'date': dateKey(date),
        'notes': notes,
        'createdAt': createdAt,
      };

  factory MedicationRecord.fromJson(Map<String, dynamic> json) =>
      MedicationRecord(
        id: (json['id'] as num?)?.toInt() ?? 0,
        medicationId: (json['medicationId'] as num?)?.toInt() ?? 0,
        medicationName: json['medicationName']?.toString() ?? '',
        medicationType: json['medicationType']?.toString() ?? '',
        scheduledTime: json['scheduledTime']?.toString() ?? '',
        actualTime: json['actualTime']?.toString() ?? '',
        dosage: json['dosage']?.toString() ?? '',
        date:
            DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
        notes: json['notes']?.toString() ?? '',
        createdAt: (json['createdAt'] as num?)?.toInt() ?? 0,
      );
}

String dateKey(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);
