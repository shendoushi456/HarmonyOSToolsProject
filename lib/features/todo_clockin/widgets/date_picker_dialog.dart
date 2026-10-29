// 日期选择弹窗(年月日三滚轮) - 对齐 DatePickerDialog.kt + dialog_alltime_picker.xml
// 支持最小日期限制(结束日期需晚于开始日期)
import 'package:flutter/material.dart';

import '../utils/clockin_date_utils.dart';
import 'wheel_picker.dart';

class DatePickerResult {
  const DatePickerResult({
    required this.year,
    required this.month,
    required this.day,
    required this.dateString,
  });

  final int year;
  final int month;
  final int day;
  final String dateString; // "2026年10月08日"
}

Future<DatePickerResult?> showDatePickerWheelDialog(
  BuildContext context, {
  DateTime? defaultDate,
  DateTime? minDate,
}) {
  return showDialog<DatePickerResult>(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => _DatePickerWheelDialog(
      defaultDate: defaultDate,
      minDate: minDate,
    ),
  );
}

class _DatePickerWheelDialog extends StatefulWidget {
  const _DatePickerWheelDialog({this.defaultDate, this.minDate});

  final DateTime? defaultDate;
  final DateTime? minDate;

  @override
  State<_DatePickerWheelDialog> createState() => _DatePickerWheelDialogState();
}

class _DatePickerWheelDialogState extends State<_DatePickerWheelDialog> {
  static const _startYear = 1900;
  static const _endYear = 2100;
  static const _themeColor = Color(0xFF6685D6);
  static const _bandColor = Color(0xFFE8EEFE);

  late int _selectedYear;
  late int _selectedMonth; // 1-12
  late int _selectedDay;

  late List<String> _dayList;
  late final FixedExtentScrollController _dayController;

  @override
  void initState() {
    super.initState();
    final now = widget.defaultDate ?? DateTime.now();
    _selectedYear = now.year.clamp(_startYear, _endYear);
    _selectedMonth = now.month.clamp(1, 12);
    _selectedDay = now.day;
    _dayList = _buildDayList(_selectedYear, _selectedMonth);
    _dayController = FixedExtentScrollController(initialItem: _selectedDay - 1);
    // 初始化后应用最小日期限制(对齐 applyMinDateRestrictions)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _applyMinDateRestrictions()) setState(() {});
    });
  }

  @override
  void dispose() {
    _dayController.dispose();
    super.dispose();
  }

  List<String> _buildDayList(int year, int month) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    return List.generate(daysInMonth,
        (i) => '${(i + 1).toString().padLeft(2, '0')}日');
  }

  void _updateDayList() {
    final maxDays = DateTime(_selectedYear, _selectedMonth + 1, 0).day;
    if (_selectedDay > maxDays) _selectedDay = maxDays;
    _dayList = _buildDayList(_selectedYear, _selectedMonth);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _dayController.jumpToItem(_selectedDay - 1);
    });
  }

  /// 当前选择是否早于最小日期
  bool _isDateBeforeMinDate() {
    final min = widget.minDate;
    if (min == null) return false;
    if (_selectedYear < min.year) return true;
    if (_selectedYear > min.year) return false;
    if (_selectedMonth < min.month) return true;
    if (_selectedMonth > min.month) return false;
    return _selectedDay < min.day;
  }

  /// 应用最小日期限制，早于最小日期则调整到最小日期
  bool _applyMinDateRestrictions() {
    if (!_isDateBeforeMinDate()) return false;
    final min = widget.minDate!;
    _selectedYear = min.year;
    _selectedMonth = min.month;
    _selectedDay = min.day;
    _dayList = _buildDayList(_selectedYear, _selectedMonth);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _dayController.jumpToItem(_selectedDay - 1);
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final yearItems =
        List.generate(_endYear - _startYear + 1, (i) => '${_startYear + i}年');
    final monthItems =
        List.generate(12, (i) => '${(i + 1).toString().padLeft(2, '0')}月');

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.75,
        padding: const EdgeInsets.symmetric(vertical: 25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 选中带 + 三个滚轮
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              height: 265,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 35,
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
                          itemExtent: 64,
                          fontSize: 16,
                          initialItem: _selectedYear - _startYear,
                          onSelected: (index) => setState(() {
                            _selectedYear = _startYear + index;
                            _applyMinDateRestrictions();
                            _updateDayList();
                          }),
                        ),
                      ),
                      Expanded(
                        child: WheelPicker(
                          items: monthItems,
                          itemExtent: 64,
                          fontSize: 16,
                          initialItem: _selectedMonth - 1,
                          onSelected: (index) => setState(() {
                            _selectedMonth = index + 1;
                            _applyMinDateRestrictions();
                            _updateDayList();
                          }),
                        ),
                      ),
                      Expanded(
                        child: WheelPicker(
                          items: _dayList,
                          itemExtent: 64,
                          fontSize: 16,
                          controller: _dayController,
                          onSelected: (index) => setState(() {
                            _selectedDay = index + 1;
                            _applyMinDateRestrictions();
                          }),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 确定按钮
            GestureDetector(
              onTap: () {
                // 确定时再次校验最小日期
                _applyMinDateRestrictions();
                Navigator.of(context).pop(DatePickerResult(
                  year: _selectedYear,
                  month: _selectedMonth,
                  day: _selectedDay,
                  dateString: formatYMD(DateTime(
                      _selectedYear, _selectedMonth, _selectedDay)),
                ));
              },
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
}
