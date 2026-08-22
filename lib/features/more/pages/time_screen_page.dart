import 'dart:async';

import 'package:flutter/material.dart';

/// 对齐 Android ClockActivity：全屏大时钟，点击页面切换黑白显示模式。
class TimeScreenPage extends StatefulWidget {
  const TimeScreenPage({super.key});

  @override
  State<TimeScreenPage> createState() => _TimeScreenPageState();
}

class _TimeScreenPageState extends State<TimeScreenPage> {
  late final Timer _timer;
  DateTime _now = DateTime.now();
  bool _dark = true;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final foreground = _dark ? Colors.white : Colors.black;
    final secondary = _dark ? const Color(0xFFB6B6B6) : const Color(0xFF666666);
    final time =
        '${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}:${_now.second.toString().padLeft(2, '0')}';
    final date =
        '${_now.year}年${_now.month.toString().padLeft(2, '0')}月${_now.day.toString().padLeft(2, '0')}日';
    return Scaffold(
        backgroundColor: _dark ? Colors.black : Colors.white,
        body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _dark = !_dark),
            child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(time,
                  style: TextStyle(
                      color: foreground,
                      fontSize: 70,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1)),
              const SizedBox(height: 8),
              Text(date, style: TextStyle(color: secondary, fontSize: 20)),
              const SizedBox(height: 32),
              Text('轻触屏幕切换显示模式',
                  style: TextStyle(color: secondary, fontSize: 12))
            ]))));
  }
}
