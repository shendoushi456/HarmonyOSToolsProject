import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/search_car_info_provider.dart';

/// 关于页
///
/// 对应 Android: AboutToolSetActivity
/// 蓝色顶栏 + "关于我们" + 返回 + Logo + 应用名 + 版本号。
/// 点击 Logo 10 次复制设备 ID（彩蛋，鸿蒙用 OAID/UDID 替代 ANDROID_ID）。
class AboutPage extends ConsumerStatefulWidget {
  const AboutPage({super.key});

  @override
  ConsumerState<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends ConsumerState<AboutPage> {
  String _version = 'V1.0.1';
  int _logoTapCount = 0;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final service = ref.read(externalAppServiceProvider);
      final version = await service.getAppVersion();
      if (mounted) {
        setState(() => _version = 'V$version');
      }
    } catch (_) {
      // 失败回退 "V1.0.1"
    }
  }

  void _onLogoTap() {
    _logoTapCount++;
    if (_logoTapCount >= 10) {
      _logoTapCount = 0;
      // 彩蛋：复制设备 ID 到剪贴板
      // 原 Android 用 Settings.Secure.ANDROID_ID，鸿蒙用 OAID/UDID 替代
      Clipboard.setData(const ClipboardData(text: '设备ID获取需鸿蒙平台通道实现'));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已复制到粘贴板：设备ID获取需鸿蒙平台通道实现')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _SettingAppBar(title: '关于我们', onBack: () => Navigator.pop(context)),
          Expanded(
            child: Column(
              children: [
                // Logo（60x60 marginTop 50，可点击触发彩蛋）
                GestureDetector(
                  onTap: _onLogoTap,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: Image.asset('assets/images/setting/ic_logo.png'),
                    ),
                  ),
                ),
                // 应用名（18sp 0xFF121212 marginTop 20）
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: const Text(
                    '悠游出行',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF121212),
                    ),
                  ),
                ),
                // 版本号（14sp 0xFF121212 marginTop 20，圆角背景）
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEEEE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _version,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF121212),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 设置子页面通用蓝色顶栏（与 policy_page 共用结构）
class _SettingAppBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _SettingAppBar({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 50,
        color: const Color(0xFF6FBFFF),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: onBack,
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Image.asset(
                        'assets/images/setting/icon_white_back.webp'),
                  ),
                ),
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
