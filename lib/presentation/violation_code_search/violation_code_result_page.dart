import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/violation_code_provider.dart';

/// 违章代码查询结果页
///
/// 对应 Android: toolCarLib/SearchViolationCodeResultActivity.kt
/// 显示违法代码/违法内容/罚款金额/扣分分值。
class ViolationCodeResultPage extends ConsumerWidget {
  final String code;

  const ViolationCodeResultPage({super.key, required this.code});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(violationCodeResultProvider(Uri.decodeComponent(code)));
    return Scaffold(
      appBar: AppBar(title: const Text('查询结果')),
      body: ColoredBox(
        color: const Color(0xFFF5F5F5),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Column(
                    children: [
                      _ResultRow(
                        label: '违法代码',
                        value: result?.code ?? Uri.decodeComponent(code),
                      ),
                      const SizedBox(height: 18),
                      _ResultRow(
                        label: '违法内容',
                        value: result?.content ?? '未找到相关信息',
                        valueAlign: TextAlign.center,
                        valueWidth: 116,
                        valueLineHeight: 17 / 12,
                      ),
                      const SizedBox(height: 18),
                      _ResultRow(
                        label: '罚款金额（元）',
                        value: result?.fine ?? '0',
                        valueAlign: TextAlign.end,
                      ),
                      const SizedBox(height: 18),
                      _ResultRow(
                        label: '扣分分值',
                        value: '${result?.points ?? 0}',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 结果行
class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final TextAlign valueAlign;
  final double? valueWidth;
  final double? valueLineHeight;

  const _ResultRow({
    required this.label,
    required this.value,
    this.valueAlign = TextAlign.start,
    this.valueWidth,
    this.valueLineHeight,
  });

  @override
  Widget build(BuildContext context) {
    final valueText = SizedBox(
      width: valueWidth,
      child: Text(
        value,
        textAlign: valueAlign,
        style: TextStyle(
          fontSize: 12,
          color: const Color(0xFF757575),
          height: valueLineHeight,
        ),
      ),
    );
    return Row(
      crossAxisAlignment: valueAlign == TextAlign.center
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF444444),
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        valueWidth != null
            ? valueText
            : Expanded(child: valueText),
      ],
    );
  }
}
