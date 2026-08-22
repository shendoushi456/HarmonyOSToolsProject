import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/medication_models.dart';
import '../viewmodels/medication_reminder_view_model.dart';

const _theme = Color(0xFF3DCEE9);
const _pageBackground = Color(0xFFF5FAFC);
const _text = Color(0xFF222222);
const _hint = Color(0xFF737A80);

class MedicationReminderPage extends ConsumerWidget {
  const MedicationReminderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(medicationReminderViewModelProvider);
    final viewModel = ref.read(medicationReminderViewModelProvider.notifier);
    final schedules = viewModel.scheduledEntries;
    final records = viewModel.selectedRecords;
    return Scaffold(
      backgroundColor: _pageBackground,
      body: state.loading
          ? const Center(child: CircularProgressIndicator(color: _theme))
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                    child: _Header(
                        selectedDate: state.selectedDate,
                        onSelect: viewModel.selectDate)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const _SectionTitle('记录'),
                      _ScheduleCard(
                        entries: schedules,
                        hasScheduledMedication:
                            viewModel.hasScheduledMedication,
                        onTap: (entry) => _showRecordSheet(context, ref, entry),
                      ),
                      const SizedBox(height: 10),
                      _ActionRow(
                          label: '按需用药',
                          onTap: () => _showAsNeededSheet(context, ref)),
                      if (records.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _RecordedCard(
                            records: records,
                            onTap: (record) =>
                                _showRecordedDetails(context, record)),
                      ],
                      const SizedBox(height: 26),
                      const _SectionTitle('你的药品'),
                      if (state.medications.isNotEmpty)
                        _MedicationList(
                          medications: state.medications,
                          onTap: (item) => _showMedicationEditor(context, ref,
                              original: item),
                        ),
                      _ActionRow(
                          label: '添加药品',
                          onTap: () => _showMedicationEditor(context, ref)),
                      const SizedBox(height: 26),
                      const _SectionTitle('关于用药'),
                      _AboutCard(onTap: () => _showMedicationAbout(context)),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }
}

class _Header extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelect;

  const _Header({required this.selectedDate, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final start = dateOnly(DateTime.now()).subtract(const Duration(days: 3));
    return Container(
      decoration: const BoxDecoration(
        color: _theme,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('用药',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            SizedBox(
              height: 64,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 9,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, index) {
                  final day = start.add(Duration(days: index));
                  final selected = dateKey(day) == dateKey(selectedDate);
                  final week = const [
                    '一',
                    '二',
                    '三',
                    '四',
                    '五',
                    '六',
                    '日'
                  ][day.weekday - 1];
                  return InkWell(
                    borderRadius: BorderRadius.circular(9),
                    onTap: () => onSelect(day),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: 45,
                      decoration: BoxDecoration(
                        color: selected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('周$week',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: selected ? _theme : Colors.white70)),
                            const SizedBox(height: 5),
                            Text('${day.day}',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: selected ? _theme : Colors.white)),
                          ]),
                    ),
                  );
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w600, color: _text)),
      );
}

class _ScheduleCard extends StatelessWidget {
  final List<MedicationScheduleEntry> entries;
  final bool hasScheduledMedication;
  final ValueChanged<MedicationScheduleEntry> onTap;
  const _ScheduleCard(
      {required this.entries,
      required this.hasScheduledMedication,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return _Surface(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Text(hasScheduledMedication ? '已记录所有定时用药' : '无定时用药',
            style: const TextStyle(color: _hint, fontSize: 15)),
      ));
    }
    return _Surface(
      child: Column(
        children: entries
            .map((entry) =>
                _ScheduleRow(entry: entry, onTap: () => onTap(entry)))
            .toList(),
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  final MedicationScheduleEntry entry;
  final VoidCallback onTap;
  const _ScheduleRow({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          child: Row(children: [
            const _PillIcon(size: 20),
            const SizedBox(width: 10),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('${entry.medication.name}-${entry.medication.type}',
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: _text)),
                  const SizedBox(height: 3),
                  Text('${entry.time.dosage}${entry.medication.type}',
                      style: const TextStyle(fontSize: 12, color: _hint)),
                ])),
            Text(entry.time.time,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600, color: _theme)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded,
                size: 20, color: Color(0xFFB4BEC4)),
          ]),
        ),
      );
}

class _ActionRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _ActionRow({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => _Surface(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 50,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(children: [
                Expanded(
                    child: Text(label,
                        style: const TextStyle(fontSize: 15, color: _text))),
                const Icon(Icons.add_circle_outline_rounded,
                    color: _theme, size: 20),
              ]),
            ),
          ),
        ),
      );
}

