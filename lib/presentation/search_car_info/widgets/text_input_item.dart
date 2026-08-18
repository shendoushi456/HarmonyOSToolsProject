import 'package:flutter/material.dart';

/// 文本输入项
///
/// 对应 Android: SearchCarInfoFragment.kt:405-495 TextInputItem
/// 白底圆角卡片 + 标题 + 输入框 + 错误提示。
class TextInputItem extends StatefulWidget {
  final String title;
  final String placeholder;
  final String inputValue;
  final ValueChanged<String> onValueChanged;
  final String? errorMessage;

  const TextInputItem({
    super.key,
    required this.title,
    required this.placeholder,
    required this.inputValue,
    required this.onValueChanged,
    this.errorMessage,
  });

  @override
  State<TextInputItem> createState() => _TextInputItemState();
}

class _TextInputItemState extends State<TextInputItem> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.inputValue);
  }

  @override
  void didUpdateWidget(covariant TextInputItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 外部状态被重置时同步文本；普通输入过程中不重设 controller，
    // 避免每次父组件 rebuild 都把光标移回开头。
    if (widget.inputValue != _controller.text) {
      _controller.value = _controller.value.copyWith(
        text: widget.inputValue,
        selection: TextSelection.collapsed(
          offset: widget.inputValue.length,
        ),
        composing: TextRange.empty,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 14, right: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF333333),
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: _controller,
                    onChanged: widget.onValueChanged,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF333333),
                    ),
                    cursorColor: const Color(0xFF0FC093),
                    maxLines: 1,
                    decoration: InputDecoration(
                      hintText: widget.inputValue.isEmpty
                          ? widget.placeholder
                          : null,
                      hintStyle: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF999999),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 4),
            child: Text(
              widget.errorMessage!,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFFF6B6B),
              ),
            ),
          ),
      ],
    );
  }
}
