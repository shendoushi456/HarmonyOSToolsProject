import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// 根据输入的文本或链接生成二维码。
class QrGeneratorPage extends StatefulWidget {
  const QrGeneratorPage({super.key});

  @override
  State<QrGeneratorPage> createState() => _QrGeneratorPageState();
}

class _QrGeneratorPageState extends State<QrGeneratorPage> {
  final TextEditingController _textController = TextEditingController();
  String _qrData = '';

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _generate() {
    final value = _textController.text.trim();
    if (value.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('请输入要生成二维码的内容')));
      return;
    }
    setState(() => _qrData = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('生成二维码')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('输入文字或链接',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            TextField(
              controller: _textController,
              minLines: 3,
              maxLines: 5,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                hintText: '例如：https://example.com',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _generate(),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _generate, child: const Text('生成二维码')),
            const SizedBox(height: 32),
            if (_qrData.isNotEmpty)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(18),
                  color: Colors.white,
                  child: QrImageView(
                    data: _qrData,
                    version: QrVersions.auto,
                    size: 240,
                    backgroundColor: Colors.white,
                  ),
                ),
              )
            else
              const Center(
                child:
                    Text('生成后的二维码将显示在这里', style: TextStyle(color: Colors.grey)),
              ),
          ],
        ),
      ),
    );
  }
}
