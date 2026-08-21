// WiFi 连接确认弹窗 - 对齐 dialog_wifi.xml
// 文案: "应用程序会将您重定向至 Wifi 设置页面。 您确定要进入吗?"
// 按钮: 取消(黑色) / 确认(#5597F7 蓝)
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class WifiConnectDialog extends StatelessWidget {
  /// 确认回调(跳系统 wifi 设置页)
  final VoidCallback? onConfirm;

  const WifiConnectDialog({super.key, this.onConfirm});

  /// 便捷显示方法
  static Future<bool?> show(BuildContext context, {VoidCallback? onConfirm}) {
    return showDialog<bool>(
      context: context,
      builder: (_) => WifiConnectDialog(onConfirm: onConfirm),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 提示文案
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                '应用程序会将您重定向至 Wifi 设置页面。 您确定要进入吗?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.black),
              ),
            ),
            const SizedBox(height: 10),
            // 按钮行
            Row(
              children: [
                // 取消按钮
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      '取消',
                      style: TextStyle(fontSize: 13, color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // 确认按钮
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      onConfirm?.call();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.wifiDialogConfirm,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      '确认',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.wifiDialogConfirm,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
