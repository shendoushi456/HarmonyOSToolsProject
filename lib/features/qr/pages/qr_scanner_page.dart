import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner_ohos/qr_code_scanner_ohos.dart';

/// 二维码扫码页。相机权限由 qr_code_scanner_ohos 在启动预览时请求。
class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'qrScanner');
  QRViewController? _controller;
  StreamSubscription<Barcode>? _scanSubscription;
  String? _result;
  bool _hasResult = false;

  void _onQrViewCreated(QRViewController controller) {
    _controller = controller;
    _scanSubscription = controller.scannedDataStream.listen((barcode) {
      final code = barcode.code;
      if (_hasResult || code == null || code.isEmpty) return;
      setState(() {
        _hasResult = true;
        _result = code;
      });
      controller.pauseCamera();
    });
  }

  Future<void> _scanAgain() async {
    setState(() {
      _hasResult = false;
      _result = null;
    });
    await _controller?.resumeCamera();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('二维码扫描'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          QRView(
            key: _qrKey,
            onQRViewCreated: _onQrViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: const Color(0xFF58C6FF),
              borderRadius: 12,
              borderLength: 32,
              borderWidth: 6,
              cutOutSize: 240,
              // 扫码框外围遮罩改为半透明，可透出相机画面
              overlayColor: Colors.black54,
            ),
          ),
          const Positioned(
            left: 24,
            right: 24,
            bottom: 52,
            child: Text(
              '将二维码放入框内，即可自动识别',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
          if (_hasResult) _buildResultSheet(context),
        ],
      ),
    );
  }

  Widget _buildResultSheet(BuildContext context) {
    final result = _result ?? '';
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('识别结果',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              SelectableText(result,
                  style: const TextStyle(fontSize: 15, height: 1.4)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _scanAgain,
                      child: const Text('继续扫描'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: result));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('识别结果已复制')));
                        }
                      },
                      child: const Text('复制结果'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
