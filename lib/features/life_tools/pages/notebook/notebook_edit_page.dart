// 记事本编辑页 - 对齐 Android RecordActivity.java + activity_record.xml
// 顶栏蓝(#7b68ee) "添加记录"/"修改记录" + 时间(编辑模式) + 多行输入框 + 删除按钮(编辑模式)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../viewmodels/notebook_edit_view_model.dart';

class NotebookEditPage extends ConsumerStatefulWidget {
  const NotebookEditPage({
    super.key,
    this.id,
    this.content,
    this.time,
  });

  /// 编辑模式传入的记录 id(null 表示新增)
  final int? id;
  final String? content;
  final String? time;

  /// 跳转便捷方法
  static Future<void> push(
    BuildContext context, {
    int? id,
    String? content,
    String? time,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NotebookEditPage(id: id, content: content, time: time),
      ),
    );
  }

  @override
  ConsumerState<NotebookEditPage> createState() => _NotebookEditPageState();
}

class _NotebookEditPageState extends ConsumerState<NotebookEditPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // 初始化 ViewModel - 对齐 RecordActivity.java:43-57 initData
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notebookEditViewModelProvider.notifier).init(
            id: widget.id,
            content: widget.content,
            time: widget.time,
          );
    });
    _controller = TextEditingController(text: widget.content ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notebookEditViewModelProvider);
    final vm = ref.read(notebookEditViewModelProvider.notifier);
    // 标题: 新增 "添加记录", 编辑 "修改记录" - 对齐 RecordActivity.java:49-53
    final title = state.isEditMode ? '修改记录' : '添加记录';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.notepadTitleBlue,
        elevation: 0,
        title: Text(title),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // 保存按钮 - 对齐 activity_record.xml note_save
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: state.isSaving
                ? null
                : () async {
                    // 先用 controller 的最新文本更新 state
                    vm.updateContent(_controller.text);
                    final ok = await vm.save();
                    if (ok && context.mounted) {
                      Navigator.pop(context);
                    } else if (!ok && context.mounted) {
                      // 显示错误信息(对齐 Toast 提示)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.error ?? '保存失败'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
          ),
        ],
      ),
      body: Column(
        children: [
          // 时间(编辑模式显示) - 对齐 activity_record.xml tv_time
          if (state.isEditMode && state.time.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                state.time,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.notepadSubText,
                ),
              ),
            ),
          // 多行输入框 - 对齐 activity_record.xml note_content
          Expanded(
            child: TextField(
              controller: _controller,
              maxLines: null,
              autofocus: true,
              style: const TextStyle(fontSize: 15, color: Colors.black),
              decoration: const InputDecoration(
                hintText: '请输入要添加的内容',
                hintStyle: TextStyle(color: Color(0xFF999999)),
                contentPadding: EdgeInsets.all(12),
                border: InputBorder.none,
                filled: true,
                fillColor: Color(0xFFFEFEFE),
              ),
              onChanged: vm.updateContent,
            ),
          ),
          // 1dp 分隔线 #9370bd
          Container(height: 1, color: const Color(0xFF9370BD)),
          // 底部删除按钮(仅编辑模式) - 对齐 activity_record.xml note_delete
          if (state.isEditMode)
            SizedBox(
              height: 55,
              child: Row(
                children: [
                  Expanded(
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: AppColors.notepadTitleBlue, size: 28),
                      onPressed: () async {
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
                          final ok = await vm.delete();
                          if (ok && context.mounted) {
                            Navigator.pop(context);
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
