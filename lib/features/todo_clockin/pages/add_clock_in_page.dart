// AddClockInActivity Flutter 迁移版 - "新的习惯"页
// 对齐 Android toolsbox_moduel/toolsbox/ui/todoclockin/AddClockInActivity.kt
//   + activity_add_clock_in.xml / dialog_clockin_time.xml / item_clockin_time.xml
// 头部：data_theme_color 蓝底 + 白色返回箭头 + 居中标题；页面背景 data_theme_color2
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/todo_clockin_entities.dart';
import '../repositories/clock_in_repository.dart';
import '../services/reminder_error_ui.dart';
import '../utils/clockin_date_utils.dart';
import '../utils/clockin_toast.dart';
import '../widgets/date_picker_dialog.dart';
import '../widgets/repeat_type_dialog.dart';
import '../widgets/time_picker_dialog.dart';

/// 定时方式(对齐 MedicationType 枚举：每天 / 周一至周五 / 周六至周日)
enum _ScheduleType {
  everyDay('每天'),
  cycleTimer('周一至周五'),
  weekSpecific('周六至周日');

  const _ScheduleType(this.text);

  final String text;
}

class AddClockInPage extends StatefulWidget {
  const AddClockInPage({super.key});

  @override
  State<AddClockInPage> createState() => _AddClockInPageState();
}

class _AddClockInPageState extends State<AddClockInPage> {
  // 主题色(对齐 colors.xml)
  static const _themeColor = Color(0xFF6685D6);
  static const _pageBgColor = Color(0xFFF0F4FF);
  static const _blackText = Color(0xFF1E1E1E);
  static const _grayText = Color(0xFF9B9B9B);

  final ClockInRepository _repository = ClockInRepository();
  final TextEditingController _nameController = TextEditingController();

  bool _isHabitNameFilled = false;
  _ScheduleType _scheduleType = _ScheduleType.everyDay;
  final List<String> _selectedTimes = [];
  late String _startDateText;
  String _endDateText = '无';

  @override
  void initState() {
    super.initState();
    // 默认开始日期为今天(对齐 setDefaultStartDate)
    _startDateText = formatYMD(DateTime.now());
    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    final filled = _nameController.text.isNotEmpty;
    if (filled != _isHabitNameFilled) {
      setState(() => _isHabitNameFilled = filled);
    }
  }

  // ============================ 业务操作 ============================

  /// 选择开始日期(对齐 showDatePickerForStartDate)
  Future<void> _showDatePickerForStartDate() async {
    final current = parseYMD(_startDateText);
    final result = await showDatePickerWheelDialog(
      context,
      defaultDate: current,
    );
    if (result == null || !mounted) return;
    setState(() => _startDateText = result.dateString);

    // 开始日期变化后校验结束日期
    final endDateStr = _endDateText;
    if (endDateStr != '无' &&
        !isEndDateAfterStartDate(result.dateString, endDateStr)) {
      final start = parseYMD(result.dateString) ?? DateTime.now();
      final adjusted = formatYMD(start.add(const Duration(days: 1)));
      setState(() => _endDateText = adjusted);
    }
  }

