// QxTodo 我的待办事项页 - 对齐 Android QxTodoActivity/QxTodoScreen
// 迁移自 toolbox_c toolsbox_moduel weather/calendar/todo（Jetpack Compose UI）
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/qx_calendar_models.dart';
import '../viewmodels/qx_todo_view_model.dart';

class QxTodoPage extends ConsumerStatefulWidget {
  const QxTodoPage({super.key});

  @override
  ConsumerState<QxTodoPage> createState() => _QxTodoPageState();
}

class _QxTodoPageState extends ConsumerState<QxTodoPage> {
  @override
  void initState() {
    super.initState();
    // 对齐 Android QxTodoViewModel 初始状态 repository.load()
    Future.microtask(
        () => ref.read(qxTodoViewModelProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(qxTodoViewModelProvider);
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
              _QxTopBar(title: '我的待办事项', onBack: () => context.pop()),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showAddDialog(context),
                    child: const Text('添加待办'),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 40),
                    itemCount:
                        state.items.isEmpty ? 1 : state.items.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (state.items.isEmpty) {
                        return const _EmptyTodoCard();
                      }
                      if (index == state.items.length) {
                        return const SizedBox(height: 40);
                      }
                      final item = state.items[index];
                      return _TodoItemCard(
                        item: item,
                        onToggleTodo: () => ref
                            .read(qxTodoViewModelProvider.notifier)
                            .toggleTodo(item.id),
                        onDeleteTodo: () => ref
                            .read(qxTodoViewModelProvider.notifier)
                            .deleteTodo(item.id),
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

  void _showAddDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => _AddTodoDialog(
        onConfirm: (text) {
          ref.read(qxTodoViewModelProvider.notifier).addTodo(text);
        },
      ),
    );
  }
}

/// 顶部返回栏（对齐 Android TodoTopBar："<" + 居中标题，58dp 高）
class _QxTopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _QxTopBar({required this.title, required this.onBack});

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
          Text(
            title,
            style: const TextStyle(
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

/// 待办条目卡（对齐 Android TodoItemCard）
class _TodoItemCard extends StatelessWidget {
  final QxTodoItem item;
  final VoidCallback onToggleTodo;
  final VoidCallback onDeleteTodo;

  const _TodoItemCard({
    required this.item,
    required this.onToggleTodo,
    required this.onDeleteTodo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Checkbox(
            value: item.done,
            onChanged: (_) => onToggleTodo(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.text,
                  maxLines: 3,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    color: item.done
                        ? const Color(0xFF8B8F95)
                        : const Color(0xFF202124),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                    decoration:
                        item.done ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(item.createdAt),
                  style: const TextStyle(
                    color: Color(0xFF8B8F95),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onDeleteTodo,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              child: Text(
                '删除',
                style: TextStyle(
                  color: Color(0xFFFF7A59),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 对齐 Android formatTime："yyyy-MM-dd HH:mm"
  String _formatTime(int millis) {
    final date = DateTime.fromMillisecondsSinceEpoch(millis);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)} '
        '${two(date.hour)}:${two(date.minute)}';
  }
}

/// 空待办卡（对齐 Android EmptyTodoCard）
class _EmptyTodoCard extends StatelessWidget {
  const _EmptyTodoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Text(
          '暂无待办，点击上方按钮添加',
          style: TextStyle(
            color: Color(0xFF7B8086),
            fontSize: 17,
          ),
        ),
      ),
    );
  }
}

/// 添加待办弹窗（对齐 Android AddTodoDialog）
class _AddTodoDialog extends StatefulWidget {
  final void Function(String) onConfirm;

  const _AddTodoDialog({required this.onConfirm});

  @override
  State<_AddTodoDialog> createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends State<_AddTodoDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('添加待办'),
      content: TextField(
        controller: _controller,
        minLines: 2,
        maxLines: null,
        decoration: const InputDecoration(
          hintText: '请输入待办事项',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            widget.onConfirm(_controller.text);
            Navigator.of(context).pop();
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}
