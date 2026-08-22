// 记事本列表页 - 对齐 Android NotebookActivity.java + activity_notepad.xml
// 顶栏 #F0FFB8 "记事本" + ListView + 悬浮添加按钮
// 点击列表项跳编辑页(预填), 长按弹删除确认, 返回后刷新(对齐 onActivityResult requestCode=1)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../viewmodels/notebook_list_view_model.dart';
import '../widgets/tool_top_bar.dart';
import 'notebook_edit_page.dart';
import 'widgets/notebook_list_item.dart';

class NotebookListPage extends ConsumerWidget {
  const NotebookListPage({super.key});

  /// 跳转便捷方法
  static Future<void> push(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotebookListPage()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notebookListViewModelProvider);
    final vm = ref.read(notebookListViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.toolsTopBarBg,
      appBar: const ToolTopBar(title: '记事本'),
      body: ListView.builder(
        itemCount: state.notes.length,
        itemBuilder: (context, index) {
          final note = state.notes[index];
          return NotebookListItem(
            note: note,
            onTap: () async {
              // 点击跳编辑页,返回后刷新 - 对齐 NotebookActivity.java:113-118 onActivityResult
              await NotebookEditPage.push(
                context,
                id: note.id,
                content: note.content,
                time: note.notebookTime,
              );
              vm.loadNotes();
            },
            onLongPress: () => _confirmDelete(context, vm, note.id!),
          );
        },
      ),
      // 悬浮添加按钮 - 对齐 activity_notepad.xml ImageView @id/add
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await NotebookEditPage.push(context);
          vm.loadNotes();
        },
        backgroundColor: AppColors.notepadTitleBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /// 长按删除确认 - 对齐 NotebookActivity.java setOnItemLongClickListener
  Future<void> _confirmDelete(
    BuildContext context,
    NotebookListViewModel vm,
    int id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('提示'),
        content: const Text('是否删除此记录?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await vm.deleteNote(id);
    }
  }
}
