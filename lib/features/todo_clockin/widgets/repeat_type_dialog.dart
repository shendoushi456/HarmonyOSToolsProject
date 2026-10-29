// 选择周期弹窗 - 对齐 Android dialog_clockin_time.xml + DialogClockinTimeBinding 用法
// 待办时间选择器中含"不重复"项；新的习惯页中不含
import 'package:flutter/material.dart';

import '../models/todo_clockin_entities.dart';

Future<RepeatType?> showRepeatTypeDialog(
  BuildContext context, {
  required RepeatType current,
  bool includeNone = false,
}) {
  return showDialog<RepeatType>(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => _RepeatTypeDialog(current: current, includeNone: includeNone),
  );
}

class _RepeatTypeDialog extends StatefulWidget {
  const _RepeatTypeDialog({required this.current, required this.includeNone});

  final RepeatType current;
  final bool includeNone;

  @override
  State<_RepeatTypeDialog> createState() => _RepeatTypeDialogState();
}

class _RepeatTypeDialogState extends State<_RepeatTypeDialog> {
  late RepeatType _selected = widget.current;

  static const _themeColor = Color(0xFF6685D6);

  List<RepeatType> get _options => [
        if (widget.includeNone) RepeatType.none,
        RepeatType.everyDay,
        RepeatType.weekday,
        RepeatType.weekend,
      ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.fromLTRB(0, 24, 0, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题"选择周期"居中加粗 16sp
            const Text(
              '选择周期',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1E1E),
              ),
            ),
            // 选项列表
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                children: [
                  for (final option in _options) _buildOption(option),
                ],
              ),
            ),
            // "完成"按钮
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(RepeatType option) {
    final selected = _selected == option;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _selected = option),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Text(
                    option.displayText,
                    style: const TextStyle(
                        fontSize: 15, color: Color(0xFF1E1E1E)),
                  ),
                ),
              ),
              // 选中显示 okay_icon
              Visibility(
                visible: selected,
                child: Image.asset(
                  'assets/images/todo_clockin/okay_icon.png',
                  width: 20,
                  height: 20,
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 5),
            height: 1,
            color: const Color(0xFFF5F5F5),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(_selected),
      child: Container(
        height: 40,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 60),
        decoration: BoxDecoration(
          color: _themeColor,
          borderRadius: BorderRadius.circular(100),
        ),
        child: const Text(
          '完成',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
