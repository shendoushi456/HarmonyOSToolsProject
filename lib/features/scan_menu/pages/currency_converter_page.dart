import 'package:flutter/material.dart';

/// 汇率换算详情页，保留原有的多币种列表换算方式。
class CurrencyConverterPage extends StatefulWidget {
  const CurrencyConverterPage({super.key});

  static Future<void> push(BuildContext context) {
    return Navigator.push(context,
        MaterialPageRoute(builder: (_) => const CurrencyConverterPage()));
  }

  @override
  State<CurrencyConverterPage> createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends State<CurrencyConverterPage> {
  static const _rates = <_Currency>[
    _Currency('美元', 'USD', 0.15),
    _Currency('欧元', 'EUR', 0.13),
    _Currency('日元', 'JPY', 16.5),
    _Currency('韩元', 'KRW', 174.8),
    _Currency('新台币', 'TWD', 4.2),
    _Currency('英镑', 'GBP', 0.11),
  ];

  final _controller = TextEditingController(text: '100');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(_controller.text) ?? 0;
    return Scaffold(
      appBar: AppBar(title: const Text('汇率换算')),
      backgroundColor: const Color(0xFFF7F8FC),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('人民币',
              style: TextStyle(fontSize: 16, color: Color(0xFF666666))),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
            decoration: const InputDecoration(
              suffixText: 'CNY',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderSide: BorderSide.none),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text('实时换算',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ),
          ..._rates.map(
              (currency) => _CurrencyRow(currency: currency, amount: amount)),
        ],
      ),
    );
  }
}

class _CurrencyRow extends StatelessWidget {
  const _CurrencyRow({required this.currency, required this.amount});
  final _Currency currency;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      color: Colors.white,
      child: Row(children: [
        Expanded(
            child: Text(currency.name, style: const TextStyle(fontSize: 16))),
        Text(currency.code, style: const TextStyle(color: Color(0xFF999999))),
        const SizedBox(width: 18),
        Text((amount * currency.rate).toStringAsFixed(2),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _Currency {
  const _Currency(this.name, this.code, this.rate);
  final String name;
  final String code;
  final double rate;
}