class _RecordedCard extends StatelessWidget {
  final List<MedicationRecord> records;
  final ValueChanged<MedicationRecord> onTap;
  const _RecordedCard({required this.records, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<MedicationRecord>>{};
    for (final record in records) {
      grouped
          .putIfAbsent(
              '${record.medicationName}(${record.medicationType})', () => [])
          .add(record);
    }
    return _Surface(
        child: Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('已记录',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, color: _text)),
        ...grouped.entries.map((entry) => InkWell(
              onTap: () => onTap(entry.value.first),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(children: [
                  Expanded(
                      child: Text(entry.key,
                          style: const TextStyle(fontSize: 14, color: _text))),
                  Text(
                      entry.value
                          .map((item) =>
                              '${item.scheduledTime}(${item.actualTime})')
                          .join('、'),
                      style: const TextStyle(fontSize: 12, color: _hint)),
                ]),
              ),
            )),
      ]),
    ));
  }
}

class _MedicationList extends StatelessWidget {
  final List<Medication> medications;
  final ValueChanged<Medication> onTap;
  const _MedicationList({required this.medications, required this.onTap});

  @override
  Widget build(BuildContext context) => _Surface(
        child: Column(
          children: medications
              .map((item) => InkWell(
                    onTap: () => onTap(item),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(children: [
                        const _PillIcon(size: 54),
                        const SizedBox(width: 16),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text('${item.name}-${item.type}',
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: item.isActive ? _text : _hint)),
                              const SizedBox(height: 6),
                              Text(item.isActive ? item.scheduleType : '已暂停',
                                  style: const TextStyle(
                                      fontSize: 14, color: _hint)),
                            ])),
                        const Icon(Icons.chevron_right_rounded,
                            color: Color(0xFFBBC4C9)),
                      ]),
                    ),
                  ))
              .toList(),
        ),
      );
}

class _AboutCard extends StatelessWidget {
  final VoidCallback onTap;
  const _AboutCard({required this.onTap});
  @override
  Widget build(BuildContext context) => _Surface(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  height: 116,
                  decoration: BoxDecoration(
                      color: const Color(0xFFE3F5FA),
                      borderRadius: BorderRadius.circular(6)),
                  child: const Center(child: _PillIcon(size: 58))),
              const SizedBox(height: 16),
              const Text('跟踪用药情况',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600, color: _text)),
              const SizedBox(height: 3),
              const Text('跟踪用药情况为何十分重要',
                  style: TextStyle(fontSize: 12, color: _hint)),
            ]),
          ),
        ),
      );
}

class _Surface extends StatelessWidget {
  final Widget child;
  const _Surface({required this.child});
  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        elevation: 1.5,
        shadowColor: const Color(0x22000000),
        child: child,
      );
}

class _PillIcon extends StatelessWidget {
  final double size;
  const _PillIcon({required this.size});
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            color: const Color(0xFFCED9EB),
            borderRadius: BorderRadius.circular(size / 3)),
        child: Icon(Icons.medication_rounded,
            size: size * .58, color: const Color(0xFF5481AE)),
      );
}

Future<void> _showRecordSheet(
    BuildContext context, WidgetRef ref, MedicationScheduleEntry entry) async {
  final note = TextEditingController();
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => _SheetFrame(
        child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('${entry.medication.name}-${entry.medication.type}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
                '${entry.time.time} 用药：${entry.time.dosage}${entry.medication.type}',
                style: const TextStyle(color: _hint)),
            const SizedBox(height: 16),
            TextField(
                controller: note,
                maxLines: 2,
                decoration: const InputDecoration(
                    labelText: '备注（可选）', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            FilledButton(
                onPressed: () async {
                  await ref
                      .read(medicationReminderViewModelProvider.notifier)
                      .recordScheduled(entry, notes: note.text);
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
                style: FilledButton.styleFrom(backgroundColor: _theme),
                child: const Text('确认用药')),
            TextButton(
                onPressed: () => Navigator.pop(sheetContext),
                child: const Text('取消')),
          ]),
    )),
  );
  note.dispose();
}

Future<void> _showRecordedDetails(
        BuildContext context, MedicationRecord record) =>
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => _SheetFrame(
          child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('${record.medicationName}-${record.medicationType}',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Text('计划时间：${record.scheduledTime}',
                  style: const TextStyle(color: _hint)),
              const SizedBox(height: 6),
              Text('实际用药：${record.actualTime}，${record.dosage}',
                  style: const TextStyle(color: _hint)),
              if (record.notes.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text('备注：${record.notes}', style: const TextStyle(color: _hint))
              ],
              const SizedBox(height: 16),
              FilledButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  style: FilledButton.styleFrom(backgroundColor: _theme),
                  child: const Text('关闭')),
            ]),
      )),
    );

