import 'package:flutter/foundation.dart';

/// 扫描二维码页面状态 - 对齐 CaptureScanActivity.kt:21-125 / MenuFragment.kt:785-829
@immutable
class QrScanState {
  final bool permissionGranted;
  final bool showPermissionRationale;
  final String? scanResult;
  final bool showResultDialog;
  final String? errorMessage;

  const QrScanState({
    // 首帧后由页面启动扫码，避免原生平台视图通道尚未就绪时创建预览。
    this.permissionGranted = false,
    this.showPermissionRationale = false,
    this.scanResult,
    this.showResultDialog = false,
    this.errorMessage,
  });

  QrScanState copyWith({
    bool? permissionGranted,
    bool? showPermissionRationale,
    String? scanResult,
    bool? showResultDialog,
    String? errorMessage,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return QrScanState(
      permissionGranted: permissionGranted ?? this.permissionGranted,
      showPermissionRationale:
          showPermissionRationale ?? this.showPermissionRationale,
      scanResult: clearResult ? null : scanResult ?? this.scanResult,
      showResultDialog: showResultDialog ?? this.showResultDialog,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
