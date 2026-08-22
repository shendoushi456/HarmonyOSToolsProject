import 'package:flutter/foundation.dart';

import '../models/medication_models.dart';

@immutable
class MedicationReminderState {
  final bool loading;
  final DateTime selectedDate;
  final List<Medication> medications;
  final List<MedicationRecord> records;

  const MedicationReminderState({
    required this.loading,
    required this.selectedDate,
    required this.medications,
    required this.records,
  });

  factory MedicationReminderState.initial() => MedicationReminderState(
        loading: true,
        selectedDate: dateOnly(DateTime.now()),
        medications: const [],
        records: const [],
      );

  MedicationReminderState copyWith({
    bool? loading,
    DateTime? selectedDate,
    List<Medication>? medications,
    List<MedicationRecord>? records,
  }) =>
      MedicationReminderState(
        loading: loading ?? this.loading,
        selectedDate: selectedDate ?? this.selectedDate,
        medications: medications ?? this.medications,
        records: records ?? this.records,
      );
}