  /// 结束日期选择(对齐 showEndDatePicker：无 / 选择具体日期)
  Future<void> _showEndDatePicker() async {
    final choice = await showDialog<int>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) => AlertDialog(
        title: const Text('结束日期'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('无'),
              onTap: () => Navigator.of(dialogContext).pop(0),
            ),
            ListTile(
              title: const Text('选择具体日期'),
              onTap: () => Navigator.of(dialogContext).pop(1),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(null),
            child: const Text('取消'),
          ),
        ],
      ),
    );
    if (choice == null || !mounted) return;
    if (choice == 0) {
      setState(() => _endDateText = '无');
      return;
    }
    _showDatePickerForEndDate();
  }

  /// 具体结束日期选择(对齐 showDatePickerForEndDate，最小日期 = 开始日期 + 1 天)
  Future<void> _showDatePickerForEndDate() async {
    final start = parseYMD(_startDateText);
    if (start == null) {
      if (mounted) showClockinToast(context, '请先选择开始日期');
      return;
    }
    final minDate = start.add(const Duration(days: 1));
    final current = parseYMD(_endDateText);
    final result = await showDatePickerWheelDialog(
      context,
      defaultDate: current ?? minDate,
      minDate: minDate,
    );
    if (result == null || !mounted) return;
    if (isEndDateAfterStartDate(_startDateText, result.dateString)) {
      setState(() => _endDateText = result.dateString);
    } else {
      showClockinToast(context, '结束日期必须晚于开始日期');
      final adjusted = formatYMD(minDate);
      setState(() => _endDateText = adjusted);
    }
  }

  /// 添加时间点(对齐 showTimePicker + addTimePoint)
  Future<void> _showTimePicker() async {
    final timeString = await showTimePickerWheelDialog(context);
    if (timeString == null || !mounted) return;
    if (_selectedTimes.contains(timeString)) {
      showClockinToast(context, '该时间点已添加');
      return;
    }
    setState(() => _selectedTimes.add(timeString));
    showClockinToast(context, '已添加时间: $timeString');
  }

  /// 移除时间点(对齐 removeTimePoint)
  void _removeTimePoint(String timeString) {
    setState(() => _selectedTimes.remove(timeString));
    showClockinToast(context, '已移除时间: $timeString');
  }

  /// 保存习惯(对齐 saveHabit)
  Future<void> _saveHabit() async {
    if (!_isHabitNameFilled) {
      showClockinToast(context, '请给习惯命名');
      return;
    }
    final habitName = _nameController.text.trim();
    if (_endDateText != '无' &&
        !isEndDateAfterStartDate(_startDateText, _endDateText)) {
      showClockinToast(context, '结束日期必须晚于开始日期');
      return;
    }

    // 先请求通知授权；授权失败不阻断保存。
    await requestNotificationIfNeeded();

    try {
      final clockInTimes = _selectedTimes.isNotEmpty
          ? _selectedTimes.join(',')
          : null;
      await _repository.saveHabit(
        name: habitName,
        scheduleType: _scheduleType.text,
        clockInTimes: clockInTimes,
        startDate: _startDateText,
        endDateText: _endDateText,
      );
      if (!mounted) return;
      showClockinToast(context, '习惯保存成功');
      Navigator.of(context).pop();
    } on PlatformException catch (error) {
      if (!mounted) return;
      // 数据已保存，提醒失败仅提示，不阻断返回。
      await handleReminderSaveFailure(context, error, savedSubject: '打卡');
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      showClockinToast(context, '保存失败: $e');
    }
  }

  // ============================ UI ============================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBgColor,
      body: Column(
        children: [
          // 头部：蓝底 50dp + 状态栏
          Container(
            color: _themeColor,
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: 50,
                child: Stack(
                  children: [
                    // 返回按钮
                    Positioned(
                      left: 8,
                      top: 0,
                      bottom: 0,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Navigator.of(context).pop(),
                        child: Center(
                          child: Image.asset(
                            'assets/images/todo_clockin/ic_arrow_back.png',
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                    ),
                    // 标题
                    const Center(
                      child: Text(
                        '新的习惯',
                        style: TextStyle(
                            fontSize: 22, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('给该习惯命名', 18, vertical: 15),
                  _buildHabitNameInput(),
                  _buildSectionTitle('定时', 16, vertical: 15),
                  _buildScheduleSetting(),
                  _buildAddTimeRow(),
                  if (_selectedTimes.isNotEmpty) _buildTimeContainer(),
                  _buildSectionTitle('持续时间', 16, vertical: 15),
                  _buildStartDateRow(),
                  _buildEndDateRow(),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 区块标题(MediumTextView)
  Widget _buildSectionTitle(String title, double fontSize,
      {double vertical = 15}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: vertical),
      child: Text(
        title,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          color: _blackText,
        ),
      ),
    );
  }

  /// 习惯名称输入(对齐 et_habit_name)
  Widget _buildHabitNameInput() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Color(0x1A000000), blurRadius: 2),
        ],
      ),
      child: TextField(
        controller: _nameController,
        maxLines: 1,
        style: const TextStyle(fontSize: 15, color: _blackText),
        decoration: const InputDecoration(
          hintText: '例：早起、锻炼等',
          hintStyle: TextStyle(fontSize: 15, color: _grayText),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  /// 定时设置行(对齐 rl_schedule_setting)
  Widget _buildScheduleSetting() {
    return _buildSettingRow(
      leftText: _scheduleType.text,
      onTap: () async {
        // 选择周期弹窗(不含"不重复"项)
        final result = await showRepeatTypeDialog(
          context,
          current: _mapScheduleToRepeat(_scheduleType),
          includeNone: false,
        );
        if (result == null || !mounted) return;
        setState(() {
          final mapped = _mapRepeatToSchedule(result);
          if (mapped != null) _scheduleType = mapped;
        });
      },
    );
  }

  /// 定时方式 → RepeatType(对齐弹窗回显)
  RepeatType _mapScheduleToRepeat(_ScheduleType type) {
    switch (type) {
      case _ScheduleType.everyDay:
        return RepeatType.everyDay;
      case _ScheduleType.cycleTimer:
        return RepeatType.weekday;
      case _ScheduleType.weekSpecific:
        return RepeatType.weekend;
    }
  }

  /// RepeatType → 定时方式(对齐 btnPositive 的文本换算)
  _ScheduleType? _mapRepeatToSchedule(RepeatType type) {
    switch (type) {
      case RepeatType.everyDay:
        return _ScheduleType.everyDay;
      case RepeatType.weekday:
        return _ScheduleType.cycleTimer;
      case RepeatType.weekend:
        return _ScheduleType.weekSpecific;
      default:
        return null;
    }
  }

  /// 添加时间行(对齐 rl_add_time)
  Widget _buildAddTimeRow() {
    final text = _selectedTimes.isEmpty
        ? '添加时间'
        : '添加时间（已添加 ${_selectedTimes.length} 个）';
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 12),
      child: _buildSettingRow(
        leftText: text,
        onTap: _showTimePicker,
        trailing: Image.asset(
          'assets/images/todo_clockin/plus_icon.png',
          width: 16,
          height: 16,
        ),
      ),
    );
  }

  /// 已添加时间点列表(对齐 time_container + item_clockin_time)
  Widget _buildTimeContainer() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          for (final time in _selectedTimes)
            Container(
              height: 50,
              margin:
                  const EdgeInsets.only(left: 20, right: 20, bottom: 12),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(color: Color(0x1A000000), blurRadius: 2),
                ],
              ),
              child: Row(
                children: [
                  Text(time,
                      style: const TextStyle(
                          fontSize: 15, color: _themeColor)),
                  const Spacer(),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _removeTimePoint(time),
                    child: const Text('删除',
                        style: TextStyle(
                            fontSize: 15, color: Color(0xFFFF0000))),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// 开始日期行(对齐 rl_start_date)
  Widget _buildStartDateRow() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 7, 20, 0),
      child: _buildSettingRow(
        leftText: '开始日期',
        onTap: _showDatePickerForStartDate,
        valueText: _startDateText,
      ),
    );
  }

  /// 结束日期行(对齐 rl_end_date)
  Widget _buildEndDateRow() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: _buildSettingRow(
        leftText: '结束日期',
        onTap: _showEndDatePicker,
        valueText: _endDateText,
      ),
    );
  }

  /// 通用白底圆角行(50dp，radius 8)
  Widget _buildSettingRow({
    required String leftText,
    required VoidCallback onTap,
    String? valueText,
    Widget? trailing,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(color: Color(0x1A000000), blurRadius: 2),
          ],
        ),
        child: Row(
          children: [
            Text(leftText,
                style: const TextStyle(fontSize: 15, color: _blackText)),
            const Spacer(),
            if (trailing != null) trailing,
            if (valueText != null) ...[
              if (trailing != null) const SizedBox(width: 5),
              Text(valueText,
                  style: const TextStyle(
                      fontSize: 15, color: _themeColor)),
            ],
            if (valueText == null && trailing == null) ...[
              const Text('更改',
                  style: TextStyle(fontSize: 15, color: _blackText)),
              const SizedBox(width: 5),
              Image.asset('assets/images/todo_clockin/arrow_right.png',
                  width: 9, height: 9),
            ],
          ],
        ),
      ),
    );
  }

  /// 保存按钮(对齐 btn_submit，名称未填时置灰禁用)
  Widget _buildSubmitButton() {
    final enabled = _isHabitNameFilled;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      alignment: Alignment.center,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? _saveHabit : null,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 80),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: enabled ? _themeColor : const Color(0xFFCACACA),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Text('保存',
              style: TextStyle(fontSize: 16, color: Colors.white)),
        ),
      ),
    );
  }
}