Future<void> _showMedicationAbout(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => _SheetFrame(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('关于用药',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              const Text('规律记录每一次用药，有助于回顾治疗计划和避免漏服。',
                  style: TextStyle(color: _hint, height: 1.55)),
              const SizedBox(height: 18),
              FilledButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  style: FilledButton.styleFrom(backgroundColor: _theme),
                  child: const Text('关闭')),
            ],
          ),
        ),
      ),
    );

Future<void> _showAsNeededSheet(BuildContext context, WidgetRef ref) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final viewModel =
            ref.read(medicationReminderViewModelProvider.notifier);
        final medications = viewModel.asNeededMedications;
        return _SheetFrame(
            child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('按需用药',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                if (medications.isEmpty)
                  const Padding(
                      padding: EdgeInsets.symmetric(vertical: 18),
                      child: Text('暂无按需药品，请先添加药品。',
                          style: TextStyle(color: _hint))),
                ...medications.map((item) {
                  final recorded = viewModel.isAsNeededRecorded(item);
                  final dose = item.times.isEmpty
                      ? defaultDosage(item.type)
                      : item.times.first.dosage;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _Surface(
                        child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(children: [
                        const _PillIcon(size: 40),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text('${item.name}-${item.type}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 3),
                              Text('按需：$dose${item.type}',
                                  style: const TextStyle(
                                      fontSize: 12, color: _hint))
                            ])),
                        TextButton(
                            onPressed: recorded
                                ? null
                                : () async {
                                    await viewModel.recordAsNeeded(item);
                                    if (sheetContext.mounted) {
                                      Navigator.pop(sheetContext);
                                    }
                                  },
                            child: Text(recorded ? '已记录' : '已用药')),
                      ]),
                    )),
                  );
                }),
              ]),
        ));
      },
    );

Future<void> _showMedicationEditor(BuildContext context, WidgetRef ref,
    {Medication? original}) async {
  final result = await showModalBottomSheet<_MedicationDraft>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _MedicationEditor(original: original),
  );
  if (result == null) return;
  await ref.read(medicationReminderViewModelProvider.notifier).saveMedication(
        original: original,
        name: result.name,
        type: result.type,
        scheduleType: result.scheduleType,
        times: result.times,
        startDate: result.startDate,
        endDate: result.endDate,
        remarks: result.remarks,
        useDays: result.useDays,
        pauseDays: result.pauseDays,
        selectedWeekdays: result.selectedWeekdays,
        intervalDays: result.intervalDays,
      );
}

class _SheetFrame extends StatelessWidget {
  final Widget child;
  const _SheetFrame({required this.child});
  @override
  Widget build(BuildContext context) => SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
                margin: const EdgeInsets.only(top: 9),
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                    color: const Color(0xFFD7DEE2),
                    borderRadius: BorderRadius.circular(2))),
            child,
          ]),
        ),
      );
}

class _MedicationDraft {
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
  const _MedicationDraft(
      {required this.name,
      required this.type,
      required this.scheduleType,
      required this.times,
      required this.startDate,
      this.endDate,
      required this.remarks,
      required this.useDays,
      required this.pauseDays,
      required this.selectedWeekdays,
      required this.intervalDays});
}

class _MedicationEditor extends StatefulWidget {
  final Medication? original;
  const _MedicationEditor({this.original});
  @override
  State<_MedicationEditor> createState() => _MedicationEditorState();
}

class _MedicationEditorState extends State<_MedicationEditor> {
  static const _types = [
    '药片',
    '胶囊',
    '液体',
    '外用',
    '乳霜',
    '吸入剂',
    '喷剂',
    '滴剂',
    '注射',
    '贴剂'
  ];
  static const _schedules = ['每天', '循环定时', '每周特定日期', '每隔几天', '按需'];
  late final TextEditingController _name;
  late final TextEditingController _remarks;
  late String _type;
  late String _schedule;
  late DateTime _start;
  DateTime? _end;
  late List<MedicationTime> _times;
  late Set<int> _weekdays;
  late int _interval;
  late int _useDays;
  late int _pauseDays;
  int? _editingDoseIndex;
  TextEditingController? _doseEditor;
  final List<TextEditingController> _retiredDoseEditors = [];

