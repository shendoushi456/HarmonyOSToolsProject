import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../router/route_names.dart';
import '../models/expense_models.dart';
import '../viewmodels/expense_state.dart';
import '../viewmodels/expense_view_model.dart';

const _pageBackground = Color(0xFFD8EFFF);
const _textPrimary = Color(0xFF222222);
const _accent = Color(0xFF2575DB);
const _progressBlue = Color(0xFF62A2F3);
const _onBlueSecondary = Color(0xFFE4F2FF);
const _dangerRed = Color(0xFFB3261E);

/// 花费记账首页 UI。
///
/// 对齐 Android ExpenseFragment：顶部标题、月度汇总卡、记录数卡、
/// 按日分组的账单卡片与上限/详情/删除弹窗。
/// 业务逻辑全部在 [ExpenseViewModel]，本文件只负责展示与事件收集。
class ExpensePage extends ConsumerStatefulWidget {
  const ExpensePage({super.key});

  @override
  ConsumerState<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends ConsumerState<ExpensePage> {
  /// 上一次超限检测的三元组，用于对齐 Android LaunchedEffect 触发条件。
  bool? _lastOverLimit;
  int _lastMonthlyExpenseCents = -1;
  int _lastMonthlyLimitCents = -1;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(expenseViewModelProvider);
    final viewModel = ref.read(expenseViewModelProvider.notifier);
    _maybeShowOverLimitToast(state);

    final isOverLimit =
        state.monthlyLimitCents > 0 && state.monthlyExpenseCents > state.monthlyLimitCents;
    final recordCount =
        state.dayGroups.fold(0, (sum, group) => sum + group.records.length);

    return Scaffold(
      backgroundColor: _pageBackground,
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: _accent))
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  const _ExpenseHeader(),
                  _ExpenseSummaryCard(state: state),
                  const SizedBox(height: 15),
                  if (isOverLimit) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 2),
                      child: Text(
                        '本月支出已超出上限 '
                        '${_formatMoney(state.monthlyExpenseCents - state.monthlyLimitCents)}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: _dangerRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  _ExpenseRecordCountCard(
                    count: recordCount,
                    period: state.selectedPeriod,
                    onAddClick: () => context.push(RoutePaths.expenseAdd),
                  ),
                  const SizedBox(height: 10),
                  ..._buildContent(state, viewModel),
                ],
              ),
            ),
    );
  }

  List<Widget> _buildContent(
      ExpenseState state, ExpenseViewModel viewModel) {
    if (state.isLoading) {
      return const [_ExpenseLoadingContent()];
    }
    if (state.errorMessage != null && state.dayGroups.isEmpty) {
      return [
        _ExpenseMessageCard(
          title: '账单加载失败',
          description: state.errorMessage!,
          actionText: '重新加载',
          onAction: viewModel.retry,
        ),
      ];
    }
    if (state.isEmpty) {
      return const [
        _ExpenseMessageCard(title: '还没有账单记录', description: '点击上方加号开始记账'),
      ];
    }
    return [
      ...state.dayGroups.map((group) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ExpenseDayCard(
              group: group,
              onRecordClick: (record) => _showDetailDialog(context, record),
              onRecordLongClick: (record) =>
                  _showDeleteDialog(context, viewModel, record),
            ),
          )),
    ];
  }

  /// 对齐 Android：超限状态下任一相关值变化即弹出提示。
  void _maybeShowOverLimitToast(ExpenseState state) {
    final over = state.monthlyLimitCents > 0 &&
        state.monthlyExpenseCents > state.monthlyLimitCents;
    final changed = _lastOverLimit != null &&
        (over != _lastOverLimit ||
            state.monthlyExpenseCents != _lastMonthlyExpenseCents ||
            state.monthlyLimitCents != _lastMonthlyLimitCents);
    if (changed && over) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
              const SnackBar(content: Text('本月支出已超出设置上限')));
      });
    }
    _lastOverLimit = over;
    _lastMonthlyExpenseCents = state.monthlyExpenseCents;
    _lastMonthlyLimitCents = state.monthlyLimitCents;
  }

  void _showDetailDialog(BuildContext context, ExpenseRecord record) {
    final visual = categoryVisual(record);
    final typeText =
        record.typeCode == ExpenseRecord.typeExpense ? '支出' : '收入';
    final buffer = StringBuffer()
      ..write('类型：$typeText\n')
      ..write('分类：${visual.label}\n')
      ..write('金额：${_formatMoney(record.amountCents)}\n')
      ..write('时间：${_formatRecordTime(record.occurredAt)}');
    if (record.note.trim().isNotEmpty) {
      buffer.write('\n备注：${record.note}');
    }
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('账单详情',
            style: TextStyle(fontWeight: FontWeight.w600, color: _textPrimary)),
        content: Text(buffer.toString(),
            style: const TextStyle(
                fontSize: 14, height: 23 / 14, color: _textPrimary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('知道了', style: TextStyle(color: _accent)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, ExpenseViewModel viewModel, ExpenseRecord record) {
    final visual = categoryVisual(record);
    final description = record.note.trim().isEmpty
        ? '${visual.label} ${_formatRecordMoney(record)}'
        : '${visual.label} · ${record.note} ${_formatRecordMoney(record)}';
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('删除账单',
            style: TextStyle(fontWeight: FontWeight.w600)),
        content: Text('确定删除这条账单吗？\n$description'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('删除', style: TextStyle(color: _dangerRed)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消', style: TextStyle(color: _accent)),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        viewModel.deleteRecord(record.id);
      }
    });
  }
}

// ==================== 顶部标题 ====================

class _ExpenseHeader extends StatelessWidget {
  const _ExpenseHeader();

  @override
  Widget build(BuildContext context) => const SizedBox(
        width: double.infinity,
        height: 64,
        child: Center(
          child: Text(
            '花费记账',
            style: TextStyle(
              fontSize: 22,
              color: _textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
}

// ==================== 汇总卡 ====================

class _ExpenseSummaryCard extends ConsumerWidget {
  final ExpenseState state;

  const _ExpenseSummaryCard({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final dayCount = _dayCountOf(state.selectedPeriod, now);
    final averageCents = state.totalExpenseCents ~/ (dayCount < 1 ? 1 : dayCount);
    final progress = state.monthlyLimitCents > 0
        ? (state.monthlyExpenseCents / state.monthlyLimitCents).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 175,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: _accent,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color(0x66999999), blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => _showLimitDialog(context, ref),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 27,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '设置上限',
                    style: TextStyle(
                        fontSize: 10,
                        color: _textPrimary,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _PeriodDropdown(
                selectedPeriod: state.selectedPeriod,
                onPeriodClick: ref
                    .read(expenseViewModelProvider.notifier)
                    .selectPeriod,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SummaryValue(
                  label: '${state.selectedPeriod.summaryPrefix}支出',
                  value: _formatMoney(state.totalExpenseCents),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 26),
                  child: _SummaryValue(
                    label: '日均支出',
                    value: _formatMoney(averageCents),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              height: 10,
              child: LinearProgressIndicator(
                value: progress,
                color: _progressBlue,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: double.infinity,
            child: Text(
              state.monthlyLimitCents > 0
                  ? '本月支出${_formatMoney(state.monthlyExpenseCents)}/${_formatMoney(state.monthlyLimitCents)}'
                  : '本月支出${_formatMoney(state.monthlyExpenseCents)} / 暂未设置上限',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, color: _onBlueSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              maxLines: 1,
              style: const TextStyle(fontSize: 10, color: _onBlueSecondary)),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 24,
              height: 28 / 24,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
}

/// 周期下拉 - 对齐 PeriodDropdown（白胶囊 + 下拉菜单）。
class _PeriodDropdown extends StatelessWidget {
  final ExpensePeriod selectedPeriod;
  final ValueChanged<ExpensePeriod> onPeriodClick;

  const _PeriodDropdown({
    required this.selectedPeriod,
    required this.onPeriodClick,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ExpensePeriod>(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: EdgeInsets.zero,
      position: PopupMenuPosition.under,
      onSelected: (period) => onPeriodClick(period),
      itemBuilder: (context) => ExpensePeriod.values
          .map((period) => PopupMenuItem(
                value: period,
                child: Text(
                  '${period.tabText}区间 · ${_periodRangeText(period)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: period == selectedPeriod ? _accent : _textPrimary,
                    fontWeight: period == selectedPeriod
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ))
          .toList(),
      child: Container(
        height: 27,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_periodRangeText(selectedPeriod),
                maxLines: 1,
                style: const TextStyle(fontSize: 10, color: _textPrimary)),
            const SizedBox(width: 8),
            const Text('▼',
                style: TextStyle(fontSize: 8, color: _textPrimary)),
          ],
        ),
      ),
    );
  }
}

// ==================== 记录数卡 ====================

class _ExpenseRecordCountCard extends StatelessWidget {
  final int count;
  final ExpensePeriod period;
  final VoidCallback onAddClick;

  const _ExpenseRecordCountCard({
    required this.count,
    required this.period,
    required this.onAddClick,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: _accent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
                color: Color(0x66999999), blurRadius: 8, offset: Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            Image.asset(AppAssets.expenseRecords, width: 42, height: 42),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  '${period.summaryPrefix}共计$count笔记录',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      const TextStyle(fontSize: 15, color: _onBlueSecondary),
                ),
              ),
            ),
            GestureDetector(
              onTap: onAddClick,
              behavior: HitTestBehavior.opaque,
              child: ClipOval(
                child: SizedBox(
                  width: 38,
                  height: 38,
                  child: Image.asset(AppAssets.expenseAdd),
                ),
              ),
            ),
          ],
        ),
      );
}

// ==================== 日卡片 ====================

class _ExpenseDayCard extends StatelessWidget {
  final ExpenseDayGroup group;
  final ValueChanged<ExpenseRecord> onRecordClick;
  final ValueChanged<ExpenseRecord> onRecordLongClick;

  const _ExpenseDayCard({
    required this.group,
    required this.onRecordClick,
    required this.onRecordLongClick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color(0x66999999), blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 41,
            padding: const EdgeInsets.symmetric(horizontal: 11),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FBFF),
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _formatDay(group.day),
                    maxLines: 1,
                    style: const TextStyle(
                        fontSize: 14,
                        color: _accent,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 190),
                  child: Text(
                    _formatDaySummary(group),
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14,
                        color: _accent,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 13, 12),
            child: Column(
              children: [
                for (var index = 0; index < group.records.length; index++) ...[
                  if (index > 0) const SizedBox(height: 10),
                  _ExpenseRecordRow(
                    record: group.records[index],
                    onClick: () => onRecordClick(group.records[index]),
                    onLongClick: () => onRecordLongClick(group.records[index]),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseRecordRow extends StatelessWidget {
  final ExpenseRecord record;
  final VoidCallback onClick;
  final VoidCallback onLongClick;

  const _ExpenseRecordRow({
    required this.record,
    required this.onClick,
    required this.onLongClick,
  });

  @override
  Widget build(BuildContext context) {
    final visual = categoryVisual(record);
    return GestureDetector(
      onTap: onClick,
      onLongPress: onLongClick,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 47,
        child: Row(
          children: [
            Image.asset(visual.iconAsset, width: 45, height: 45),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    visual.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14,
                        color: _textPrimary,
                        fontWeight: FontWeight.w600),
                  ),
                  if (record.note.trim().isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      record.note,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14,
                          color: _accent,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _formatRecordMoney(record),
              style: const TextStyle(
                  fontSize: 14,
                  color: _textPrimary,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== 空态/加载/错误 ====================

class _ExpenseLoadingContent extends StatelessWidget {
  const _ExpenseLoadingContent();

  @override
  Widget build(BuildContext context) => const SizedBox(
        width: double.infinity,
        height: 130,
        child: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: _accent,
            ),
          ),
        ),
      );
}

class _ExpenseMessageCard extends StatelessWidget {
  final String title;
  final String description;
  final String? actionText;
  final VoidCallback? onAction;

  const _ExpenseMessageCard({
    required this.title,
    required this.description,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        height: 130,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16,
                      color: _textPrimary,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 7),
              Text(description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: _accent)),
              if (actionText != null && onAction != null) ...[
                const SizedBox(height: 9),
                GestureDetector(
                  onTap: onAction,
                  child: Text(actionText!,
                      style: const TextStyle(
                          fontSize: 14,
                          color: _accent,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ],
          ),
        ),
      );
}

// ==================== 上限设置弹窗 ====================

void _showLimitDialog(BuildContext context, WidgetRef ref) {
  final state = ref.read(expenseViewModelProvider);
  final viewModel = ref.read(expenseViewModelProvider.notifier);
  final controller = TextEditingController(
    text: state.monthlyLimitCents > 0
        ? _formatEditableMoney(state.monthlyLimitCents)
        : '',
  );
  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      String? errorText;
      return StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('设置本月支出上限',
              style:
                  TextStyle(fontWeight: FontWeight.w600, color: _textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: _pageBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Row(
                  children: [
                    const Text('¥',
                        style: TextStyle(
                            fontSize: 18,
                            color: _accent,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        autofocus: true,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style: const TextStyle(
                            fontSize: 18,
                            color: _textPrimary,
                            fontWeight: FontWeight.w500),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isCollapsed: true,
                          hintText: '请输入金额',
                          hintStyle: TextStyle(
                              fontSize: 16, color: Color(0xFF888888)),
                        ),
                        onChanged: (value) {
                          if (RegExp(r'^\d{0,9}(\.\d{0,2})?$').hasMatch(value)) {
                            setDialogState(() => errorText = null);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              if (errorText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(errorText!,
                      style:
                          const TextStyle(fontSize: 12, color: _dangerRed)),
                ),
            ],
          ),
          actions: [
            if (state.monthlyLimitCents > 0)
              TextButton(
                onPressed: () {
                  viewModel.saveMonthlyLimit(0);
                  Navigator.pop(dialogContext);
                },
                child: const Text('清除上限',
                    style: TextStyle(color: _dangerRed)),
              ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child:
                  const Text('取消', style: TextStyle(color: _textPrimary)),
            ),
            TextButton(
              onPressed: () {
                final cents = _toLimitCentsOrNull(controller.text);
                if (cents == null || cents <= 0) {
                  setDialogState(() => errorText = '请输入大于0的有效金额');
                  return;
                }
                viewModel.saveMonthlyLimit(cents);
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                      const SnackBar(content: Text('本月支出上限已保存')));
              },
              child: const Text('保存',
                  style:
                      TextStyle(color: _accent, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
    },
  );
}

// ==================== 分类映射与格式化 ====================

class ExpenseCategoryVisual {
  final String label;
  final String iconAsset;
  const ExpenseCategoryVisual(this.label, this.iconAsset);
}

/// 分类 → 展示文案与图标 - 对齐 Android categoryVisual。
ExpenseCategoryVisual categoryVisual(ExpenseRecord record) {
  final code = record.categoryCode.trim().toLowerCase();
  switch (code) {
    case 'shopping':
    case '购物':
    case 'transport':
    case '交通':
    case 'entertainment':
    case '娱乐':
    case 'other':
    case '其他':
      return const ExpenseCategoryVisual('购物', AppAssets.expenseShopping);
    case 'meal':
    case 'food':
    case '餐饮':
    case '吃饭':
      return const ExpenseCategoryVisual('餐饮', AppAssets.expenseMeal);
    case 'phone':
    case 'mobile':
    case '话费':
      return const ExpenseCategoryVisual('话费', AppAssets.expensePhone);
    case 'salary':
    case 'income':
    case '工资':
    case '工资收入':
    case 'other_income':
    case '其他收入':
      return const ExpenseCategoryVisual('工资收入', AppAssets.expenseIncome);
    default:
      if (record.typeCode == ExpenseRecord.typeIncome) {
        return ExpenseCategoryVisual(
            record.categoryCode.trim().isEmpty ? '收入' : record.categoryCode,
            AppAssets.expenseIncome);
      }
      return ExpenseCategoryVisual(
          record.categoryCode.trim().isEmpty ? '其他' : record.categoryCode,
          AppAssets.expenseShopping);
  }
}

/// 分 → "¥xx.xx"，两位小数四舍五入 - 对齐 formatMoney。
String _formatMoney(int cents) {
  final safe = cents < 0 ? 0 : cents;
  final yuan = safe ~/ 100;
  final remainder = ((safe % 100) + 0.5).round();
  // 进位处理
  var y = yuan;
  var r = remainder;
  if (r >= 100) {
    y += 1;
    r = 0;
  }
  return '¥$y.${r.toString().padLeft(2, '0')}';
}

/// 分 → 可编辑金额文本（去尾零）- 对齐 formatEditableMoney。
String _formatEditableMoney(int cents) {
  final yuan = cents ~/ 100;
  final remainder = cents % 100;
  if (remainder == 0) return '$yuan';
  if (remainder % 10 == 0) return '$yuan.${remainder ~/ 10}';
  return '$yuan.${remainder.toString().padLeft(2, '0')}';
}

/// 记录金额：支出带"−"前缀，均不带"¥" - 对齐 formatRecordMoney。
String _formatRecordMoney(ExpenseRecord record) {
  final prefix = record.typeCode == ExpenseRecord.typeExpense ? '−' : '';
  return '$prefix${_formatMoney(record.amountCents).replaceFirst('¥', '')}';
}

/// 日汇总："支出：xx  收入：xx" - 对齐 formatDaySummary。
String _formatDaySummary(ExpenseDayGroup group) {
  final buffer = StringBuffer();
  if (group.expenseCents > 0 || group.incomeCents == 0) {
    buffer.write(
        '支出：${_formatMoney(group.expenseCents).replaceFirst('¥', '')}');
  }
  if (group.incomeCents > 0) {
    if (buffer.isNotEmpty) buffer.write('  ');
    buffer.write(
        '收入：${_formatMoney(group.incomeCents).replaceFirst('¥', '')}');
  }
  return buffer.toString();
}

/// "M月d日 EEEE"（星期） - 对齐 ExpenseDayFormatter。
String _formatDay(DateTime day) {
  const weekLabels = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
  return '${day.month}月${day.day}日 ${weekLabels[day.weekday - 1]}';
}

/// "yyyy年M月d日 HH:mm" - 对齐 ExpenseRecordTimeFormatter。
String _formatRecordTime(DateTime value) =>
    '${value.year}年${value.month}月${value.day}日 '
    '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

/// 周期按钮文本 - 对齐 periodRangeText。
String _periodRangeText(ExpensePeriod period) {
  final today = DateTime.now();
  switch (period) {
    case ExpensePeriod.year:
      return '${today.year}年';
    case ExpensePeriod.month:
      return '${today.year}年${today.month}月';
    case ExpensePeriod.week:
      final start =
          DateTime(today.year, today.month, today.day)
              .subtract(Duration(days: today.weekday - 1));
      final end = start.add(const Duration(days: 6));
      return '${start.month}月${start.day}日-${end.month}月${end.day}日';
    case ExpensePeriod.day:
      return '${today.month}月${today.day}日';
  }
}

/// 元文本 → 分，校验失败返回 null - 对齐 toLimitCentsOrNull。
int? _toLimitCentsOrNull(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return null;
  final parts = trimmed.split('.');
  if (parts.length > 2) return null;
  final yuan = int.tryParse(parts[0]);
  if (yuan == null) return null;
  var cents = yuan * 100;
  if (parts.length == 2) {
    final fraction = parts[1];
    if (fraction.isEmpty) return cents;
    if (fraction.length == 1) {
      cents += int.parse(fraction) * 10;
    } else if (fraction.length == 2) {
      cents += int.parse(fraction);
    } else {
      return null;
    }
  }
  return cents;
}

int _lengthOfYear(int year) =>
    (year % 4 == 0 && year % 100 != 0) || year % 400 == 0 ? 366 : 365;

int _lengthOfMonth(int year, int month) {
  if (month == 12) return 31;
  return DateTime(year, month + 1, 0).day;
}

/// 周期对应天数 - 对齐 Android summaryCard 的 dayCount。
int _dayCountOf(ExpensePeriod period, DateTime now) {
  switch (period) {
    case ExpensePeriod.year:
      return _lengthOfYear(now.year);
    case ExpensePeriod.month:
      return _lengthOfMonth(now.year, now.month);
    case ExpensePeriod.week:
      return 7;
    case ExpensePeriod.day:
      return 1;
  }
}
