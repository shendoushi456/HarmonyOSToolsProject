import 'package:flutter/material.dart';
import '../widgets/tool_top_bar.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});
  static Future<void> push(BuildContext context) => Navigator.push(
      context, MaterialPageRoute(builder: (_) => const CalculatorPage()));
  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String display = '0';
  double? left;
  String? op;
  bool clearOnNext = false;

  void press(String value) {
    setState(() {
      if (value == 'C') {
        display = '0';
        left = null;
        op = null;
        clearOnNext = false;
        return;
      }
      if ('0123456789.'.contains(value)) {
        if (clearOnNext || display == '0') {
          display = value == '.' ? '0.' : value;
        } else if (!(value == '.' && display.contains('.'))) {
          display += value;
        }
        clearOnNext = false;
        return;
      }
      if (value == '=') {
        _calculate();
        op = null;
        left = null;
        clearOnNext = true;
        return;
      }
      if ('+-×÷'.contains(value)) {
        left = double.tryParse(display) ?? 0;
        op = value;
        clearOnNext = true;
      }
    });
  }

  void _calculate() {
    final a = left;
    final b = double.tryParse(display);
    if (a == null || b == null || op == null) {
      return;
    }
    double result;
    switch (op) {
      case '+':
        result = a + b;
        break;
      case '-':
        result = a - b;
        break;
      case '×':
        result = a * b;
        break;
      case '÷':
        result = b == 0 ? double.nan : a / b;
        break;
      default:
        result = b;
    }
    display = result.isNaN || result.isInfinite
        ? '错误'
        : (result % 1 == 0
            ? result.toInt().toString()
            : result
                .toStringAsFixed(8)
                .replaceFirst(RegExp(r'0+$'), '')
                .replaceFirst(RegExp(r'\.$'), ''));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ToolTopBar(title: '大字计算器'),
      backgroundColor: const Color(0xFFF7F3FF),
      body: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(24),
              child: FittedBox(
                alignment: Alignment.centerRight,
                child: Text(display,
                    style: const TextStyle(
                        fontSize: 54,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF352570))),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                'C',
                '÷',
                '×',
                '-',
                '7',
                '8',
                '9',
                '+',
                '4',
                '5',
                '6',
                '=',
                '1',
                '2',
                '3',
                '.',
                '0'
              ].map(_key).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _key(String label) => ElevatedButton(
      onPressed: () => press(label),
      style: ElevatedButton.styleFrom(
          backgroundColor:
              label == '=' ? const Color(0xFF352570) : Colors.white,
          foregroundColor:
              label == '=' ? Colors.white : const Color(0xFF352570),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
      child: Text(label,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w500)));
}
