// 首页 - 还原 Android NewLifeFragment（不含节日节气/历史上的今天）。
// 数据复用 life_tools 的 note 表与 NotebookRepository；编辑页仍由既有 MVVM 负责保存。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/utils/lunar_util.dart';
import '../../../router/route_names.dart';
import '../../life_tools/models/notebook_bean.dart';
import '../../life_tools/pages/notebook/notebook_edit_page.dart';
import '../../life_tools/viewmodels/notebook_list_view_model.dart';

class NewLifeHomePage extends ConsumerStatefulWidget {
  const NewLifeHomePage({super.key});

  @override
  ConsumerState<NewLifeHomePage> createState() => _NewLifeHomePageState();
}

class _NewLifeHomePageState extends ConsumerState<NewLifeHomePage> {
  late DateTime _displayMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayMonth = DateTime(now.year, now.month);
    _selectedDate = DateTime(now.year, now.month, now.day);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notebookListViewModelProvider.notifier).loadNotes();
    });
  }

  void _changeMonth(int offset) {
    setState(() {
      _displayMonth =
          DateTime(_displayMonth.year, _displayMonth.month + offset);
      _selectedDate = DateTime(_displayMonth.year, _displayMonth.month, 1);
    });
  }

  Future<void> _openEditor([NotebookBean? note]) async {
    await NotebookEditPage.push(
      context,
      id: note?.id,
      content: note?.content,
      time: note?.notebookTime,
    );
    if (mounted) {
      await ref.read(notebookListViewModelProvider.notifier).loadNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final notesState = ref.watch(notebookListViewModelProvider);
    return Scaffold(

      backgroundColor: const Color(0xFFF2F4F5),
      body: Column(

        children: [
          _NewLifeTopBar(onSettingsTap: () => context.push(RoutePaths.setting)),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _CalendarSection(
                    displayMonth: _displayMonth,
                    selectedDate: _selectedDate,
                    onPrevious: () => _changeMonth(-1),
                    onNext: () => _changeMonth(1),
                    onDateSelected: (date) =>
                        setState(() => _selectedDate = date),
                  ),
                  const SizedBox(height: 19),
                  _NotesSection(
                    loading: notesState.isLoading,
                    notes: notesState.notes,
                    onAdd: _openEditor,
                    onNoteTap: _openEditor,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NewLifeTopBar extends StatelessWidget {
  const _NewLifeTopBar({required this.onSettingsTap});

  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFACD5EF), Color(0xFFF2F4F5)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 50,
          child: Stack(
            children: [
              const Positioned(
                left: 0,
                right: 0,
                top: 24,
                child: Text(
                  '日历',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF1E1E1E),
                    fontSize: 22,
                    height: 1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                top: 21,
                right: 20,
                child: GestureDetector(
                  onTap: onSettingsTap,
                  child: Image.asset(AppAssets.newLifeSettings,
                      width: 25, height: 25),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalendarSection extends StatelessWidget {
  const _CalendarSection({
    required this.displayMonth,
    required this.selectedDate,
    required this.onPrevious,
    required this.onNext,
    required this.onDateSelected,
  });

  final DateTime displayMonth;
  final DateTime selectedDate;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: onPrevious,
                  child: Image.asset(AppAssets.newLifeCalendarPrevious,
                      width: 15, height: 15),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '${displayMonth.year}年${displayMonth.month}月',
                    style: const TextStyle(
                      color: Color(0xFF1E1E1E),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onNext,
                  child: Image.asset(AppAssets.newLifeCalendarNext,
                      width: 15, height: 15),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x26000000),
                    blurRadius: 3,
                    offset: Offset(0, 2)),
              ],
            ),
            child: _MonthGrid(
              displayMonth: displayMonth,
              selectedDate: selectedDate,
              onDateSelected: onDateSelected,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.displayMonth,
    required this.selectedDate,
    required this.onDateSelected,
  });

  final DateTime displayMonth;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(displayMonth.year, displayMonth.month, 1);
    final days = DateTime(displayMonth.year, displayMonth.month + 1, 0).day;
    final leadingBlankCount = first.weekday - 1; // Android 日历按周一开始。
    final rowCount = ((leadingBlankCount + days + 6) ~/ 7).clamp(5, 6);
    final cells = List<DateTime?>.generate(rowCount * 7, (index) {
      final day = index - leadingBlankCount + 1;
      return day >= 1 && day <= days
          ? DateTime(displayMonth.year, displayMonth.month, day)
          : null;
    });

    return Column(
      children: [
        Container(
          height: 30,
          color: const Color(0xFF88DBFF),
          child: const Row(
            children: [
              _WeekTitle('一'),
              _WeekTitle('二'),
              _WeekTitle('三'),
              _WeekTitle('四'),
              _WeekTitle('五'),
              _WeekTitle('六'),
              _WeekTitle('日'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        for (var row = 0; row < rowCount; row++)
          SizedBox(
            height: 48,
            child: Row(
              children: List.generate(7, (column) {
                final date = cells[row * 7 + column];
                if (date == null) return const Expanded(child: SizedBox());
                final isSelected = _sameDay(date, selectedDate);
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onDateSelected(date),
                    child: Center(
                      child: Container(
                        width: 35,
                        height: 38,
                        decoration: isSelected
                            ? const BoxDecoration(
                                color: Color(0xFF88DBFF),
                                shape: BoxShape.circle)
                            : null,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${date.day}',
                              style: TextStyle(
                                fontSize: 14,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              LunarUtil.lunarLabel(date),
                              style: TextStyle(
                                fontSize: 9,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF999999),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  static bool _sameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

class _WeekTitle extends StatelessWidget {
  const _WeekTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Center(
          child: Text(text,
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        ),
      );
}

class _NotesSection extends StatelessWidget {
  const _NotesSection({
    required this.loading,
    required this.notes,
    required this.onAdd,
    required this.onNoteTap,
  });

  final bool loading;
  final List<NotebookBean> notes;
  final VoidCallback onAdd;
  final ValueChanged<NotebookBean> onNoteTap;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.only(top: 48, bottom: 48),
        child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (notes.isEmpty) {
      return GestureDetector(
        onTap: onAdd,
        child: Column(
          children: [
            Image.asset(AppAssets.newLifeAddNote, width: 96, height: 96),
            const SizedBox(height: 20),
            const Text('随手记一记',
                style: TextStyle(color: Colors.black, fontSize: 12)),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        children: [
          for (var index = 0; index < notes.length; index++)
            _NoteRow(note: notes[index], onTap: () => onNoteTap(notes[index])),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: onAdd,
              child:
                  Image.asset(AppAssets.newLifeAddNote, width: 60, height: 60),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteRow extends StatelessWidget {
  const _NoteRow({required this.note, required this.onTap});
  final NotebookBean note;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final date = _noteDate(note.notebookTime);
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              child: Column(
                children: [
                  Text('${date.day}',
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 28,
                          height: .86,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${date.month}',
                      style: const TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 68,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8)),
                child: Text(
                  note.content.isEmpty ? '无内容' : note.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Color(0xFF5A5A5A),
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DateTime _noteDate(String value) {
    final match = RegExp(r'(\d{4})年(\d{1,2})月(\d{1,2})日').firstMatch(value);
    if (match != null) {
      return DateTime(int.parse(match.group(1)!), int.parse(match.group(2)!),
          int.parse(match.group(3)!));
    }
    return DateTime.now();
  }
}
