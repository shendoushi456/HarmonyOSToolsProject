// 日历页子 Widget 集合 - 对齐 Android CalendarFragment 的 Composable
// 包含: CalendarHeader/Card/Week/InfoCard/HistoryList/HistoryDetailDialog
//       ExpenseContent/ExpenseDialog/ExpenseDatePickerRow/ExpenseInputRow/TypeButton/ActionButton
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/lunar_util.dart';
import '../../models/calendar_tab.dart';
import '../../models/expense_entry.dart';
import '../../models/history_event.dart';

// ==================== 基础组件 ====================

/// 类型按钮 - 对齐 Android TypeButton(行 903-925)
/// 52x20dp,圆角 3,选中蓝底白字
class TypeButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onClick;

  const TypeButton({
    super.key,
    required this.text,
    required this.selected,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        width: 52,
        height: 20,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.calendarBlue : const Color(0xFFECECEC),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF787878),
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

/// 操作按钮 - 对齐 Android ActionButton(行 927-951)
/// 64x28dp,圆角 4,蓝底白字(禁用灰)
class ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onClick;
  final bool enabled;

  const ActionButton({
    super.key,
    required this.text,
    required this.onClick,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onClick : null,
      child: Container(
        width: 64,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? AppColors.calendarBlue : const Color(0xFFCFCFCF),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// 记账输入框行 - 对齐 Android ExpenseInputRow(行 845-901)
/// 标签(58宽) + 输入框(底部 1dp 线)
class ExpenseInputRow extends StatelessWidget {
  final String label;
  final String value;
  final String hint;
  final TextInputType keyboardType;
  final void Function(String) onValueChange;

  const ExpenseInputRow({
    super.key,
    required this.label,
    required this.value,
    required this.hint,
    this.keyboardType = TextInputType.text,
    required this.onValueChange,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 58,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.calendarText,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 30,
              child: Stack(
                children: [
                  // TextField - 用自带 hintText,避免叠加 Widget 拦截点击
                  TextField(
                    controller: TextEditingController(text: value)
                      ..selection = TextSelection.fromPosition(
                        TextPosition(offset: value.length),
                      ),
                    onChanged: onValueChange,
                    maxLines: 1,
                    keyboardType: keyboardType,
                    style: const TextStyle(
                      color: AppColors.calendarText,
                      fontSize: 13,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      hintText: hint,
                      hintStyle: const TextStyle(
                        color: Color(0xFF777777),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  // 底部 1dp 线 - 仅占底部,不影响 TextField 点击
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(height: 1, color: const Color(0xFFE0E0E0)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 记账日期选择行 - 对齐 Android ExpenseDatePickerRow(行 775-843)
class ExpenseDatePickerRow extends StatelessWidget {
  final String value;
  final DateTime fallbackDate;
  final void Function(String) onDateSelected;

  const ExpenseDatePickerRow({
    super.key,
    required this.value,
    required this.fallbackDate,
    required this.onDateSelected,
  });

  Future<void> _openDatePicker(BuildContext context) async {
    final initialDate = DateTime.tryParse(value) ?? fallbackDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onDateSelected(picked.toIso8601String().split('T').first);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: 58,
            child: Text(
              '日期：',
              style: TextStyle(
                color: AppColors.calendarText,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _openDatePicker(context),
              child: SizedBox(
                height: 30,
                child: Stack(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            value.isEmpty ? '请选择日期' : value,
                            style: TextStyle(
                              color: value.isEmpty
                                  ? const Color(0xFF777777)
                                  : AppColors.calendarText,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const Text(
                          '选择',
                          style: TextStyle(
                            color: AppColors.calendarBlue,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(height: 1, color: const Color(0xFFE0E0E0)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 列表组件 ====================

/// 历史上的今天列表 - 对齐 Android HistoryList(行 476-524)
class HistoryList extends StatelessWidget {
  final DateTime selectedDate;
  final List<HistoryEvent> events;
  final bool loading;
  final void Function(HistoryEvent) onHistoryClick;

  const HistoryList({
    super.key,
    required this.selectedDate,
    required this.events,
    required this.loading,
    required this.onHistoryClick,
  });

  @override
  Widget build(BuildContext context) {
    if (loading || events.isEmpty) {
      return Center(
        child: Text(
          loading
              ? '正在获取真实历史数据…'
              : '${selectedDate.month}月${selectedDate.day}日暂无历史数据',
          style: const TextStyle(color: AppColors.calendarHint, fontSize: 14),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Column(
          children: [
            InkWell(
              onTap: () => onHistoryClick(event),
              child: SizedBox(
                height: 43,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    event.name,
                    style: const TextStyle(
                      color: AppColors.calendarText,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            Container(height: 1, color: AppColors.calendarDivider),
          ],
        );
      },
    );
  }
}

/// 历史详情弹窗 - 对齐 Android HistoryDetailDialog(行 526-570)
class HistoryDetailDialog extends StatelessWidget {
  final HistoryEvent event;
  final VoidCallback onDismiss;

  const HistoryDetailDialog({
    super.key,
    required this.event,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.name,
              style: const TextStyle(
                color: AppColors.calendarText,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 18),
              child: Text(
                event.detail.isEmpty ? event.name : event.detail,
                style: const TextStyle(
                  color: Color(0xFF4A4A4A),
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 24),
                child: GestureDetector(
                  onTap: onDismiss,
                  child: Container(
                    width: 72,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.calendarBlue,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '关闭',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 记账列表内容 - 对齐 Android ExpenseContent(行 572-664)
class ExpenseContent extends StatelessWidget {
  final List<ExpenseEntry> entries;
  final VoidCallback onAdd;
  final void Function(ExpenseEntry) onEdit;

  const ExpenseContent({
    super.key,
    required this.entries,
    required this.onAdd,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 32),
            child: Text(
              entries.isEmpty ? '暂无记账' : '记账记录',
              style: const TextStyle(
                color: AppColors.calendarText,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (entries.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 18),
              child: Text(
                '点击下方按钮添加收入或支出',
                style: TextStyle(color: AppColors.calendarHint, fontSize: 14),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 15),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return InkWell(
                    onTap: () => onEdit(entry),
                    child: SizedBox(
                      height: 54,
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 24,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: entry.income
                                  ? AppColors.calendarBlue
                                  : AppColors.qmtqOrange,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              entry.income ? '收入' : '支出',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.note.isEmpty ? '未填写说明' : entry.note,
                                    style: const TextStyle(
                                      color: AppColors.calendarText,
                                      fontSize: 15,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    entry.date,
                                    style: const TextStyle(
                                      color: AppColors.calendarHint,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Text(
                            '${entry.income ? '+' : '-'}¥${entry.amount}',
                            style: TextStyle(
                              color: entry.income
                                  ? AppColors.calendarBlue
                                  : AppColors.expenseOrange,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: 30, top: 12),
            child: ActionButton(text: '添加', onClick: onAdd),
          ),
        ],
      ),
    );
  }
}

/// 记账弹窗 - 对齐 Android ExpenseDialog(行 666-773)
class ExpenseDialog extends StatefulWidget {
  final DateTime selectedDate;
  final ExpenseEntry? editingEntry;
  final VoidCallback onDismiss;
  final void Function(ExpenseEntry) onAdd;
  final void Function(ExpenseEntry) onModify;
  final void Function(ExpenseEntry) onDelete;

  const ExpenseDialog({
    super.key,
    required this.selectedDate,
    this.editingEntry,
    required this.onDismiss,
    required this.onAdd,
    required this.onModify,
    required this.onDelete,
  });

  @override
  State<ExpenseDialog> createState() => _ExpenseDialogState();
}

class _ExpenseDialogState extends State<ExpenseDialog> {
  late String _date;
  late bool _income;
  late String _amount;
  late String _note;

  @override
  void initState() {
    super.initState();
    _date = widget.editingEntry?.date ??
        widget.selectedDate.toIso8601String().split('T').first;
    _income = widget.editingEntry?.income ?? true;
    _amount = widget.editingEntry?.amount ?? '';
    _note = widget.editingEntry?.note ?? '';
  }

  String _normalizeDate(String value) {
    try {
      return DateTime.parse(value).toIso8601String().split('T').first;
    } catch (_) {
      return widget.selectedDate.toIso8601String().split('T').first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.only(left: 28, right: 28, top: 28, bottom: 26),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.editingEntry == null ? '添加记账支出' : '修改记账内容',
                style: const TextStyle(
                  color: AppColors.calendarText,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              ExpenseDatePickerRow(
                value: _date,
                fallbackDate: widget.selectedDate,
                onDateSelected: (v) => setState(() => _date = v),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 22),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 58,
                      child: Text(
                        '类型：',
                        style: TextStyle(
                          color: AppColors.calendarText,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TypeButton(
                      text: '收入',
                      selected: _income,
                      onClick: () => setState(() => _income = true),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: TypeButton(
                        text: '支出',
                        selected: !_income,
                        onClick: () => setState(() => _income = false),
                      ),
                    ),
                  ],
                ),
              ),
              ExpenseInputRow(
                label: '金额：',
                value: _amount,
                hint: '请输入金额',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onValueChange: (v) => _amount = v,
              ),
              ExpenseInputRow(
                label: '说明：',
                value: _note,
                hint: '说明来源或用途',
                onValueChange: (v) => _note = v,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ActionButton(
                      text: '添加',
                      onClick: () {
                        if (_amount.trim().isNotEmpty) {
                          widget.onAdd(ExpenseEntry(
                            id: DateTime.now().millisecondsSinceEpoch,
                            date: _normalizeDate(_date),
                            income: _income,
                            amount: _amount,
                            note: _note,
                          ));
                        }
                      },
                    ),
                    ActionButton(
                      text: '修改',
                      enabled: widget.editingEntry != null,
                      onClick: () {
                        final entry = widget.editingEntry;
                        if (entry != null) {
                          widget.onModify(ExpenseEntry(
                            id: entry.id,
                            date: _normalizeDate(_date),
                            income: _income,
                            amount: _amount,
                            note: _note,
                          ));
                        }
                      },
                    ),
                    ActionButton(
                      text: '删除',
                      enabled: widget.editingEntry != null,
                      onClick: () {
                        final entry = widget.editingEntry;
                        if (entry != null) widget.onDelete(entry);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== 日历核心组件 ====================

/// 单周日历行 - 对齐 Android CalendarWeek(行 340-410)
class CalendarWeek extends StatelessWidget {
  final List<DateTime> dates;
  final DateTime displayMonth;
  final DateTime selectedDate;
  final double rowHeight;
  final Map<DateTime, String> lunarLabels;
  final void Function(DateTime) onSelectDate;

  const CalendarWeek({
    super.key,
    required this.dates,
    required this.displayMonth,
    required this.selectedDate,
    required this.rowHeight,
    required this.lunarLabels,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    // 选中周:选中日期在本周内时高亮
    final bool isWeekSelected = dates.contains(selectedDate);

    return SizedBox(
      height: rowHeight,
      child: Stack(
        children: [
          // 选中周背景图
          if (isWeekSelected)
            Positioned.fill(
              child: Image.asset(
                AppAssets.calendarWeekHighlight,
                fit: BoxFit.fill,
              ),
            ),
          // 7 个日期 - 用 spaceBetween 对齐星期行
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: dates.map((date) {
              final isSelected = date == selectedDate;
              final isOffMonth =
                  date.year != displayMonth.year || date.month != displayMonth.month;
              return GestureDetector(
                onTap: () => onSelectDate(date),
                child: SizedBox(
                  width: 36,
                  height: rowHeight,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 选中日圆形背景
                      if (isSelected)
                        Container(
                          width: rowHeight < 36 ? 29 : 36,
                          height: rowHeight < 36 ? 29 : 36,
                          decoration: const BoxDecoration(
                            color: AppColors.calendarBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      // 日期数字 + 农历
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            date.day.toString(),
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : isOffMonth
                                      ? AppColors.calendarOffMonth
                                      : isWeekSelected
                                          ? AppColors.calendarDateBlue
                                          : AppColors.calendarText,
                              fontSize: rowHeight < 36 ? 11 : 12,
                            ),
                          ),
                          Text(
                            lunarLabels[date] ?? '',
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : isOffMonth
                                      ? AppColors.calendarOffMonth
                                      : isWeekSelected
                                          ? AppColors.calendarDateBlue
                                          : AppColors.calendarText,
                              fontSize: rowHeight < 36 ? 7 : 8,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// 日历卡片 - 对齐 Android CalendarCard(行 241-338)
class CalendarCard extends StatelessWidget {
  final DateTime displayMonth;
  final DateTime selectedDate;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final void Function(DateTime) onSelectDate;

  const CalendarCard({
    super.key,
    required this.displayMonth,
    required this.selectedDate,
    required this.onPrevious,
    required this.onNext,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    final first = DateTime(displayMonth.year, displayMonth.month, 1);
    // Dart weekday: Mon=1..Sun=7,offset = weekday - 1
    final offset = first.weekday - 1;
    final start = first.subtract(Duration(days: offset));
    // 本月天数(下个月第 0 天)
    final monthLength =
        DateTime(displayMonth.year, displayMonth.month + 1, 0).day;
    final rowCount = ((offset + monthLength + 6) ~/ 7);
    final rows = rowCount < 5 ? 5 : rowCount;
    final rowHeight = rows > 5 ? 29.0 : 36.0;
    final dates = List.generate(rows * 7, (i) => start.add(Duration(days: i)));
    // 农历标签
    final lunarLabels = {for (final d in dates) d: LunarUtil.lunarLabel(d)};

    return SizedBox(
      width: 335,
      height: 328,
      child: Stack(
        children: [
          // 背景图
          Positioned.fill(
            child: Image.asset(AppAssets.calendarCard, fit: BoxFit.fill),
          ),
          // 内容
          Padding(
            padding: const EdgeInsets.only(left: 13, right: 13, top: 46, bottom: 21),
            child: Column(
              children: [
                // 月份切换行
                SizedBox(
                  height: 36,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: onPrevious,
                          child: Image.asset(
                            AppAssets.calendarLeft,
                            width: 28,
                            height: 28,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          '${displayMonth.year}.${displayMonth.month}',
                          style: const TextStyle(
                            color: AppColors.calendarText,
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: onNext,
                          child: Image.asset(
                            AppAssets.calendarRight,
                            width: 28,
                            height: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // 周几标题
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: SizedBox(
                    height: 24,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                          .map((d) => SizedBox(
                                width: 36,
                                child: Text(
                                  d,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.calendarText,
                                    fontSize: 13,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
                // 日期网格
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    children: List.generate(rows, (rowIndex) {
                      final weekDates =
                          dates.sublist(rowIndex * 7, (rowIndex + 1) * 7);
                      return CalendarWeek(
                        dates: weekDates,
                        displayMonth: displayMonth,
                        selectedDate: selectedDate,
                        rowHeight: rowHeight,
                        lunarLabels: lunarLabels,
                        onSelectDate: onSelectDate,
                      );
                    }),
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

/// 日历头部 - 对齐 Android CalendarHeader(行 204-239)
class CalendarHeader extends StatelessWidget {
  final DateTime displayMonth;
  final DateTime selectedDate;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final void Function(DateTime) onSelectDate;

  const CalendarHeader({
    super.key,
    required this.displayMonth,
    required this.selectedDate,
    required this.onPrevious,
    required this.onNext,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return SizedBox(
      height: 462,
      child: Stack(
        children: [
          // "日历"标题 - statusBarsPadding + top 13
          Positioned(
            top: topPadding + 13,
            left: 0,
            right: 0,
            child: const Center(
              child: Text(
                '日历',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // 日历卡片
          Positioned(
            top: 108,
            left: 0,
            right: 0,
            child: Center(
              child: CalendarCard(
                displayMonth: displayMonth,
                selectedDate: selectedDate,
                onPrevious: onPrevious,
                onNext: onNext,
                onSelectDate: onSelectDate,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 信息卡(含 Tab + 历史列表/记账) - 对齐 Android CalendarInformationCard(行 412-474)
class CalendarInformationCard extends StatelessWidget {
  final CalendarTab selectedTab;
  final DateTime selectedDate;
  final List<HistoryEvent> historyEvents;
  final bool historyLoading;
  final List<ExpenseEntry> entries;
  final void Function(CalendarTab) onTabSelected;
  final VoidCallback onAdd;
  final void Function(ExpenseEntry) onEdit;
  final void Function(HistoryEvent) onHistoryClick;

  const CalendarInformationCard({
    super.key,
    required this.selectedTab,
    required this.selectedDate,
    required this.historyEvents,
    required this.historyLoading,
    required this.entries,
    required this.onTabSelected,
    required this.onAdd,
    required this.onEdit,
    required this.onHistoryClick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: selectedTab == CalendarTab.history ? 414 : 396,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Tab 栏
          SizedBox(
            height: 58,
            child: Row(
              children: CalendarTab.values.map((tab) {
                final isSelected = selectedTab == tab;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTabSelected(tab),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.calendarBlue : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: tab == CalendarTab.history
                              ? const Radius.circular(20)
                              : Radius.zero,
                          topRight: tab == CalendarTab.history
                              ? const Radius.circular(20)
                              : Radius.zero,
                          // topRight: tab == CalendarTab.expense
                          //     ? const Radius.circular(20)
                          //     : Radius.zero,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        tab.title,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.calendarText,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // 分隔线
          Container(height: 1, color: AppColors.calendarDivider),
          // 内容区
          Expanded(
            child: selectedTab == CalendarTab.history
                ? HistoryList(
                    selectedDate: selectedDate,
                    events: historyEvents,
                    loading: historyLoading,
                    onHistoryClick: onHistoryClick,
                  )
                : ExpenseContent(
                    entries: entries,
                    onAdd: onAdd,
                    onEdit: onEdit,
                  ),
          ),
        ],
      ),
    );
  }
}
