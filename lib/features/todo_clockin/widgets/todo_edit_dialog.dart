// 添加/编辑待办弹窗 - 对齐 Android showAddTodoDialog/showTodoDetails + dialog_add_todo.xml
// 内容输入(100dp) + 时间胶囊(设置提醒后显示) + "设置提醒"/"完成"按钮
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/todo_clockin_entities.dart';
import '../repositories/todo_repository.dart';
import '../services/reminder_error_ui.dart';
import '../utils/clockin_date_utils.dart';
import '../utils/clockin_toast.dart';
import 'date_time_picker_dialog.dart';

class TodoTimeInfo {
  TodoTimeInfo({
    required this.year,
    required this.month,
    required this.day,
    required this.hour,
    required this.minute,
    required this.repeatType,
    required this.isExpired,
  });

  final int year;
  final int month;
  final int day;
  final int hour;
  final int minute;
  final RepeatType repeatType;
  final bool isExpired;
}

/// 弹窗占位文本(安卓 layout 中默认值，保存前需排除)
const String kTodoChipPlaceholder = '2025-1-20  21:38';

Future<bool?> showTodoEditDialog(
  BuildContext context, {
  TodoEntity? todo, // null = 添加模式
}) {
  return showDialog<bool>(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => _TodoEditDialog(todo: todo),
  );
}

class _TodoEditDialog extends StatefulWidget {
  const _TodoEditDialog({this.todo});

  final TodoEntity? todo;

  @override
  State<_TodoEditDialog> createState() => _TodoEditDialogState();
}

class _TodoEditDialogState extends State<_TodoEditDialog> {
  static const _themeColor = Color(0xFF6685D6);
  static const _expiredColor = Color(0xFFD11A1A);

  late final TextEditingController _contentController;
  final TodoRepository _repository = TodoRepository();

