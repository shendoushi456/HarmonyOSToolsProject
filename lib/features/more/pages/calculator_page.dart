import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/calculator_view_model.dart';

/// 对齐 Android CommonJiSuanQiActivity 的普通计算器入口。
class CalculatorPage extends ConsumerWidget {
  const CalculatorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorViewModelProvider);
    final vm = ref.read(calculatorViewModelProvider.notifier);
    const rows = [
      ['C', 'x²', '√', '⌫'],
      ['(', ')', '%', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '+'],
      ['0', '00', '.', '=']
    ];
    return Scaffold(
        backgroundColor: const Color(0xFFF4F5F7),
        appBar: AppBar(title: const Text('普通计算器'), elevation: 0),
        body: SafeArea(
            top: false,
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 126),
                      padding: const EdgeInsets.all(16),
                      alignment: Alignment.bottomRight,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12)),
                      child: SingleChildScrollView(
                          reverse: true,
                          scrollDirection: Axis.horizontal,
                          child: Text(state.display,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 38,
                                  color: state.hasError
                                      ? const Color(0xFFD85D5D)
                                      : const Color(0xFF1F252B))))),
                  const SizedBox(height: 12),
                  Expanded(
                      child: Column(
                          children:
                              List<Widget>.generate(rows.length, (rowIndex) {
                    final row = rows[rowIndex];
                    return Expanded(
                        child: Row(
                            children:
                                List<Widget>.generate(row.length, (index) {
                      final label = row[index];
                      return Expanded(
                          child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: _CalculatorButton(
                                  label: label,
                                  emphasized: label == '=',
                                  onTap: () => _handle(vm, label))));
                    })));
                  })))
                ]))));
  }

  void _handle(CalculatorViewModel vm, String label) {
    switch (label) {
      case 'C':
        vm.clear();
        return;
      case '⌫':
        vm.backspace();
        return;
      case 'x²':
        vm.square();
        return;
      case '√':
        vm.squareRoot();
        return;
      case '%':
        vm.percent();
        return;
      case '=':
        vm.evaluate();
        return;
      case '÷':
        vm.input('/');
        return;
      case '×':
        vm.input('*');
        return;
      default:
        vm.input(label);
    }
  }
}

class _CalculatorButton extends StatelessWidget {
  final String label;
  final bool emphasized;
  final VoidCallback onTap;
  const _CalculatorButton(
      {required this.label, required this.emphasized, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
      color: emphasized ? const Color(0xFF71CEC8) : Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Center(
              child: Text(label,
                  style: TextStyle(
                      color:
                          emphasized ? Colors.white : const Color(0xFF262C32),
                      fontSize: 22,
                      fontWeight: FontWeight.w500)))));
}
