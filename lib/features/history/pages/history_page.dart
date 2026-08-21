// 历史上的今天页 - 对齐 Android HistoryActivity
// 顶部栏"历史上的今天" + 返回 + 日期切换 action + 2 列瀑布流 + 加载/失败态
// 卡片点击 → 详情弹窗(含复制按钮 + 剪贴板 + SnackBar 提示)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/history_event.dart';
import '../services/history_service.dart';
import '../widgets/history_event_card.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final HistoryService _service = HistoryService();
  List<HistoryEvent> _events = const [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadHistory(_selectedDate);
  }

  /// 加载历史今天 - 对齐 Android loadHistory(url)
  Future<void> _loadHistory(DateTime date) async {
    setState(() {
      _isLoading = true;
    });
    final events = await _service.fetchHistory(date);
    if (!mounted) return;
    setState(() {
      _events = events;
      _isLoading = false;
    });
  }

  /// 日期切换 - 对齐 Android DatePickerDialog
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(DateTime.now().year, 1, 1),
      lastDate: DateTime(DateTime.now().year, 12, 31),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      await _loadHistory(picked);
    }
  }

  /// 显示详情弹窗 - 对齐 Android CopyDialog(this, "事件概况", gk)
  void _showDetail(HistoryEvent event) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('事件概况'),
        content: Text(event.detail),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              // 复制到剪贴板 - 对齐 Android 复制按钮
              Clipboard.setData(ClipboardData(text: event.detail));
              Navigator.of(context).pop();
              // 对齐 Android Alerter "复制成功" 提示
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('已成功将内容复制到剪切板'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('复制'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('历史上的今天'),
        backgroundColor: const Color(0xFFF0FFB8),
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          // 切换日期菜单项 - 对齐 Android menu_history "切换日期"
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _pickDate,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : MasonryGridView.count(
              padding: const EdgeInsets.all(10),
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              itemCount: _events.length,
              itemBuilder: (context, index) => HistoryEventCard(
                event: _events[index],
                onTap: () => _showDetail(_events[index]),
              ),
            ),
    );
  }
}
