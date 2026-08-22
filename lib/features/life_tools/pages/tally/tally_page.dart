// 记账页 - 对齐 Android ManageActivity.java + activity_manage.xml
// 顶栏 #F0FFB8 "收支管理" + "添加"按钮 + 表头 + ListView + 弹层 dialog_add
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../viewmodels/tally_view_model.dart';
import '../widgets/tool_top_bar.dart';
import 'widgets/tally_edit_dialog.dart';
import 'widgets/tally_list_item.dart';

class TallyPage extends ConsumerWidget {
  const TallyPage({super.key});

  static Future<void> push(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TallyPage()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tallyViewModelProvider);
    final vm = ref.read(tallyViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: ToolTopBar(
        title: '收支管理',
        actions: [
          TextButton(
            onPressed: vm.showAddDialog,
            child: const Text('添加', style: TextStyle(fontSize: 18, color: Color(0xFF101112))),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // 表头(对齐 activity_manage.xml 表头 日期/类型/金额/说明)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Row(
                  children: const [
                    Expanded(flex: 15, child: _HeaderText('日期')),
                    Expanded(flex: 10, child: _HeaderText('类型')),
                    Expanded(flex: 10, child: _HeaderText('金额')),
                    Expanded(flex: 15, child: _HeaderText('说明')),
                  ],
                ),
              ),
              Container(height: 0.5, color: AppColors.tallyDivider),
              // 列表
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : state.tallyList.isEmpty
                        ? const Center(child: Text('暂无记账记录'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            itemCount: state.tallyList.length,
                            itemBuilder: (context, index) {
                              final t = state.tallyList[index];
                              return TallyListItem(
                                tally: t,
                                onTap: () => vm.showEditDialog(t),
                                onLongPress: () => _confirmDelete(context, vm, t.id!),
                              );
                            },
                          ),
              ),
            ],
          ),
          // 弹层 dialog_add
          if (state.isDialogVisible) TallyEditDialog(),
        ],
      ),
    );
  }

  /// 长按删除确认 - 对齐 ManageActivity.java setOnItemLongClickListener
  Future<void> _confirmDelete(
    BuildContext context,
    TallyViewModel vm,
    int id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('提示'),
        content: const Text('是否删除此项?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('确定')),
        ],
      ),
    );
    if (confirmed == true) {
      await vm.deleteItem(id);
    }
  }
}

class _HeaderText extends StatelessWidget {
  const _HeaderText(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18, color: AppColors.tallyHeaderText),
      textAlign: TextAlign.center,
    );
  }
}
