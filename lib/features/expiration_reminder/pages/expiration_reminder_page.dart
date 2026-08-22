import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/expiry_product.dart';
import '../viewmodels/expiry_state.dart';
import '../viewmodels/expiry_view_model.dart';

const _blue = Color(0xFF3DCEE9);
const _bg = Color(0xFFF5FAFC);
const _text = Color(0xFF222222);
const _hint = Color(0xFF737A80);

class ExpirationReminderPage extends ConsumerWidget {
  const ExpirationReminderPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(expiryViewModelProvider);
    final vm = ref.read(expiryViewModelProvider.notifier);
    final stats = vm.statistics;
    return Scaffold(
      backgroundColor: _bg,
      body: state.loading
          ? const Center(child: CircularProgressIndicator(color: _blue))
          : Stack(children: [
              CustomScrollView(slivers: [
                SliverToBoxAdapter(child: _ExpiryHeader(stats: stats)),
                SliverToBoxAdapter(
                    child: _FilterBar(
                        selected: state.filter, onChanged: vm.selectFilter)),
                if (vm.filteredProducts.isEmpty)
                  const SliverFillRemaining(
                      child: Center(
                          child: Text('暂无物品',
                              style: TextStyle(fontSize: 20, color: _text))))
                else
                  SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 92),
                      sliver: SliverList(
                          delegate:
                              SliverChildBuilderDelegate((context, index) {
                        final product = vm.filteredProducts[index];
                        return _ProductCard(
                            product: product,
                            remainingDays: vm.remainingDays(product),
                            onTap: () => _showProductEditor(context, ref,
                                original: product));
                      }, childCount: vm.filteredProducts.length))),
              ]),
              _DraggableAddButton(
                  onTap: () => _showProductEditor(context, ref)),
            ]),
    );
  }
}

class _DraggableAddButton extends StatefulWidget {
  final VoidCallback onTap;
  const _DraggableAddButton({required this.onTap});

  @override
  State<_DraggableAddButton> createState() => _DraggableAddButtonState();
}

class _DraggableAddButtonState extends State<_DraggableAddButton> {
  static const _buttonSize = 56.0;
  double? _left;
  double? _top;
  bool _dragging = false;

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        final maxLeft = constraints.maxWidth > _buttonSize
            ? constraints.maxWidth - _buttonSize
            : 0.0;
        final maxTop = constraints.maxHeight > _buttonSize
            ? constraints.maxHeight - _buttonSize
            : 0.0;
        final left = (_left ?? (maxLeft - 20)).clamp(0.0, maxLeft).toDouble();
        final top = (_top ?? (maxTop - 22)).clamp(0.0, maxTop).toDouble();
        return Stack(children: [
          AnimatedPositioned(
              duration:
                  _dragging ? Duration.zero : const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              left: left,
              top: top,
              child: GestureDetector(
                  onPanStart: (_) => setState(() => _dragging = true),
                  onPanUpdate: (details) => setState(() {
                        _left = (left + details.delta.dx)
                            .clamp(0.0, maxLeft)
                            .toDouble();
                        _top = (top + details.delta.dy)
                            .clamp(0.0, maxTop)
                            .toDouble();
                      }),
                  onPanEnd: (_) => setState(() {
                        _dragging = false;
                        _left =
                            left + _buttonSize / 2 < constraints.maxWidth / 2
                                ? 20.0
                                : maxLeft - 20.0;
                      }),
                  child: FloatingActionButton(
                      onPressed: widget.onTap,
                      backgroundColor: _blue,
                      tooltip: '新增物品',
                      child: const Icon(Icons.add, color: Colors.white))))
        ]);
      });
}

class _ExpiryHeader extends StatelessWidget {
  final ExpiryStatistics stats;
  const _ExpiryHeader({required this.stats});
  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
            color: _blue,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
        child: SafeArea(
            bottom: false,
            child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('临期提醒',
                          style: TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 18),
                      Row(children: [
                        _Stat(value: stats.total, label: '全部'),
                        _Stat(value: stats.expired, label: '已过期'),
                        _Stat(value: stats.days7, label: '7天内过期'),
                        _Stat(value: stats.days30, label: '30天内过期')
                      ]),
                    ]))),
      );
}

