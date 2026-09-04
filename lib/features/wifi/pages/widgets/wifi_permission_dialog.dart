// WiFi 权限说明弹窗 - 对齐 ToolsWifiHomeFragment.showPermissionRequestDialog
// 文案对齐安卓: "获取Wi-Fi信息权限" + 权限说明 + "同意并继续/取消"
import 'package:flutter/material.dart';

class WifiPermissionDialog extends StatelessWidget {
  /// 同意回调
  final VoidCallback? onAgree;

  const WifiPermissionDialog({super.key, this.onAgree});

  /// 便捷显示方法, 返回是否同意
  static Future<bool?> show(BuildContext context, {VoidCallback? onAgree}) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => WifiPermissionDialog(onAgree: onAgree),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('获取Wi-Fi信息权限'),
      content: const Text(
        '为了扫描和显示附近的Wi-Fi网络，需要获取以下权限：\n\n'
        '• Wi-Fi状态权限（查看当前Wi-Fi连接）\n'
        '• 位置权限（Android 10+需要，用于扫描Wi-Fi）\n'
        '• 网络状态权限（检测网络连接）\n\n'
        '这些权限仅用于Wi-Fi管理和网络诊断功能。',
        style: TextStyle(fontSize: 13),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            onAgree?.call();
          },
          child: const Text('同意并继续'),
        ),
      ],
    );
  }
}
