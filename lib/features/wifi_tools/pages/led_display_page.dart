// LED 全屏显示页 - 对齐 Android Led1Activity(滚动模式,MarqueeView 跑马灯)
// 与 Led2Activity(普通模式,全屏静止 TextView)
// 全屏沉浸(隐系统栏),按 LedPage 传入的 nr/bjys/wzys/dx/sd 渲染
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LedDisplayPage extends StatefulWidget {
  final bool scrollMode; // true=Led1 滚动 false=Led2 静止
  final String text;
  final Color bgColor;
  final Color fgColor;
  final double fontSize;
  final double speed; // 滚动速度(4~40,数值越大越快)

  const LedDisplayPage({
    super.key,
    required this.scrollMode,
    required this.text,
    required this.bgColor,
    required this.fgColor,
    required this.fontSize,
    required this.speed,
  });

  @override
  State<LedDisplayPage> createState() => _LedDisplayPageState();
}

class _LedDisplayPageState extends State<LedDisplayPage> {
  double _offset = 0; // 跑马灯水平偏移
  Timer? _timer;
  double _screenWidth = 0;
  double _textWidth = 0;

  @override
  void initState() {
    super.initState();
    // 对齐 ImmersionBar 隐系统栏
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    if (widget.scrollMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startMarquee();
      });
    }
  }

  /// 对齐 MarqueeView: 文本从右侧进入,匀速向左滚动,尾部离开后循环
  void _startMarquee() {
    _screenWidth = MediaQuery.of(context).size.width;
    // 文本宽度近似: fontSize * 1.0 * 字符数(中英文混合粗估)
    _textWidth = widget.text.length * widget.fontSize;
    _offset = _screenWidth;
    // 速度映射: speed(4~40) → 每帧像素(px/16ms),默认 12 → 约 4px/帧
    final pxPerTick = widget.speed / 3.0;
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      setState(() => _offset -= pxPerTick);
      // 尾部完全离开左侧后重置回右侧
      if (_offset < -_textWidth) {
        _offset = _screenWidth;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    // 恢复系统栏
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.bgColor,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(), // 点击退出(等效系统返回)
        child: Center(
          child: widget.scrollMode
              ? _buildMarquee()
              : _buildStatic(),
        ),
      ),
    );
  }

  /// 普通模式(Led2): 全屏静止文本居中
  Widget _buildStatic() {
    return Text(
      widget.text,
      textAlign: TextAlign.center,
      style: TextStyle(
          color: widget.fgColor, fontSize: widget.fontSize),
    );
  }

  /// 滚动模式(Led1): ClipRect 内水平位移文本
  Widget _buildMarquee() {
    return ClipRect(
      child: SizedBox(
        width: double.infinity,
        child: Stack(
          children: [
            Positioned(
              left: _offset,
              child: Text(
                widget.text,
                style: TextStyle(
                    color: widget.fgColor, fontSize: widget.fontSize),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
