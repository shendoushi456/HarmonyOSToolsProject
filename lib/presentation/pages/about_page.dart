import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 关于页 —— 对应 Android setting 模块 AboutToolSetActivity +
/// activity_about_tool.xml：#A7C6FA 标题栏（返回 + "关于我们"）+
/// 居中 logo（60dp，连点 10 次复制设备标识）+ 应用名 + 版本号胶囊。
class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  int _clickCount = 0;

  /// 原版为获取 ANDROID_ID；鸿蒙沙箱下无对应 Flutter API，
  /// 保真保留连点 10 次触发复制与 Toast 的行为框架。
  Future<void> _showDeviceId() async {
    _clickCount++;
    if (_clickCount >= 10) {
      _clickCount = 0;
      const androidId = '';
      await Clipboard.setData(const ClipboardData(text: androidId));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已复制到粘贴板：')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 标题栏：#A7C6FA 55dp + iv_back + 居中白字 18sp
          Container(
            height: 55,
            color: const Color(0xFFA7C6FA),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 15,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Image.asset(
                      'assets/images/recipes_tools/iv_back.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
                const Text('关于我们',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ],
            ),
          ),
          // logo（60dp，marginTop 50，连点 10 次复制设备标识）
          GestureDetector(
            onTap: _showDeviceId,
            child: Container(
              margin: const EdgeInsets.only(top: 50),
              width: 60,
              height: 60,
              child: Image.asset('assets/images/recipes_tools/ic_logo.png'),
            ),
          ),
          // 应用名（原版 @string/app_name，资源合并后为宿主应用名）
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text('乐熊菜谱',
                style: TextStyle(color: Color(0xFF121212), fontSize: 18)),
          ),
          // 版本号胶囊（shape_hui_circel：白底 #CBCBCB 描边，80x20dp）
          Container(
            margin: const EdgeInsets.only(top: 20),
            width: 80,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFCBCBCB), width: 1),
            ),
            alignment: Alignment.center,
            child: const Text('V1.0.0',
                style: TextStyle(color: Color(0xFF121212), fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
