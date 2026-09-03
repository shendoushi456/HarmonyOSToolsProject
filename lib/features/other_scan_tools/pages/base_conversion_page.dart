import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/base_conversion_view_model.dart';

class BaseConversionPage extends ConsumerStatefulWidget {
  const BaseConversionPage({super.key});

  static Future<void> push(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const BaseConversionPage()),
      );

  @override
  ConsumerState<BaseConversionPage> createState() => _BaseConversionPageState();
}

class _BaseConversionPageState extends ConsumerState<BaseConversionPage> {
  final _controllers = <int, TextEditingController>{
    10: TextEditingController(),
    2: TextEditingController(),
    8: TextEditingController(),
    16: TextEditingController(),
  };
  var _updating = false;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(baseConversionViewModelProvider, (_, next) {
      _updating = true;
      for (final entry in next.values.entries) {
        final controller = _controllers[entry.key]!;
        if (controller.text != entry.value) {
          controller.value = TextEditingValue(
            text: entry.value,
            selection: TextSelection.collapsed(offset: entry.value.length),
          );
        }
      }
      _updating = false;
    });
    final vm = ref.read(baseConversionViewModelProvider.notifier);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text('进制转换器'),
        backgroundColor: const Color(0xFFFFFFFF),
        foregroundColor: const Color(0xFF333333),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('输入任意进制数，自动换算为其余进制',
              style: TextStyle(color: Color(0xFF777777))),
          const SizedBox(height: 18),
          for (final entry
              in const {10: '十进制', 2: '二进制', 8: '八进制', 16: '十六进制'}.entries) ...[
            TextField(
              controller: _controllers[entry.key],
              textCapitalization: TextCapitalization.characters,
              keyboardType: TextInputType.text,
              onChanged: (value) {
                if (!_updating) vm.update(value, entry.key);
              },
              decoration: InputDecoration(
                labelText: entry.value,
                prefixIcon: const Icon(Icons.text_fields_outlined),
                filled: true,
                fillColor: Colors.white,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 18),
          ],
        ],
      ),
    );
  }
}