  @override
  void initState() {
    super.initState();
    final item = widget.original;
    _name = TextEditingController(text: item?.name ?? '');
    _remarks = TextEditingController(text: item?.remarks ?? '');
    _type = item?.type ?? _types.first;
    _schedule = item?.scheduleType ?? '每天';
    _start = item?.startDate ?? dateOnly(DateTime.now());
    _end = item?.endDate;
    _times = item?.times.toList() ??
        [MedicationTime(time: '08:00', dosage: defaultDosage(_type))];
    _weekdays = item?.selectedWeekdays.toSet() ?? {DateTime.now().weekday};
    _interval = item?.intervalDays ?? 1;
    _useDays = item == null || item.useDays == 0 ? 21 : item.useDays;
    _pauseDays = item == null || item.pauseDays == 0 ? 7 : item.pauseDays;
  }

  @override
  void dispose() {
    _name.dispose();
    _remarks.dispose();
    _doseEditor?.dispose();
    for (final controller in _retiredDoseEditors) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _SheetFrame(
          child: Padding(
        padding: EdgeInsets.fromLTRB(
            20, 8, 20, MediaQuery.viewInsetsOf(context).bottom + 24),
        child: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              Row(children: [
                Expanded(
                    child: Text(widget.original == null ? '添加药品' : '编辑药品',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600))),
                if (widget.original != null)
                  IconButton(
                      tooltip: '删除药品',
                      onPressed: _delete,
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: Color(0xFFD95C5C)))
              ]),
              const SizedBox(height: 12),
              TextField(
                  controller: _name,
                  decoration: const InputDecoration(
                      labelText: '药品名称', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              _dropdown(
                  label: '药品类型',
                  value: _type,
                  values: _types,
                  onChanged: (value) => setState(() => _type = value)),
              const SizedBox(height: 12),
              _dropdown(
                  label: '定时方式',
                  value: _schedule,
                  values: _schedules,
                  onChanged: (value) => setState(() => _schedule = value)),
              if (_schedule != '按需') ...[
                const SizedBox(height: 14),
                const Text('服药时间',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                ..._times
                    .asMap()
                    .entries
                    .map((entry) => _timeRow(entry.key, entry.value)),
                TextButton.icon(
                    onPressed: _addTime,
                    icon: const Icon(Icons.add),
                    label: const Text('添加服药时间'))
              ],
              if (_schedule == '每周特定日期') ...[
                const SizedBox(height: 10),
                const Text('选择星期',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                Wrap(
                    spacing: 7,
                    children: List.generate(7, (index) {
                      final weekday = index + 1;
                      final labels = ['一', '二', '三', '四', '五', '六', '日'];
                      return FilterChip(
                          label: Text('周${labels[index]}'),
                          selected: _weekdays.contains(weekday),
                          onSelected: (selected) => setState(() {
                                if (selected) {
                                  _weekdays.add(weekday);
                                } else if (_weekdays.length > 1) {
                                  _weekdays.remove(weekday);
                                }
                              }));
                    }))
              ],
              if (_schedule == '每隔几天') ...[
                const SizedBox(height: 10),
                _stepper('每隔 $_interval 天', _interval,
                    (value) => setState(() => _interval = value))
              ],
              if (_schedule == '循环定时') ...[
                const SizedBox(height: 10),
                _stepper('连续用药 $_useDays 天', _useDays,
                    (value) => setState(() => _useDays = value)),
                _stepper('暂停 $_pauseDays 天', _pauseDays,
                    (value) => setState(() => _pauseDays = value))
              ],
              const SizedBox(height: 12),
              _dateRow('开始日期', _start, () async {
                final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2200),
                    initialDate: _start);
                if (picked != null) setState(() => _start = picked);
              }),
              _dateRow('结束日期', _end, () async {
                final picked = await showDatePicker(
                    context: context,
                    firstDate: _start,
                    lastDate: DateTime(2200),
                    initialDate: _end ?? _start);
                if (picked != null) setState(() => _end = picked);
              }),
              if (_end != null)
                Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                        onPressed: () => setState(() => _end = null),
                        child: const Text('不限结束日期'))),
              TextField(
                  controller: _remarks,
                  maxLines: 2,
                  decoration: const InputDecoration(
                      labelText: '备注（可选）', border: OutlineInputBorder())),
              const SizedBox(height: 18),
              FilledButton(
                  onPressed: _save,
                  style: FilledButton.styleFrom(backgroundColor: _theme),
                  child: Text(widget.original == null ? '完成添加' : '保存修改')),
            ])),
      ));

  Widget _dropdown(
          {required String label,
          required String value,
          required List<String> values,
          required ValueChanged<String> onChanged}) =>
      DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
              labelText: label, border: const OutlineInputBorder()),
          items: values
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: (item) {
            if (item != null) onChanged(item);
          });
  Widget _stepper(String label, int value, ValueChanged<int> changed) =>
      Row(children: [
        Expanded(child: Text(label, style: const TextStyle(color: _hint))),
        IconButton(
            onPressed: value <= 1 ? null : () => changed(value - 1),
            icon: const Icon(Icons.remove_circle_outline)),
        Text('$value'),
        IconButton(
            onPressed: () => changed(value + 1),
            icon: const Icon(Icons.add_circle_outline))
      ]);
  Widget _dateRow(String label, DateTime? date, VoidCallback onTap) => ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(date == null
          ? '无'
          : '${date.year}年${date.month.toString().padLeft(2, '0')}月${date.day.toString().padLeft(2, '0')}日'),
      trailing: const Icon(Icons.calendar_today_outlined),
      onTap: onTap);
  Widget _timeRow(int index, MedicationTime item) => Column(children: [
        Row(children: [
          Expanded(
              child: Text(item.time, style: const TextStyle(fontSize: 16))),
          Expanded(
              child: Text(
                  item.dosage.isEmpty ? defaultDosage(_type) : item.dosage,
                  style: const TextStyle(color: _hint))),
          IconButton(
              tooltip: '修改剂量',
              onPressed: () => _beginEditDosage(index),
              icon: const Icon(Icons.edit_outlined)),
          IconButton(
              tooltip: '选择时间',
              onPressed: () => _pickTime(index),
              icon: const Icon(Icons.access_time_rounded)),
          if (_times.length > 1)
            IconButton(
                tooltip: '删除时间',
                onPressed: () => setState(() => _times.removeAt(index)),
                icon: const Icon(Icons.remove_circle_outline,
                    color: Color(0xFFD95C5C)))
        ]),
        if (_editingDoseIndex == index)
          Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                Expanded(
                    child: TextField(
                        controller: _doseEditor,
                        autofocus: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _commitDosage(index),
                        decoration: const InputDecoration(
                            labelText: '剂量',
                            hintText: '例如：1片',
                            border: OutlineInputBorder()))),
                const SizedBox(width: 8),
                FilledButton(
                    onPressed: () => _commitDosage(index),
                    style: FilledButton.styleFrom(backgroundColor: _theme),
                    child: const Text('确定')),
              ]))
      ]);
  Future<void> _pickTime(int index) async {
    final parts = _times[index].time.split(':');
    final picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(
            hour: int.tryParse(parts.first) ?? 8,
            minute: int.tryParse(parts.last) ?? 0));
    if (picked != null) {
      setState(() => _times[index] = MedicationTime(
          time:
              '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
          dosage: _times[index].dosage.isEmpty
              ? defaultDosage(_type)
              : _times[index].dosage));
    }
  }

  void _beginEditDosage(int index) {
    if (_doseEditor != null) {
      _retiredDoseEditors.add(_doseEditor!);
    }
    _doseEditor = TextEditingController(
        text: _times[index].dosage.isEmpty
            ? defaultDosage(_type)
            : _times[index].dosage);
    setState(() => _editingDoseIndex = index);
  }

  void _commitDosage(int index) {
    final dosage = _doseEditor?.text.trim() ?? '';
    if (dosage.isEmpty) return;
    setState(() {
      _times[index] = MedicationTime(time: _times[index].time, dosage: dosage);
      _editingDoseIndex = null;
    });
  }

  void _addTime() => setState(() =>
      _times.add(MedicationTime(time: '12:00', dosage: defaultDosage(_type))));
  void _save() {
    if (_name.text.trim().isEmpty ||
        (_schedule != '按需' && _times.isEmpty) ||
        (_end != null && _end!.isBefore(_start))) {
      return;
    }
    Navigator.pop(
        context,
        _MedicationDraft(
            name: _name.text,
            type: _type,
            scheduleType: _schedule,
            times: _schedule == '按需' ? _times.take(1).toList() : _times,
            startDate: _start,
            endDate: _end,
            remarks: _remarks.text,
            useDays: _useDays,
            pauseDays: _pauseDays,
            selectedWeekdays: _weekdays.toList(),
            intervalDays: _interval));
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
                title: const Text('删除药品？'),
                content: const Text('删除后其用药记录也会移除。'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('取消')),
                  TextButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      child: const Text('删除'))
                ]));
    if (confirmed == true && mounted) {
      await ProviderScope.containerOf(context)
          .read(medicationReminderViewModelProvider.notifier)
          .deleteMedication(widget.original!);
      if (mounted) Navigator.pop(context);
    }
  }
}
