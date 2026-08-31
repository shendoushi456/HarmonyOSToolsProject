// 历史上的今天 - 对齐 Android HistoryActivity
// 复用 calendar/services/HistoryService 抓取 360 历史今天 + calendar/models/HistoryEvent
import 'package:flutter/material.dart';
import '../../calendar/models/history_event.dart';
import '../../calendar/services/history_service.dart';
import '../pages/widgets/history_today_list_item.dart';

class HistoryTodayPage extends StatefulWidget {
  const HistoryTodayPage({super.key});

  static Future<void> push(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HistoryTodayPage()),
    );
  }

  @override
  State<HistoryTodayPage> createState() => _HistoryTodayPageState();
}

class _HistoryTodayPageState extends State<HistoryTodayPage> {
  final HistoryService _service = HistoryService();
  List<HistoryEvent> _events = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await _service.fetchHistory(DateTime.now());
      if (mounted) setState(() => _events = list);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: true,
        child: Column(
          children: [
            // 顶栏: 返回 + 标题"历史上的今天"
            _buildTopBar(context),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text('加载失败: $_error'))
                      : _events.isEmpty
                          ? const Center(child: Text('暂无数据'))
                          : RefreshIndicator(
                              onRefresh: _load,
                              child: ListView.builder(
                                itemCount: _events.length,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                itemBuilder: (ctx, i) {
                                  final e = _events[i];
                                  return HistoryTodayListItem(
                                    event: e,
                                    onTap: () =>
                                        _showDetail(context, e),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.only(top: 0),
      child: Stack(
        children: [
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
              ),
            ),
          ),
          const Center(
            child: Text(
              '历史上的今天',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context, HistoryEvent e) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(e.time == '今日' ? '今日' : '${e.time}年'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(e.name,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(e.detail, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
