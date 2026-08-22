// 记账 ViewModel - 对齐 Android ManageActivity.java
// 数据流: loadTally → showAddDialog/showEditDialog → add/update/delete → loadTally 刷新
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tally_bean.dart';
import '../repositories/tally_repository.dart';
import 'tally_state.dart';

export 'tally_state.dart';

class TallyViewModel extends Notifier<TallyState> {
  final TallyRepository _repository = TallyRepository();

  @override
  TallyState build() {
    Future.microtask(loadTally);
    return const TallyState(isLoading: true);
  }

  /// 加载记账列表 - 对齐 ManageActivity.java:225-234 showQueryData
  Future<void> loadTally() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final list = await _repository.queryTally();
      state = state.copyWith(tallyList: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 显示新增弹层 - 对齐 ManageActivity.java manage_add onClick
  void showAddDialog() {
    state = TallyState(
      tallyList: state.tallyList,
      isDialogVisible: true,
      isEditMode: false,
      editingId: null,
      date: '',
      type: '支出',
      money: '',
      state: '',
    );
  }

  /// 显示编辑弹层 - 对齐 ManageActivity.java:125-164 点击列表项
  void showEditDialog(Tally tally) {
    state = state.copyWith(
      tallyList: state.tallyList,
      isDialogVisible: true,
      isEditMode: true,
      editingId: tally.id,
      date: tally.tallyTime,
      type: tally.tallyType,
      money: tally.tallyMoney.toString(),
      state: tally.tallyState,
    );
  }

  /// 隐藏弹层 - 对齐 ManageActivity.java:197-205 hideDialog
  void hideDialog() {
    state = state.copyWith(
      isDialogVisible: false,
      isEditMode: false,
      editingId: null,
      date: '',
      type: '支出',
      money: '',
      state: '',
    );
  }

  /// 更新表单字段
  void updateDate(String d) => state = state.copyWith(date: d);
  void updateType(String t) => state = state.copyWith(type: t);
  void updateMoney(String m) => state = state.copyWith(money: m);
  void updateState(String s) => state = state.copyWith(state: s);

  /// 校验输入 - 对齐 ManageActivity.java:366-398 validateInput
  String? validateInput() {
    if (state.date.isEmpty) return '请选择日期';
    if (state.money.isEmpty) return '请输入金额';
    final money = double.tryParse(state.money);
    if (money == null) return '金额格式不正确';
    if (state.state.isEmpty) return '请输入说明';
    return null;
  }

  /// 新增 - 对齐 ManageActivity.java:335-364 add
  Future<bool> add() async {
    final err = validateInput();
    if (err != null) {
      state = state.copyWith(error: err);
      return false;
    }
    try {
      await _repository.insertTally(
        state.date,
        state.type,
        double.parse(state.money),
        state.state,
      );
      await loadTally();
      hideDialog();
      return true;
    } catch (e) {
      state = state.copyWith(error: '添加失败: $e');
      return false;
    }
  }

  /// 修改 - 对齐 ManageActivity.java:300-333 update
  Future<bool> update() async {
    if (state.editingId == null) return false;
    final err = validateInput();
    if (err != null) {
      state = state.copyWith(error: err);
      return false;
    }
    try {
      await _repository.updateTally(
        state.editingId!,
        state.date,
        state.type,
        double.parse(state.money),
        state.state,
      );
      await loadTally();
      hideDialog();
      return true;
    } catch (e) {
      state = state.copyWith(error: '修改失败: $e');
      return false;
    }
  }

  /// 删除 - 对齐 ManageActivity.java:275-298 delete
  Future<bool> delete() async {
    if (state.editingId == null) return false;
    try {
      await _repository.deleteTally(state.editingId!);
      await loadTally();
      hideDialog();
      return true;
    } catch (e) {
      state = state.copyWith(error: '删除失败: $e');
      return false;
    }
  }

  /// 删除列表项 - 对齐 ManageActivity.java 长按删除
  Future<void> deleteItem(int id) async {
    await _repository.deleteTally(id);
    await loadTally();
  }
}

/// 记账 ViewModel Provider
final tallyViewModelProvider =
    NotifierProvider<TallyViewModel, TallyState>(TallyViewModel.new);
