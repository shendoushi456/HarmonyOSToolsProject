import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../life_tools/pages/widgets/tool_top_bar.dart';
import '../viewmodels/calculator_view_model.dart';

class CalculatorPage extends ConsumerWidget {
  const CalculatorPage({super.key});

  static Future<void> push(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CalculatorPage()),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorViewModelProvider);
    final vm = ref.read(calculatorViewModelProvider.notifier);
    return Scaffold(
      backgroundColor: const Color(0xFFE7E9ED),
      appBar: const ToolTopBar(title: '普通计算器'),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Container(
              width: double.infinity,
              height: 132,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Expanded(
                    child: SingleChildScrollView(
                        reverse: true,
                        child: Text(state.expression,
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                                fontSize: 28, color: Color(0xFF6A6A6A))))),
                Text(state.display,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 34, color: Color(0xFF222222))),
              ]),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Column(children: [
                _row(vm, const ['C', 'x²', '√', '⌫']),
                _row(vm, const ['(', ')', '%', '÷']),
                _row(vm, const ['7', '8', '9', '×']),
                _row(vm, const ['4', '5', '6', '−']),
                _row(vm, const ['1', '2', '3', '+']),
                _row(vm, const ['0', '00', '.', '=']),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _row(CalculatorViewModel vm, List<String> labels) {
    return Expanded(
      child: Row(
        children: labels
            .map((label) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: label == '='
                            ? const Color(0xFFF6C766)
                            : Colors.white,
                        foregroundColor: const Color(0xFF303030),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () => _tap(vm, label),
                      child: Text(label, style: const TextStyle(fontSize: 20)),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  void _tap(CalculatorViewModel vm, String label) {
    switch (label) {
      case 'C':
        vm.clear();
        break;
      case '⌫':
        vm.backspace();
        break;
      case 'x²':
        vm.square();
        break;
      case '√':
        vm.squareRoot();
        break;
      case '%':
        vm.percent();
        break;
      case '=':
        vm.calculate();
        break;
      case '.':
        vm.decimal();
        break;
      case '÷':
        vm.operator('/');
        break;
      case '×':
        vm.operator('*');
        break;
      case '−':
        vm.operator('-');
        break;
      case '+':
        vm.operator('+');
        break;
      case '(':
      case ')':
        vm.input(label);
        break;
      default:
        vm.input(label);
    }
  }
}
