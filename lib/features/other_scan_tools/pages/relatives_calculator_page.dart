import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/relatives_calculator_view_model.dart';

class RelativesCalculatorPage extends ConsumerWidget {
  const RelativesCalculatorPage({super.key});

  static Future<void> push(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RelativesCalculatorPage()),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(relativesCalculatorViewModelProvider);
    final vm = ref.read(relativesCalculatorViewModelProvider.notifier);
    return Scaffold(
      backgroundColor: const Color(0xFFE9ECF1),
      appBar: AppBar(
        title: const Text('亲戚关系计算器'),
        backgroundColor: const Color(0xFFFFFFFF),
        foregroundColor: const Color(0xFF333333),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(state.input,
                      textAlign: TextAlign.right,
                      style:
                          const TextStyle(fontSize: 30, color: Colors.black)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 70,
                    child: Text(state.result,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            fontSize: 20, color: Color(0xFF959595))),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
                color: Color(0xFFF9FBFE),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    const Text('男', style: TextStyle(fontSize: 20)),
                    Switch(value: state.isWoman, onChanged: vm.setWoman),
                    const Text('女', style: TextStyle(fontSize: 20)),
                  ]),
                  _KeyRow(
                      labels: const ['丈夫', '妻子', 'C', '⌫'],
                      onTap: (label) {
                        if (label == 'C') {
                          vm.clear();
                        } else if (label == '⌫') {
                          vm.delete();
                        } else {
                          vm.append(label);
                        }
                      }),
                  _KeyRow(
                      labels: const ['爸爸', '妈妈', '哥哥', '弟弟'], onTap: vm.append),
                  _KeyRow(
                      labels: const ['姐姐', '妹妹', '儿子', '女儿'], onTap: vm.append),
                  Row(children: [
                    Expanded(
                        child: _CalculatorButton(
                            label: '互查',
                            enabled: state.canReverse,
                            onTap: vm.toggleReverse)),
                    Expanded(
                        child: _CalculatorButton(
                            label: '=', primary: true, onTap: vm.calculate)),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyRow extends StatelessWidget {
  const _KeyRow({required this.labels, required this.onTap});
  final List<String> labels;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) => Row(children: [
        for (final label in labels)
          Expanded(
              child:
                  _CalculatorButton(label: label, onTap: () => onTap(label))),
      ]);
}

class _CalculatorButton extends StatelessWidget {
  const _CalculatorButton(
      {required this.label,
      required this.onTap,
      this.primary = false,
      this.enabled = true});
  final String label;
  final VoidCallback onTap;
  final bool primary;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(6),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: enabled ? onTap : null,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor:
                  primary ? const Color(0xFF0080FF) : const Color(0xFFFFFFFF),
              foregroundColor: primary
                  ? Colors.white
                  : (label == 'C' ? const Color(0xFF0080FF) : Colors.black),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(label,
                style: TextStyle(
                    fontSize: label == '=' || label == 'C' ? 28 : 19)),
          ),
        ),
      );
}
