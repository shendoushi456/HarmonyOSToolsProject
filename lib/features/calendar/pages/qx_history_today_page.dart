// QxHistoryToday 历史上的今天页 - 对齐 Android QxHistoryTodayActivity/QxHistoryTodayScreen
// 迁移自 toolbox_c toolsbox_moduel weather/calendar/history（Jetpack Compose UI）
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/qx_calendar_models.dart';
import '../viewmodels/qx_history_today_view_model.dart';
import 'qx_calendar_page.dart';

class QxHistoryTodayPage extends ConsumerStatefulWidget {
  /// 对齐 Android QxHistoryTodayActivity.EXTRA_DATE（yyyy-MM-dd 字符串）
  final String? date;

  const QxHistoryTodayPage({super.key, this.date});

  @override
  ConsumerState<QxHistoryTodayPage> createState() =>
      _QxHistoryTodayPageState();
}

class _QxHistoryTodayPageState extends ConsumerState<QxHistoryTodayPage> {
  @override
  void initState() {
    super.initState();
    // 对齐 Android Activity.onCreate：解析 EXTRA_DATE 失败回退今天
    final parsed = DateTime.tryParse(widget.date ?? '');
    final date = parsed ?? DateTime.now();
    Future.microtask(
        () => ref.read(qxHistoryTodayViewModelProvider.notifier).refresh(date));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(qxHistoryTodayViewModelProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF79C9FA), Color(0xFFEAF7FF), Colors.white],
          ),
        ),
        child: SafeArea(
          top: true,
          bottom: false,
          child: Column(
            children: [
              _HistoryTopBar(onBack: () => context.pop()),
              const SizedBox(height: 18),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 40),
                    itemCount: _itemCount(state),
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      if (state.loading) {
                        return index == 0
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 26),
                                child: Text(
                                  '正在获取历史事件...',
                                  style: TextStyle(
                                    color: Color(0xFF7B8086),
                                    fontSize: 17,
                                  ),
                                ),
                              )
                            : const SizedBox(height: 40);
                      }
                      if (state.events.isEmpty) {
                        return index == 0
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 34),
                                child: Text(
                                  '暂无历史事件',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF7B8086),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            : const SizedBox(height: 40);
                      }
                      if (index == state.events.length) {
                        return const SizedBox(height: 40);
                      }
                      final event = state.events[index];
                      return _HistoryEventCard(
                        event: event,
                        onClick: () => _showEventDetail(context, event),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _itemCount(QxHistoryTodayUiState state) {
    if (state.loading) return 1 + 1; // loading 提示 + 底部间距
    if (state.events.isEmpty) return 1 + 1; // 空态 + 底部间距
    return state.events.length + 1;
  }

  void _showEventDetail(BuildContext context, QxHistoryEventUi event) {
    showDialog<void>(
      context: context,
      builder: (context) => QxHistoryEventDetailDialog(event: event),
    );
  }
}

/// 顶部返回栏（对齐 Android HistoryTopBar："<" + 居中标题，58dp 高）
class _HistoryTopBar extends StatelessWidget {
  final VoidCallback onBack;

  const _HistoryTopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: onBack,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Text(
                  '<',
                  style: TextStyle(
                    color: Color(0xFF202124),
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const Text(
            '历史上的今天',
            style: TextStyle(
              color: Color(0xFF202124),
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 历史事件卡（对齐 Android HistoryEventCard：网络图 + 标题/年份/描述）
class _HistoryEventCard extends StatelessWidget {
  final QxHistoryEventUi event;
  final VoidCallback onClick;

  const _HistoryEventCard({required this.event, required this.onClick});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onClick,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.imageUrl.isNotEmpty)
              SizedBox(
                width: double.infinity,
                height: 154,
                // 对齐 Android AsyncImage：加载失败保持空白
                child: Image.network(
                  event.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 3,
                    overflow: TextOverflow.clip,
                    style: const TextStyle(
                      color: Color(0xFF202124),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                  if (event.year.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      event.year,
                      style: const TextStyle(
                        color: Color(0xFF62BDF7),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (event.description.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      event.description,
                      maxLines: 5,
                      overflow: TextOverflow.clip,
                      style: const TextStyle(
                        color: Color(0xFF555B62),
                        fontSize: 16,
                        height: 1.25,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