  // 时间胶囊状态(对应 dialogBinding.llTimeDisplay / test / testtv)
  bool _timeDisplayVisible = false;
  String _timeText = '';
  Color _timeTextColor = Colors.black;
  TodoTimeInfo? _currentTodoTimeInfo;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.todo?.content ?? '');
    // 编辑模式：已有提醒时间则解析并直接显示时间胶囊(对齐 showTodoDetails)
    final todo = widget.todo;
    if (todo != null && todo.reminderTime.isNotEmpty) {
      try {
        final timeInfo = _parseTodoTextFromReminderTime(todo.reminderTime);
        _currentTodoTimeInfo = timeInfo;
        final dateTimeStr = formatReminderTime(timeInfo.year, timeInfo.month,
            timeInfo.day, timeInfo.hour, timeInfo.minute);
        final repeatType = RepeatType.fromCode(todo.repeatType);
        var cycleText = '';
        if (repeatType == RepeatType.weekday) {
          cycleText = ' - 周一至周五';
        } else if (repeatType == RepeatType.weekend) {
          cycleText = ' - 周六至周日';
        }
        final isExpired = isDateTimeExpired(DateTime(timeInfo.year,
            timeInfo.month, timeInfo.day, timeInfo.hour, timeInfo.minute));
        final finalText = isExpired
            ? '$dateTimeStr - 已过期'
            : (cycleText.isNotEmpty ? '$dateTimeStr$cycleText' : dateTimeStr);
        _timeText = finalText;
        _timeTextColor = isExpired ? _expiredColor : Colors.black;
        _timeDisplayVisible = true;
      } catch (_) {
        _timeDisplayVisible = false;
        _currentTodoTimeInfo = null;
      }
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  /// 从提醒时间字符串解析时间信息(对齐 parseTodoTextFromReminderTime)
  TodoTimeInfo _parseTodoTextFromReminderTime(String reminderTime) {
    final match =
        RegExp(r'(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2})')
            .firstMatch(reminderTime);
    if (match != null) {
      return TodoTimeInfo(
        year: int.parse(match.group(1)!),
        month: int.parse(match.group(2)!),
        day: int.parse(match.group(3)!),
        hour: int.parse(match.group(4)!),
        minute: int.parse(match.group(5)!),
        repeatType: RepeatType.none,
        isExpired: false,
      );
    }
    // 解析失败回退当前时间(对齐 catch 分支)
    final now = DateTime.now();
    return TodoTimeInfo(
      year: now.year,
      month: now.month,
      day: now.day,
      hour: now.hour,
      minute: now.minute,
      repeatType: RepeatType.none,
      isExpired: false,
    );
  }

  /// 处理选择的时间(对齐 processSelectedDateTime)
  void _processSelectedDateTime(DateTimePickerResult result) {
    final isExpired = isDateTimeExpired(
        DateTime(result.year, result.month, result.day, result.hour,
            result.minute));
    final dateTimeStr = formatReminderTime(
        result.year, result.month, result.day, result.hour, result.minute);
    var cycleText = '';
    if (result.repeatType == RepeatType.weekday) {
      cycleText = ' - 周一至周五';
    } else if (result.repeatType == RepeatType.weekend) {
      cycleText = ' - 周六至周日';
    }
    final finalText = isExpired
        ? '$dateTimeStr - 已过期'
        : (cycleText.isNotEmpty ? '$dateTimeStr$cycleText' : dateTimeStr);

    setState(() {
      _timeText = finalText;
      _timeTextColor = isExpired ? _expiredColor : Colors.black;
      _timeDisplayVisible = true;
      _currentTodoTimeInfo = TodoTimeInfo(
        year: result.year,
        month: result.month,
        day: result.day,
        hour: result.hour,
        minute: result.minute,
        repeatType: result.repeatType,
        isExpired: isExpired,
      );
    });
  }

  /// 关闭时间胶囊(对齐 ivClose)
  void _closeTimeDisplay() {
    setState(() {
      _timeDisplayVisible = false;
      _currentTodoTimeInfo = null;
      _timeText = '';
    });
  }

  /// 保存(对齐 tvSaveTodo)
  Future<void> _save() async {
    final todoContent = _contentController.text.trim();
    if (todoContent.isEmpty) {
      if (mounted) showClockinToast(context, '请输入待办事项');
      return;
    }

    final hasTimeSet = _timeDisplayVisible &&
        _timeText.trim().isNotEmpty &&
        !_timeText.contains(kTodoChipPlaceholder);

    // 设置了提醒时间则先请求通知授权；授权失败不阻断保存。
    if (hasTimeSet) {
      await requestNotificationIfNeeded();
    }

    final isEdit = widget.todo != null;
    bool success;
    try {
      if (hasTimeSet && _currentTodoTimeInfo != null) {
        final timeInfo = _currentTodoTimeInfo!;
        if (isEdit) {
          success = await _repository.updateTodo(
            id: widget.todo!.id,
            content: todoContent,
            year: timeInfo.year,
            month: timeInfo.month,
            day: timeInfo.day,
            hour: timeInfo.hour,
            minute: timeInfo.minute,
            repeatType: timeInfo.repeatType,
          );
        } else {
          final result = await _repository.saveTodo(
            content: todoContent,
            year: timeInfo.year,
            month: timeInfo.month,
            day: timeInfo.day,
            hour: timeInfo.hour,
            minute: timeInfo.minute,
            repeatType: timeInfo.repeatType,
          );
          success = result > 0;
        }
      } else {
        if (isEdit) {
          success = await _repository.updateTodoWithoutTime(
              widget.todo!.id, todoContent);
        } else {
          final result =
              await _repository.saveTodoWithoutTime(todoContent);
          success = result > 0;
        }
      }
    } on PlatformException catch (error) {
      if (!mounted) return;
      // 数据已保存，提醒失败仅提示，不阻断关闭。
      await handleReminderSaveFailure(context, error);
      if (!mounted) return;
      Navigator.of(context).pop(true);
      return;
    }

    if (!mounted) return;
    showClockinToast(context, success
        ? (isEdit ? '更新成功' : '保存成功')
        : (isEdit ? '更新失败' : '保存失败'));
    if (success) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 内容输入框(EditText 100dp)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: _contentController,
                maxLines: 1,
                style: const TextStyle(
                    fontSize: 15, color: Color(0xFF1E1E1E)),
                decoration: const InputDecoration(
                  hintText: '添加待办……',
                  hintStyle:
                      TextStyle(fontSize: 15, color: Color(0xFF9B9B9B)),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            // 时间胶囊(默认隐藏)
            Visibility(
              visible: _timeDisplayVisible,
              maintainState: false,
              child: Container(
                margin: const EdgeInsets.only(left: 23),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 3, horizontal: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                              'assets/images/todo_clockin/nz2_icon.png',
                              width: 10,
                              height: 10),
                          const SizedBox(width: 3),
                          Text(_timeText,
                              style: TextStyle(
                                  fontSize: 10, color: _timeTextColor)),
                          // 关闭按钮
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _closeTimeDisplay,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Image.asset(
                                  'assets/images/todo_clockin/close_icon.png',
                                  width: 8,
                                  height: 8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 69),
            // 底部按钮区域(右对齐)
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // "设置提醒"按钮(时间胶囊显示时隐藏)
                  Visibility(
                    visible: !_timeDisplayVisible,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _showDatePicker,
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        height: 40,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 15),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x15999999),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                                'assets/images/todo_clockin/nz2_icon.png',
                                width: 12,
                                height: 12),
                            const SizedBox(width: 3),
                            const Text('设置提醒',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF1E1E1E))),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // "完成"按钮
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _save,
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _themeColor,
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x15999999),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      child: const Text('完成',
                          style: TextStyle(
                              fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 打开日期时间选择器(对齐 showDatePickerForStartDate：
  /// 有暂存时间则预设，否则从当前文本解析，再不行用当前时间)
  Future<void> _showDatePicker() async {
    final preset = _currentTodoTimeInfo;
    DateTime? defaultDateTime;
    if (preset != null) {
      defaultDateTime = DateTime(preset.year, preset.month, preset.day,
          preset.hour, preset.minute);
    } else if (_timeText.trim().isNotEmpty &&
        _timeText != kTodoChipPlaceholder) {
      final match = RegExp(r'(\d{4})-(\d{1,2})-(\d{1,2})\s+(\d{1,2}):(\d{1,2})')
          .firstMatch(_timeText);
      if (match != null) {
        defaultDateTime = DateTime(
          int.parse(match.group(1)!),
          int.parse(match.group(2)!),
          int.parse(match.group(3)!),
          int.parse(match.group(4)!),
          int.parse(match.group(5)!),
        );
      }
    }
    defaultDateTime ??= DateTime.now();

    final result = await showDateTimePickerDialog(
      context,
      defaultDateTime: defaultDateTime,
    );
    if (result != null && mounted) {
      _processSelectedDateTime(result);
    }
  }
}
