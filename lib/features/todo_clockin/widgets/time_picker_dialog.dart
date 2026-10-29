// 时间选择弹窗(时分两滚轮，循环滚动) - 对齐 TimePickerDialog.kt + dialog_time_picker.xml
// 时/分之间为黑色竖线与"两点"分隔符，确定后回调 "HH:mm"
import 'package:flutter/material.dart';

import 'wheel_picker.dart';

Future<String?> showTimePickerWheelDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => const _TimePickerWheelDialog(),
  );
}

class _TimePickerWheelDialog extends StatefulWidget {
  const _TimePickerWheelDialog();

  @override
  State<_TimePickerWheelDialog> createState() => _TimePickerWheelDialogState();
}

class _TimePickerWheelDialogState extends State<_TimePickerWheelDialog> {
  static const _themeColor = Color(0xFF6685D6);

  late int _selectedHour;
  late int _selectedMinute;

  @override
  void initState() {
    super.initState();
    // 默认当前时间(对齐 setCurrentTime)
    final now = DateTime.now();
    _selectedHour = now.hour;
    _selectedMinute = now.minute;
  }

  @override
  Widget build(BuildContext context) {
    final hourItems =
        List.generate(24, (i) => '${i.toString().padLeft(2, '0')}时');
    final minuteItems =
        List.generate(60, (i) => '${i.toString().padLeft(2, '0')}分');

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
            // 时滚轮 | 两点 | 分滚轮，两侧带黑色竖线刻度
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              height: 165,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _verticalTick(),
                  Expanded(
                    child: WheelPicker(
                      items: hourItems,
                      itemExtent: 68,
                      fontSize: 17,
                      initialItem: _selectedHour,
                      selectedColor: const Color(0xFF1E1E1E),
                      unselectedColor: const Color(0xFF9B9B9B),
                      cyclic: true,
                      onSelected: (index) =>
                          setState(() => _selectedHour = index),
                    ),
                  ),
                  _verticalTick(),
                  // "两点"分隔符(两个小圆点)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    width: 11,
                    height: 1,
                    color: const Color(0xFF1E1E1E),
                  ),
                  _verticalTick(),
                  Expanded(
                    child: WheelPicker(
                      items: minuteItems,
                      itemExtent: 68,
                      fontSize: 17,
                      initialItem: _selectedMinute,
                      selectedColor: const Color(0xFF1E1E1E),
                      unselectedColor: const Color(0xFF9B9B9B),
                      cyclic: true,
                      onSelected: (index) =>
                          setState(() => _selectedMinute = index),
                    ),
                  ),
                  _verticalTick(),
                ],
              ),
            ),
            // 确定按钮
            GestureDetector(
              onTap: () => Navigator.of(context).pop(
                '${_selectedHour.toString().padLeft(2, '0')}:'
                '${_selectedMinute.toString().padLeft(2, '0')}',
              ),
              child: Container(
                height: 40,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 60),
                margin: const EdgeInsets.only(top: 16),
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

  /// 黑色竖线刻度(1dp x 26dp)
  Widget _verticalTick() {
    return Container(
      width: 1,
      height: 26,
      color: const Color(0xFF1E1E1E),
    );
  }
}
