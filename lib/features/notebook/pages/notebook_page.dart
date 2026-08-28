import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../router/route_names.dart';
import '../viewmodels/notebook_view_model.dart';

class NotebookPage extends ConsumerWidget {
  const NotebookPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(notebookViewModelProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCEB),
      appBar: AppBar(
          title: const Text('记事本'),
          backgroundColor: const Color(0xFFF0FFB8),
          foregroundColor: const Color(0xFF1E1E1E),
          elevation: 0),
      body: entries.isEmpty
          ? const Center(
              child: Text('暂无记录', style: TextStyle(color: Color(0xFF777777))))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
              itemCount: entries.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Color(0xFFE4E4E4)),
              itemBuilder: (context, index) {
                final entry = entries[index];
                return InkWell(
                  onTap: () =>
                      context.push(RoutePaths.notebookRecord, extra: entry),
                  onLongPress: () => _confirmDelete(context, ref, entry.id),
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 7),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entry.content,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.black, height: 1.3)),
                            const SizedBox(height: 5),
                            Text(entry.time,
                                style:
                                    const TextStyle(color: Color(0xFF7B68EE))),
                          ])),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
          onPressed: () => context.push(RoutePaths.notebookRecord),
          backgroundColor: const Color(0xFF7B68EE),
          child: const Icon(Icons.add)),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, String id) async {
    final yes = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
                    title: const Text('删除确认'),
                    content: const Text('是否删除此记录？'),
                    actions: [
                      TextButton(
                          onPressed: () => context.pop(false),
                          child: const Text('取消')),
                      TextButton(
                          onPressed: () => context.pop(true),
                          child: const Text('确定'))
                    ])) ??
        false;
    if (yes) await ref.read(notebookViewModelProvider.notifier).remove(id);
  }
}
