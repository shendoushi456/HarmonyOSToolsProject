import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'qr_scan_state.dart';

final qrScanViewModelProvider = NotifierProvider<QrScanViewModel, QrScanState>(
  QrScanViewModel.new,
);

/// 扫描二维码 ViewModel - 对齐 CaptureScanActivity.kt:21-125 / MenuFragment.kt:785-829
class QrScanViewModel extends Notifier<QrScanState> {
  @override
  QrScanState build() {
    return const QrScanState();
  }

  /// 显示权限说明弹窗 - 对齐 MenuFragment.kt:802-811 QRCameraPremissDialog
  void showPermissionRationale() {
    state = state.copyWith(showPermissionRationale: true);
  }

  void dismissPermissionRationale() {
    state = state.copyWith(showPermissionRationale: false);
  }

  /// 用户同意权限说明后，标记可以继续（实际权限由 mobile_scanner 自动申请）
  void onAgreeRationale() {
    state = state.copyWith(showPermissionRationale: false, permissionGranted: true);
  }

  /// 拒绝权限后提示并返回
  void onDenyPermission() {
    state = state.copyWith(
      permissionGranted: false,
      showPermissionRationale: false,
      errorMessage: '没有相机权限授权，无法使用！',
    );
  }

  /// 扫描到条码 - 对齐 MenuFragment.kt:793-800 CaptureScanActivity 结果
  void onScan(BarcodeCapture capture) {
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final code = barcodes.first.rawValue;
    if (code != null && code.isNotEmpty) {
      state = state.copyWith(scanResult: code, showResultDialog: true);
    }
  }

  /// 复制扫描结果 - 对齐 UtilsPic.CopyDialog
  Future<void> copyResult() async {
    if (state.scanResult == null) return;
    await Clipboard.setData(ClipboardData(text: state.scanResult!));
  }

  void dismissResult() {
    state = state.copyWith(showResultDialog: false, clearResult: true);
  }
}
