// 滚轮选择器 - 对齐 Android com.contrarywind.view.WheelView
// 非循环/循环滚动、选中项主题色、无 3D 透视，与 WheelView 默认观感对齐
import 'package:flutter/material.dart';

class WheelPicker extends StatefulWidget {
  const WheelPicker({
    super.key,
    required this.items,
    this.initialItem = 0,
    this.controller,
    this.itemExtent = 52,
    this.fontSize = 13,
    this.selectedColor = const Color(0xFF6685D6),
    this.unselectedColor = const Color(0xFF7A7A7A),
    this.cyclic = false,
    this.onSelected,
  });

  final List<String> items;
  final int initialItem;
  final FixedExtentScrollController? controller;
  final double itemExtent;
  final double fontSize;
  final Color selectedColor;
  final Color unselectedColor;
  final bool cyclic;
  final ValueChanged<int>? onSelected;

  @override
  State<WheelPicker> createState() => _WheelPickerState();
}

class _WheelPickerState extends State<WheelPicker> {
  FixedExtentScrollController? _ownedController;
  int _index = 0;

  FixedExtentScrollController get _effectiveController {
    if (widget.controller != null) return widget.controller!;
    return _ownedController ??=
        FixedExtentScrollController(initialItem: widget.initialItem);
  }

  @override
  void initState() {
    super.initState();
    _index = widget.initialItem;
  }

  @override
  void dispose() {
    _ownedController?.dispose();
    super.dispose();
  }

  int get _currentIndex {
    final controller = _effectiveController;
    if (controller.hasClients) {
      return controller.selectedItem.clamp(0, widget.items.length - 1);
    }
    return _index.clamp(0, widget.items.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final idx = _currentIndex;
        if (idx != _index) {
          setState(() => _index = idx);
          widget.onSelected?.call(idx);
        }
        return false;
      },
      child: ListWheelScrollView.useDelegate(
        controller: _effectiveController,
        itemExtent: widget.itemExtent,
        perspective: 0.0001, // 关闭 3D 透视
        physics: const FixedExtentScrollPhysics(),
        childDelegate: widget.cyclic
            ? ListWheelChildLoopingListDelegate(children: _buildChildren())
            : ListWheelChildListDelegate(children: _buildChildren()),
      ),
    );
  }

  List<Widget> _buildChildren() {
    final current = _currentIndex;
    return [
      for (var i = 0; i < widget.items.length; i++)
        Center(
          child: Text(
            widget.items[i],
            style: TextStyle(
              fontSize: widget.fontSize,
              color: i == current
                  ? widget.selectedColor
                  : widget.unselectedColor,
            ),
          ),
        ),
    ];
  }
}
