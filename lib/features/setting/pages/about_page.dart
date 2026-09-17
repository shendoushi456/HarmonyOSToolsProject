// 关于页 - 对齐 Android third-module/setting AboutToolSetActivity + activity_about_us_tool.xml
// 白底居中列;顶栏 50dp #6FBFFF + 白返回键(icon_white_back) + 白 20sp「关于我们」;
// logo(ic_logo) 60dp + 应用名 18sp #FF121212 + 版本胶囊(V 版本号,描边 #CBCBCB)
// 连点 logo 10 次复制版本号(原版复制 AndroidId,鸿蒙无等价 API 已注释说明)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_assets.dart';
import '../utils/app_info_util.dart';
import 'policy_page.dart' show kSettingBoxTheme;

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  int _clickCount = 0;

  Future<void> _onLogoTap() async {
    _clickCount++;
    if (_clickCount >= 10) {
      _clickCount = 0;
      // 对齐原版连点 10 次复制标识(原版复制 AndroidId,
      // 鸿蒙无等价 API,保留复制版本号的既有简化)
      await Clipboard.setData(
        const ClipboardData(text: 'V${AppInfoUtil.version}'),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已复制到粘贴板：V${AppInfoUtil.version}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 顶栏 50dp #6FBFFF + 白返回键 + 白 20sp「关于我们」
          Container(
            width: double.infinity,
            color: kSettingBoxTheme,
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Text('关于我们',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500)),
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Image.asset(
                              AppAssets.settingBoxIconWhiteBack,
                              width: 20,
                              height: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 居中列: logo + 应用名 + 版本胶囊
          Expanded(
            child: Column(
              children: [
                // logo 60dp(连点 10 次复制)
                GestureDetector(
                  onTap: _onLogoTap,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Image.asset(AppAssets.appLogo,
                        width: 60, height: 60),
                  ),
                ),
                // 应用名 18sp #FF121212
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    AppInfoUtil.appName,
                    style: TextStyle(
                        color: Color(0xFF121212), fontSize: 18),
                  ),
                ),
                // 版本胶囊(V 版本号,白底 1dp #CBCBCB 描边,padding 10/5)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border:
                          Border.all(color: const Color(0xFFCBCBCB)),
                    ),
                    child: const Text(
                      'V${AppInfoUtil.version}',
                      style: TextStyle(
                          color: Color(0xFF121212), fontSize: 14),
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