class _Stat extends StatelessWidget {
  final int value;
  final String label;
  const _Stat({required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Expanded(
          child: Column(children: [
        Text('$value',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 11))
      ]));
}

class _FilterBar extends StatelessWidget {
  final ExpiryFilter selected;
  final ValueChanged<ExpiryFilter> onChanged;
  const _FilterBar({required this.selected, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    const entries = [
      _FilterOption(ExpiryFilter.all, '全部'),
      _FilterOption(ExpiryFilter.valid, '未过期'),
      _FilterOption(ExpiryFilter.expired, '已过期'),
      _FilterOption(ExpiryFilter.days30, '30天内过期'),
      _FilterOption(ExpiryFilter.days7, '7天内过期'),
      _FilterOption(ExpiryFilter.days3, '3天内过期'),
      _FilterOption(ExpiryFilter.day1, '1天内过期')
    ];
    return SizedBox(
        height: 54,
        child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            scrollDirection: Axis.horizontal,
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, index) {
              final entry = entries[index];
              final active = selected == entry.filter;
              return ChoiceChip(
                  label: Text(entry.label),
                  selected: active,
                  selectedColor: const Color(0xFFDDF7FC),
                  labelStyle: TextStyle(color: active ? _blue : _hint),
                  side: BorderSide.none,
                  onSelected: (_) => onChanged(entry.filter));
            }));
  }
}

class _FilterOption {
  final ExpiryFilter filter;
  final String label;
  const _FilterOption(this.filter, this.label);
}

class _ReminderOption {
  final String label;
  final int days;
  const _ReminderOption(this.label, this.days);
}

class _ProductCard extends StatelessWidget {
  final ExpiryProduct product;
  final int remainingDays;
  final VoidCallback onTap;
  const _ProductCard(
      {required this.product,
      required this.remainingDays,
      required this.onTap});
  @override
  Widget build(BuildContext context) => Card(
      elevation: 1.5,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                        color: const Color(0xFFA3CDFF),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.inventory_2_outlined,
                        color: Color(0xFF3C78B8), size: 32)),
                const SizedBox(width: 10),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(product.name,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: _text)),
                      const SizedBox(height: 7),
                      Text('过期日期  ${_formatDate(product.expiryDate)}',
                          style: const TextStyle(fontSize: 12, color: _hint)),
                      if (product.reminderDaysBefore > 0)
                        Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(product.reminderOption,
                                style: const TextStyle(
                                    fontSize: 12, color: _blue)))
                    ])),
                Column(children: [
                  Text('$remainingDays',
                      style: TextStyle(
                          fontSize: 29,
                          fontWeight: FontWeight.w600,
                          color: remainingDays <= 0
                              ? const Color(0xFFD65A5A)
                              : _text)),
                  const Text('剩余天数',
                      style: TextStyle(fontSize: 10, color: _hint))
                ])
              ]))));
}

Future<void> _showProductEditor(BuildContext context, WidgetRef ref,
    {ExpiryProduct? original}) async {
  final draft = await showModalBottomSheet<_ExpiryDraft>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ProductEditor(original: original));
  if (draft == null) return;
  await ref.read(expiryViewModelProvider.notifier).saveProduct(
      original: original,
      name: draft.name,
      productionDate: draft.productionDate,
      expiryDate: draft.expiryDate,
      reminderDaysBefore: draft.reminderDaysBefore,
      reminderOption: draft.reminderOption);
}

class _ExpiryDraft {
  final String name;
  final DateTime productionDate;
  final DateTime expiryDate;
  final int reminderDaysBefore;
  final String reminderOption;
  const _ExpiryDraft(
      {required this.name,
      required this.productionDate,
      required this.expiryDate,
      required this.reminderDaysBefore,
      required this.reminderOption});
}

class _ProductEditor extends StatefulWidget {
  final ExpiryProduct? original;
  const _ProductEditor({this.original});
  @override
  State<_ProductEditor> createState() => _ProductEditorState();
}

class _ProductEditorState extends State<_ProductEditor> {
  static const _reminders = [
    _ReminderOption('不提醒', 0),
    _ReminderOption('提前1天', 1),
    _ReminderOption('提前2天', 2),
    _ReminderOption('提前1周', 7),
    _ReminderOption('提前2周', 14),
    _ReminderOption('提前1个月', 30),
    _ReminderOption('提前3个月', 90),
    _ReminderOption('提前6个月', 180)
  ];
  late final TextEditingController _name;
  late final TextEditingController _shelfLifeDays;
  late DateTime _production;
  late DateTime _expiry;
  late int _reminderDays;
  late String _reminderText;
  @override
  void initState() {
    super.initState();
    final item = widget.original;
    final now = expiryDateOnly(DateTime.now());
    _name = TextEditingController(text: item?.name ?? '');
    _production = item?.productionDate ?? now;
    _expiry = item?.expiryDate ?? now.add(const Duration(days: 30));
    _shelfLifeDays = TextEditingController(
        text: _expiry.difference(_production).inDays.toString());
    _reminderDays = item?.reminderDaysBefore ?? 0;
    _reminderText = item?.reminderOption ?? '不提醒';
  }

