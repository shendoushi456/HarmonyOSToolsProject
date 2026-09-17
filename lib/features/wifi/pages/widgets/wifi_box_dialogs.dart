// WiFi 弹窗集合 - 对齐 Android wifilist/WifiLinkDialog.java + dialog_wifi.xml
import 'package:flutter/material.dart';
import '../../../../core/network/wifi_native_channel.dart';
import '../../utils/wifi_box_support.dart';

/// 连接弹窗 - 对齐 setting_wifi_link_dialog.xml:
/// black_box(#12171E 圆角6) 250sdp 宽,标题白字,白底输入框,取消/连接 blue_circle 按钮
Future<void> showWifiLinkDialog(BuildContext context, WifiBoxEntry entry) {
  return showDialog(
    context: context,
    barrierColor: Colors.black54,
    builder: (dialogContext) => _WifiLinkDialog(entry: entry),
  );
}

class _WifiLinkDialog extends StatefulWidget {
  final WifiBoxEntry entry;
  const _WifiLinkDialog({required this.entry});

  @override
  State<_WifiLinkDialog> createState() => _WifiLinkDialogState();
}

class _WifiLinkDialogState extends State<_WifiLinkDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 连接(对齐 WifiLinkDialog.connectToWifi:
  /// createWifiConfig(preSharedKey)→disconnect→addNetwork→enableNetwork→reconnect;
  /// 鸿蒙侧由 WifiPlugin.connectWifi 等价实现)
  Future<void> _connect() async {
    Navigator.of(context).pop();
    await WifiNativeChannel.instance
        .connectWifi(widget.entry.ssid, _controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 250,
        // 对齐 black_box: #12171E 圆角 6dp
        decoration: BoxDecoration(
          color: const Color(0xFF12171E),
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.only(top: 10, bottom: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // wifi_title: 白字居中 12sdp,默认为 SSID
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 15),
              child: Text(
                widget.entry.ssid,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            // password_edit: 白底圆角输入框 30sdp 高
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.center,
              child: TextField(
                controller: _controller,
                obscureText: true,
                style:
                    const TextStyle(color: Colors.black, fontSize: 10),
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: '请输入WIFI密码',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ),
            ),
            // 取消/连接按钮(80x25 blue_circle 圆形,文字 #123049 12sp)
            SizedBox(
              height: 35,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _dialogButton('取消', () => Navigator.of(context).pop()),
                  const SizedBox(width: 10),
                  _dialogButton('连接', _connect),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 25,
        margin: const EdgeInsets.only(top: 2),
        // 对齐 blue_circle: 渐变 #32cdff→#0096ff 圆形
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF32CDFF), Color(0xFF0096FF)],
          ),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(label,
            style: const TextStyle(color: Color(0xFF123049), fontSize: 12)),
      ),
    );
  }
}

/// 系统设置确认弹窗 - 对齐 dialog_wifi.xml(取消白字/确认绿字,strength_item_box 黑底)
/// 对应安卓 SDK>28 点击列表项的 dialog 分支
Future<void> showWifiSystemDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierColor: Colors.black54,
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 260,
        // 对齐 strength_item_box: #12171E 圆角 5
        decoration: BoxDecoration(
          color: const Color(0xFF12171E),
          borderRadius: BorderRadius.circular(5),
        ),
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                '是否前往系统设置连接 WiFi?',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('取消',
                      style: TextStyle(color: Colors.white, fontSize: 13)),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    await WifiNativeChannel.instance.openWifiSettings();
                  },
                  child: const Text('确认',
                      style: TextStyle(
                          color: WifiBoxSupport.greenColor, fontSize: 13)),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
