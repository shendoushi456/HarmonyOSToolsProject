import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../models/expense_models.dart';
import '../viewmodels/expense_view_model.dart';

const _pageBackground = Color(0xFFD8EFFF);
const _textPrimary = Color(0xFF222222);
const _muted = Color(0xFF8C9691);
const _accent = Color(0xFF2575DB);
const _accentDark = Color(0xFF1E61B4);
const _selectedBlue = Color(0xFFB7DCFA);
const _errorRed = Color(0xFFB33A3A);

/// 添加账单页 - 对齐 Android AddExpenseActivity。
class AddExpensePage extends ConsumerStatefulWidget {
  const AddExpensePage({super.key});

  @override
  ConsumerState<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends ConsumerState<AddExpensePage> {
  static const _maxNoteLength = 40;
  static const _amountRegex = r'^\d{0,9}(\.\d{0,2})?$';

  int _typeCode = ExpenseRecord.typeExpense;
  String _amountText = '';
  String _categoryCode = 'meal';
  String _note = '';
  DateTime _occurredAt = DateTime.now();
  bool _isSaving = false;
  String? _errorMessage;

  final _amountFocus = FocusNode();
  final _noteFocus = FocusNode();
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _noteController = TextEditingController();
  }

  /// 分类选项 - 对齐 Android ExpenseCategoryOptions / IncomeCategoryOptions。
  List<_CategoryOption> get _options => _typeCode == ExpenseRecord.typeExpense
      ? const [
          _CategoryOption('meal', '餐饮', AppAssets.expenseMeal),
          _CategoryOption('shopping', '购物', AppAssets.expenseShopping),
          _CategoryOption('phone', '话费', AppAssets.expensePhone),
          _CategoryOption('other', '其他', AppAssets.expenseShopping),
        ]
      : const [
          _CategoryOption('salary', '工资', AppAssets.expenseIncome),
          _CategoryOption('other_income', '其他收入', AppAssets.expenseIncome),
        ];