  @override
  void dispose() {
    _name.dispose();
    _shelfLifeDays.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
      top: false,
      child: Container(
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
          child: Padding(
              padding: EdgeInsets.fromLTRB(
                  20, 12, 20, MediaQuery.viewInsetsOf(context).bottom + 24),
              child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                    Row(children: [
                      Expanded(
                          child: Text(widget.original == null ? '新增物品' : '物品详情',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w600))),
                      if (widget.original != null)
                        IconButton(
                            onPressed: _delete,
                            tooltip: '删除物品',
                            icon: const Icon(Icons.delete_outline,
                                color: Color(0xFFD65A5A)))
                    ]),
                    const SizedBox(height: 16),
                    TextField(
                        controller: _name,
                        decoration: const InputDecoration(
                            labelText: '物品名称',
                            hintText: '请输入',
                            border: OutlineInputBorder())),
                    const SizedBox(height: 14),
                    _dateTile('生产日期', _production, () => _pickDate(true)),
                    _dateTile('过期日期', _expiry, () => _pickDate(false)),
                    TextField(
                        controller: _shelfLifeDays,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: '保质期天数',
                            suffixText: '天',
                            border: OutlineInputBorder()),
                        onChanged: _updateExpiryFromShelfLife),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                        value: _reminderText,
                        decoration: const InputDecoration(
                            labelText: '提前提醒', border: OutlineInputBorder()),
                        items: _reminders
                            .map((item) => DropdownMenuItem(
                                value: item.label, child: Text(item.label)))
                            .toList(),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          final item = _reminders
                              .firstWhere((item) => item.label == value);
                          setState(() {
                            _reminderText = item.label;
                            _reminderDays = item.days;
                          });
                        }),
                    const SizedBox(height: 22),
                    FilledButton(
                        onPressed: _save,
                        style: FilledButton.styleFrom(backgroundColor: _blue),
                        child: Text(widget.original == null ? '保存' : '保存修改'))
                  ])))));
  Widget _dateTile(String label, DateTime date, VoidCallback tap) => ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(_formatDate(date)),
      trailing: const Icon(Icons.calendar_today_outlined),
      onTap: tap);
  Future<void> _pickDate(bool production) async {
    final picked = await showDatePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime(2200),
        initialDate: production ? _production : _expiry);
    if (picked == null) return;
    setState(() {
      if (production) {
        _production = picked;
        _expiry = _production.add(Duration(days: _shelfLifeDaysValue));
      } else if (picked.isAfter(_production)) {
        _expiry = picked;
        _shelfLifeDays.text = _expiry.difference(_production).inDays.toString();
      }
    });
  }

  int get _shelfLifeDaysValue {
    final value = int.tryParse(_shelfLifeDays.text.trim()) ?? 1;
    return value < 1 ? 1 : value;
  }

  void _updateExpiryFromShelfLife(String value) {
    final days = int.tryParse(value.trim());
    if (days == null || days < 1) {
      return;
    }
    setState(() => _expiry = _production.add(Duration(days: days)));
  }

  void _save() {
    if (_name.text.trim().isEmpty ||
        _shelfLifeDaysValue < 1 ||
        !_expiry.isAfter(_production)) {
      return;
    }
    Navigator.pop(
        context,
        _ExpiryDraft(
            name: _name.text,
            productionDate: _production,
            expiryDate: _expiry,
            reminderDaysBefore: _reminderDays,
            reminderOption: _reminderText));
  }

  Future<void> _delete() async {
    await ProviderScope.containerOf(context)
        .read(expiryViewModelProvider.notifier)
        .deleteProduct(widget.original!);
    if (mounted) Navigator.pop(context);
  }
}

String _formatDate(DateTime date) =>
    '${date.year}年${date.month.toString().padLeft(2, '0')}月${date.day.toString().padLeft(2, '0')}日';
