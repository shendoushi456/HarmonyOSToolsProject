// 日期时间选择弹窗(五滚轮：年月日时分) - 对齐 DateTimePickerDialog.kt + dialog_datetime_picker.xml
// 支持"重复提醒"选择，确定时回调选中时间与重复类型
import 'package:flutter/material.dart';

import '../models/todo_clockin_entities.dart';
import 'repeat_type_dialog.dart';
import 'wheel_picker.dart';

class DateTimePickerResult {
  const DateTimePickerResult({
    required this.year,
    required this.month,
    required this.day,
    required this.hour,
    required this.minute,
    required this.repeatType,
  });

  final int year;
  final int month;
  final int day;
  final int hour;
  final int minute;
  final RepeatType repeatType;
}

Future<DateTimePickerResult?> showDateTimePickerDialog(
  BuildContext context, {
  DateTime? defaultDateTime,
  RepeatType initialRepeatType = RepeatType.none,
}) {
  return showDialog<DateTimePickerResult>(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => _DateTimePickerDialog(
      defaultDateTime: defaultDateTime,
      initialRepeatType: initialRepeatType,
    ),
  );
}

class _DateTimePickerDialog extends StatefulWidget {
  const _DateTimePickerDialog({
    this.defaultDateTime,
    required this.initialRepeatType,
  });

  final DateTime? defaultDateTime;
  final RepeatType initialRepeatType;

  @override
  State<_DateTimePickerDialog> createState() => _DateTimePickerDialogState();
}

class _DateTimePickerDialogState extends State<_DateTimePickerDialog> {
  static const _startYear = 1900;
  static const _endYear = 2100;
  static const _themeColor = Color(0xFF6685D6);
  static const _bandColor = Color(0xFFE8EEFE);

  late int _selectedYear;
  late int _selectedMonth; // 1-12
  late int _selectedDay;
  late int _selectedHour;
  late int _selectedMinute;
  late RepeatType _repeatType;

  late List<String> _dayList;
  late final FixedExtentScrollController _dayController;

  @override
  void initState() {
    super.initState();
    final now = widget.defaultDateTime ?? DateTime.now();
    _selectedYear = now.year.clamp(_startYear, _endYear);
    _selectedMonth = now.month.clamp(1, 12);
    _selectedDay = now.day;
    _selectedHour = now.hour.clamp(0, 23);
    _selectedMinute = now.minute.clamp(0, 59);
    _repeatType = widget.initialRepeatType;
    _dayList = _buildDayList(_selectedYear, _selectedMonth);
    _dayController = FixedExtentScrollController(initialItem: _selectedDay - 1);
  }

  @override
  void dispose() {
    _dayController.dispose();
    super.dispose();
  }

  List<String> _buildDayList(int year, int month) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    return List.generate(
        daysInMonth, (i) => (i + 1).toString().padLeft(2, '0'));
  }

  void _updateDayList() {
    final maxDays = DateTime(_selectedYear, _selectedMonth + 1, 0).day;
    if (_selectedDay > maxDays) _selectedDay = maxDays;
    _dayList = _buildDayList(_selectedYear, _selectedMonth);
    // 更新天数滚轮选中位置(对齐 updateDayWheelView)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _dayController.jumpToItem(_selectedDay - 1);
    });
  }

  String get _estimatedTimeText =>
      '预计时间：$_selectedYear年${_selectedMonth.toString().padLeft(2, '0')}月'
      '${_selectedDay.toString().padLeft(2, '0')}日  '
      '${_selectedHour.toString().padLeft(2, '0')}:'
      '${_selectedMinute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final yearItems =
        List.generate(_endYear - _startYear + 1, (i) => '${_startYear + i}');
    final monthItems =
        List.generate(12, (i) => (i + 1).toString().padLeft(2, '0'));
    final hourItems =
        List.generate(24, (i) => i.toString().padLeft(2, '0'));
    final minuteItems =
        List.generate(60, (i) => i.toString().padLeft(2, '0'));

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.symmetric(vertical: 25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题行：闹钟图标 + "设置时间"
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/todo_clockin/nz2_icon.png',
                    width: 16, height: 16),
                const SizedBox(width: 3),
                const Text('设置时间',
                    style: TextStyle(
                        fontSize: 16, color: Color(0xFF1E1E1E))),
              ],
            ),
            // 预计时间
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: double.infinity,
              alignment: Alignment.center,
              child: Text(_estimatedTimeText,
                  style: const TextStyle(
                      fontSize: 10, color: Color(0xFF9B9B9B))),
            ),
            // 年月日时分标签
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                      child: Text('年',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 15, color: Color(0xFF1E1E1E)))),
                  Expanded(
                      child: Text('月',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 15, color: Color(0xFF1E1E1E)))),
                  Expanded(
                      child: Text('日',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 15, color: Color(0xFF1E1E1E)))),
                  Expanded(
                      child: Text('时',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 15, color: Color(0xFF1E1E1E)))),
                  Expanded(
                      child: Text('分',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 15, color: Color(0xFF1E1E1E)))),
                ],
              ),
            ),
            // 选中带 + 五个滚轮
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 中间选中背景带
                  Container(
                    height: 30,
                    margin: const EdgeInsets.symmetric(horizontal: 0),
                    decoration: BoxDecoration(
                      color: _bandColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: WheelPicker(
                          items: yearItems,
                          initialItem: _selectedYear - _startYear,
                          onSelected: (index) => setState(() {
                            _selectedYear = _startYear + index;
                            _updateDayList();
                          }),
                        ),
                      ),
                      Expanded(
                        child: WheelPicker(
                          items: monthItems,
                          initialItem: _selectedMonth - 1,
                          onSelected: (index) => setState(() {
                            _selectedMonth = index + 1;
                            _updateDayList();
                          }),
                        ),
                      ),
                      Expanded(
                        child: WheelPicker(
                          items: _dayList,
                          controller: _dayController,
                          onSelected: (index) =>
                              setState(() => _selectedDay = index + 1),
                        ),
                      ),
                      Expanded(
                        child: WheelPicker(
                          items: hourItems,
                          initialItem: _selectedHour,
                          onSelected: (index) =>
                              setState(() => _selectedHour = index),
                        ),
                      ),
                      Expanded(
                        child: WheelPicker(
                          items: minuteItems,
                          initialItem: _selectedMinute,
                          onSelected: (index) =>
                              setState(() => _selectedMinute = index),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 重复提醒行
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _showRepeatDialog,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text('重复提醒',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1E1E1E))),
                    ),
                    Text(_repeatType.displayText,
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF1E1E1E))),
                    const SizedBox(width: 3),
                    Image.asset('assets/images/todo_clockin/arrow_right.png',
                        width: 9, height: 9),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 确定按钮
            GestureDetector(
              onTap: () => Navigator.of(context).pop(DateTimePickerResult(
                year: _selectedYear,
                month: _selectedMonth,
                day: _selectedDay,
                hour: _selectedHour,
                minute: _selectedMinute,
                repeatType: _repeatType,
              )),
              child: Container(
                height: 40,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 60),
                decoration: BoxDecoration(
                  color: _themeColor,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Text('确定',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 重复提醒选择(对齐 showRepeatReminderDialog，含"不重复"选项)
  Future<void> _showRepeatDialog() async {
    final result = await showRepeatTypeDialog(
      context,
      current: _repeatType,
      includeNone: true,
    );
    if (result != null && mounted) {
      setState(() => _repeatType = result);
    }
  }
}
