import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 生成二维码页面状态 - 对齐 QRCodeActivity.java:52-252
@immutable
class QrGenerateState {
  final String inputText;
  final Color foregroundColor;
  final Color backgroundColor;
  final String? logoPath;
  final double size;
  final Uint8List? generatedQrBytes;
  final bool showPreviewDialog;
  final bool isSaving;

  const QrGenerateState({
    this.inputText = '',
    this.foregroundColor = Colors.black,
    this.backgroundColor = Colors.white,
    this.logoPath,
    this.size = 300,
    this.generatedQrBytes,
    this.showPreviewDialog = false,
    this.isSaving = false,
  });

  QrGenerateState copyWith({
    String? inputText,
    Color? foregroundColor,
    Color? backgroundColor,
    String? logoPath,
    double? size,
    Uint8List? generatedQrBytes,
    bool? showPreviewDialog,
    bool? isSaving,
    bool clearLogo = false,
    bool clearQr = false,
  }) {
    return QrGenerateState(
      inputText: inputText ?? this.inputText,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      logoPath: clearLogo ? null : logoPath ?? this.logoPath,
      size: size ?? this.size,
      generatedQrBytes: clearQr ? null : generatedQrBytes ?? this.generatedQrBytes,
      showPreviewDialog: showPreviewDialog ?? this.showPreviewDialog,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}
