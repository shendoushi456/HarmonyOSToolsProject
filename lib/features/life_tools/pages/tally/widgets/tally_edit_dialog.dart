// 记账编辑弹层 - 对齐 Android activity_manage.xml dialog_add
// 日期(点击弹DatePicker) + 类型(DropdownButton) + 金额 + 说明 + 添加/修改/删除按钮
// 用 ConsumerStatefulWidget 持久化 controller,避免重建导致输入异常
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../viewmodels/tally_view_model.dart';

class TallyEditDialog extends ConsumerStatefulWidget {
  const TallyEditDialog({super.key});

  @override
  ConsumerState<TallyEditDialog> createState() => _TallyEditDialogState();
}

class _TallyEditDialogState extends ConsumerState<TallyEditDialog> {
  late final TextEditingController _dateController;
  late final TextEditingController _moneyController;
  late final TextEditingController _stateController;
  bool _controllersInitialized = false;

  void _ensureControllersInit(TallyState state) {
    if (_controllersInitialized) return;
    _dateController = TextEditingController(text: state.date);
    _moneyController = TextEditingController(text: state.money);
    _stateController = TextEditingController(text: state.state);
    _controllersInitialized = true;
  }

  @override
  void dispose() {
    if (_controllersInitialized) {
      _dateController.dispose();
      _moneyController.dispose();
      _stateController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tallyViewModelProvider);
    final vm = ref.read(tallyViewModelProvider.notifier);
    _ensureControllersInit(state);

    return Container(
      color: const Color(0x66000000), // 60% 透明遮罩
      alignment: Alignment.center,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 关闭按钮(对齐 dialog_dis)
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: vm.hideDialog,
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Text(
                        '关闭',
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                    ),
                  ),
                ),
                // 日期行
                _buildLabel('日期:'),
                GestureDetector(
                  onTap: () => _pickDate(context, vm),
                  child: AbsorbPointer(
                    child: TextField(
                      controller: _dateController,
                      decoration: const InputDecoration(hintText: '请选择日期'),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // 类型行
                _buildLabel('类型:'),
                DropdownButton<String>(
                  value: state.type,
                  isExpanded: true,
                  items: const ['收入', '支出']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => v != null ? vm.updateType(v) : null,
                ),
                const SizedBox(height: 12),
                // 金额行
                _buildLabel('金额:'),
                TextField(
                  controller: _moneyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: '输入该项金额'),
                  onChanged: vm.updateMoney,
                ),
                const SizedBox(height: 12),
                // 说明行
                _buildLabel('说明:'),
                TextField(
                  controller: _stateController,
                  decoration: const InputDecoration(hintText: '说明来源或用途~'),
                  onChanged: vm.updateState,
                ),
                const SizedBox(height: 24),
                // 按钮行 - 对齐 setEditMode 控制可见性
                Row(
                  children: [
                    // 添加按钮(仅新增模式)
                    if (!state.isEditMode)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            // 确保 state 是最新值
                            vm.updateMoney(_moneyController.text);
                            vm.updateState(_stateController.text);
                            final ok = await vm.add();
                            if (!ok && context.mounted && state.error != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(state.error!)),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.notepadTitleBlue,
                          ),
                          child: const Text('添加', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    // 修改+删除按钮(仅编辑模式)
                    if (state.isEditMode) ...[
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            vm.updateMoney(_moneyController.text);
                            vm.updateState(_stateController.text);
                            final ok = await vm.update();
                            if (!ok && context.mounted && state.error != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(state.error!)),
                              );
                            }
                          },
                          child: const Text('修改'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final ok = await vm.delete();
                            if (!ok && context.mounted && state.error != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(state.error!)),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.expenseOrange),
                          child: const Text('删除', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text, style: const TextStyle(fontSize: 16, color: Colors.black87)),
    );
  }

  /// 日期选择 - 对齐 ManageActivity.java:246-251 DatePickerDialog
  Future<void> _pickDate(BuildContext context, TallyViewModel vm) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      // 格式 yyyy-MM-dd - 对齐 ManageActivity.java:410-420 onDateSet
      final m = picked.month.toString().padLeft(2, '0');
      final d = picked.day.toString().padLeft(2, '0');
      final dateStr = '${picked.year}-$m-$d';
      vm.updateDate(dateStr);
      _dateController.text = dateStr;
    }
  }
}
