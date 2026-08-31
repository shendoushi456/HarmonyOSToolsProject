// 对齐 master_saolaisao 的 QrScannerPage：使用鸿蒙原生平台视图完成预览和识别。
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_code_scanner_ohos/qr_code_scanner_ohos.dart';

import '../viewmodels/qr_scan_state.dart';
import '../viewmodels/qr_scan_view_model.dart';

class QrScanPage extends ConsumerStatefulWidget {
  const QrScanPage({super.key});

  static Future<void> push(BuildContext context) {
    return Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const QrScanPage()),
    );
  }

  @override
  ConsumerState<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends ConsumerState<QrScanPage> {
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'qrScanner');
  QRViewController? _controller;
  StreamSubscription<Barcode>? _scanSubscription;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    // 等首帧完成后再创建原生扫码视图，确保插件通道已就绪。
    // 这里不会显示应用内的隐私权限提示，插件仍会按需请求系统相机权限。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(qrScanViewModelProvider.notifier).startScan();
      }
    });
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  void _onQrViewCreated(QRViewController controller) {
    _controller = controller;
    _scanSubscription?.cancel();
    _scanSubscription = controller.scannedDataStream.listen((barcode) {
      final code = barcode.code;
      if (code == null || code.isEmpty) return;
      final state = ref.read(qrScanViewModelProvider);
      if (state.showResultDialog) return;
      ref.read(qrScanViewModelProvider.notifier).onScan(code);
      unawaited(controller.pauseCamera());
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(qrScanViewModelProvider);
    final vm = ref.read(qrScanViewModelProvider.notifier);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (state.permissionGranted)
            Positioned.fill(
              child: QRView(
                key: _qrKey,
                onQRViewCreated: _onQrViewCreated,
                cameraFacing: CameraFacing.back,
                formatsAllowed: const [BarcodeFormat.qrcode],
                onPermissionSet: (_, granted) {
                  if (!granted && mounted) {
                    setState(() => _permissionDenied = true);
                  }
                },
                // 保留扫描框边线，但不遮暗扫描框四周，让完整相机画面可见。
                overlay: QrScannerOverlayShape(
                  borderColor: const Color(0xFF58C6FF),
                  borderRadius: 12,
                  borderLength: 32,
                  borderWidth: 6,
                  cutOutSize: 240,
                  overlayColor: Colors.transparent,
                ),
              ),
            )
          else
            const ColoredBox(color: Colors.black),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 12,
            left: 12,
            child: IconButton(
              tooltip: '返回',
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.maybePop(context),
            ),
          ),
          if (state.permissionGranted && !_permissionDenied)
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
          if (_permissionDenied)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  '无法开启相机，请授予相机权限后重试',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          if (state.showResultDialog && state.scanResult != null)
            _buildResultSheet(context, state, vm),
        ],
      ),
    );
  }

  Widget _buildResultSheet(
    BuildContext context,
    QrScanState state,
    QrScanViewModel vm,
  ) {
    final result = state.scanResult!;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        color: Colors.transparent,
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
                const Text('扫描结果',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                SelectableText(result,
                    style: const TextStyle(fontSize: 15, height: 1.4)),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        vm.dismissResult();
                        await _controller?.resumeCamera();
                      },
                      child: const Text('继续扫描'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        await vm.copyResult();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('识别结果已复制')),
                          );
                        }
                      },
                      child: const Text('复制结果'),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
