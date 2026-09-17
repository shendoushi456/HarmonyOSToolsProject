// LED滚动设置页 - 对齐 Android smalltoolslibrary LedActivity + activity_led.xml
// 白底,AppBar #F6C766 标题"LED手机字幕";文本输入+普通/滚动模式 ToggleGroup
// +背景色卡(默认#000000)+字幕颜色卡(默认 appbarColor #F6C766,均 flask 色轮)
// +字幕大小 seekbar(60~240 默认120)+滚动速度 seekbar(4~40 默认12,滚动模式可见)
// 确定 FAB(zts 底)→跳 LedDisplayPage 全屏(空文本 Toast,对齐安卓)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../router/route_names.dart';
import '../widgets/color_picker_dialog.dart';

class LedPage extends StatefulWidget {
  const LedPage({super.key});

  @override
  State<LedPage> createState() => _LedPageState();
}

class _LedPageState extends State<LedPage> {
  final TextEditingController _controller = TextEditingController();
  bool _scrollMode = false; // false=普通模式(b1) true=滚动模式(b2)
  Color _bgColor = const Color(0xFF000000);
  Color _textColor = const Color(0xFFF6C766);
  double _fontSize = 120;
  double _speed = 12;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 确定 FAB: 空文本 Toast(对齐安卓);否则带参跳全屏页
  void _onConfirm() {
    if (_controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('请输入文本内容'), duration: Duration(seconds: 1)));
      return;
    }
    // 对齐安卓 startActivity(Led1/Led2) 传 nr/bjys/wzys/dx/sd
    // (Color 组件访问器转 hex,避免旧 value 弃用告警)
    String hex(Color c) {
      final r = (c.r * 255).round().toRadixString(16).padLeft(2, '0');
      final g = (c.g * 255).round().toRadixString(16).padLeft(2, '0');
      final b = (c.b * 255).round().toRadixString(16).padLeft(2, '0');
      return '$r$g$b';
    }

    final query = Uri(queryParameters: {
      'mode': _scrollMode ? 'scroll' : 'normal',
      'text': _controller.text,
      'bg': hex(_bgColor),
      'fg': hex(_textColor),
      'size': _fontSize.toInt().toString(),
      'speed': _speed.toInt().toString(),
    }).query;
    context.push('${RoutePaths.ledDisplay}?$query');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6C766),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('LED手机字幕',
            style: TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFF6C766), // 对齐 zts
        onPressed: _onConfirm,
        child: const Icon(Icons.touch_app, color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 文本输入(对齐 EditText hint 请输入文本内容)
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: '请输入文本内容',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            // 普通/滚动模式切换(对齐 ToggleGroup outlined 黑字)
            Row(
              children: [
                _toggleButton('普通模式', !_scrollMode,
                    () => setState(() => _scrollMode = false)),
                const SizedBox(width: 10),
                _toggleButton('滚动模式', _scrollMode,
                    () => setState(() => _scrollMode = true)),
              ],
            ),
            const SizedBox(height: 16),
            // 背景颜色卡(bj1 默认 #000000,24dp 圆 12dp)
            _colorCard('背景颜色', _bgColor, () async {
              final c = await showColorPickerDialog(context, _bgColor);
              if (c != null) setState(() => _bgColor = c);
            }),
            const SizedBox(height: 12),
            // 字幕颜色卡(wz1 默认 appbarColor)
            _colorCard('字幕颜色', _textColor, () async {
              final c = await showColorPickerDialog(context, _textColor);
              if (c != null) setState(() => _textColor = c);
            }),
            const SizedBox(height: 16),
            // 字幕大小 seekbar1(60~240 默认120)
            _sliderCard(
              label: '字幕大小',
              value: _fontSize,
              min: 60,
              max: 240,
              onChanged: (v) => setState(() => _fontSize = v),
            ),
            // 滚动速度 seekbar2(4~40 默认12,仅滚动模式可见)
            if (_scrollMode) ...[
              const SizedBox(height: 12),
              _sliderCard(
                label: '滚动速度',
                value: _speed,
                min: 4,
                max: 40,
                onChanged: (v) => setState(() => _speed = v),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _toggleButton(String label, bool selected, VoidCallback onTap) {
    // 对齐 outlined ToggleGroup: 白底描边黑字,选中黑底白字
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.black : Colors.white,
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(label,
              style: TextStyle(
                  color: selected ? Colors.white : Colors.black,
                  fontSize: 14)),
        ),
      ),
    );
  }

  Widget _colorCard(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFBDBDBD)), // 对齐 itemBackColor 描边
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12), // 24dp 圆 12dp
                border: Border.all(color: const Color(0xFFBDBDBD)),
              ),
            ),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _sliderCard({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFBDBDBD)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Expanded(
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: (max - min).toInt(),
              activeColor: Colors.black,
              inactiveColor: const Color(0xFFE5E5E5),
              label: value.toInt().toString(),
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(value.toInt().toString(),
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
