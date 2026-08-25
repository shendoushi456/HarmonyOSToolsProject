import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  /// 用户同意权限说明后，展示鸿蒙原生扫码预览；插件会申请实际相机权限。
  void onAgreeRationale() {
    state =
        state.copyWith(showPermissionRationale: false, permissionGranted: true);
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
  void onScan(String? code) {
    if (code != null && code.isNotEmpty && !state.showResultDialog) {
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