  @override
  void dispose() {
    _amountFocus.dispose();
    _noteFocus.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildTypeSelector(),
                    const SizedBox(height: 14),
                    _buildAmountCard(),
                    const SizedBox(height: 14),
                    _buildCategorySelector(),
                    const SizedBox(height: 14),
                    _buildDateRow(),
                    const SizedBox(height: 14),
                    _buildNoteCard(),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style:
                              const TextStyle(fontSize: 13, color: _errorRed),
                        ),
                      ),
                    const SizedBox(height: 24),
                    _buildSaveButton(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 顶栏：返回键 + 居中标题。
  Widget _buildHeader() => SizedBox(
        width: double.infinity,
        height: 67,
        child: Stack(
          children: [
            Positioned(
              left: 12,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () => context.pop(),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    child: const Text(
                      '‹',
                      style: TextStyle(
                        fontSize: 38,
                        height: 40 / 38,
                        color: _textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Center(
              child: Text(
                '添加账单',
                style: TextStyle(
                  fontSize: 22,
                  color: _textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );

  /// 支出/收入切换 - 对齐 TypeSelector。
  Widget _buildTypeSelector() => Container(
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: const [
            BoxShadow(
                color: Color(0x4D999999), blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildTypeOption(
                text: '支出',
                selected: _typeCode == ExpenseRecord.typeExpense,
                onClick: () => _setType(ExpenseRecord.typeExpense),
              ),
            ),
            Expanded(
              child: _buildTypeOption(
                text: '收入',
                selected: _typeCode == ExpenseRecord.typeIncome,
                onClick: () => _setType(ExpenseRecord.typeIncome),
              ),
            ),
          ],
        ),
      );

  Widget _buildTypeOption({
    required String text,
    required bool selected,
    required VoidCallback onClick,
  }) =>
      GestureDetector(
        onTap: onClick,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            color: selected ? _selectedBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: _textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );

  /// 金额输入卡 - 对齐 AmountInputCard。
  Widget _buildAmountCard() => _FormCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('金额', style: TextStyle(fontSize: 13, color: _muted)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  '¥',
                  style: TextStyle(
                    fontSize: 31,
                    color: _textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    focusNode: _amountFocus,
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9.]')),
                    ],
                    style: const TextStyle(
                      fontSize: 34,
                      color: _textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isCollapsed: true,
                      hintText: '0.00',
                      hintStyle:
                          TextStyle(fontSize: 34, color: Color(0xFFC4C4C4)),
                    ),
                    onChanged: (value) {
                      if (RegExp(_amountRegex).hasMatch(value)) {
                        setState(() {
                          _amountText = value;
                          _errorMessage = null;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  /// 分类选择 - 对齐 CategorySelector（横向滚动卡片）。
  Widget _buildCategorySelector() => _FormCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('分类', style: TextStyle(fontSize: 13, color: _muted)),
            const SizedBox(height: 12),
            SizedBox(
              height: 89,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _options.length,
                separatorBuilder: (_, __) => const SizedBox(width: 11),
                itemBuilder: (context, index) {
                  final option = _options[index];
                  final selected = _categoryCode == option.code;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _categoryCode = option.code;
                      _errorMessage = null;
                    }),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 66,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          width: selected ? 1.5 : 1,
                          color:
                              selected ? _accent : const Color(0xFFE7F0F1),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          Image.asset(option.iconAsset,
                              width: 40, height: 40),
                          const SizedBox(height: 5),
                          Text(
                            option.label,
                            maxLines: 1,
                            style: const TextStyle(
                                fontSize: 12, color: _textPrimary),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );

  /// 记账日期行 - 对齐 DateRow。
  Widget _buildDateRow() => GestureDetector(
        onTap: _pickDate,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x4D999999),
                  blurRadius: 6,
                  offset: Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  '记账日期',
                  style: TextStyle(
                    fontSize: 15,
                    color: _textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                _formatDate(_occurredAt),
                style: const TextStyle(fontSize: 15, color: _accentDark),
              ),
              const SizedBox(width: 5),
              const Text('›',
                  style: TextStyle(fontSize: 24, color: _textPrimary)),
            ],
          ),
        ),
      );

  /// 备注输入卡 - 对齐 NoteInputCard。
  Widget _buildNoteCard() => _FormCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('备注（选填）',
                style: TextStyle(fontSize: 13, color: _muted)),
            const SizedBox(height: 9),
            SizedBox(
              height: 54,
              child: TextField(
                focusNode: _noteFocus,
                controller: _noteController,
                maxLength: _maxNoteLength,
                style: const TextStyle(
                    fontSize: 16, height: 22 / 16, color: _textPrimary),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                  counterText: '',
                  hintText: '例如：午餐、网购',
                  hintStyle:
                      TextStyle(fontSize: 15, color: Color(0xFFC4C4C4)),
                ),
                onChanged: (value) {
                  if (value.length <= _maxNoteLength) {
                    setState(() => _note = value);
                  }
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Text(
                '${_note.length}/$_maxNoteLength',
                textAlign: TextAlign.end,
                style: const TextStyle(fontSize: 11, color: _muted),
              ),
            ),
          ],
        ),
      );

  /// 保存按钮 - 对齐 SaveExpenseButton。
  Widget _buildSaveButton() => GestureDetector(
        onTap: _isSaving ? null : _save,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: _accent,
            borderRadius: BorderRadius.circular(25),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x4D999999),
                  blurRadius: 6,
                  offset: Offset(0, 2)),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            _isSaving ? '保存中…' : '保存账单',
            style: const TextStyle(
              fontSize: 17,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );

  /// 切换类型时重置默认分类 - 对齐 AddExpenseViewModel.setType。
  void _setType(int typeCode) {
    setState(() {
      _typeCode = typeCode;
      _categoryCode =
          typeCode == ExpenseRecord.typeIncome ? 'salary' : 'meal';
      _errorMessage = null;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _occurredAt,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    // 对齐 withTimeFrom：仅替换日期，保留原时间。
    setState(() {
      _occurredAt = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _occurredAt.hour,
        _occurredAt.minute,
        _occurredAt.second,
      );
    });
  }

  Future<void> _save() async {
    if (_isSaving) return;
    final amountCents = _parseAmountCents(_amountText);
    if (amountCents == null || amountCents <= 0) {
      setState(() => _errorMessage = '请输入正确的金额');
      return;
    }
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    final error = await ref.read(expenseViewModelProvider.notifier).addRecord(
          typeCode: _typeCode,
          categoryCode: _categoryCode,
          amountCents: amountCents,
          note: _note,
          occurredAt: _occurredAt,
        );
    if (!mounted) return;
    if (error == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('账单添加成功')));
      context.pop();
    } else {
      setState(() {
        _isSaving = false;
        _errorMessage = error;
      });
    }
  }

  /// 元文本 → 分 - 对齐 parseAmountCents（BigDecimal → 分）。
  int? _parseAmountCents(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    final parts = trimmed.split('.');
    if (parts.length > 2) return null;
    final yuan =
        parts[0].isEmpty ? 0 : int.tryParse(parts[0]);
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

  /// "yyyy年M月d日" - 对齐 AddExpenseDateFormatter。
  String _formatDate(DateTime value) =>
      '${value.year}年${value.month}月${value.day}日';
}

/// 表单卡片容器 - 对齐 FormCard（白底圆角16 + 阴影）。
class _FormCard extends StatelessWidget {
  final Widget child;

  const _FormCard({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Color(0x4D999999), blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: child,
      );
}

class _CategoryOption {
  final String code;
  final String label;
  final String iconAsset;

  const _CategoryOption(this.code, this.label, this.iconAsset);
}
