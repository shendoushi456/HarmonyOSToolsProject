import 'package:flutter/material.dart';

class OtherCurrencyConverterPage extends StatefulWidget {
  const OtherCurrencyConverterPage({super.key});

  static Future<void> push(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const OtherCurrencyConverterPage()),
      );

  @override
  State<OtherCurrencyConverterPage> createState() =>
      _OtherCurrencyConverterPageState();
}

class _OtherCurrencyConverterPageState
    extends State<OtherCurrencyConverterPage> {
  static const _currencies = [
    _Currency('美元', 'USD', 0.15),
    _Currency('欧元', 'EUR', 0.13),
    _Currency('日元', 'JPY', 16.5),
    _Currency('韩元', 'KRW', 174.8),
    _Currency('新台币', 'TWD', 4.2),
    _Currency('英镑', 'GBP', 0.11),
  ];
  final _cnyController = TextEditingController(text: '0');
  final _foreignController = TextEditingController(text: '0');
  var _currency = _currencies.first;
  var _editingCny = true;

  @override
  void dispose() {
    _cnyController.dispose();
    _foreignController.dispose();
    super.dispose();
  }

  void _convert(bool fromCny) {
    final source = fromCny ? _cnyController : _foreignController;
    final target = fromCny ? _foreignController : _cnyController;
    final value = double.tryParse(source.text) ?? 0;
    final converted = fromCny ? value * _currency.rate : value / _currency.rate;
    target.text =
        converted.toStringAsFixed(2).replaceFirst(RegExp(r'\\.00$'), '');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFFFFBF4),
        appBar: AppBar(
            title: const Text('汇率换算'),
            backgroundColor: const Color(0xFFFFFBF4),
            foregroundColor: const Color(0xFF1E1E1E),
            elevation: 0),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
          child: Column(children: [
            _CurrencyCard(
                label: '人民币(CNY)',
                code: 'CNY',
                controller: _cnyController,
                onChanged: (_) {
                  _editingCny = true;
                  _convert(true);
                }),
            IconButton(
                icon: const Icon(Icons.swap_vert_circle_outlined, size: 34),
                onPressed: () {
                  setState(() {
                    final value = _cnyController.text;
                    _cnyController.text = _foreignController.text;
                    _foreignController.text = value;
                    _editingCny = !_editingCny;
                    _convert(_editingCny);
                  });
                }),
            _CurrencyCard(
                label: '${_currency.name}(${_currency.code})',
                code: _currency.code,
                controller: _foreignController,
                onChanged: (_) {
                  _editingCny = false;
                  _convert(false);
                },
                onSelect: () async {
                  final selected = await showModalBottomSheet<_Currency>(
                      context: context,
                      builder: (_) => ListView(children: [
                            for (final item in _currencies)
                              ListTile(
                                  title: Text('${item.name} (${item.code})'),
                                  onTap: () => Navigator.pop(context, item))
                          ]));
                  if (selected != null) {
                    setState(() {
                      _currency = selected;
                      _convert(_editingCny);
                    });
                  }
                }),
          ]),
        ),
      );
}

class _CurrencyCard extends StatelessWidget {
  const _CurrencyCard(
      {required this.label,
      required this.code,
      required this.controller,
      required this.onChanged,
      this.onSelect});
  final String label;
  final String code;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onSelect;
  @override
  Widget build(BuildContext context) => Container(
        height: 96,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Row(children: [
          InkWell(
              onTap: onSelect,
              child: SizedBox(
                  width: 132,
                  child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.flag_outlined, size: 22),
                            const SizedBox(height: 8),
                            Text(label,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold))
                          ])))),
          const VerticalDivider(indent: 15, endIndent: 15, color: Colors.black),
          Expanded(
              child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 30),
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(left: 10)))),
          Padding(padding: const EdgeInsets.only(right: 10), child: Text(code)),
        ]),
      );
}

class _Currency {
  const _Currency(this.name, this.code, this.rate);
  final String name;
  final String code;
  final double rate;
}
