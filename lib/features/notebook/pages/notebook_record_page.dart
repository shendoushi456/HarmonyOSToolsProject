import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/notebook_entry.dart';
import '../viewmodels/notebook_view_model.dart';

class NotebookRecordPage extends ConsumerStatefulWidget {
  final NotebookEntry? entry;
  const NotebookRecordPage({super.key, this.entry});
  @override
  ConsumerState<NotebookRecordPage> createState() => _NotebookRecordPageState();
}

class _NotebookRecordPageState extends ConsumerState<NotebookRecordPage> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.entry?.content ?? '');

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: Text(widget.entry == null ? '添加记录' : '修改记录'),
            backgroundColor: const Color(0xFFF0FFB8),
            foregroundColor: const Color(0xFF1E1E1E),
            elevation: 0,
            actions: [
              IconButton(
                  onPressed: _save, icon: const Icon(Icons.save_outlined)),
              if (widget.entry != null)
                IconButton(
                    onPressed: _delete, icon: const Icon(Icons.delete_outline))
            ]),
        body: Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
                controller: _controller,
                autofocus: widget.entry == null,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                    hintText: '请输入记录内容', border: InputBorder.none))),
      );

  Future<void> _save() async {
    final content = _controller.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('修改内容不能为空!')));
      return;
    }
    await ref
        .read(notebookViewModelProvider.notifier)
        .upsert(id: widget.entry?.id, content: content);
    // 编辑页由列表页 push 打开，保存后返回原列表；状态已更新，列表会自动刷新。
    if (mounted) context.pop(true);
  }

  Future<void> _delete() async {
    await ref.read(notebookViewModelProvider.notifier).remove(widget.entry!.id);
    if (mounted) context.pop(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
