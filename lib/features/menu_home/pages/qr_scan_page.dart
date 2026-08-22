// 对齐 Android CaptureScanActivity.kt:21-125 / MenuFragment.kt:785-829 scanQrCode
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../viewmodels/qr_scan_state.dart';
import '../viewmodels/qr_scan_view_model.dart';

class QrScanPage extends ConsumerStatefulWidget {
  const QrScanPage({super.key});

  static Future<void> push(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QrScanPage()),
    );
  }

  @override
  ConsumerState<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends ConsumerState<QrScanPage> {
  late final MobileScannerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      formats: [BarcodeFormat.qrCode],
      facing: CameraFacing.back,
    );
    // 首次进入显示权限说明
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(qrScanViewModelProvider.notifier).showPermissionRationale();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(qrScanViewModelProvider);
    final vm = ref.read(qrScanViewModelProvider.notifier);

    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: vm.onScan,
          ),
          // 顶部返回按钮
          Positioned(
            top: MediaQuery.paddingOf(context).top + 12,
            left: 12,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // 提示文字
          const Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '请对准二维码',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          // 权限说明弹窗 - 对齐 MenuFragment.kt:802-811
          if (state.showPermissionRationale)
            _buildPermissionDialog(context, vm),
          // 扫描结果弹窗 - 对齐 UtilsPic.CopyDialog
          if (state.showResultDialog && state.scanResult != null)
            _buildResultDialog(context, state, vm),
          if (state.errorMessage != null)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.black54,
                child: Text(
                  state.errorMessage!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPermissionDialog(BuildContext context, QrScanViewModel vm) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '隐私权限提示',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                '为了更好的体验，即将进入的功能页面会直接调用相机展示扫描功能的页面，我们需要您的相机权限，请允许我们访问您的相机。',
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        vm.onDenyPermission();
                        Navigator.pop(context);
                      },
                      child: const Text('取消'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: vm.onAgreeRationale,
                      child: const Text('同意'),
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

  Widget _buildResultDialog(BuildContext context, QrScanState state, QrScanViewModel vm) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '扫描结果',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SelectableText(state.scanResult!),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        vm.dismissResult();
                      },
                      child: const Text('取消'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await vm.copyResult();
                        if (context.mounted) {
                          vm.dismissResult();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('复制成功')),
                          );
                        }
                      },
                      child: const Text('复制'),
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
